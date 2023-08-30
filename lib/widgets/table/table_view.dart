// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:fml/data/data.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/event/event.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_view.dart';
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
  State<TableView> createState() => _TableViewState();
}

class _TableViewState extends WidgetState<TableView> implements IEventScrolling
{
  Widget? busy;

  final List<PlutoColumn> columns = [];
  final List<PlutoRow> rows = [];

  final HashMap<int, HashMap<int,Widget>> views = HashMap<int, HashMap<int,Widget>>();

  @override
  didChangeDependencies()
  {
    // register event listeners
    EventManager.of(widget.model)?.registerEventListener(EventTypes.scroll, onScroll);
    EventManager.of(widget.model)?.registerEventListener(EventTypes.complete, onComplete);
    EventManager.of(widget.model)?.registerEventListener(EventTypes.scrollto, onScrollTo, priority: 0);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(TableView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.model != widget.model))
    {
      // remove old event listeners
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.scroll, onScroll);
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.complete, onComplete);
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.scrollto, onScrollTo);

      // register new event listeners
      EventManager.of(widget.model)?.registerEventListener(EventTypes.scroll, onScroll);
      EventManager.of(widget.model)?.registerEventListener(EventTypes.complete, onComplete);
      EventManager.of(widget.model)?.registerEventListener(EventTypes.scrollto, onScrollTo, priority: 0);
    }
  }

  @override
  void dispose()
  {
    // remove event listeners
    EventManager.of(widget.model)?.removeEventListener(EventTypes.scroll, onScroll);
    EventManager.of(widget.model)?.removeEventListener(EventTypes.complete, onComplete);
    EventManager.of(widget.model)?.removeEventListener(EventTypes.scrollto, onScrollTo);

    super.dispose();
  }

  closeKeyboard() async
  {
    try
    {
      FocusScope.of(context).unfocus();
    }
    catch (e)
    {
      Log().exception(e);
    }
  }

  /// Takes an event (onscroll) and uses the id to scroll to that widget
  onScrollTo(Event event)
  {
    // BuildContext context;
    event.handled = true;
    if (event.parameters!.containsKey('id'))
    {
      String? id = event.parameters!['id'];
      var child = widget.model.findDescendantOfExactType(null, id: id);

      // if there is an error with this, we need to check _controller.hasClients as it must not be false when using [ScrollPosition],such as [position], [offset], [animateTo], and [jumpTo],
      if ((child != null) && (child.context != null))
      {
        Scrollable.ensureVisible(child.context,
            duration: Duration(seconds: 1), alignment: 0.2);
      }
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

  @override
  void onScroll(Event event) async
  {
    // if (hScroller != null && vScroller != null)
    // {
    //   scroll(event, hScroller, vScroller);
    // }
    event.handled = true;
  }

  scroll(Event event, ScrollController? hScroller, ScrollController? vScroller) async
  {
    try
    {
      if (event.parameters!.containsKey("direction") &&
          event.parameters!.containsKey("pixels")) {
        String? direction = event.parameters!["direction"];
        double distance = double.parse(event.parameters!["pixels"]!);
        if (direction != null) {
          if (direction == 'left' || direction == 'right') {
            double offset = hScroller!.offset;
            double moveToPosition =
                offset + (direction == 'left' ? -distance : distance);
            hScroller.animateTo(moveToPosition,
                duration: Duration(milliseconds: 300), curve: Curves.easeOut);
          } else if (direction == 'up' || direction == 'down') {
            double offset = vScroller!.offset;
            double moveToPosition =
                offset + (direction == 'up' ? -distance : distance);
            vScroller.animateTo(moveToPosition,
                duration: Duration(milliseconds: 300), curve: Curves.easeOut);
          }
        }
      }
    }
    catch (e)
    {
      Log().error('onScroll Error: ');
      Log().exception(e, caller: 'View');
    }
  }

  /// Callback function for when the model changes, used to force a rebuild with setState()
  @override
  onModelChange(WidgetModel model, {String? property, dynamic value})
  {
    var b = Binding.fromString(property);
    if (b?.property == 'busy') return;
    if (mounted) setState(() {});
  }

  /// [PlutoGridStateManager] has many methods and properties to dynamically manipulate the grid.
  /// You can manipulate the grid dynamically at runtime by passing this through the [onLoaded] callback.
  late final PlutoGridStateManager stateManager;

  void _buildColumns()
  {
    columns.clear();
    for (var model in widget.model.header!.cells)
    {
      var height = widget.model.header?.height ?? PlutoGridSettings.rowHeight;
      var title = WidgetSpan(child: SizedBox(height: height, child:BoxView(model)));

      var column = PlutoColumn(
          title: model.id,
          sort: PlutoColumnSort.none,
          titleSpan: title,
          field: model.id,
          type: PlutoColumnType.text(),
          enableSorting: model.sortable,
          enableEditingMode: false,
          titlePadding: EdgeInsets.all(0),
          cellPadding: EdgeInsets.all(0),
          renderer: (rendererContext) => cellBuilder(rendererContext));

      columns.add(column);
    }
  }

  PlutoGridConfiguration _buildConfig()
  {
    var radius = BorderRadius.circular(widget.model.radiusTopRight);

    // style
    var style = PlutoGridStyleConfig(

        defaultCellPadding: EdgeInsets.all(0),

        columnHeight: widget.model.header?.height ?? PlutoGridSettings.rowHeight,

        rowHeight: widget.model.getRowModel(0)?.height ?? widget.model.getEmptyRowModel()?.height ?? PlutoGridSettings.rowHeight,

        gridBorderRadius: radius
    );

    // config
    var configuration = PlutoGridConfiguration(
        style: style
    );

    return configuration;
  }

  void buildAllRows() => buildOutRows(double.infinity.toInt());
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

    // create the row
    PlutoRow? row;
    if (widget.model.data is Data && rowIdx < (widget.model.data as Data).length)
    {
      Map<String, PlutoCell> cells = {};

      // get row model
      int colIdx = 0;
      for (var column in columns)
      {
        var model = widget.model.getRowCellModel(rowIdx, colIdx);
        cells[column.field] = PlutoCell(value: model?.value);
        colIdx++;
      }
      row = PlutoRow(cells: cells, sortIdx: rowIdx);
      rows.add(row);
    }

    return row;
  }

  Widget cellBuilder(PlutoColumnRendererContext context)
  {
    if (!columns.contains(context.column)) return Text("");
    if (!rows.contains(context.row)) return Text("");

    var colIdx = columns.indexOf(context.column);
    var rowIdx = rows.indexOf(context.row);

    print("row-> $rowIdx");

    // return the view
    if (views[rowIdx]?.containsKey(colIdx) ?? false) return views[rowIdx]![colIdx]!;

    Widget? view;

    // get row model
    TableRowModel? model = widget.model.getRowModel(rowIdx);

    // get cell view
    if (model != null && colIdx >= 0 && colIdx < model.cells.length)
    {
      // build the view
      view = RepaintBoundary(child: BoxView(model.cells[colIdx]));

      // cache the view
      if (!views.containsKey(rowIdx)) views[rowIdx] = HashMap<int,Widget>();
      views[rowIdx]![colIdx] = view;
    }
    else
    {
      view = Text("");
    }

    return view;
  }

  Future<PlutoInfinityScrollRowsResponse> onLazyLoad(PlutoInfinityScrollRowsRequest request) async
  {
    // rows are filtered?
    var filter = request.filterRows.isNotEmpty;

    // rows are sorted?
    var sort   = request.sortColumn != null && !request.sortColumn!.sort.isNone;

    // total number of rows
    var rows = widget.model.data is Data ? (widget.model.data as Data).length : 0;

    // number of records to fetch
    var fetchSize = 50;

    // index of last row fetched
    var rowIdx = 0;
    if (request.lastRow != null)
    {
      var row = request.lastRow!;
      rowIdx = this.rows.contains(row) ? this.rows.indexOf(row) : 0;
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
      final filter = FilterHelper.convertRowsToFilter(request.filterRows, stateManager.refColumns);
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
    final bool isLast = fetchedRows.isEmpty || rows < this.rows.length;

    // notify the user
    if (isLast && mounted)
    {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Last Page!')));
    }

    var list = fetchedRows.toList();

    return Future.value(PlutoInfinityScrollRowsResponse(isLast: isLast, rows: list));
  }

  Future<PlutoLazyPaginationResponse> onPageLoad(PlutoLazyPaginationRequest request) async
  {
    // rows are filtered?
    var filter = request.filterRows.isNotEmpty;

    // rows are sorted?
    var sort   = request.sortColumn != null && !request.sortColumn!.sort.isNone;

    // total number of rows
    var rows = widget.model.data is Data ? (widget.model.data as Data).length : 0;

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
      final filter = FilterHelper.convertRowsToFilter(request.filterRows, stateManager.refColumns);
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

    Iterable<PlutoRow> fetchedRows = tempList.getRange(max(0, start), min(tempList.length, end));

    //await Future.delayed(const Duration(milliseconds: 500));

    return Future.value(PlutoLazyPaginationResponse(totalPage: pages, rows: fetchedRows.toList()));
  }

  void onLoaded(PlutoGridOnLoadedEvent event)
  {
    stateManager = event.stateManager;
    stateManager.setShowColumnFilter(true);
  }

  void onChanged(PlutoGridOnChangedEvent event)
  {
    print(event);
  }

  void onSelected (PlutoGridOnSelectedEvent event)
  {
    print("row selected => ${event.rowIdx}");
  }

  void onSorted (PlutoGridOnSortedEvent event) async
  {
    var index = columns.contains(event.column) ? columns.indexOf(event.column) : null;
    if (index == null) return;
    views.clear();
    //await widget.model.onSortData(index);
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
    // build the columns
    _buildColumns();

    // build style
    var config = _buildConfig();

    // build the content loader
    var loader = _lazyLoader;//widget.model.pageSize > 0 ?  _pageLoader : _lazyLoader;

    // build the grid
    var view = PlutoGrid(key: GlobalKey(),
        configuration: config,
        columns: columns,
        rows: [],
        onLoaded: onLoaded,
        onChanged: onChanged,
        onSelected: onSelected,
        onSorted: onSorted,
        createFooter: loader);

    return view;
  }
}
