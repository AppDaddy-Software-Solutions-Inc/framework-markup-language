// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:fml/data/data.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/alignment/alignment.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/table/table_header_cell_model.dart';
import 'package:fml/widgets/table/table_row_cell_model.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/table/table_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid_export/pluto_grid_export.dart' as pluto_grid_export;
import 'package:csv/csv.dart';

enum Toggle {on, off}

class TableView extends StatefulWidget implements IWidgetView
{
  @override
  final TableModel model;
  TableView(this.model) : super(key: ObjectKey(model));

  @override
  State<TableView> createState() => TableViewState();
}

class TableViewState extends WidgetState<TableView>
{
  Widget? busy;

  /// [PlutoGridStateManager] has many methods and properties to dynamically manipulate the grid.
  /// You can manipulate the grid dynamically at runtime by passing this through the [onLoadedHandler] callback.
  PlutoGridStateManager? stateManager;

  // pluto grid
  PlutoGrid? grid;

  // list of Pluto Columns
  final List<PlutoColumn> columns = [];

  // list of Pluto Rows
  final List<PlutoRow> rows = [];

  // maps PlutoColumn -> TableHeaderModel
  // this is necessary since PlutoColumns can be re-ordered
  final HashMap<PlutoColumn, TableHeaderCellModel> map = HashMap<PlutoColumn, TableHeaderCellModel>();

  final HashMap<TableRowCellModel, Widget> views = HashMap<TableRowCellModel, Widget>();

  // hold a pointer to the last selected cell;
  PlutoCell? lastCell;

  @override
  void dispose()
  {
    super.dispose();
    stateManager?.removeListener(onSelectedHandler);
  }

  closeKeyboard() async
  {
    try
    {
      FocusScope.of(context).unfocus();
    }
    catch(e)
    {
      Log().exception(e);
    }
  }

  /// Callback function for when the model changes, used to force a rebuild with setState()
  @override
  onModelChange(WidgetModel model, {String? property, dynamic value})
  {
    var b = Binding.fromString(property);
    if (b?.property == 'busy') return;

    super.onModelChange(model);
  }

  PlutoColumnType getColumnType(TableHeaderCellModel model)
  {
    var type = model.type?.toLowerCase().trim();
    switch (type)
    {
      case "number":
      case "numeric":
        return PlutoColumnType.number(format: "#", applyFormatOnInit: false);
      case "money":
      case "currency":
        return PlutoColumnType.currency();
      case "date":
        return PlutoColumnType.date();
      case "time":
        return PlutoColumnType.time();
      case "text":
      case "string":
      default:
        return PlutoColumnType.text();
    }
  }

  // build all rows
  void buildAllRows() => buildOutRows(widget.model.getDataRowCount());

  void buildOutRows(int length)
  {
    // build rows
    while (rows.length < length)
    {
      var row = buildRow(rows.length);
      if (row == null) break;
    }
  }

  PlutoRow? buildRow(int rowIdx)
  {
    // row already created
    if (rowIdx < rows.length) return rows[rowIdx];

    PlutoRow? row;

    // get the data row
    dynamic data = widget.model.getData(rowIdx);

    // create the row
    if (data != null)
    {
      Map<String, PlutoCell> cells = {};

      // get row model
      for (var column in columns)
      {
        dynamic value;

        // get column index
        var colIdx = map.containsKey(column) ? map[column]!.index : -1;

        // get column model
        var model = widget.model.header?.cell(colIdx);

        // simple grid
        if (model?.usesRenderer ?? false)
        {
          var model = widget.model.getRowCellModel(rowIdx, colIdx);
          value = model?.value;
        }
        else
        {
          value = Data.readValue(data, column.field) ?? "";
        }

        cells[column.field] = PlutoCell(value: value);
        colIdx++;
      }
      row = PlutoRow(cells: cells, sortIdx: rowIdx);
      rows.add(row);
    }

    return row;
  }

  Widget cellBuilder(PlutoColumnRendererContext context)
  {
    // get row and column indexes
    var rowIdx = rows.indexOf(context.row);
    var colIdx = map.containsKey(context.column) ? map[context.column]!.index : -1;

    // not found
    if (rowIdx.isNegative || colIdx.isNegative) return Text("");

    // get cell model
    TableRowCellModel? model = widget.model.getRowCellModel(rowIdx, colIdx);
    if (model == null) return Text("");

    // return the view
    if (views.containsKey(model)) return views[model]!;

    // build the view
    var view = RepaintBoundary(child: BoxView(model));

    // cache the view
    views[model] = view;

    return view;
  }

