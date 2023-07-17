// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/template/template.dart';
import 'package:fml/widgets/chart_painter/chart_model.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/busy/busy_view.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fml/widgets/widget/widget_state.dart';

enum ChartType {
  timeSeriesChart,
  barChart,
  ordinalComboChart,
  numericComboChart,
  pieChart
}

/// Chart View
///
/// Builds a Chart View using [CHART.ChartModel], [SERIES.ChartSeriesModel], [AXIS.ChartAxisModel] and
/// [EXCERPT.Model] properties
class ChartView extends StatefulWidget implements IWidgetView
{
  @override
  final ChartPainterModel model;
  ChartView(this.model) : super(key: ObjectKey(model));

  @override
  State<ChartView> createState() => _ChartViewState();
}

class _ChartViewState extends WidgetState<ChartView>
{
  Future<Template>? template;
  Future<ChartPainterModel>? chartViewModel;
  BusyView? busy;
  ChartType? chartType;

  @override
  void initState()
  {
    super.initState();
  }



  BarChart buildBarChart(seriesData){
    List<BarChartGroupData> data = [BarChartGroupData(x: 0, barRods: seriesData)];
    BarChart chart = BarChart(
      BarChartData(
        barGroups: data,
        minY: 0,
        maxY: 20,
        rangeAnnotations: RangeAnnotations(),
        borderData: FlBorderData(
          show: true,
        ),
        gridData: const FlGridData(
          show: true,
        ),
        titlesData: const FlTitlesData(
          show: false,
        ),
      ),
    );

    return chart;
  }

  LineChart buildLineChart(List<FlSpot> seriesData){
    List<LineChartBarData> data = [
      LineChartBarData(
        spots: seriesData)];
    LineChart chart = LineChart(
      LineChartData(
        lineBarsData: data,
        minY: 0,
        maxY: 20,
        //range annotations (blocks)
        rangeAnnotations: RangeAnnotations(horizontalRangeAnnotations: [], verticalRangeAnnotations: []),
        borderData: FlBorderData(
          show: true,
        ),
        gridData: const FlGridData(
          show: true,
        ),
        titlesData: const FlTitlesData(
          //righttitles shows on left side? lefttitles shows on right side
          rightTitles: AxisTitles(),
          bottomTitles: AxisTitles(),
          show: true,
        ),
      ),
    );

    return chart;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // save system constraints
    onLayout(constraints);

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // Busy / Loading Indicator
    busy ??= BusyView(BusyModel(widget.model, visible: widget.model.busy, observable: widget.model.busyObservable));

    Widget view;

    // get the children
    List<Widget> children = widget.model.inflate();

    try {
     widget.model.series[0].dataPoint.sort((a, b) => a.x.compareTo(b.x));
     view = buildLineChart(widget.model.series[0].dataPoint);
    } catch(e) {
      Log().exception(e, caller: 'chart_view builder() ');
      view = Center(child: Icon(Icons.add_chart));
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

    return view;
  }
}
