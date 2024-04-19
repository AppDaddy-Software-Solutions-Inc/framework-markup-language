// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'padding_model.dart';

class PaddingView extends StatefulWidget implements ViewableWidgetView {
  @override
  final PaddingModel model;

  PaddingView(this.model) : super(key: ObjectKey(model));

  @override
  State<PaddingView> createState() => _PaddingViewState();
}

class _PaddingViewState extends ViewableWidgetState<PaddingView> {
  @override
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    double pTop = max(widget.model.marginTop ?? 0, 0);
    double pBottom = max(widget.model.marginBottom ?? 0, 0);
    double pLeft = max(widget.model.marginLeft ?? 0, 0);
    double pRight = max(widget.model.marginRight ?? 0, 0);

    // simple empty box
    if (widget.model.children == null || widget.model.children!.isEmpty) {
      return SizedBox(width: pLeft + pRight, height: pTop + pBottom);
    }

    // box view
    Widget view = BoxView(widget.model, widget.model.inflate());

    // build the child views
    return view;
  }
}
