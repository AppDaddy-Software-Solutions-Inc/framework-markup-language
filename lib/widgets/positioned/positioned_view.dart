// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'positioned_model.dart';

class PositionedView extends StatefulWidget implements IWidgetView
{
  final List<Widget> children = [];
  final PositionedModel model;
  PositionedView(this.model) : super(key: ObjectKey(model));

  @override
  _PositionedViewState createState() => _PositionedViewState();
}

class _PositionedViewState extends WidgetState<PositionedView>
{
  @override
  Widget build(BuildContext context) => builder(context, null);

  Widget builder(BuildContext context, BoxConstraints? constraints)
  {
    // Set Build Constraints in the [WidgetModel]
    //setConstraints(constraints);

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    //////////////////
    /* Add Children */
    //////////////////
    List<Widget> children = [];
    if (widget.model.children != null)
      widget.model.children!.forEach((model) {
        if (model is IViewableWidget) {
          children.add((model as IViewableWidget).getView());
        }
      });
    if (children.isEmpty) children.add(Container());
    var child = children.length == 1 ? children[0] : Column(children: children);

    ////////////////////////////
    /* Parent Must be a Stack */
    ////////////////////////////
    if (widget.model.xoffset != null && widget.model.yoffset != null) {
      double fromTop = (widget.model.getMaxHeight()! / 2) + widget.model.yoffset!;
      double fromLeft = (widget.model.getMaxWidth()! / 2) + widget.model.xoffset!;
      return Positioned(top: fromTop, left: fromLeft, child: child);
    } else
      return Positioned(
          top: widget.model.top,
          bottom: widget.model.bottom,
          left: widget.model.left,
          right: widget.model.right,
          child: child);
  }
}
