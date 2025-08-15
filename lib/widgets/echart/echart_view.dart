// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
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

  GraphifyView? graph;
  final controller = GraphifyController();

  @override
  void onDestroy() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: _build);

  Widget _build(BuildContext context, BoxConstraints constraints) {

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    Widget view;

    // build graph
    if (graph == null) {
      graph = GraphifyView(controller: controller, initialOptions: widget.model.options);
    }
    else {
      controller.update(widget.model.options);
    }

    // set view
    view = graph as Widget;

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
