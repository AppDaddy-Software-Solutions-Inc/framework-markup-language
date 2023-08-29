// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/transforms/sort.dart';
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

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class TableView extends StatefulWidget implements IWidgetView {
  @override
  final TableModel model;
  TableView(this.model) : super(key: ObjectKey(model));

  @override
  State<TableView> createState() => _TableViewState();
}

class _TableViewState extends WidgetState<TableView> implements IEventScrolling
{
  Widget? busy;

  ScrollController? hScroller;
  ScrollController? vScroller;

  final List<PlutoColumn> columns = [];
  final List<PlutoRow> rows = [];

  @override
  void initState()
  {
    super.initState();

    hScroller = ScrollController();
    vScroller = ScrollController();
  }

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
  void dispose() {
    // remove event listeners
    EventManager.of(widget.model)
        ?.removeEventListener(EventTypes.scroll, onScroll);
    EventManager.of(widget.model)
        ?.removeEventListener(EventTypes.complete, onComplete);
    EventManager.of(widget.model)
        ?.removeEventListener(EventTypes.scrollto, onScrollTo);

    hScroller?.dispose();
    vScroller?.dispose();

    super.dispose();
  }

  closeKeyboard() async {
    try {
      FocusScope.of(context).unfocus();
    } catch (e) {
      Log().exception(e);
    }
  }

  /// Takes an event (onscroll) and uses the id to scroll to that widget
  onScrollTo(Event event) {
    // BuildContext context;
    event.handled = true;
    if (event.parameters!.containsKey('id')) {
      String? id = event.parameters!['id'];
      var child = widget.model.findDescendantOfExactType(null, id: id);

      // if there is an error with this, we need to check _controller.hasClients as it must not be false when using [ScrollPosition],such as [position], [offset], [animateTo], and [jumpTo],
      if ((child != null) && (child.context != null)) {
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
    if (hScroller != null && vScroller != null)
    {
      scroll(event, hScroller, vScroller);
    }
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
    try
    {
      var b = Binding.fromString(property);
      if (b?.property == 'busy') return;
      if (mounted) setState(() {});
    }
    catch (e)
    {
      Log().exception(e, caller: ' onModelChange(WidgetModel model,{String? property, dynamic value})');
    }
  }

  /// [PlutoGridStateManager] has many methods and properties to dynamically manipulate the grid.
  /// You can manipulate the grid dynamically at runtime by passing this through the [onLoaded] callback.
  late final PlutoGridStateManager stateManager;

  @override
  Widget build(BuildContext context)
  {
    // build the columns
    columns.clear();
    for (var model in widget.model.header!.cells)
    {
      var column = PlutoColumn(
        title: model.id,
        sort: model.sortType == SortTypes.ascending ? PlutoColumnSort.ascending : (model.sortType == SortTypes.descending ? PlutoColumnSort.descending : PlutoColumnSort.none),
        titleSpan: WidgetSpan(child: BoxView(model)),
        field: model.field ?? model.id,
        type: PlutoColumnType.text(),
        enableSorting: model.sortBy != null,
        enableEditingMode: false,
        renderer: (rendererContext) => cellBuilder(rendererContext));

      columns.add(column);
    }

    // build the data
    rows.clear();
    if (widget.model.data is Data)
    {
      var list = (widget.model.data as Data);
      for (int i = 0; i < list.length; i++)
      {
        var data = list[i];
        Map<String, PlutoCell> cells = {};
        for (var column in columns)
        {
          var value = Data.readValue(data, column.field);
          cells[column.field] = PlutoCell(value: value);
        }
        rows.add(PlutoRow(cells: cells));
      }
    }

    // build the grid
    var view = PlutoGrid(key: GlobalKey(),
      columns: columns,
      rows: rows,
      onLoaded: (PlutoGridOnLoadedEvent event)
      {
        stateManager = event.stateManager;
        stateManager.setShowColumnFilter(true);
      },
      onChanged: (PlutoGridOnChangedEvent event)
      {
        print(event);
      },
      onSelected: (PlutoGridOnSelectedEvent event)
      {
        print("row selected => ${event.rowIdx}");
      },
      onSorted: (PlutoGridOnSortedEvent event) async
      {
        var index = columns.contains(event.column) ? columns.indexOf(event.column) : null;
        if (index == null) return;
        await widget.model.onSortData(index);
      }
    );
    return view;
  }

  Widget cellBuilder(PlutoColumnRendererContext context)
  {
    var colIdx = columns.contains(context.column) ? columns.indexOf(context.column) : null;

    Widget? view;

    // get row model
    TableRowModel? model = widget.model.getRowModel(context.rowIdx);

    // get cell view
    if (model != null && colIdx != null && colIdx < model.cells.length)
    {
      view = BoxView(model.cells[colIdx]);
    }

    return view ?? Text("");
  }
}
