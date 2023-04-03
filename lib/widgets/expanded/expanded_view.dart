// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/helper/alignment.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/expanded/expanded_model.dart';
import 'package:fml/widgets/row/row_model.dart';
import 'package:fml/widgets/column/column_model.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class ExpandedView extends StatefulWidget implements IWidgetView
{
  final ExpandedModel model;

  ExpandedView(this.model) : super(key: ObjectKey(model));

  @override
  _ExpandedViewState createState() => _ExpandedViewState();
}

class _ExpandedViewState extends WidgetState<ExpandedView>
{
  @override
  Widget build(BuildContext context)
  {
    /// Unfortunately, this cant go inside a layoutBuilder() like other widgets.
    /// If placed inside a layoutBuilder(), children don't expand correctly.

    // Check if widget is visible before wasting resources on building it.
    if (!widget.model.visible) return Offstage();

    // build children
    List<Widget> children = widget.model.inflate();
    if (children.isEmpty) children.add(Container());
    var view = children.length == 1 ? children[0] : Column(children: children);

    // determine the parent has a size in its primary axis
    // if no size, Expanded will fail. We therefore just return the view
    bool allow =
        (widget.model.parent is RowModel) ||
        (widget.model.parent is ColumnModel) ||
        (widget.model.parent is BoxModel && AlignmentHelper.getLayoutType((widget.model.parent as BoxModel).layout) != LayoutType.stack);

    return allow ? Expanded(flex: widget.model.flex ?? 1, child: view) : view;
  }
}
