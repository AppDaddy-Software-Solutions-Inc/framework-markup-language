// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/helper/string.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/template/template.dart';
import 'package:fml/widgets/chart_painter/bar/bar_chart_model.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/busy/busy_view.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fml/widgets/widget/widget_state.dart';

/// Chart View
///
/// Builds a Chart View using [CHART.ChartModel], [SERIES.ChartSeriesModel], [AXIS.ChartAxisModel] and
/// [EXCERPT.Model] properties
class BarChartView extends StatefulWidget implements IWidgetView
{
  @override
  final BarChartModel model;
  BarChartView(this.model) : super(key: ObjectKey(model));

  @override
  State<BarChartView> createState() => _ChartViewState();
}

class _ChartViewState extends WidgetState<BarChartView>
{
  Future<Template>? template;
  Future<BarChartModel>? chartViewModel;
  BusyView? busy;

  Widget bottomTitles(double value, TitleMeta meta) {
    var style = TextStyle(fontSize: widget.model.xaxis.labelsize ?? 8, color: Theme.of(context).colorScheme.outline);
    String text = value.toInt() < widget.model.uniqueValues.length && widget.model.uniqueValues.isNotEmpty ? widget.model.uniqueValues.elementAt(value.toInt()).toString(): value.toString();
    // replace the value with the x value of the index[value] in the list of data points.
    return SideTitleWidget(
      axisSide: meta.axisSide,
      fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
      angle: widget.model.xaxis.labelrotation,
      child: Text(text, style: style),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    var style = TextStyle(fontSize: widget.model.yaxis.labelsize ?? 8, color: Theme.of(context).colorScheme.outline);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      angle: widget.model.yaxis.labelrotation,
      fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
      child: Text(value.toString(), style: style, textAlign: TextAlign.center),
    );
  }

  BarChart buildChart(seriesData){
    BarChart chart = BarChart(
      BarChartData(
        barGroups: widget.model.barDataList,
        minY: S.toDouble(widget.model.yaxis.min),
        maxY: S.toDouble(widget.model.yaxis.max),

        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false),  axisNameWidget: !S.isNullOrEmpty(widget.model.title) ? Text(widget.model.title!, style: TextStyle(fontSize: 12),): null,),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
              axisNameWidget: !S.isNullOrEmpty(widget.model.yaxis.title) ? Text(widget.model.yaxis.title!, style: TextStyle(fontSize: 12),): null,
              sideTitles: SideTitles(
                interval: S.toDouble(widget.model.yaxis.interval),
                showTitles: widget.model.yaxis.labelvisible,
                getTitlesWidget: leftTitles,
              )
          ),
          bottomTitles: AxisTitles(
              axisNameWidget: !S.isNullOrEmpty(widget.model.xaxis.title) ? Text(widget.model.xaxis.title!, style: TextStyle(fontSize: 12),): null,
              sideTitles: SideTitles(
                interval: S.toDouble(widget.model.xaxis.interval),
                showTitles: widget.model.xaxis.labelvisible,
                getTitlesWidget: bottomTitles,
              )
          ),
          show: true,
        ),
      ),
    );

    return chart;
  }

  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // Busy / Loading Indicator
    busy ??= BusyView(BusyModel(widget.model, visible: widget.model.busy, observable: widget.model.busyObservable));

    Widget? view;

    // get the children
    List<Widget> children = widget.model.inflate();

    try {
        view = buildChart(widget.model.series);
    } catch(e) {
      Log().exception(e, caller: 'bar_chart_view builder() ');
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