// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/widgets/row/row_model.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/layout_widget_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:flutter/material.dart';
import 'package:fml/helper/common_helpers.dart';

class RowView extends StatefulWidget implements IWidgetView
{
  final LayoutWidgetModel model;

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
    // save system constraints
    onLayout(constraints);

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // build the child views
    List<Widget> children = widget.model.inflate();
    if (children.isEmpty) children.add(Container());

    //this must go after the children are determined. Returns an alignment map.
    var alignment = AlignmentHelper.alignWidgetAxis(LayoutType.row, widget.model.center, AlignmentHelper.getHorizontalAlignmentType(widget.model.halign), AlignmentHelper.getVerticalAlignmentType(widget.model.valign));

    // get user defined constraints
    var modelConstraints = widget.model.constraints.model;

    // get main axis size
    MainAxisSize? mainAxisSize = widget.model.getHorizontalAxisSize();

    /// safeguard - don't allow infinite width
    if (constraints.maxWidth == double.infinity && mainAxisSize == MainAxisSize.max && !modelConstraints.hasHorizontalExpansionConstraints) mainAxisSize = MainAxisSize.min;

    // check if wrap is true,and return the wrap widgets children.
    Widget view;

    // create view
    if (widget.model.wrap == true)
      view = Wrap(
              children: children,
              direction: Axis.horizontal,
              alignment: alignment.mainWrapAlignment,
              runAlignment: alignment.mainWrapAlignment,
              crossAxisAlignment: alignment.crossWrapAlignment);
    else
      view = Row(
              children: children,
              crossAxisAlignment: alignment.crossAlignment,
              mainAxisAlignment: alignment.mainAlignment,
              mainAxisSize: mainAxisSize);

    // apply user padding
    // skip these if this is being managed at a higher level (BoxModel)
    if (widget.model is RowModel) view = applyPadding(view);

    // apply user defined constraints
    // skip these if this is being managed at a higher level (BoxModel)
    if (widget.model is RowModel) view = applyConstraints(view, widget.model.constraints.model);

    return view;
  }
}