  List<PlutoRow> applyFilters(List<PlutoRow> list)
  {
    if (stateManager != null)
    {
      final filterRows = stateManager!.filterRows;
      final filterCols = stateManager!.refColumns;
      final filter = FilterHelper.convertRowsToFilter(filterRows,filterCols);
      if (filter != null) return list.where(filter).toList();
    }
    return list;
  }

  List<PlutoRow> applySort(List<PlutoRow> list)
  {
    if (stateManager != null)
    {
      PlutoColumn? column = stateManager?.getSortedColumn;
      if (column != null)
      {
        list = [...list];
        list.sort((a, b)
        {
          final sortA = column.sort.isAscending ? a : b;
          final sortB = column.sort.isAscending ? b : a;
          return column.type.compare(sortA.cells[column.field]!.valueForSorting, sortB.cells[column.field]!.valueForSorting);
        });
      }
    }
    return list;
  }

  Future<PlutoInfinityScrollRowsResponse> onLazyLoad(PlutoInfinityScrollRowsRequest request) async
  {
    // rows are filtered?
    var filter = request.filterRows.isNotEmpty;

    // rows are sorted?
    var sort = request.sortColumn != null && !request.sortColumn!.sort.isNone;

    // number of records to fetch
    var fetchSize = 50;

    // index of last row fetched
    var rowIdx = 0;
    if (request.lastRow != null)
    {
      var row = request.lastRow!;
      rowIdx = rows.contains(row) ? rows.indexOf(row) : 0;
    }

    // build rows
    if (filter || sort)
    {
      // build all
      buildAllRows();
    }
    else
    {
      buildOutRows(rowIdx + fetchSize);
    }

    // build the list
    List<PlutoRow> tempList = rows.toList();

    // filter the list
    if (filter)
    {
      tempList = applyFilters(tempList);
    }

    // sort the list
    if (sort)
    {
      tempList = applySort(tempList);
    }

    // Data needs to be implemented so that the next row
    // to be fetched by the user is fetched from the server according to the value of lastRow.
    //
    // If [request.lastRow] is null, it corresponds to the first page.
    // After that, implement request.lastRow to get the next row from the server.
    //
    // How many are fetched is not a concern in PlutoGrid.
    // The user just needs to bring as many as they can get at one time.
    //
    // To convert data from server to PlutoRow
    // You can convert it using [PlutoRow.fromJson].
    // In the example, PlutoRow is already created, so it is not created separately.
    Iterable<PlutoRow> fetchedRows = tempList.skipWhile((row) => request.lastRow != null && row.key != request.lastRow!.key);

    if (request.lastRow == null)
    {
      fetchedRows = fetchedRows.take(fetchSize);
    }
    else
    {
      fetchedRows = fetchedRows.skip(1).take(fetchSize);
    }

    // await Future.delayed(const Duration(milliseconds: 500));

    // The return value returns the PlutoInfinityScrollRowsResponse class.
    // isLast should be true when there is no more data to load.
    // rows should pass a List<PlutoRow>.
    // total number of rows
    final bool isLast = fetchedRows.isEmpty || widget.model.getDataRowCount() < rows.length;

    // notify the user
    if (isLast && mounted)
    {
      //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Last Page!')));
    }

    // convert to list
    var list = fetchedRows.toList();

    // set selected
    var lastRow = lastCell?.row;
    if (list.contains(lastRow))
    {
      stateManager?.setCurrentCell(lastCell, list.indexOf(lastRow!));
    }

    return Future.value(PlutoInfinityScrollRowsResponse(isLast: isLast, rows: list));
  }

  Future<PlutoLazyPaginationResponse> onPageLoad(PlutoLazyPaginationRequest request) async
  {
    // rows are filtered?
    var filter = request.filterRows.isNotEmpty;

    // rows are sorted?
    var sort = request.sortColumn != null && !request.sortColumn!.sort.isNone;

    // total number of rows
    var rows = widget.model.getDataRowCount();

    // page size
    var pageSize = widget.model.pageSize;
    if (pageSize <= 0) pageSize = 10;

    // total number of pages
    var pages = (rows / pageSize).ceil();

    // build rows
    if (filter || sort)
    {
      // build all
      buildAllRows();
    }
    else
    {
      // build only as many as required
      buildOutRows(pageSize * request.page);
    }

    // build the list
    List<PlutoRow> tempList = this.rows.toList();

    // filter the list
    if (filter)
    {
      tempList = applyFilters(tempList);

      pages = (tempList.length / pageSize).ceil();
      if (pages < 0) pages = 1;
    }

    // sort the list
    if (sort)
    {
      tempList = applySort(tempList);
    }

    final page  = request.page;
    final start = (page - 1) * pageSize;
    final end   = start + pageSize;

    // get list of rows
    var fetchedRows = tempList.getRange(max(0, start), min(tempList.length, end)).toList();

    // set selected
    var lastRow = lastCell?.row;
    if (fetchedRows.contains(lastRow))
    {
      stateManager?.setCurrentCell(lastCell, fetchedRows.indexOf(lastRow!));
    }

    return Future.value(PlutoLazyPaginationResponse(totalPage: pages, rows: fetchedRows));
  }

