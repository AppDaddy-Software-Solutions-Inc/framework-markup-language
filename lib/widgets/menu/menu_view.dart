// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/event/manager.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/event/event.dart' ;
import 'package:flutter/material.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/widgets/busy/busy_view.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/menu/menu_model.dart';
import 'package:fml/widgets/menu/item/menu_item_view.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class MenuView extends StatefulWidget implements IWidgetView
{
  @override
  final MenuModel model;
  MenuView(this.model);

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends WidgetState<MenuView> implements IEventScrolling
{
  BusyView? busy;
  ScrollController? vScroller;

  @override
  void initState()
  {
    super.initState();
    vScroller = ScrollController();
  }

  @override
  didChangeDependencies()
  {
    // register event listeners
    EventManager.of(widget.model)?.registerEventListener(EventTypes.scroll, onScroll);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(MenuView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    
    if ((oldWidget.model != widget.model))
    {
      // remove old event listeners
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.scroll, onScroll);

      // register new event listeners
      EventManager.of(widget.model)?.registerEventListener(EventTypes.scroll, onScroll);
    }
  }

  @override
  void dispose()
  {
    // remove event listeners
    EventManager.of(widget.model)?.removeEventListener(EventTypes.scroll, onScroll);

    vScroller?.dispose();

    super.dispose();
  }

  @override
  void onScroll(Event event) async
  {
    if (vScroller != null) scroll(event, vScroller);
    event.handled = true;
  }

  scroll(Event event, ScrollController? scroller) async {
    try {
      if (event.parameters!.containsKey("direction") &&
          event.parameters!.containsKey("pixels") &&
          scroller != null) {
        String? direction = event.parameters!["direction"];
        double distance = double.parse(event.parameters!["pixels"]!);
        if (direction != null) {
          double offset = scroller.offset;
          double moveToPosition = offset +
              ((direction == 'up' || direction == 'left')
                  ? -distance
                  : distance);
          scroller.animateTo(moveToPosition,
              duration: Duration(milliseconds: 300), curve: Curves.easeOut);
        }
      }
    } catch(e) {
      Log().error('onScroll Error: $e');
    }
  }

  /// Callback function for when the model changes, used to force a rebuild with setState()
  @override
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    if (mounted) setState(() {});
  }

  Widget _buildMenuItems(double width) {
    List<MenuItemView> tilesList = []; //list of tiles
    List<Widget> tileRows = []; // row of tiles from list
    List<Row> rowsList = []; // list of rows containing tiles
    for (var item in widget.model.items) {
      MenuItemView tile = MenuItemView(item);
      tilesList.add(tile);
    }
    double menuColPadding = isMobile ? 0.0 : 25.0;
    double tilePadding = isMobile ? 5.0 : 0;
    int tilesPerRow =
        ((/*MediaQuery.of(context).size.*/ width - (menuColPadding * 2)) ~/
            (isMobile
                ? (170 + (tilePadding * 2))
                : (270 + (tilePadding * 2))));
    int tileCountForRow = 0;
    for (int i = 0; i < tilesList.length; i++) {
      tileRows.add(
          Padding(padding: EdgeInsets.all(tilePadding), child: tilesList[i]));
      tileCountForRow++;
      if (tileCountForRow >= tilesPerRow) {
        rowsList.add(Row(
          children: tileRows,
          mainAxisSize: MainAxisSize.min,
        ));
        tileRows = [];
        tileCountForRow = 0;
      }
      if (i == tilesList.length - 1 && tileRows.isNotEmpty) {
        // add partially filled row
        rowsList.add(Row(
          children: tileRows,
          mainAxisSize: MainAxisSize.min,
        ));
      }
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(menuColPadding),
        child: Column(
          children: rowsList,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // save system constraints
    onLayout(constraints);

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    //var background = BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor);

    /// Busy / Loading Indicator
    busy ??= BusyView(BusyModel(widget.model, visible: widget.model.busy, observable: widget.model.busyObservable));

    //////////
    /* View */
    //////////
    Widget view = Stack(children: [
      _buildMenuItems(widget.model.calculatedMaxWidthOrDefault),
      Center(child: busy)
    ]);

    return Container(color: widget.model.color ?? Theme.of(context).colorScheme.background, child: Center(child: SingleChildScrollView(controller: vScroller, child: view)));
  }
}
