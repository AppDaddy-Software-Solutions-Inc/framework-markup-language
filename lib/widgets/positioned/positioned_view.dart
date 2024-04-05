// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_data.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'positioned_model.dart';

class PositionedView extends StatefulWidget implements IWidgetView {
  final List<Widget> children = [];

  @override
  final PositionedModel model;
  PositionedView(this.model) : super(key: ObjectKey(model));

  @override
  State<PositionedView> createState() => _PositionedViewState();
}

class _PositionedViewState extends WidgetState<PositionedView> {

  @override
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // build the child views
    List<Widget> children = widget.model.inflate();
    if (children.isEmpty) children.add(Container());

    // get child
    var child = children.length == 1 ? children[0] : Column(children: children);

    // get parent layout
    LayoutType? layout;
    if (widget.model.parent is BoxModel) layout = BoxModel.getLayoutType((widget.model.parent as BoxModel).layout);

    // parent is not a stack?
    if (layout != LayoutType.stack) {
      return LayoutBoxChildData(model: widget.model, child: child);
    }

    if (widget.model.xoffset != null && widget.model.yoffset != null) {

      double fromTop =
          (widget.model.myMaxHeightOrDefault / 2) + widget.model.yoffset!;

      double fromLeft =
          (widget.model.myMaxWidthOrDefault / 2) + widget.model.xoffset!;

      return LayoutBoxChildData(
          model: widget.model, top: fromTop, left: fromLeft, child: child);
    }

    return LayoutBoxChildData(
        model: widget.model,
        top: widget.model.top,
        bottom: widget.model.bottom,
        left: widget.model.left,
        right: widget.model.right,
        child: child);
  }
}
