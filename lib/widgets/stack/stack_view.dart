// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/positioned/positioned_view.dart';
import 'package:fml/widgets/stack/stack_model.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/widgets/widget/layout_widget_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class StackView extends StatefulWidget implements IWidgetView
{
  final LayoutWidgetModel model;

  StackView(this.model) : super(key: ObjectKey(model));

  @override
  _StackViewState createState() => _StackViewState();
}

class _StackViewState extends WidgetState<StackView>
{
  List<Widget> _layoutChildren()
  {
    // get model constraints
    var constraints = widget.model.constraints.model;

    // build the child views
    List<Widget> children = widget.model.inflate();
    if (children.isEmpty) children.add(Container(width: 0, height: 0));

    MainAxisSize horizontalAxisSize = widget.model.getHorizontalAxisSize();
    MainAxisSize verticalAxisSize   = widget.model.getVerticalAxisSize();

    // The stack sizes itself to contain all the non-positioned children,
    // which are positioned according to alignment.
    var hasNonPositionedChildren = children.firstWhereOrNull((child) => child is! PositionedView) != null;

    // calculate the box width
    double? width = (horizontalAxisSize == MainAxisSize.min) ? (constraints.width ?? constraints.minWidth  ?? (hasNonPositionedChildren ? null : 50))  : double.infinity;

    // calculate the box height
    double? height = (verticalAxisSize == MainAxisSize.min) ? (constraints.height ?? constraints.minHeight ?? (hasNonPositionedChildren ? null : 50)) : double.infinity;

    // a sized box where width is double.infinity and height is double.infinity
    // is the same as using SizedBox.expand()
    children.add(SizedBox(width: width, height: height));

    return children;
  }
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // save system constraints
    onLayout(constraints);

    // layout the children
    var children = _layoutChildren();

    // calculate the alignment
    var alignment = AlignmentHelper.alignWidgetAxis(LayoutType.stack, widget.model.center, AlignmentHelper.getHorizontalAlignmentType(widget.model.halign), AlignmentHelper.getVerticalAlignmentType(widget.model.valign));

    // create the stack
    Widget view = Stack(children: children, alignment: alignment.aligned, fit: StackFit.loose);

    // add margins
    // skip these if this is being managed at a higher level (BoxModel)
    if (widget.model is StackModel) view = addMargins(view);

    // apply user defined constraints
    // skip these if this is being managed at a higher level (BoxModel)
    if (widget.model is StackModel) view = applyConstraints(view, widget.model.constraints.model);

    return view;
  }
}
