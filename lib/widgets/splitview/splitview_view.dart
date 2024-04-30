// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fml/navigation/navigation_manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/splitview/splitview_model.dart';
import 'package:fml/event/event.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';

class SplitView extends StatefulWidget implements ViewableWidgetView {

  @override
  final SplitViewModel model;

  SplitView(this.model) : super(key: ObjectKey(model));

  @override
  State<SplitView> createState() => SplitViewState();
}

class SplitViewState extends ViewableWidgetState<SplitView> {

  BoxConstraints constraints = const BoxConstraints();

  BoxView? view0;
  BoxView? view1;

  void onBack(Event event) {
    event.handled = true;
    String? pages = fromMap(event.parameters, 'until');
    if (!isNullOrEmpty(pages)) NavigationManager().back(pages);
  }

  void onClose(Event event) {
    event.handled = true;
    NavigationManager().back(-1);
  }

  void _onDrag(DragUpdateDetails details, BoxConstraints constraints) {

    var ratio = widget.model.ratio;

    var maxHeight = constraints.hasBoundedHeight ? constraints.maxHeight : 0.0;
    var maxWidth = constraints.hasBoundedWidth ? constraints.maxWidth : 0.0;
    if (widget.model.vertical) {
      if (maxHeight > 0) {
        var height = (ratio * maxHeight) + details.delta.dy;
        ratio = height / maxHeight;
      }
    } else {
      if (maxWidth > 0) {
        var width = (ratio * maxWidth) + details.delta.dx;
        ratio = width / maxWidth;
      }
    }

    // reset the ratio
    if (ratio < 0) ratio = 0;
    if (ratio > 1) ratio = 1;
    widget.model.ratio = ratio;
  }

  Widget _buildHandle(BoxConstraints constraints) {

    var color = widget.model.dividerColor ?? Theme.of(context).colorScheme.onInverseSurface;

    // vertical splitter
    if (widget.model.vertical) {

      var width = constraints.maxWidth;
      var height = widget.model.dividerWidth;

      Widget bar = Container(
          color: color,
          width: width, height: height);

      bar = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (DragUpdateDetails details) =>
              _onDrag(details, constraints),
          child: MouseRegion(cursor: SystemMouseCursors.resizeUpDown, child: bar));

      Widget handle = Icon(Icons.drag_handle, color: widget.model.dividerHandleColor);
      handle = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragUpdate: (DragUpdateDetails details) =>
              _onDrag(details, constraints),
          child: MouseRegion(cursor: SystemMouseCursors.resizeLeftRight, child: handle));

      Widget view = Stack(alignment: Alignment.center, children: [bar, Positioned(left: 10,  right: 10, child: handle)]);

      return view;
    }

    // horizontal splitter
    else {
      var width = widget.model.dividerWidth;
      var height = constraints.maxHeight;

      Widget bar = Container(
          color: color,
          width: width, height: height);

      bar = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (DragUpdateDetails details) =>
              _onDrag(details, constraints),
          child: MouseRegion(cursor: SystemMouseCursors.resizeLeftRight, child: bar));

      Widget handle = Icon(Icons.drag_handle, color: widget.model.dividerHandleColor);
      handle = Transform.rotate(angle: 90 * pi / 180, child: handle);
      handle = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: (DragUpdateDetails details) =>
              _onDrag(details, constraints),
          child: MouseRegion(cursor: SystemMouseCursors.resizeLeftRight, child: handle));

      Widget view = Stack(alignment: Alignment.center, children: [bar, Positioned(top: 10,  bottom: 10, child: handle)]);

      return view;
    }
  }

  BoxView view(int i)
  {
    // get children
    var children = widget.model.viewableChildren;

    // find box model at specified child index
    Widget? view;
    if (children.length > i) {
      view = children.elementAt(i).getView();
      if (view is BoxView) return view;
    }

    // missing view
    return BoxView(BoxModel(widget.model, null), (_,__) => const []);
  }

  @override
  Widget build(BuildContext context) {
    var view = BoxView(widget.model, builder);
    return view;
  }

  List<Widget> builder(BuildContext context, BoxConstraints constraints) {

    // left pane
    view0 ??= view(0);
    view1 ??= view(1);

    // ratio box1:box2. if 1, box 1 is 100% size
    var ratio = widget.model.ratio;
    if (ratio < 0) ratio = 0;
    if (ratio > 1) ratio = 1;
    var flex = (ratio * 1000).ceil();

    List<Widget> children = [];

    // left/top view
    view0 ??= view(0);
    view0!.model.setFlex(flex);
    view0!.model.needsLayout = true;
    children.add(view0!);

    // handle
    Widget handle = _buildHandle(constraints);
    children.add(handle);

    // right/bottom view
    view1 ??= view(1);
    view1!.model.setFlex(1000 - flex);
    view1!.model.needsLayout = true;
    children.add(view1!);

    return children;
  }
}
