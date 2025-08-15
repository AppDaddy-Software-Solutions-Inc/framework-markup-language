// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:fml/widgets/echart/echart_model.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'package:graphify/graphify.dart';

class eChartView extends StatefulWidget implements ViewableWidgetView {

  @override
  final eChartModel model;
  eChartView(this.model) : super(key: ObjectKey(model));

  @override
  State<eChartView> createState() => _eChartViewState();
}

class _eChartViewState extends ViewableWidgetState<eChartView> {

  bool initialized = false;
  GraphifyView? egraph;
  Map<String,dynamic> option = {};
  final controller = GraphifyController();

  @override
  void onDestroy() {
    controller.dispose();
    super.dispose();
  }
   int rebuilds = 0;

  Timer? timer;
  void rebuild() {
    if (widget.model.options == option) return;
    if (mounted) setState(() {});
  }


  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: _build);

  Widget _build(BuildContext context, BoxConstraints constraints) {

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // build graph
    if (egraph == null) {
      option = widget.model.options;
      egraph = GraphifyView(controller: controller, initialOptions: option, onCreated: () => initialized = true);
      timer = Timer(Duration(seconds: 1), () => rebuild());
    }

    else if (option != widget.model.options && !timer!.isActive) {
      option = widget.model.options;
      controller.update(option);
      timer = Timer(Duration(seconds: 1), () => rebuild());
    }

    // set view
    Widget view = egraph as Widget;

    // add interceptor
    if (!widget.model.enabled) {
      var interceptor = PointerInterceptor(child: Container(color: Colors.transparent, width: constraints.maxWidth, height: constraints.maxHeight));
      view = Stack(children: [view, interceptor],);
    }

    // add margins
    view = addMargins(view);

    // apply visual transforms
    view = applyTransforms(view);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.tightestOrDefault);

    return view;
  }
}
