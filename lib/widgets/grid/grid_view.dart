// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:math';
import 'dart:ui';
import 'package:fml/event/manager.dart';
import 'package:fml/widgets/dragdrop/draggable_view.dart';
import 'package:fml/widgets/dragdrop/droppable_view.dart';
import 'package:fml/widgets/scroller/scroller_behavior.dart';
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/event/event.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/widgets/scrollshadow/scroll_shadow_view.dart';
import 'package:fml/widgets/scrollshadow/scroll_shadow_model.dart';
import 'package:fml/widgets/measure/measure_view.dart';
import 'package:fml/widgets/grid/grid_model.dart';
import 'package:fml/widgets/grid/item/grid_item_view.dart';
import 'package:fml/widgets/grid/item/grid_item_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:fml/helpers/helpers.dart';

class GridView extends StatefulWidget implements IWidgetView {
  @override
  final GridModel model;
  GridView(this.model) : super(key: ObjectKey(model));

  @override
  State<GridView> createState() => GridViewState();
}

class GridViewState extends WidgetState<GridView> {
  Widget? busy;
  bool startup = true;
  final ScrollController controller = ScrollController();

  late ScrollShadowModel scrollShadow;
  late double gridWidth;
  late double gridHeight;
  late double prototypeWidth;
  late double prototypeHeight;
  late int count;
  dynamic direction = Axis.vertical;

  @override
  void initState() {
    super.initState();

    // Clean
    widget.model.clean = true;
  }

  @override
  didChangeDependencies() {
    // register event listeners
    EventManager.of(widget.model)
        ?.registerEventListener(EventTypes.scroll, onScroll);
    EventManager.of(widget.model)
        ?.registerEventListener(EventTypes.sort, onSort);
    EventManager.of(widget.model)
        ?.registerEventListener(EventTypes.scrollto, onScrollTo, priority: 0);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(GridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model != widget.model) {
      // remove old event listeners
      EventManager.of(oldWidget.model)
          ?.removeEventListener(EventTypes.scroll, onScroll);
      EventManager.of(oldWidget.model)
          ?.removeEventListener(EventTypes.sort, onSort);
      EventManager.of(oldWidget.model)
          ?.removeEventListener(EventTypes.scrollto, onScrollTo);

      // register new event listeners
      EventManager.of(widget.model)
          ?.registerEventListener(EventTypes.scroll, onScroll);
      EventManager.of(widget.model)
          ?.registerEventListener(EventTypes.sort, onSort);
      EventManager.of(widget.model)
          ?.registerEventListener(EventTypes.scrollto, onScrollTo, priority: 0);
    }
  }

