// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:fml/data/data.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/event/event.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/table/table_header_cell_model.dart';
import 'package:fml/widgets/table/table_row_cell_model.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/table/table_model.dart';
import 'package:fml/widgets/table/table_row_model.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:pluto_grid/pluto_grid.dart';

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
  /// You can manipulate the grid dynamically at runtime by passing this through the [onLoaded] callback.
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

  // holds a pointer to the last selected row
  PlutoRow? lastSelectedRow;

  // holds a pointer to the last selected cell
  PlutoCell? lastSelectedCell;

  @override
  void initState()
  {
    super.initState();

    // build the columns
    _buildColumns();
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

  Future<bool> onComplete(Event event) async
  {
    bool ok = true;

    // Specific Complete?
    if ((event.parameters != null) &&
        (!S.isNullOrEmpty(event.parameters!['id'])) &&
        (event.parameters!['id'] != widget.model.id)) return ok;

    // Mark Event as Handled
    event.handled = true;

    // Force Close
    await closeKeyboard();

    // Confirm
    //int response = await DialogService().show(type: DialogType.info, title: phrase.confirmTableComplete, buttons: [Text(phrase.yes, style: TextStyle(fontSize: 18, color: Colors.white)),Text(phrase.no, style: TextStyle(fontSize: 18, color: Colors.white))]);

    ok = true;

    // Row Level Event?
    TableRowModel? row;
    if (event.model != null)
    {
      row = event.model!.findAncestorOfExactType(TableRowModel);
    }

    // Complete the Table
    if (ok)
    {
      if (row != null)
      {
        ok = await row.complete();
      }
      else
      {
        ok = await widget.model.complete();
      }
    }

    // Fire OnComplete
    if (ok)
    {
      if (row != null)
      {
        ok = await row.onComplete();
      }
      else
      {
        //ok = await widget.model.onComplete(context);
      }
    }

    return ok;
  }

  /// Callback function for when the model changes, used to force a rebuild with setState()
  @override
  onModelChange(WidgetModel model, {String? property, dynamic value})
  {
    var b = Binding.fromString(property);
    if (b?.property == 'busy') return;
    if (mounted) setState(() {});
  }

  PlutoColumnType getColumnType(TableHeaderCellModel model)
  {
    var type = model.type?.toLowerCase().trim();
    switch (type)
    {
      case "text":
      case "string":
        return PlutoColumnType.text();
      case "number":
      case "numeric":
        return PlutoColumnType.number();
      case "money":
      case "currency":
        return PlutoColumnType.currency();
      case "date":
        return PlutoColumnType.date();
      case "time":
        return PlutoColumnType.time();
      default:
        return PlutoColumnType.text();
    }
  }

  void _buildColumns()
  {
    columns.clear();
    map.clear();
    for (var model in widget.model.header!.cells)
    {
      var height = widget.model.header?.height ?? PlutoGridSettings.rowHeight;
      var title  = WidgetSpan(child: SizedBox(height: height, child:BoxView(model)));
      var name   = model.name  ?? model.field ?? "Column ${model.index}";
      var field  = model.field ?? model.name  ?? name;

      // cell builder - for performance reasons, tables without defined
      // table rows can be rendered much quicker
      var builder = widget.model.hasPrototype ? (rendererContext) => cellBuilder(rendererContext) : null;

      // build the column
      var column = PlutoColumn(
          title: name,
          sort: PlutoColumnSort.none,
          titleSpan: title,
          field: field,
          type: getColumnType(model),
          enableSorting: model.sortable,
          enableFilterMenuItem: model.filter,
          enableEditingMode: false,
          titlePadding: EdgeInsets.all(0),
          cellPadding: EdgeInsets.all(0),
          renderer: builder);

      // add to the column list
      map[column] = model;

      // add to columns
      columns.add(column);
    }
  }

  PlutoGridConfiguration _buildConfig()
  {
    var colHeight = widget.model.header?.height ?? PlutoGridSettings.rowHeight;
    var rowHeight = widget.model.getRowModel(0)?.height ?? widget.model.getEmptyRowModel()?.height ?? colHeight;
    var borderRadius = BorderRadius.circular(widget.model.radiusTopRight);

    // style
    var style = PlutoGridStyleConfig(

        defaultCellPadding: EdgeInsets.all(0),

        columnHeight: colHeight,

        rowHeight: rowHeight,

        gridBorderRadius: borderRadius
    );

    // config
    return PlutoGridConfiguration(style: style);
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
    dynamic data = widget.model.getDataRow(rowIdx);

    // create the row
    if (data != null)
    {
      Map<String, PlutoCell> cells = {};

      // get row model
      int colIdx = 0;
      for (var column in columns)
      {
        dynamic value;

        // defined body
        if (widget.model.hasPrototype)
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

    // If you have a filtering state,
    // you need to implement it so that the user gets data from the server
    // according to the filtering state.
    //
    // request.page is 1 when the filtering state changes.
    // This is because, when the filtering state is changed,
    // the first page must be loaded with the new filtering applied.
    //
    // request.filterRows is a List<PlutoRow> type containing filtering information.
    // To convert to Map type, you can do as follows.
    //
    // FilterHelper.convertRowsToMap(request.filterRows);
    //
    // When the filter of abc is applied as Contains type to column2
    // and 123 as Contains type to column3, for example
    // It is returned as below.
    // {column2: [{Contains: 123}], column3: [{Contains: abc}]}
    //
    // If multiple filtering conditions are set in one column,
    // multiple conditions are included as shown below.
    // {column2: [{Contains: abc}, {Contains: 123}]}
    //
    // The filter type in FilterHelper.defaultFilters is the default,
    // If there is user-defined filtering,
    // the title set by the user is returned as the filtering type.
    // All filtering can change the value returned as a filtering type by changing the name property.
    // In case of PlutoFilterTypeContains filter, if you change the static type name to include
    // PlutoFilterTypeContains.name = 'include';
    // {column2: [{include: abc}, {include: 123}]} will be returned.
    if (filter)
    {
      final filter = FilterHelper.convertRowsToFilter(request.filterRows, stateManager!.refColumns);
      tempList = tempList.where(filter!).toList();
    }

    // If there is a sort state,
    // you need to implement it so that the user gets data from the server
    // according to the sort state.
    //
    // request.page is 1 when the sort state changes.
    // This is because when the sort state changes,
    // new data to which the sort state is applied must be loaded.
    if (sort)
    {
      tempList = [...tempList];
      tempList.sort((a, b)
      {
        final sortA = request.sortColumn!.sort.isAscending ? a : b;
        final sortB = request.sortColumn!.sort.isAscending ? b : a;
        return request.sortColumn!.type.compare(sortA.cells[request.sortColumn!.field]!.valueForSorting, sortB.cells[request.sortColumn!.field]!.valueForSorting);
      });
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
    if (list.contains(lastSelectedRow))
    {
      stateManager?.setCurrentCell(lastSelectedCell, list.indexOf(lastSelectedRow!));
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

    // If you have a filtering state,
    // you need to implement it so that the user gets data from the server
    // according to the filtering state.
    //
    // request.page is 1 when the filtering state changes.
    // This is because, when the filtering state is changed,
    // the first page must be loaded with the new filtering applied.
    //
    // request.filterRows is a List<PlutoRow> type containing filtering information.
    // To convert to Map type, you can do as follows.
    //
    // FilterHelper.convertRowsToMap(request.filterRows);
    //
    // When the filter of abc is applied as Contains type to column2
    // and 123 as Contains type to column3, for example
    // It is returned as below.
    // {column2: [{Contains: 123}], column3: [{Contains: abc}]}
    //
    // If multiple filtering conditions are set in one column,
    // multiple conditions are included as shown below.
    // {column2: [{Contains: abc}, {Contains: 123}]}
    //
    // The filter type in FilterHelper.defaultFilters is the default,
    // If there is user-defined filtering,
    // the title set by the user is returned as the filtering type.
    // All filtering can change the value returned as a filtering type by changing the name property.
    // In case of PlutoFilterTypeContains filter, if you change the static type name to include
    // PlutoFilterTypeContains.name = 'include';
    // {column2: [{include: abc}, {include: 123}]} will be returned.
    if (filter)
    {
      final filter = FilterHelper.convertRowsToFilter(request.filterRows, stateManager!.refColumns);
      tempList = tempList.where(filter!).toList();

      pages = (tempList.length / pageSize).ceil();
      if (pages < 0) pages = 1;
    }

    // If there is a sort state,
    // you need to implement it so that the user gets data from the server
    // according to the sort state.
    //
    // request.page is 1 when the sort state changes.
    // This is because when the sort state changes,
    // new data to which the sort state is applied must be loaded.
    if (sort)
    {
      tempList = [...tempList];
      tempList.sort((a, b)
      {
        final sortA = request.sortColumn!.sort.isAscending ? a : b;
        final sortB = request.sortColumn!.sort.isAscending ? b : a;
        return request.sortColumn!.type.compare(sortA.cells[request.sortColumn!.field]!.valueForSorting, sortB.cells[request.sortColumn!.field]!.valueForSorting);
      });
    }

    final page  = request.page;
    final start = (page - 1) * pageSize;
    final end   = start + pageSize;

    // get list of rows
    var fetchedRows = tempList.getRange(max(0, start), min(tempList.length, end)).toList();

    // set selected
    if (fetchedRows.contains(lastSelectedRow))
    {
      stateManager?.setCurrentCell(lastSelectedCell, fetchedRows.indexOf(lastSelectedRow!));
    }

    return Future.value(PlutoLazyPaginationResponse(totalPage: pages, rows: fetchedRows));
  }

  void onLoaded(PlutoGridOnLoadedEvent event)
  {
    stateManager = event.stateManager;

    // handles changes in selection state
    //stateManager!.addListener(onSelected);

    // show filter bar
    if (widget.model.filterBar)
    {
      stateManager?.setShowColumnFilter(true);
    }
  }

  void onSelected(PlutoGridOnSelectedEvent event)
  {
    // get row and column
    var row  = event.row;
    var cell = event.cell;

    // update the model
    if (row != null && cell?.column != null)
    {
      var rowIdx = rows.indexOf(row);
      var colIdx = map.containsKey(cell?.column) ? map[cell?.column]!.index : -1;
      if (!rowIdx.isNegative && !colIdx.isNegative)
      {
        var model = widget.model.getRowCellModel(rowIdx, colIdx);
        if (model != null)
        {
          // toggle selected
          model.onSelect();

          // user clicked same cell?
          bool sameCell = (lastSelectedRow == row && lastSelectedCell == cell);
          bool deselect = sameCell && !model.selected;

          if (deselect)
          {
            stateManager?.clearCurrentCell(notify: true);
          }

          // set last row and cell
          lastSelectedRow  = deselect ? null : row;
          lastSelectedCell = deselect ? null : cell;
        }
      }
    }
  }

  void onSorted(PlutoGridOnSortedEvent event) async
  {
    views.clear();
  }

  // forces the lazy/page loaders to refire
  void refresh()
  {
    stateManager?.eventManager?.addEvent(PlutoGridSetColumnFilterEvent(filterRows: []));
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

  @override
  Widget build(BuildContext context)
  {
    // build style
    var config = _buildConfig();

    // build the content loader
    var loader = widget.model.pageSize > 0 ?  _pageLoader : _lazyLoader;

    // build the grid
    grid ??= PlutoGrid(key: GlobalKey(),
        configuration: config,
        columns: columns,
        rows: [],
        mode: PlutoGridMode.selectWithOneTap,
        onSelected: onSelected,
        onLoaded: onLoaded,
        onSorted: onSorted,
        createFooter: loader);

    return grid!;
  }
}
