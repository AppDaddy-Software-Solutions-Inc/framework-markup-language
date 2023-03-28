// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/column/column_model.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class ColumnView extends StatefulWidget implements IWidgetView
{
  final ColumnModel model;

  ColumnView(this.model) : super(key: ObjectKey(model));

  @override
  _ColumnViewState createState() => _ColumnViewState();
}

class _ColumnViewState extends WidgetState<ColumnView>
{
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // save system constraints
    widget.model.setSystemConstraints(constraints);

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // build the child views
    List<Widget> children = widget.model.inflate();
    if (children.isEmpty) children.add(Container());

    // this must go after the children are determined
    var alignment = AlignmentHelper.alignWidgetAxis(children.length, 'column', widget.model.center, widget.model.halign, widget.model.valign);

    // get user defined constraints
    var localConstraints = widget.model.localConstraints;

    // set main axis size
    var mainAxisSize = widget.model.expand == false ? MainAxisSize.min : MainAxisSize.max;

    /// safeguard - don't allow infinite height
    if (constraints.maxHeight == double.infinity && mainAxisSize == MainAxisSize.max && !localConstraints.hasVerticalExpansionConstraints) mainAxisSize = MainAxisSize.min;

    Widget view;

    // set padding
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

    // create view
    if (widget.model.wrap == true)
      view = Padding( padding: insets, child: Wrap(
          children: children,
          direction: Axis.vertical,
          alignment: alignment.mainWrapAlignment,
          runAlignment: alignment.mainWrapAlignment,
          crossAxisAlignment: alignment.crossWrapAlignment));
    else
      view = Padding( padding: insets, child:Column(
          children: children,
          mainAxisAlignment: alignment.mainAlignment,
          crossAxisAlignment: alignment.crossAlignment,
          mainAxisSize: mainAxisSize));

    // apply user defined constraints
    return applyConstraints(view, localConstraints);
  }
}
