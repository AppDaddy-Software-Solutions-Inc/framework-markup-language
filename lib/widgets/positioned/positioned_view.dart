// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/stack/stack_model.dart';
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
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // build the child views
    List<Widget> children = widget.model.inflate();
    if (children.isEmpty) children.add(Container());
    var child = children.length == 1 ? children[0] : Column(children: children);

    // A positioned widget's immediate parent must be a stack
    Widget view = child;
    if (widget.model.parent is StackModel || (widget.model.parent is BoxModel && (widget.model.parent as BoxModel).getLayoutType() == LayoutTypes.stack))
    {
      if (widget.model.xoffset != null && widget.model.yoffset != null)
      {
        double fromTop = (widget.model.globalMaxHeight! / 2) + widget.model.yoffset!;
        double fromLeft = (widget.model.globalMaxWidth! / 2) + widget.model.xoffset!;
        view = Positioned(top: fromTop, left: fromLeft, child: view);
      }
      else view = Positioned(top: widget.model.top, bottom: widget.model.bottom, left: widget.model.left, right: widget.model.right, child: view);
    }

    return view;
  }
}
