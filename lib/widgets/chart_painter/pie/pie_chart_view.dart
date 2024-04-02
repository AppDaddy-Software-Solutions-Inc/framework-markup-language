// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/template/template.dart';
import 'package:fml/widgets/chart_painter/pie/pie_chart_model.dart';
import 'package:fml/widgets/chart_painter/series/chart_series_extended.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/busy/busy_view.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fml/widgets/widget/widget_state.dart';

/// Chart View
///
/// Builds a Chart View using [CHART.ChartModel], [SERIES.ChartSeriesModel], [AXIS.ChartAxisModel] and
/// [EXCERPT.Model] properties
class PieChartView extends StatefulWidget implements IWidgetView {
  @override
  final PieChartModel model;
  PieChartView(this.model) : super(key: ObjectKey(model));

  @override
  State<PieChartView> createState() => _PieChartViewState();
}

class _PieChartViewState extends WidgetState<PieChartView> {
  Future<Template>? template;
  Future<PieChartModel>? chartViewModel;
  BusyView? busy;
  OverlayEntry? tooltip;

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    hideTooltip();
  }

  @override
  void didUpdateWidget(dynamic oldWidget) {
    super.didUpdateWidget(oldWidget);
    hideTooltip();
  }

  @override
  dispose() {
    hideTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // Busy / Loading Indicator
    busy ??= BusyView(BusyModel(widget.model,
        visible: widget.model.busy, observable: widget.model.busyObservable));

    Widget? view;

    // get the children
    List<Widget> children = widget.model.inflate();

    try {
      view = PieChart(PieChartData(
          sections: widget.model.pieData,
          centerSpaceRadius: widget.model.centerRadius,
          sectionsSpace: widget.model.spacing,
          pieTouchData: PieTouchData(touchCallback: onPieTouch)));
    } catch (e) {
      Log().exception(e, caller: 'chart_view builder() ');
      view = const Center(child: Icon(Icons.add_chart));
    }

    // Prioritize chart ux interactions
    view = Listener(behavior: HitTestBehavior.opaque, child: view);
    view = Container(child: view);
    children.insert(0, view);

    // add busy
    children.add(Center(child: busy));

    // Display children over chart
    view = Stack(children: children);

    // add margins
    view = addMargins(view);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.tightestOrDefault);

    return view;
  }

  void onPieTouch(FlTouchEvent event, PieTouchResponse? response) {
    bool exit = response?.touchedSection == null || event is FlPointerExitEvent;
    bool enter = !exit;

    if (enter) {
      Offset? point = event.localPosition;

      List<IExtendedSeriesInterface> spots = [];
      var spot = response!.touchedSection?.touchedSection;

      if (spot is IExtendedSeriesInterface) {
        spots.add(spot as IExtendedSeriesInterface);

        RenderBox? render = context.findRenderObject() as RenderBox?;
        if (render != null && point != null) {
          point = render.localToGlobal(point);
        }
      }

      // show tooltip in post frame callback
      WidgetsBinding.instance.addPostFrameCallback((_) => showTooltip(
          widget.model.getTooltips(spots), point?.dx ?? 0, point?.dy ?? 0));

      // ensure screen updates
      WidgetsBinding.instance.ensureVisualUpdate();
    }

    // hide tooltip
    if (exit) {
      // show tooltip in post frame callback
      WidgetsBinding.instance.addPostFrameCallback((_) => hideTooltip());

      // ensure screen updates
      WidgetsBinding.instance.ensureVisualUpdate();
    }
  }

  void showTooltip(List<Widget> views, double x, double y) {
    // remove old tooltip
    hideTooltip();

    // show new tooltip
    if (views.isNotEmpty) {
      tooltip = OverlayEntry(
          builder: (context) => Positioned(
              left: x,
              top: y + 25,
              child: Column(mainAxisSize: MainAxisSize.min, children: views)));
      Overlay.of(context).insert(tooltip!);
    }
  }

  void hideTooltip() {
    // remove old tooltip
    try {
      tooltip?.remove();
      tooltip?.dispose();
    } catch (e) {
      Log().exception(e);
    }
  }
}
