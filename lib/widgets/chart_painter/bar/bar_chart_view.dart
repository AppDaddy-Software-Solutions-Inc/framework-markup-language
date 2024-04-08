// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/template/template.dart';
import 'package:fml/widgets/chart_painter/bar/bar_chart_model.dart';
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
class BarChartView extends StatefulWidget implements IWidgetView {
  @override
  final BarChartModel model;
  BarChartView(this.model) : super(key: ObjectKey(model));

  @override
  State<BarChartView> createState() => _ChartViewState();
}

class _ChartViewState extends WidgetState<BarChartView> {
  Future<Template>? template;
  Future<BarChartModel>? chartViewModel;
  BusyView? busy;
  OverlayEntry? tooltip;

  BarChart? chart;

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

  Widget bottomTitles(double value, TitleMeta meta) {
    var style = TextStyle(
        fontSize: widget.model.xaxis.labelsize ?? 8,
        color: Theme.of(context).colorScheme.outline);
    String text = value.toInt() < widget.model.uniqueValues.length &&
            widget.model.uniqueValues.isNotEmpty
        ? widget.model.uniqueValues.elementAt(value.toInt()).toString()
        : value.toString();
    // replace the value with the x value of the index[value] in the list of data points.
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
      angle: widget.model.xaxis.labelrotation,
      child: Text(text, style: style),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    var style = TextStyle(
        fontSize: widget.model.yaxis.labelsize ?? 8,
        color: Theme.of(context).colorScheme.outline);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      angle: widget.model.yaxis.labelrotation,
      fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
      child: Text(value.toString(), style: style, textAlign: TextAlign.center),
    );
  }

  BarChart buildChart(seriesData) {
    BarChart chart = BarChart(
      BarChartData(
        barGroups: widget.model.barDataList,
        minY: toDouble(widget.model.yaxis.min),
        maxY: toDouble(widget.model.yaxis.max),
        barTouchData: BarTouchData(
            touchCallback: onBarTouch,
            touchTooltipData:
                BarTouchTooltipData(getTooltipItem: getTooltipItems)),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(
            sideTitles: const SideTitles(showTitles: false),
            axisNameWidget: !isNullOrEmpty(widget.model.title)
                ? Text(
                    widget.model.title!,
                    style: const TextStyle(fontSize: 12),
                  )
                : null,
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
              axisNameWidget: !isNullOrEmpty(widget.model.yaxis.title)
                  ? Text(
                      widget.model.yaxis.title!,
                      style: const TextStyle(fontSize: 12),
                    )
                  : null,
              sideTitles: SideTitles(
                reservedSize: widget.model.yaxis.padding ?? 22,
                interval: toDouble(widget.model.yaxis.interval),
                showTitles: widget.model.yaxis.labelvisible,
                getTitlesWidget: leftTitles,
              )),
          bottomTitles: AxisTitles(
              axisNameWidget: !isNullOrEmpty(widget.model.xaxis.title)
                  ? Text(
                      widget.model.xaxis.title!,
                      style: const TextStyle(fontSize: 12),
                    )
                  : null,
              sideTitles: SideTitles(
                reservedSize: widget.model.xaxis.padding ?? 22,
                interval: toDouble(widget.model.xaxis.interval),
                showTitles: widget.model.xaxis.labelvisible,
                getTitlesWidget: bottomTitles,
              )),
          show: true,
        ),
      ),
    );

    return chart;
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
      chart = buildChart(widget.model.series);
      view = chart;
    } catch (e) {
      Log().exception(e, caller: 'bar_chart_view builder() ');
      view = const Center(child: Icon(Icons.add_chart));
    }

    // Prioritize chart ux interactions
    view = Listener(behavior: HitTestBehavior.opaque, child: view);
    view = SafeArea(child: view);
    children.insert(0, SafeArea(child: view));

    // add busy
    children.add(Center(child: busy));

    // Display children over chart
    view = Stack(children: children);

    // add margins
    view = addMargins(view);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.tightestOrDefault);

    // add margins around the entire widget
    view = addMargins(view);

    return view;
  }

  BarTooltipItem getTooltipItems(BarChartGroupData group, int groupIndex,
      BarChartRodData rod, int rodIndex) {
    return BarTooltipItem("${rod.fromY}, ${rod.toY}", const TextStyle());
  }

  void onBarTouch(FlTouchEvent event, BarTouchResponse? response) {
    bool exit = response?.spot == null;
    bool enter = !exit;

    if (enter) {
      List<IExtendedSeriesInterface> spots = [];
      var spot = response?.spot;

      if (spot?.touchedRodData is IExtendedSeriesInterface) {
        var item = spot!.touchedRodData as IExtendedSeriesInterface;

        // stacked item?
        if (spot.touchedRodData.rodStackItems.isNotEmpty) {
          item = spot.touchedRodData.rodStackItems.firstWhereOrNull((e) =>
                      e is IExtendedSeriesInterface && e.toY == spot.spot.y)
                  as IExtendedSeriesInterface? ??
              item;
        }
        spots.add(item);
      }

      // reponse.spot.offset is the top of the bar

      RenderBox? render = context.findRenderObject() as RenderBox?;
      Offset? point = event.localPosition;
      if (render != null && point != null) {
        point = render.localToGlobal(point);
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
      tooltip = null;
    } catch (e) {
      Log().exception(e);
    }
  }
}
