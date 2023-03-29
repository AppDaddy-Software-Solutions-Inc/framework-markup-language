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
    widget.model.systemConstraints = constraints;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // build the child views
    List<Widget> children = widget.model.inflate();
    if (children.isEmpty) children.add(Container());

    var constr = widget.model.globalConstraints;
    if (widget.model.expand)
      children.add(ConstrainedBox(
          child: Container(),
          constraints: BoxConstraints(
              minHeight: constr.minHeight!,
              maxHeight: constr.maxHeight!,
              minWidth: constr.minWidth!,
              maxWidth: constr.maxWidth!)));

    var alignment = AlignmentHelper.alignWidgetAxis(children.length, 'stack', widget.model.center, widget.model.halign, widget.model.valign);

    //////////
    /* View */
    //////////
    Widget view = Stack(children: children, alignment: alignment.aligned, fit: StackFit.loose);

    ////////////////////
    /* Padding values */
    ////////////////////
    EdgeInsets insets = EdgeInsets.only();
    if (widget.model.paddings > 0)
    {
      // pad all
      if (widget.model.paddings == 1) insets = EdgeInsets.all(widget.model.padding);

      // pad directions v,h
      else if (widget.model.paddings == 2) insets = EdgeInsets.symmetric(vertical: widget.model.padding, horizontal: widget.model.padding2);

      // pad sides top, right, bottom
      else if (widget.model.paddings == 3) insets = EdgeInsets.only(top: widget.model.padding, left: widget.model.padding2, right: widget.model.padding2, bottom: widget.model.padding3);

      // pad sides top, right, bottom
      else if (widget.model.paddings == 4) insets = EdgeInsets.only(top: widget.model.padding, right: widget.model.padding2, bottom: widget.model.padding3, left: widget.model.padding4);

      view = Padding(padding: insets, child: view);
    }

    // apply user defined constraints
    return applyConstraints(view, widget.model.modelConstraints);
  }
}
