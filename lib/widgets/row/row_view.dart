// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/widgets/row/row_model.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:flutter/material.dart';
import 'package:fml/helper/common_helpers.dart';

class RowView extends StatefulWidget implements IWidgetView
{
  final RowModel model;

  RowView(this.model) : super(key: ObjectKey(model));

  @override
  _RowViewState createState() => _RowViewState();
}

class _RowViewState extends WidgetState<RowView>
{
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // set constraints
    setConstraints(constraints);

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

    //this must go after the children are determined. Returns an alignment map.
    Map<String, dynamic> align = AlignmentHelper.alignWidgetAxis(
        children.length,
        'row',
        widget.model.center,
        widget.model.halign,
        widget.model.valign);
    CrossAxisAlignment? crossAlignment = align['crossAlignment'];
    MainAxisAlignment? mainAlignment = align['mainAlignment'];
    WrapAlignment? mainWrapAlignment = align['mainWrapAlignment'];
    WrapCrossAlignment? crossWrapAlignment = align['crossWrapAlignment'];

    // set main axis size
    var mainAxisSize = widget.model.expand == false ? MainAxisSize.min : MainAxisSize.max;

    /// safeguard - don't allow infinite size
    if (mainAxisSize == MainAxisSize.max && constraints.maxWidth == double.infinity) mainAxisSize = MainAxisSize.min;

    // check if wrap is true,and return the wrap widgets children.
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

    if (widget.model.wrap == true)
      view = Padding(
          padding: insets,
          child: Wrap(
              children: children,
              direction: Axis.horizontal,
              alignment: mainWrapAlignment!,
              runAlignment: mainWrapAlignment,
              crossAxisAlignment: crossWrapAlignment!));
    else
      view = Padding(
          padding: insets,
          child: Row(
              children: children,
              crossAxisAlignment: crossAlignment!,
              mainAxisAlignment: mainAlignment!,
              mainAxisSize: mainAxisSize));

    // Constrained?
    if (widget.model.hasSizing)
    {
      var constraints =  widget.model.getConstraints();
      double minWidth  = widget.model.haslHorizontalSizing ? constraints.minWidth  ?? 0.0 : 0.0;
      double maxWidth  = widget.model.haslHorizontalSizing ? constraints.maxWidth  ?? double.infinity : double.infinity;
      double minHeight = widget.model.hasVerticalSizing   ? constraints.minHeight ?? 0.0 : 0.0;
      double maxHeight = widget.model.hasVerticalSizing   ? constraints.maxHeight ?? double.infinity : double.infinity;
      view = ConstrainedBox(child: view, constraints: BoxConstraints(minHeight: minHeight, maxHeight: maxHeight, minWidth: minWidth, maxWidth: maxWidth));
    }

    return view;
  }
}
