// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/stack/stack_model.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class StackView extends StatefulWidget implements IWidgetView
{
  final StackModel model;

  StackView(this.model) : super(key: ObjectKey(model));

  @override
  _StackViewState createState() => _StackViewState();
}

class _StackViewState extends WidgetState<StackView>
{
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // save system constraints
    onLayout(constraints);

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // build the child views
    List<Widget> children = widget.model.inflate();
    if (children.isEmpty) children.add(Container());

    var constr = widget.model.constraints.calculate();
    if (widget.model.expand)
      children.add(ConstrainedBox(
          child: Container(),
          constraints: BoxConstraints(
              minHeight: constr.minHeight!,
              maxHeight: constr.maxHeight!,
              minWidth: constr.minWidth!,
              maxWidth: constr.maxWidth!)));

    var alignment = AlignmentHelper.alignWidgetAxis(LayoutType.stack, widget.model.center, AlignmentHelper.getHorizontalAlignmentType(widget.model.halign), AlignmentHelper.getVerticalAlignmentType(widget.model.valign));

    // create the stack
    Widget view = Stack(children: children, alignment: alignment.aligned, fit: StackFit.loose);

    // apply user padding
    view = applyPadding(view);

    // apply user defined constraints
    return applyConstraints(view, widget.model.constraints.model);
  }
}
