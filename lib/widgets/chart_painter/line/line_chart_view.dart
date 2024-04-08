// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/template/template.dart';
import 'package:fml/widgets/chart_painter/series/chart_series_extended.dart';
import 'package:fml/widgets/chart_painter/series/chart_series_model.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/busy/busy_view.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:intl/intl.dart';
import 'line_chart_model.dart';

/// Chart View
///
/// Builds a Chart View using [CHART.ChartModel], [SERIES.ChartSeriesModel], [AXIS.ChartAxisModel] and
/// [EXCERPT.Model] properties
class LineChartView extends StatefulWidget implements IWidgetView {
  @override
  final LineChartModel model;
  LineChartView(this.model) : super(key: ObjectKey(model));

  @override
  State<LineChartView> createState() => _LineChartViewState();
}

class _LineChartViewState extends WidgetState<LineChartView> {
  Future<Template>? template;
  Future<LineChartModel>? chartViewModel;
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

  Widget bottomTitles(double value, TitleMeta meta) {
    var style = TextStyle(
        fontSize: widget.model.xaxis.labelsize ?? 8,
        color: Theme.of(context).colorScheme.outline);
    //int? index = toInt(value);
    String text = "";
    if (widget.model.xaxis.type == 'date') {
      try {
        text = DateFormat(widget.model.xaxis.format ?? 'yyyy/MM/dd')
            .format(DateTime.fromMillisecondsSinceEpoch(value.toInt()))
            .toString();
      } catch (e) {
        Log().exception(
            'Error formatting date when creating bottom titles widget');
      }
    } else if (widget.model.xaxis.type == 'category' ||
        widget.model.xaxis.type == 'raw') {
      text = value.toInt() <= widget.model.uniqueValues.length &&
              widget.model.uniqueValues.isNotEmpty
          ? widget.model.uniqueValues.elementAt(value.toInt()).toString()
          : value.toString();
    } else {
      text = value.toString();
    }
    // replace the value with the x value of the index[value] in the list of data points.
    return SideTitleWidget(
      axisSide: meta.axisSide,
      fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
      angle: 0.30,
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
      fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
      child: Text(value.toString(), style: style, textAlign: TextAlign.center),
    );
  }

  //Comes in as list of series
  LineChart buildLineChart(List<ChartPainterSeriesModel> seriesData) {
    LineChart chart = LineChart(
      LineChartData(
        lineBarsData: widget.model.lineDataList,
        lineTouchData: LineTouchData(
            touchCallback: onLineTouch,
            touchTooltipData:
                LineTouchTooltipData(getTooltipItems: getTooltipItems)),

        //the series must determine the min and max y
        minY: toDouble(widget.model.yaxis.min),
        maxY: toDouble(widget.model.yaxis.max),
        minX: toDouble(widget.model.xaxis.min),
        maxX: toDouble(widget.model.xaxis.max),
        borderData: FlBorderData(
          show: true,
        ),
        gridData: const FlGridData(
          show: true,
        ),
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
                interval: toDouble(widget.model.yaxis.interval),
                reservedSize: widget.model.yaxis.padding ?? 22,
                showTitles: true,
                //getTitlesWidget: leftTitles,
              )),
          bottomTitles: AxisTitles(
              axisNameWidget: !isNullOrEmpty(widget.model.xaxis.title)
                  ? Text(
                      widget.model.xaxis.title!,
                      style: const TextStyle(fontSize: 12),
                    )
                  : null,
              sideTitles: SideTitles(
                interval: widget.model.xaxis.type == 'category' ||
                        widget.model.xaxis.type == 'raw'
                    ? 1
                    : toDouble(widget.model.xaxis.interval),
                showTitles: true,
                reservedSize: widget.model.xaxis.padding ?? 22,
                getTitlesWidget: bottomTitles,
              )),
          show: true,
        ),
      ),
    );
    return chart;
  }

  void onLineTouch(FlTouchEvent event, LineTouchResponse? response) {
    bool exit = (response?.lineBarSpots?.isEmpty ?? true) ||
        event is FlPointerExitEvent;
    bool enter = !exit;

    if (enter) {
      List<IExtendedSeriesInterface> spots = [];
      for (var spot in response!.lineBarSpots!) {
        var mySpot = spot.bar.spots[spot.spotIndex];
        if (mySpot is IExtendedSeriesInterface) {
          spots.add(mySpot as IExtendedSeriesInterface);
        }
      }

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

  List<LineTooltipItem> getTooltipItems(List<LineBarSpot> touchedSpots) {
    List<LineTooltipItem> tooltips = [];
    var showTips = false;
    for (var spot in touchedSpots) {
      var mySpot = spot.bar.spots[spot.spotIndex];
      if (mySpot is FlSpotExtended && mySpot.series.tooltips) showTips = true;

      tooltips.add(LineTooltipItem("${spot.y}", const TextStyle()));
    }
    if (!showTips) tooltips.clear();
    return tooltips;
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
      view = buildLineChart(widget.model.series);
    } catch (e) {
      Log().exception(e, caller: 'chart_view builder() ');
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
}
