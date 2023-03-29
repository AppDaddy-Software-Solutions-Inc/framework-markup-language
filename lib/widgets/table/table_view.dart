// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:ui';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:fml/event/manager.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/phrase.dart';
import 'package:fml/event/event.dart'        ;
import 'package:flutter/material.dart';
import 'package:fml/widgets/busy/busy_view.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/table/table_model.dart';
import 'package:fml/widgets/table/header/table_header_view.dart';
import 'package:fml/widgets/table/header/cell/table_header_cell_model.dart';
import 'package:fml/widgets/table/header/cell/table_header_cell_view.dart';
import 'package:fml/widgets/table/row/table_row_model.dart';
import 'package:fml/widgets/table/row/table_row_view.dart';
import 'package:fml/widgets/table/row/cell/table_row_cell_view.dart';
import 'package:fml/helper/measured.dart';
import 'package:fml/widgets/scrollbar/scrollbar_view.dart';
import 'package:fml/system.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior
{
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details)
  {
    return child;
  }
}

class TableView extends StatefulWidget implements IWidgetView
{
  final TableModel model;
  TableView(this.model) : super(key: ObjectKey(model));

  @override
  _TableViewState createState() => _TableViewState();
}

class _TableViewState extends WidgetState<TableView> implements IEventScrolling
{
  BusyView? busy;
  Future<TableModel>? future;
  bool startup = true;

  ScrollController? hScroller;
  ScrollController? vScroller;

