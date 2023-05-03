// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fml/widgets/column/column_view.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'padding_model.dart';

class PaddingView extends StatefulWidget implements IWidgetView
{
  @override
  final PaddingModel model;

  PaddingView(this.model) : super(key: ObjectKey(model));

  @override
  State<PaddingView> createState() => _PaddingViewState();
}

class _PaddingViewState extends WidgetState<PaddingView>
{
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints) 
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // set constraints
    onLayout(constraints);

    double pTop    = max(widget.model.marginTop ?? 0, 0);
    double pBottom = max(widget.model.marginBottom ?? 0, 0);
    double pLeft   = max(widget.model.marginLeft ?? 0, 0);
    double pRight  = max(widget.model.marginRight ?? 0, 0);

    // simple empty box
    if (widget.model.children == null || widget.model.children!.isEmpty) return SizedBox(width: pLeft + pRight, height: pTop + pBottom);

    // column view
    Widget view = ColumnView(widget.model);

    // build the child views
    return view;
  }
}
