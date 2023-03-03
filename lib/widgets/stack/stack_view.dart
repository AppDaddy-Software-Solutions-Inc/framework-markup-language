// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/stack/stack_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
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
    // Set Build Constraints in the [WidgetModel]
    setConstraints(constraints);

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    ///////////
    /* Child */
    ///////////
    List<Widget> children = [];
    if (widget.model.children != null)
      widget.model.children!.forEach((model) {
        if (model is IViewableWidget) {
                    children.add((model as IViewableWidget).getView());
        }
      });
    if (children.isEmpty) children.add(Container());
    var constr = widget.model.getConstraints();
    if (widget.model.expand)
      children.add(ConstrainedBox(
          child: Container(),
          constraints: BoxConstraints(
              minHeight: constr.minHeight!,
              maxHeight: constr.maxHeight!,
              minWidth: constr.minWidth!,
              maxWidth: constr.maxWidth!)));

    Map<String, dynamic> align = AlignmentHelper.alignWidgetAxis(
        children.length,
        'stack',
        widget.model.center,
        widget.model.halign,
        widget.model.valign);
    Alignment aligned = align['aligned'];

    //////////
    /* View */
    //////////
    Widget view;

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
    }

    view = Padding(
        padding: insets,
        child:
            Stack(children: children, alignment: aligned, fit: StackFit.loose));

    //////////////////
    /* Constrained? */
    //////////////////

    if (widget.model.expand == false) {
      view = Padding(
          padding: insets,
          child: Stack(children: children, alignment: aligned));
    } else if (widget.model.hasSizing) {
      view = ConstrainedBox(
          child: view,
          constraints: BoxConstraints(
              minHeight: constr.minHeight!,
              maxHeight: constr.maxHeight!,
              minWidth: constr.minWidth!,
              maxWidth: constr.maxWidth!));
    }

    return view;
  }
}