  int visibleRows = 0;

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
    EventManager.of(widget.model)?.registerEventListener(EventTypes.scroll,   onScroll);
    EventManager.of(widget.model)?.registerEventListener(EventTypes.export,   onExport);
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
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.scroll,   onScroll);
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.export,   onExport);
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.complete, onComplete);
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.scrollto, onScrollTo);

      // register new event listeners
      EventManager.of(widget.model)?.registerEventListener(EventTypes.scroll,   onScroll);
      EventManager.of(widget.model)?.registerEventListener(EventTypes.export,   onExport);
      EventManager.of(widget.model)?.registerEventListener(EventTypes.complete, onComplete);
      EventManager.of(widget.model)?.registerEventListener(EventTypes.scrollto, onScrollTo, priority: 0);
    }
  }

  @override
  void dispose()
  {
    // remove event listeners
    EventManager.of(widget.model)?.removeEventListener(EventTypes.scroll,   onScroll);
    EventManager.of(widget.model)?.removeEventListener(EventTypes.export,   onExport);
    EventManager.of(widget.model)?.removeEventListener(EventTypes.complete, onComplete);
    EventManager.of(widget.model)?.removeEventListener(EventTypes.scrollto, onScrollTo);

    hScroller?.dispose();
    vScroller?.dispose();

    super.dispose();
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

  /// Takes an event (onscroll) and uses the id to scroll to that widget
  onScrollTo(Event event) {
    // BuildContext context;
    event.handled = true;
    if (event.parameters!.containsKey('id')) {
      String? id = event.parameters!['id'];
      var child = widget.model.findDescendantOfExactType(null, id: id);

      // if there is an error with this, we need to check _controller.hasClients as it must not be false when using [ScrollPosition],such as [position], [offset], [animateTo], and [jumpTo],
      if ((child != null) && (child.context != null))
        Scrollable.ensureVisible(child.context, duration: Duration(seconds: 1), alignment: 0.2);
    }
  }

  Future<bool> onComplete(Event event) async
  {
    bool ok = true;

    ////////////////////////
    /* Specific Complete? */
    ////////////////////////
    if ((event.parameters != null) && (!S.isNullOrEmpty(event.parameters!['id'])) && (event.parameters!['id'] != widget.model.id)) return ok;

    ///////////////////////////
    /* Mark Event as Handled */
    ///////////////////////////
    event.handled = true;

    /////////////////
    /* Force Close */
    /////////////////
    await closeKeyboard();

    /////////////
    /* Confirm */
    /////////////
    //int response = await DialogService().show(type: DialogType.info, title: phrase.confirmTableComplete, buttons: [Text(phrase.yes, style: TextStyle(fontSize: 18, color: Colors.white)),Text(phrase.no, style: TextStyle(fontSize: 18, color: Colors.white))]);

    ok = true;

    //////////////////////
    /* Row Level Event? */
    //////////////////////
    TableRowModel? row;
    if (event.model != null) row = event.model!.findAncestorOfExactType(TableRowModel);

    ////////////////////////
    /* Complete the Table */
    ////////////////////////
    if (ok)
    {
      if (row != null)
           ok = await row.complete();
      else ok = await widget.model.complete();
    }

    /////////////////////
    /* Fire OnComplete */
    /////////////////////
    if (ok)
    {
      if (row != null)
           ok = await row.onComplete();
      else ok = await widget.model.onComplete(context);
    }

    return ok;
  }

  void onExport(Event event) async
  {
    if (event.parameters!['format'] != 'print')
    {
      event.handled = true;
      System.toast(S.toStr(phrase.exportingData), duration: 1);
      await widget.model.export();
    }
  }

  @override
  void onScroll(Event event) async
  {
    if (this.hScroller != null && this.vScroller != null) scroll(event, this.hScroller, this.vScroller);
    event.handled = true;
  }

  scroll(Event event, ScrollController? hScroller, ScrollController? vScroller) async
  {
    try
    {
      if (event.parameters!.containsKey("direction") && event.parameters!.containsKey("pixels"))
      {
        String? direction = event.parameters!["direction"];
        double distance = double.parse(event.parameters!["pixels"]!);
        if (direction != null)
        {
          if (direction == 'left' || direction == 'right') {
            double offset = hScroller!.offset;
            double moveToPosition = offset + (direction == 'left' ? -distance : distance);
            hScroller.animateTo(moveToPosition, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
          }
          else if (direction == 'up' || direction == 'down') {
            double offset = vScroller!.offset;
            double moveToPosition = offset + (direction == 'up' ? -distance : distance);
            vScroller.animateTo(moveToPosition, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
          }
        }
      }
    }
    catch(e)
    {
      Log().error('onScroll Error: ');
      Log().exception(e, caller: 'View');
    }
  }

  /// Callback function for when the model changes, used to force a rebuild with setState()
  onModelChange(WidgetModel model,{String? property, dynamic value})
  {
    try
    {
      var b = Binding.fromString(property);
      if (b?.property == 'busy') return;
      if (this.mounted) setState(() {});
    }
    catch(e)
    {
      Log().exception(e, caller: ' onModelChange(WidgetModel model,{String? property, dynamic value})');
    }
  }

  onProxyHeaderSize(Size size, {dynamic data})
  {
    setState(()
    {
      widget.model.proxyheader = size;
    });
  }

  onProxyRowSize(Size size, {dynamic data})
  {
    setState(()
    {
      widget.model.proxyrow = size;
    });
  }

  _setWidth(int index, double width)
  {
    TableHeaderCellModel? cell = widget.model.tableheader!.cells[index];
    double? cellwidth = cell.width;
    if (!widget.model.widths.containsKey(index)) widget.model.widths[index] = cellwidth ?? width;
    if (width > widget.model.widths[index]!) widget.model.widths[index] = cellwidth ?? width;
  }

  onProxyHeaderCellSize(Size size, {dynamic data})
  {
    if (size.height > widget.model.heights['header']!) widget.model.heights['header'] = size.height;
    if (data is int)
    {
      double width = size.width;
      if (!S.isNullOrEmpty(widget.model.tableheader!.cells[data].sort)) width += 16;
      _setWidth(data, width);
    }
  }

  onProxyRowCellSize(Size size, {dynamic data})
  {
    if (size.height > widget.model.heights['row']!) widget.model.heights['row'] = size.height;
    if (data is int)
    {
      double width = size.width;
      if (!S.isNullOrEmpty(widget.model.tableheader!.cells[data].sort)) width += 16;
      _setWidth(data, width);
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    ///////////////////
    /* Clear Padding */
    ///////////////////
    widget.model.cellpadding.clear();

    // save system constraints
    widget.model.systemConstraints = constraints;

    double? viewportHeight = widget.model.height ?? widget.model.globalConstraints.maxHeight;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    //////////////////
    /* Proxy Header */
    //////////////////
    if (widget.model.proxyheader == null) return headerBuilder(proxy: true);

    //////////////////
    /* Content Size */
    //////////////////
    double contentWidth = widget.model.getContentWidth();

    ///////////////////
    /* Viewport Size */
    ///////////////////
    double viewportWidth  = constraints.maxWidth;
    if (((widget.model.height ?? 0) > 0) && ((widget.model.height ?? 0) < viewportHeight!)) viewportHeight = widget.model.height;

    //////////////////////////////////
    /* Set Padding to Fill Viewport */
    //////////////////////////////////
    double padding = viewportWidth - contentWidth;
    widget.model.calculatePadding(padding);
    if (padding < 0) padding = 0;

    /////////////////
    /* Header Size */
    /////////////////
    double headerHeight = widget.model.heights['header']!;
    double headerWidth  = contentWidth + padding;

    ///////////////////////////
    /* Horizontal Scroll Bar */
    ///////////////////////////
    ScrollbarView hslider = ScrollbarView(Direction.horizontal, hScroller, viewportWidth, headerWidth);
    double trackHeight = hslider.isVisible() ? (isMobile ? 25 : 15) : 0;

    /////////////////
    /* Footer Size */
    /////////////////
    double? footerHeight = widget.model.heights['footer'];
    double footerWidth  = contentWidth + padding;
    if (widget.model.paged == false) footerHeight = 0;

    ///////////////
    /* Body Size */
    ///////////////
    double bodyHeight = viewportHeight! - headerHeight - footerHeight! - trackHeight;
    double bodyWidth = contentWidth + padding;
    visibleRows = (bodyHeight / widget.model.heights['row']!).floor();

    //////////////////
    /* Build Header */
    //////////////////
    Widget header = headerBuilder();

    /////////////////////////
    /* Vertical Scroll Bar */
    /////////////////////////
    Widget vslider = Container();
    if (widget.model.proxyrow != null)
    {
      var height   = widget.model.heights['row']!;
      var rows     = widget.model.data?.length ?? 0;
      int pagesize = widget.model.pagesize ?? rows;
      if (pagesize > rows) pagesize = rows;
      double theoreticalHeight = pagesize * height;
      if (theoreticalHeight > 0) vslider = ScrollbarView(Direction.vertical, vScroller, bodyHeight, theoreticalHeight, itemExtent: widget.model.heights['row']);
    }

    ////////////////
    /* Build Body */
    ////////////////

    Widget list;

    list = ListView.custom(physics: widget.model.onpulldown != null ? const AlwaysScrollableScrollPhysics() : null, scrollDirection: Axis.vertical, controller: vScroller, itemExtent: widget.model.heights['row'], childrenDelegate: SliverChildBuilderDelegate((BuildContext context, int index) {return rowBuilder(context, index);},));

    if(widget.model.onpulldown != null) list = RefreshIndicator(
        onRefresh: () => widget.model.onPull(context),
        child: list);

    ScrollBehavior behavior = (widget.model.onpulldown != null || widget.model.draggable) ? MyCustomScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        }) : MyCustomScrollBehavior();

    Widget body = UnconstrainedBox(child: SizedBox(width: bodyWidth, height: bodyHeight, child: ScrollConfiguration(behavior: behavior, child: list)));

    ///////////////////////////////////
    /* Build Horizontal Scroll Track */
    ///////////////////////////////////
    Widget htrack = Container();
    if (trackHeight > 0) htrack = Container(width: footerWidth, height: trackHeight);

    //////////////////
    /* Build Footer */
    //////////////////
    Widget footer = footerBuilder(footerWidth, footerHeight);

    //////////////
    /* Overlays */
    //////////////
    Widget footerOverlay1 = Container(width: viewportWidth, height: footerHeight, child: Center(child: footerPageSize()));
    Widget footerOverlay2 = Container(width: viewportWidth, height: footerHeight, child: footerRecordsDisplayed());
    Widget footerOverlay3 = Container(width: viewportWidth, height: footerHeight, child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.center, children:[footerPrevPage(), footerCurrPage(), footerNextPage()]));

    // Busy
    if (busy == null) busy = BusyView(BusyModel(widget.model, visible: widget.model.busy, observable: widget.model.busyObservable));

    ///////////
    /* Table */
    ///////////
    Widget table = Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children:[header,body,htrack,footer]);

    ////////////////////
    /* Scrolled Table */
    ////////////////////
    Widget scrolledTable;

    scrolledTable = SingleChildScrollView(scrollDirection: Axis.horizontal, child: table, controller: hScroller);

    if(widget.model.onpulldown != null || widget.model.draggable) scrolledTable = ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      child: scrolledTable,
    );

    //////////
    /* View */
    //////////
    return Stack(children: [scrolledTable, Positioned(top: headerHeight, right: 0, child: vslider), Positioned(bottom: footerHeight, left: 0, child: hslider),  Positioned(bottom: 0, left: 0, child: footerOverlay1), Positioned(bottom: 0, left: 0, child: footerOverlay2), Positioned(bottom: 0, left: 0, child: footerOverlay3), Center(child: busy)]);
  }

  Widget headerBuilder({bool proxy = false})
  {
    if ((proxy) == true)
    {
      List<Widget> children = [];

      ///////////////////////////////////
      /* Proxy Each Cell in the Header */
      ///////////////////////////////////
      int i = 0;
      widget.model.tableheader!.cells.forEach((model)
      {
        Widget view = TableHeaderCellView(model);
        var width  = model.width;
        var height = model.height;
        if ((width ?? 0) > 0 || (height ?? 0) > 0) view = SizedBox(child: view, width: width, height: height);


        final int index = i++;
        children.add(MeasuredView(UnconstrainedBox(child: view), onProxyHeaderCellSize, data: index));
      });

      //////////////////////
      /* Proxy the Header */
      //////////////////////
      children.add(MeasuredView(UnconstrainedBox(child: TableHeaderView(widget.model.tableheader, null, null, null)), onProxyHeaderSize));

      /////////////////////
      /* Return Offstage */
      /////////////////////
      return Offstage(child: Row(mainAxisSize: MainAxisSize.min, children: children));
    }

    else return TableHeaderView(widget.model.tableheader, widget.model.heights['header'], widget.model.widths, widget.model.cellpadding);
  }

  Widget? rowBuilder(BuildContext context, int index)
  {
    ///////////////////
    /* Get Row Model */
    ///////////////////
    TableRowModel? model = getRowModel(index);
    if (model == null) return null;

    bool proxy = false;
    if ((widget.model.proxyrow == null) && (widget.model.data != null) && (widget.model.data.isNotEmpty) && (index == 0)) proxy = true;

    ///////////////
    /* Proxy Row */
    ///////////////
    if (proxy)
    {
      List<Widget> children = [];

      ///////////////
      /* Proxy Row */
      ///////////////
      children.add(MeasuredView(UnconstrainedBox(child: TableRowView(model, null, null, null, null)), onProxyRowSize));

      ////////////////////////////////
      /* Proxy Each Cell in the Row */
      ////////////////////////////////
      int i = 0;
      model.cells.forEach((m)
      {
        final int index = i++;
        children.add(MeasuredView(UnconstrainedBox(child: TableRowCellView(m, null)), onProxyRowCellSize, data: index));
      });

      /////////////////////
      /* Return Offstage */
      /////////////////////
      return Offstage(child: UnconstrainedBox(child: Row(mainAxisSize: MainAxisSize.min, children: children)));
    }

    else return TableRowView(model, index, widget.model.height ?? widget.model.heights['row'], widget.model.widths, widget.model.cellpadding);
  }

  Widget footerBuilder(double width, double? height)
  {
    Color? color = widget.model.tableheader?.color ?? Theme.of(context).colorScheme.secondaryContainer;

    Color? bordercolor = widget.model.tableheader!.bordercolor ?? Colors.transparent;
    if ((widget.model.tablefooter != null) && (widget.model.tablefooter!.bordercolor != null)) bordercolor = widget.model.tablefooter!.bordercolor;
    if (bordercolor == null) bordercolor = Theme.of(context).colorScheme.outline;

    return Container(width: width, height: height, decoration: BoxDecoration(color: color, border: Border.all(color: bordercolor)));
  }

  Widget footerPageSize()
  {
    int records  = widget.model.data != null ? widget.model.data.length : 0;
    if (records > 0)
    {
      //////////
      /* Page */
      //////////
      int page = widget.model.page ?? 1;
      if (page < 0) page = 1;

      /////////////////////
      /* Page Increments */
      /////////////////////
      int i = widget.model.pagesize ?? 10;
      List<DropdownMenuItem<int>> items = [];
      while (i < records)
      {
        var item = DropdownMenuItem<int>(value: i, child: Text(i.toString()));
        items.add(item);
        i = i * 2;
      }

      //////////////
      /* Show All */
      //////////////
      var item = DropdownMenuItem<int>(value: records, child: Text(records.toString()));
      if (!items.contains(records)) items.add(item);

      ////////////////////
      /* Selected Value */
      ////////////////////
      DropdownMenuItem? selected = items.firstWhereOrNull((item) => (item.value! >= (widget.model.pagesize ?? 0)));
      if (selected == null) selected = items.first;

      return Padding(padding: EdgeInsets.only(left: 10),
          child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(child: Text(phrase.pagesize, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)), padding: EdgeInsets.only(right: 6)),
                MouseRegion(cursor: SystemMouseCursors.click,
                    child: UnconstrainedBox(clipBehavior: Clip.hardEdge,
                      child: DropdownButton<int>(value: selected.value,
                          underline: Container(),
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 15),
                          icon: Icon(Icons.keyboard_arrow_down, color: items.length > 1 ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.2)),
                          iconSize: 20, items: items,
                          onChanged: (int? newValue)  {
                            widget.model.page = 1;
                            widget.model.pagesize = newValue;
                          })))
              ]));
    }
    return Container();
  }

  Widget footerPrevPage()
  {
    List<Widget> children = [];
    children.add(Container());

    int pagesize = widget.model.pagesize ?? 0;
    if (pagesize > 0)
    {
      int page = widget.model.page ?? 1;
      if (page < 0) page = 1;

      ///////////////
      /* Prev Page */
      ///////////////
      if (page > 1)
           return MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(child: Padding(child: Icon(Icons.navigate_before, color: Theme.of(context).colorScheme.onSecondaryContainer), padding: EdgeInsets.only(left: 5, right: 5)), onTap: () => widget.model.page = page - 1));
      else return Padding(child: Icon(Icons.navigate_before, color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.2)), padding: EdgeInsets.only(left: 5, right: 5));
    }
    return Container();
  }

  Widget footerNextPage()
  {
    List<Widget> children = [];
    children.add(Container());

    int pagesize = widget.model.pagesize ?? 0;
    if (pagesize > 0)
    {
      int? records  = widget.model.data != null ? widget.model.data.length : 0;
      int pagesize = widget.model.pagesize ?? records!;

      int page = widget.model.page ?? 1;
      if (page < 0) page = 1;

      int pages = (pagesize > 0) ? (records! / pagesize).ceil() : 0;

      ///////////////
      /* Next Page */
      ///////////////
      if (page < pages)
           return MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(child: Padding(child: Icon(Icons.navigate_next, color: Theme.of(context).colorScheme.onSecondaryContainer), padding: EdgeInsets.only(left: 5, right: 5)), onTap: () =>  widget.model.page = page + 1));
      else return Padding(child: Icon(Icons.navigate_next, color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.2)), padding: EdgeInsets.only(left: 5, right: 5));
    }
    return Container();
  }

  Widget footerCurrPage() {

    if (widget.model.pagesize != null && widget.model.pagesize! > 0) {
      int? records  = widget.model.data != null ? widget.model.data.length : 0;
      int? pageSize = widget.model.pagesize ?? records;
      int? pages = (widget.model.pagesize! > 0) ? (records! / pageSize!).ceil() : null;
      return Padding(padding: EdgeInsets.all(5),
          child: Text('${widget.model.page ?? ''}${(pages != null && pages > 0) ? '/$pages' : ''}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)));
    }
    return Container();
  }

  Widget footerRecordsDisplayed()
  {
    int pagesize = widget.model.pagesize ?? 0;
    if (pagesize > 0)
    {
      int records  = widget.model.data != null ? widget.model.data.length : 0;
      if (pagesize > records) pagesize = records;

      int page = widget.model.page ?? 1;
      if (page < 0) page = 1;

      ///////////////////////
      /* Records Displayed */
      ///////////////////////
      if (records == 0)
        return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(padding: EdgeInsets.only(left: 10), child: Text('${phrase.no} ${phrase.records}'))
            ]);
      int start = 1;
      int end   = pagesize;
      if (page > 1)
      {
        start = pagesize * (page - 1) + 1;
        end   = start + pagesize - 1;
        if (end > records) end = records;
      }
      return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.only(left: 10),
                child: Text('${phrase.records} ${start.toString()} to ${end.toString()} ${phrase.of} ${records.toString()}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),))
          ]);
    }
    return Container();
  }

  void afterFirstLayout(BuildContext context)
  {
    //////////////////////////////////////
    /* Initial Vertical Scroll Position */
    //////////////////////////////////////
    ScrollController? controller = vScroller;
    if (controller != null) _handleScrollNotification(ScrollUpdateNotification(metrics: FixedScrollMetrics(minScrollExtent: controller.position.minScrollExtent, maxScrollExtent: controller.position.maxScrollExtent, pixels: controller.position.pixels, viewportDimension: controller.position.viewportDimension, axisDirection: controller.position.axisDirection), context: context, scrollDelta: 0.0));

    ////////////////////////////////////////
    /* Initial Horizontal Scroll Position */
    ////////////////////////////////////////
    controller = hScroller;
    if (controller != null)  _handleScrollNotification(ScrollUpdateNotification(metrics: FixedScrollMetrics(minScrollExtent: controller.position.minScrollExtent, maxScrollExtent: controller.position.maxScrollExtent, pixels: controller.position.pixels, viewportDimension: controller.position.viewportDimension, axisDirection: controller.position.axisDirection), context: context, scrollDelta: 0.0));
  }

  void updateShadowPostframe(BuildContext context)
  {
    /////////////////////////////
    /* Initial Scroll Position */
    /////////////////////////////
    ScrollController? controller = vScroller;
    if (controller != null && controller.hasClients) _handleScrollNotification(ScrollUpdateNotification(metrics: FixedScrollMetrics(minScrollExtent: controller.position.minScrollExtent, maxScrollExtent: controller.position.maxScrollExtent, pixels: controller.position.pixels, viewportDimension: controller.position.viewportDimension, axisDirection: controller.position.axisDirection), context: context, scrollDelta: 0.0));
    controller = hScroller;
    if (controller != null && controller.hasClients) _handleScrollNotification(ScrollUpdateNotification(metrics: FixedScrollMetrics(minScrollExtent: controller.position.minScrollExtent, maxScrollExtent: controller.position.maxScrollExtent, pixels: controller.position.pixels, viewportDimension: controller.position.viewportDimension, axisDirection: controller.position.axisDirection), context: context, scrollDelta: 0.0));
  }

  bool _handleScrollNotification(ScrollNotification notification)
  {
    if (notification.metrics.hasViewportDimension)
    {
      if ((notification.metrics.axisDirection == AxisDirection.left) || (notification.metrics.axisDirection == AxisDirection.right))
      {
        widget.model.moreLeft = ((notification.metrics.maxScrollExtent > 0) && (((notification.metrics.atEdge == true) && (notification.metrics.pixels >  0)) || (notification.metrics.atEdge == false)));
        widget.model.moreRight = ((notification.metrics.maxScrollExtent > 0) && (((notification.metrics.atEdge == true) && (notification.metrics.pixels <= 0)) || (notification.metrics.atEdge == false)));
      }
      else
      {
        widget.model.moreUp = ((notification.metrics.maxScrollExtent > 0) && (((notification.metrics.atEdge == true) && (notification.metrics.pixels >  0)) || (notification.metrics.atEdge == false)));
        widget.model.moreDown = ((notification.metrics.maxScrollExtent > 0) && (((notification.metrics.atEdge == true) && (notification.metrics.pixels <= 0)) || (notification.metrics.atEdge == false)));
      }
    }
    return true;
  }

  TableRowModel? getRowModel(int index)
  {
    int records  = widget.model.data != null ? widget.model.data.length : 0;
    int pagesize = widget.model.pagesize ?? records;

    int page = widget.model.page ?? 1;
    if (page < 0) page = 1;

    if (index >= records) return getEmptyRowModel(index, index);

    int from = (page - 1) * pagesize;
    int to = from + pagesize - 1;

    int offset = from + index;
    if ((offset > to)  || (offset >= records)) return getEmptyRowModel(offset - from, index);

    return widget.model.getRowModel(offset);
  }

  TableRowModel? getEmptyRowModel(int offset, index)
  {
    if ((visibleRows - offset) > 0)
    {
      var model = widget.model.getEmptyRowModel();
      if (model != null) model.index = index;
      return model;
    }
    return null;
  }
}