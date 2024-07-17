// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/tabview/tab_model.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';

class Tab extends StatefulWidget implements ViewableWidgetView {

  @override
  final TabModel model;

  Tab(this.model) : super(key: ObjectKey(model));

  @override
  State<Tab> createState() => _TabState();
}

class _TabState extends ViewableWidgetState<Tab> with TickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // build the view
    Widget view = widget.model.getView();

    // add margins
    view = addMargins(view);

    // apply visual transforms
    view = applyTransforms(view);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.constraints);

    return view;
  }
}
