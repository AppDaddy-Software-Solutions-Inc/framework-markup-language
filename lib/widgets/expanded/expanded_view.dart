// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';

import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/expanded/expanded_model.dart';
import 'package:fml/widgets/row/row_model.dart';
import 'package:fml/widgets/column/column_model.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:hive/hive.dart';

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
    List<Widget> children = [];
    if (widget.model.children != null)
      widget.model.children!.forEach((model)
      {
        if (model is IViewableWidget) {
          children.add((model as IViewableWidget).getView());
        }
      });
    if (children.isEmpty) children.add(Container());

    var view = children.length == 1 ? children[0] : Column(children: children);

    // determine the layout type of the parent
    LayoutTypes? layout;
         if (widget.model.parent is RowModel) layout = LayoutTypes.row;
    else if (widget.model.parent is ColumnModel) layout = LayoutTypes.column;
    else if (widget.model.parent is BoxModel) layout = (widget.model.parent as BoxModel).getLayoutType();

    // parent must be a Row or Column or Box Model
    if (layout == LayoutTypes.row || layout == LayoutTypes.column)
           view = Expanded(flex: widget.model.flex, child: view);
    return view;
  }
}
