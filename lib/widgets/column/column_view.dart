// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/column/column_model.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/widgets/widget/layout_widget_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class ColumnView extends StatefulWidget implements IWidgetView
{
  final LayoutWidgetModel model;

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
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // save system constraints
    onLayout(constraints);

    // build the child views
    List<Widget> children = widget.model.inflate();
    if (children.isEmpty) children.add(Container());

    // this must go after the children are determined
    var alignment = AlignmentHelper.alignWidgetAxis(LayoutType.column, widget.model.center, AlignmentHelper.getHorizontalAlignmentType(widget.model.halign), AlignmentHelper.getVerticalAlignmentType(widget.model.valign));

    // get user defined constraints
    var localConstraints = widget.model.constraints.model;

    // get main axis size
    MainAxisSize? mainAxisSize = widget.model.getVerticalAxisSize();

    /// safeguard - don't allow infinite height
    if (constraints.maxHeight == double.infinity && mainAxisSize == MainAxisSize.max && !localConstraints.hasVerticalExpansionConstraints) mainAxisSize = MainAxisSize.min;

    Widget view;

    // create view
    if (widget.model.wrap == true)
      view = Wrap(children: children,
          direction: Axis.vertical,
          alignment: alignment.mainWrapAlignment,
          runAlignment: alignment.mainWrapAlignment,
          crossAxisAlignment: alignment.crossWrapAlignment);
    else
      view = Column(
          children: children,
          mainAxisAlignment: alignment.mainAlignment,
          crossAxisAlignment: alignment.crossAlignment,
          mainAxisSize: mainAxisSize);

    // add margins
    // skip these if this is being managed at a higher level (BoxModel)
    if (widget.model is ColumnModel) view = addMargins(view);

    // apply user defined constraints
    // skip these if this is being managed at a higher level (BoxModel)
    if (widget.model is ColumnModel) view = applyConstraints(view, widget.model.constraints.model);

    return view;
  }
}