  @override
  void dispose() {
    // remove event listeners
    EventManager.of(widget.model)
        ?.removeEventListener(EventTypes.scroll, onScroll);
    EventManager.of(widget.model)?.removeEventListener(EventTypes.sort, onSort);
    EventManager.of(widget.model)
        ?.removeEventListener(EventTypes.scrollto, onScrollTo);

    controller.dispose();
    super.dispose();
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
            duration: const Duration(seconds: 1), alignment: 0.2);
      }
    }
  }

  void onSort(Event event) async {
    if (event.parameters != null) {
      String? field = event.parameters!.containsKey('field')
          ? event.parameters!['field']
          : null;
      String? type = event.parameters!.containsKey('type')
          ? event.parameters!['type']
          : 'string';
      String? ascending = event.parameters!.containsKey('ascending')
          ? event.parameters!['ascending']
          : 'true';
      if (!isNullOrEmpty(field)) {
        widget.model.sort(field, type, toBool(ascending));
      }
    }
  }

  void onScroll(Event event) async {
    scroll(event, controller);
    event.handled = true;
  }

  scroll(Event event, ScrollController? sc) async {
    try {
      if (event.parameters!.containsKey("direction") &&
          event.parameters!.containsKey("pixels")) {
        String? direction = event.parameters!["direction"];
        double distance = double.parse(event.parameters!["pixels"]!);
        if (direction != null) {
          if (direction == 'left' || direction == 'right') {
            double offset = sc!.offset;
            double moveToPosition =
                offset + (direction == 'left' ? -distance : distance);
            sc.animateTo(moveToPosition,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut);
          } else if (direction == 'up' || direction == 'down') {
            double offset = sc!.offset;
            double moveToPosition =
                offset + (direction == 'up' ? -distance : distance);
            sc.animateTo(moveToPosition,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut);
          }
        }
      }
    } catch (e) {
      Log().error('onScroll Error: ');
      Log().exception(e, caller: 'table.View');
    }
  }

  Widget? itemBuilder(BuildContext context, int rowIndex) {
    int startIndex = (rowIndex * count);
    int endIndex = (startIndex + count);

    // If all rows are built return null
    if (startIndex >= widget.model.items.length) return null;

    List<Widget> children = [];
    for (int i = startIndex; i < endIndex; i++) {
      if (i < widget.model.items.length) {
        // create the view
        var model = widget.model.items[i]!;
        Widget view = GridItemView(model);

        // droppable?
        if (model.droppable) {
          view = DroppableView(model, view);
        }

        // draggable?
        if (model.draggable) {
          view = DraggableView(model, view);
        }

        // wrap for selectable
        view = MouseRegion(cursor: SystemMouseCursors.click, child: view);
        view = GestureDetector(
            onTap: () => model.onTap(),
            behavior: HitTestBehavior.translucent,
            child: view);

        // add view to child list
        children.add(Expanded(
            child: SizedBox(
                width: prototypeWidth, height: prototypeHeight, child: view)));
      } else {
        // add empty placeholder
        children.add(Expanded(child: Container()));
      }
    }

    if (direction == Axis.vertical) {
      return Row(mainAxisSize: MainAxisSize.min, children: children);
    } else {
      return Column(mainAxisSize: MainAxisSize.min, children: children);
    }
  }

  void afterFirstLayout(BuildContext context) {
    _handleScrollNotification(ScrollUpdateNotification(
        metrics: FixedScrollMetrics(
            minScrollExtent: controller.position.minScrollExtent,
            maxScrollExtent: controller.position.maxScrollExtent,
            pixels: controller.position.pixels,
            devicePixelRatio: View.of(context).devicePixelRatio,
            viewportDimension: controller.position.viewportDimension,
            axisDirection: controller.position.axisDirection),
        context: context,
        scrollDelta: 0.0));
  }

  onMeasuredItem(Size size, {dynamic data}) {
    setState(() {
      widget.model.size = size;
    });
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.hasViewportDimension) {
      if ((notification.metrics.axisDirection == AxisDirection.left) ||
          (notification.metrics.axisDirection == AxisDirection.right)) {
        widget.model.moreLeft = ((notification.metrics.maxScrollExtent > 0) &&
            (((notification.metrics.atEdge == true) &&
                    (notification.metrics.pixels > 0)) ||
                (notification.metrics.atEdge == false)));
        widget.model.moreRight = ((notification.metrics.maxScrollExtent > 0) &&
            (((notification.metrics.atEdge == true) &&
                    (notification.metrics.pixels <= 0)) ||
                (notification.metrics.atEdge == false)));
      } else {
        widget.model.moreUp = ((notification.metrics.maxScrollExtent > 0) &&
            (((notification.metrics.atEdge == true) &&
                    (notification.metrics.pixels > 0)) ||
                (notification.metrics.atEdge == false)));
        widget.model.moreDown = ((notification.metrics.maxScrollExtent > 0) &&
            (((notification.metrics.atEdge == true) &&
                    (notification.metrics.pixels <= 0)) ||
                (notification.metrics.atEdge == false)));
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // build the prototype
    if (widget.model.size == null || widget.model.items.isEmpty) {
      Widget prototypeGrid = Container();
      try {
        // build model
        var model = GridItemModel.fromXml(widget.model, widget.model.prototype);
        if (model != null) {
          prototypeGrid = Offstage(
              child: MeasureView(UnconstrainedBox(child: GridItemView(model)),
                  onMeasuredItem));
        }
      } catch (e) {
        prototypeGrid = const Text('Error Prototyping GridModel');
      }
      return prototypeGrid;
    }

    gridWidth = widget.model.width ?? widget.model.myMaxWidthOrDefault;
    gridHeight = widget.model.height ?? widget.model.myMaxHeightOrDefault;

    if (widget.model.items.isNotEmpty) {
      prototypeWidth = widget.model.items.entries.first.value.width ??
          widget.model.myMaxWidthOrDefault /
              (sqrt(widget.model.items.length) + 1);
      prototypeHeight = widget.model.items.entries.first.value.height ??
          widget.model.myMaxHeightOrDefault /
              (sqrt(widget.model.items.length) + 1);
    } else {
      prototypeWidth = widget.model.myMaxWidthOrDefault /
          (sqrt(widget.model.items.length) + 1);
      prototypeHeight = widget.model.myMaxHeightOrDefault /
          (sqrt(widget.model.items.length) + 1);
    }

    widget.model.direction == 'horizontal'
        ? direction = Axis.horizontal
        : direction = Axis.vertical;

    // Protect against infinity calculations when screen is smaller than the grid item in the none expanding direction
    if (direction == Axis.vertical && gridWidth < prototypeWidth) {
      gridWidth = prototypeWidth;
    } else if (direction == Axis.horizontal && gridHeight < prototypeHeight) {
      gridHeight = prototypeHeight;
    }

    if (direction == Axis.vertical) {
      double cellWidth = prototypeWidth;
      if (cellWidth == 0) cellWidth = 160;
      count = (gridWidth / cellWidth).floor();
    } else {
      double cellHeight = prototypeHeight;
      if (cellHeight == 0) cellHeight = 160;
      count = (gridHeight / cellHeight).floor();
    }

    /// Busy / Loading Indicator
    busy ??= BusyModel(widget.model,
            visible: widget.model.busy, observable: widget.model.busyObservable)
        .getView();

    // Build the Grid Rows
    Widget view = ListView.builder(
        scrollDirection: direction,
        physics: widget.model.onpulldown != null
            ? const AlwaysScrollableScrollPhysics()
            : null,
        controller: controller,
        itemBuilder: itemBuilder);

    if (widget.model.onpulldown != null) {
      view = RefreshIndicator(
          onRefresh: () => widget.model.onPull(context), child: view);
    }

    if (widget.model.onpulldown != null || widget.model.allowDrag) {
      view = ScrollConfiguration(
        behavior: ProperScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: view,
      );
    } else {
      view = ScrollConfiguration(behavior: ProperScrollBehavior(), child: view);
    }

    // add margins
    view = addMargins(view);

    // apply visual transforms
    view = applyTransforms(view);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.tightestOrDefault);


    List<Widget> children = [];

    children.add(view);

    // Initialize scroll shadows to controller after building
    if (widget.model.scrollShadows == true) {
      scrollShadow = ScrollShadowModel(widget.model);
      children.add(ScrollShadowView(scrollShadow));
    }

    children.add(Center(child: busy));

    view = Stack(children: children);

    return view;
  }

  Offset? positionOf() {
    RenderBox? render = context.findRenderObject() as RenderBox?;
    return render?.localToGlobal(Offset.zero);
  }

  Size? sizeOf() {
    RenderBox? render = context.findRenderObject() as RenderBox?;
    return render?.size;
  }
}
