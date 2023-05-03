// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/stack/stack_model.dart';
import 'package:fml/widgets/alignment/alignment.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:fml/widgets/layout/layout_model.dart';

class StackView extends StatefulWidget implements IWidgetView
{
  @override
  final LayoutModel model;

  StackView(this.model) : super(key: ObjectKey(model));

  @override
  State<StackView> createState() => _StackViewState();
}

class _StackViewState extends WidgetState<StackView>
{
  List<Widget> _layoutChildren()
  {
    // build the child views
    List<Widget> children = widget.model.inflate();
    if (children.isEmpty) children.add(Container(width: 0, height: 0));

    // this seems to be the "magic glue" that forces the stack
    // to expand to the size of its outer container
    children.insert(0, Container());

    return children;
  }

  @override
  void initState()
  {
    super.initState();

    // remove listener to the model if the model
    // is not a stack model. The BoxModel will share the same model
    // and rebuild this view on model change
    if (widget.model is! StackModel) widget.model.removeListener(this);
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
    var alignment = WidgetAlignment(widget.model.layoutType, widget.model.center, widget.model.halign, widget.model.valign);

    // create the stack
    Widget view = Stack(children: children, alignment: alignment.aligned, fit: StackFit.loose);

    // add margins
    if (model is StackModel) view = addMargins(view);

    // apply user defined constraints
    if (model is StackModel) view = applyConstraints(view, widget.model.constraints.model);

    // allow the box to shrink on any axis that is not expanding
    // this is done by applying an UnconstrainedBox() to the view
    // in the direction of the constrained axis
    if (!widget.model.expand) view = UnconstrainedBox(child: view);

    return view;
  }
}
