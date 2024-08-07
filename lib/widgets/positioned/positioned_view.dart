// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_layout.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'positioned_model.dart';

class PositionedView extends StatefulWidget implements ViewableWidgetView {
  final List<Widget> children = [];

  @override
  final PositionedModel model;
  PositionedView(this.model) : super(key: ObjectKey(model));

  @override
  State<PositionedView> createState() => _PositionedViewState();
}

class _PositionedViewState extends ViewableWidgetState<PositionedView> {

  onDrag(DragUpdateDetails details) {

    if (!widget.model.draggable) return;

    var dx = details.delta.dx;
    var dy = details.delta.dy;

    widget.model.disableNotifications();
    widget.model.right   = null;
    widget.model.bottom  = null;
    widget.model.xoffset = null;
    widget.model.yoffset = null;
    widget.model.left = (widget.model.left ?? 0) + dx;
    widget.model.top  = (widget.model.top ?? 0)  + dy;
    widget.model.enableNotifications();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints) {

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();


    // build the child views
    List<Widget> children = widget.model.inflate();
    if (children.isEmpty) children.add(Container());

    var view = children.length == 1 ? children[0] : Column(mainAxisSize: MainAxisSize.min, children: children);

    // draggable?
    if (widget.model.draggable) {
      view = MouseRegion(cursor: SystemMouseCursors.move, child: GestureDetector(
          onPanUpdate: onDrag,
          behavior: HitTestBehavior.deferToChild,
          child: view));
    }

    // resizeable?
    if (widget.model.resizeable) {
      view = getResizeableView(view);
    }

    view = BoxLayout(model: widget.model, child: view);

    return view;
  }
}
