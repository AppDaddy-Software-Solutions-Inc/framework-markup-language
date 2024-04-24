// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/navigation/navigation_manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/splitview/split_view_model.dart';
import 'package:fml/event/event.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';

class SplitViewView extends StatefulWidget implements ViewableWidgetView {

  @override
  final SplitViewModel model;

  SplitViewView(this.model) : super(key: ObjectKey(model));

  @override
  State<SplitViewView> createState() => SplitViewViewState();
}

class SplitViewViewState extends ViewableWidgetState<SplitViewView> {

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
    widget.model.needsRebuild = true;
    widget.model.ratio = ratio;
  }

  Widget _buildHandle(BoxConstraints constraints) {
    var myDividerColor =
        widget.model.dividerColor ?? Theme.of(context).colorScheme.onInverseSurface;
    var myDividerWidth = widget.model.dividerWidth;

    Widget view = widget.model.vertical
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (DragUpdateDetails details) =>
                _onDrag(details, constraints),
            onTap: () => widget.model.ratio = 0,
            child: Container(
                color: myDividerColor,
                child: SizedBox(
                    width: constraints.maxWidth,
                    height: myDividerWidth,
                    child: MouseRegion(
                        cursor: SystemMouseCursors.resizeUpDown,
                        child: Stack(children: [
                          Positioned(
                              top: -10,
                              child: Icon(Icons.drag_handle,
                                  color: widget.model.dividerHandleColor))
                        ])))))
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (DragUpdateDetails details) =>
                _onDrag(details, constraints),
            child: Container(
                color: myDividerColor,
                child: SizedBox(
                    width: myDividerWidth,
                    height: constraints.maxHeight,
                    child: MouseRegion(
                        cursor: SystemMouseCursors.resizeLeftRight,
                        child: RotationTransition(
                            turns: const AlwaysStoppedAnimation(.25),
                            child: Icon(Icons.drag_handle,
                                color: widget.model.dividerHandleColor))))));

    return view;
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