  // called when grid is loaded
  void onLoadedHandler(PlutoGridOnLoadedEvent event)
  {
    stateManager = event.stateManager;

    // add selection handler
    stateManager?.removeListener(onSelectedHandler);
    stateManager?.addListener(onSelectedHandler);

    stateManager?.activateColumnsAutoSize();

    // show filter bar
    if (widget.model.filterBar)
    {
      stateManager!.setShowColumnFilter(true);
    }
  }

  // called when a field changes via edit.
  // only applies to simple grid
  void onChangedHandler(final PlutoGridOnChangedEvent event) async
  {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp)
    {
      var rowIdx = rows.indexOf(event.row);
      var colIdx = map.containsKey(event.column) ? map[event.column]!.index : -1;
      widget.model.onChangeHandler(rowIdx, colIdx, event.value, event.oldValue);

      // we need this to force an update
      // of the selected data
      debounce?.cancel();
      onSelectedHandler();
    });
  }

  Timer? debounce;
  void onSelectedHandler()
  {
    if (stateManager == null) return;

    // we get multiple onSelect calls
    if (debounce?.isActive ?? false) return;
    debounce = Timer(Duration(milliseconds: 250),(){});

    // get row and column
    var row  = stateManager!.currentRow;
    var cell = stateManager!.currentCell;

    // edit mode
    if (stateManager!.isEditing) return;

    // field is editable
    bool editing = (cell != null && cell == lastCell && stateManager!.isEditableCell(cell));

    // set toggle state
    Toggle toggle = cell == lastCell ? Toggle.off : Toggle.on;
    if (editing) toggle = Toggle.on;

    // manage toggle state
    switch (toggle)
    {
      case Toggle.off :

        // clear state
        stateManager?.clearCurrentCell(notify: false);

        // clear model selection
        widget.model.onDeSelect();

        // clear selected
        lastCell = null;

        break;

      case Toggle.on :

        // get row index
        var rowIdx = row != null ? rows.indexOf(row) : -1;

        // get column index
        var colIdx = map.containsKey(cell?.column) ? map[cell?.column]!.index : -1;

        // set model selection
        widget.model.onSelect(rowIdx, colIdx);

        // remember last selected
        lastCell = cell;

        break;
    }
  }

  // called when a field sort operation happens
  void onSortedHandler(PlutoGridOnSortedEvent event) async
  {
    views.clear();
  }

  void rebuild()
  {
    grid = null;
    rows.clear();
    super.onModelChange(widget.model);
  }

  // forces the lazy/page loaders to refire
  void refresh()
  {
    // force a page reload
    stateManager?.eventManager?.addEvent(PlutoGridSetColumnFilterEvent(filterRows: []));
  }

  List<String> getColumnTitles(PlutoGridStateManager state) => getVisibleColumns(state).map((e) => e.title).toList();

  List<PlutoColumn> getVisibleColumns(PlutoGridStateManager state) => state.columns.where((element) => !element.hide).toList();

  List<String?> getSerializedRow(PlutoGridStateManager state, PlutoRow plutoRow)
  {
    List<String?> serializedRow = [];

    // Order is important, so we iterate over columns
    for (PlutoColumn column in getVisibleColumns(state))
    {
      dynamic value = plutoRow.cells[column.field]?.value;
      serializedRow.add(column.formattedValueForDisplay(value));
    }
    return serializedRow;
  }

  void autosize(String? mode)
  {
    // format mode
    mode = mode?.trim().toLowerCase();

    switch (mode)
    {
      case "scale":
        stateManager?.setColumnSizeConfig(PlutoGridColumnSizeConfig(autoSizeMode: PlutoAutoSizeMode.scale));
        break;

      case "equal":
        stateManager?.setColumnSizeConfig(PlutoGridColumnSizeConfig(autoSizeMode: PlutoAutoSizeMode.equal));
        break;

      case "fit":
      for (PlutoColumn column in columns)
      {
        stateManager?.autoFitColumn(context, column);
      }
      break;

      case "none":
      default:
      stateManager?.setColumnSizeConfig(PlutoGridColumnSizeConfig(autoSizeMode: PlutoAutoSizeMode.none));
      break;
    }
  }

  // sets the page size
  void setPageSize(int size)
  {
    if (size <= 0) return;
    stateManager?.setPageSize(size);
  }

  Future<String?> exportToCSV() async
  {
    if (stateManager == null) return null;

    // This ensures we have built out all rows
    buildAllRows();

    // filter the list
    var list = applyFilters(rows);

    // sort the list
    list = applySort(list);

    // serialize the list
    List<List<String?>> serialized = [];
    for (var row in list)
    {
      serialized.add(getSerializedRow(stateManager!, row));
    }

    String csv = const ListToCsvConverter().convert(
      [
        getColumnTitles(stateManager!),
        ...serialized,
      ],
      delimitAllFields: true);

    return csv;
  }

  Future<Uint8List?> exportToCSVBytes() async
  {
    var file = await exportToCSV();
    if (file == null) return null;
    return const Utf8Encoder().convert(file);
  }

  Future<Uint8List?> exportToPDF() async
  {
    if (stateManager == null) return null;

    // This ensures we have built out all rows
    buildAllRows();

    // filter the list
    var list = applyFilters(rows);

    // sort the list
    list = applySort(list);

    // serialize the list
    List<List<String?>> serialized = [];
    for (var row in list)
    {
      serialized.add(getSerializedRow(stateManager!, row));
    }

    // get the fonts
    //final fontRegular = await rootBundle.load('assets/fonts/open_sans/OpenSans-Regular.ttf');
    //final fontBold = await rootBundle.load('assets/fonts/open_sans/OpenSans-Bold.ttf');
    //final themeData = pluto_grid_export.ThemeData.withFont(base: pluto_grid_export.Font.ttf(fontRegular), bold: pluto_grid_export.Font.ttf(fontBold));

    // build the theme
    final themeData = pluto_grid_export.ThemeData.base();

    // these should be passed not hard coded
    var title   = "Table Export";
    var creator = "Futter Markup Language";
    var format  = pluto_grid_export.PdfPageFormat.a4.landscape;

    // generate the report
    var bytes = pluto_grid_export.GenericPdfController(
      title: title,
      creator: creator,
      format: format,
      columns: getColumnTitles(stateManager!),
      rows: serialized,
      themeData: themeData,
    ).generatePdf();

    return bytes;
  }

  PlutoLazyPagination _pageLoader(PlutoGridStateManager stateManager)
  {
    var loader = PlutoLazyPagination(

        stateManager: stateManager,

        // fetch routine called on
        // page change
        fetch: onPageLoad,

        // Determine the first page.
        // Default is 1.
        initialPage: 1,

        // First call the fetch function to determine whether to load the page.
        // Default is true.
        initialFetch: true,

        // Decide whether sorting will be handled by the server.
        // If false, handle sorting on the client side.
        // Default is true.
        fetchWithSorting: true,

        // Decide whether filtering is handled by the server.
        // If false, handle filtering on the client side.
        // Default is true.
        fetchWithFiltering: true,

        // Determines the page size to move to the previous and next page buttons.
        // Default value is null. In this case,
        // it moves as many as the number of page buttons visible on the screen.
        pageSizeToMove: null
    );

    return loader;
  }

  PlutoInfinityScrollRows _lazyLoader(PlutoGridStateManager stateManager)
  {
    var loader = PlutoInfinityScrollRows(

      stateManager: stateManager,

      // fetch routine called on
      // page change
      fetch: onLazyLoad,

      // First call the fetch function to determine whether to load the page.
      // Default is true.
      initialFetch: true,

      // Decide whether sorting will be handled by the server.
      // If false, handle sorting on the client side.
      // Default is true.
      fetchWithSorting: true,

      // Decide whether filtering is handled by the server.
      // If false, handle filtering on the client side.
      // Default is true.
      fetchWithFiltering: true,
    );

    return loader;
  }

  PlutoColumnTextAlign _getAlignment()
  {
    var align = WidgetAlignment(widget.model.layoutType, widget.model.center, widget.model.halign, widget.model.valign);
    if (align.aligned == Alignment.topCenter || align.aligned == Alignment.center || align.aligned == Alignment.bottomCenter) return PlutoColumnTextAlign.center;
    if (align.aligned == Alignment.topLeft   || align.aligned == Alignment.centerLeft || align.aligned == Alignment.bottomLeft) return PlutoColumnTextAlign.left;
    if (align.aligned == Alignment.topRight  || align.aligned == Alignment.centerRight || align.aligned == Alignment.bottomRight) return PlutoColumnTextAlign.right;
    return PlutoColumnTextAlign.center;
  }

  PlutoGridConfiguration _buildConfig()
  {
    var colHeight    = widget.model.header?.height ?? PlutoGridSettings.rowHeight;
    var rowHeight    = widget.model.getRowModel(0)?.height ?? colHeight;

    var borderRadius = BorderRadius.circular(widget.model.radiusTopRight);
    var borderColor  = widget.model.bordercolor ?? Color(0xFFDDE2EB);

    var textStyle    = TextStyle(fontSize: widget.model.textSize, color: widget.model.textColor);

    // row colors
    var rowColor     = widget.model.color ?? Colors.white;
    var oddRowColor  = widget.model.color != null && widget.model.color2 != null ? widget.model.color : null;
    var evenRowColor = widget.model.color != null && widget.model.color2 != null ? widget.model.color : null;

    // style
    var style = PlutoGridStyleConfig(

      defaultCellPadding: EdgeInsets.all(0),

      columnHeight: colHeight,

      rowHeight: rowHeight,

      cellTextStyle: textStyle,

      borderColor: borderColor,

      gridBorderRadius: borderRadius,

      columnAscendingIcon: Icon(Icons.arrow_downward_rounded),

      columnDescendingIcon: Icon(Icons.arrow_upward_rounded),

      rowColor: rowColor,

      oddRowColor: oddRowColor,

      evenRowColor: evenRowColor,

      enableGridBorderShadow: widget.model.shadow,
    );

    // config
    return PlutoGridConfiguration(style: style);
  }

  void _buildColumns()
  {
    columns.clear();
    map.clear();

    if (widget.model.header == null) return;

    List<String> fields = [];
    for (var cell in widget.model.header!.cells)
    {
      var height = widget.model.header?.height ?? PlutoGridSettings.rowHeight;
      var header = WidgetSpan(child: SizedBox(height: height, child:BoxView(cell)));
      var title  = cell.title ?? cell.field ?? "Column ${cell.index}";

      // field names must be unique across columns
      var field  = cell.field ?? cell.title ?? title;
      int i = 1;
      while (fields.contains(field))
      {
        field = "$field-${i++}";
      }
      fields.add(field);

      // cell builder - for performance reasons, tables without defined
      // table rows can be rendered much quicker
      var builder = cell.usesRenderer ? (rendererContext) => cellBuilder(rendererContext) : null;

      // cell is editable
      var editable = !cell.usesRenderer && cell.editable;

      // cell is resizeable
      var resizeable = cell.resizeable;

      // show context menu?
      var showMenu = cell.menu;

      // get cell alignment
      var alignment = _getAlignment();

      // build the column
      var column = PlutoColumn(
          title: title,
          sort: PlutoColumnSort.none,
          titleSpan: header,
          field: field,
          type: getColumnType(cell),
          textAlign: alignment,
          enableSorting: cell.sortable,
          enableFilterMenuItem: cell.filter,
          enableEditingMode: editable,
          enableAutoEditing: false,
          enableContextMenu: showMenu,
          enableDropToResize: resizeable,
          readOnly: !editable,
          titlePadding: EdgeInsets.all(0),
          cellPadding: EdgeInsets.all(0),
          width: cell.widthOuter ?? PlutoGridSettings.columnWidth,
          minWidth: PlutoGridSettings.minColumnWidth,
          renderer: builder);

      // add to the column list
      map[column] = cell;

      // add to columns
      columns.add(column);
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // set system sizing
    onLayout(constraints);

    // build style
    if (grid == null)
    {
      // build the columns
      _buildColumns();

      var config = _buildConfig();

      // build the grid
      grid = PlutoGrid(key: GlobalKey(),
          configuration: config,
          columns: columns,
          rows: [],
          mode: PlutoGridMode.normal,
          onLoaded: onLoadedHandler,
          onSorted: onSortedHandler,
          onChanged: onChangedHandler,
          createFooter: widget.model.pageSize > 0 ?  _pageLoader : _lazyLoader);
    }

    // apply constraints
    var view = applyConstraints(grid!, widget.model.constraints);

    // add margins around the entire widget
    view = addMargins(view);

    return view;
  }
}
