// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/helper/string.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/template/template.dart';
import 'package:fml/widgets/chart_painter/series/chart_series_model.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
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
class LineChartView extends StatefulWidget implements IWidgetView
{
  @override
  final LineChartModel model;
  LineChartView(this.model) : super(key: ObjectKey(model));

  @override
  State<LineChartView> createState() => _LineChartViewState();
}

class _LineChartViewState extends WidgetState<LineChartView>
{
  Future<Template>? template;
  Future<LineChartModel>? chartViewModel;
  BusyView? busy;

  Widget bottomTitles(double value, TitleMeta meta) {
    var style = TextStyle(fontSize: 8, color: Theme.of(context).colorScheme.outline);
    //int? index = S.toInt(value);
    String text = "";
    if(widget.model.xaxis.type == 'date') {
      text = DateFormat(widget.model.xaxis.format ?? 'yyyy/MM/dd').format(DateTime.fromMillisecondsSinceEpoch(value.toInt())).toString();
    } else if (widget.model.xaxis.type == 'category' || widget.model.xaxis.type == 'raw'){
      text = value.toInt() <= widget.model.uniqueValues.length && widget.model.uniqueValues.isNotEmpty ? widget.model.uniqueValues.elementAt(value.toInt()).toString(): value.toString();
    } else {
      text = value.toString();
    }
      // replace the value with the x value of the index[value] in the list of data points.
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(text, style: style),
        angle: 0.30,
      );
    }

  Widget leftTitles(double value, TitleMeta meta) {
    var style = TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.outline);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
      child: Text(value.toString(), style: style, textAlign: TextAlign.center),
    );
  }

  //Comes in as list of series
  LineChart buildLineChart(List<ChartPainterSeriesModel> seriesData){

    LineChart chart = LineChart(
      LineChartData(
        lineBarsData: widget.model.lineDataList,
        //the series must determine the min and max y
        minY: S.toDouble(widget.model.yaxis.min),
        maxY: S.toDouble(widget.model.yaxis.max),
        minX: S.toDouble(widget.model.xaxis.min),
        maxX: S.toDouble(widget.model.xaxis.max),
        borderData: FlBorderData(
          show: true,
        ),
        gridData: const FlGridData(
          show: true,
        ),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
              axisNameWidget: !S.isNullOrEmpty(widget.model.yaxis.title) ? Text(widget.model.yaxis.title!, style: TextStyle(fontSize: 12),): null,
              sideTitles: SideTitles(
                interval: S.toDouble(widget.model.yaxis.interval),
                reservedSize: 24,
                showTitles: true,
                getTitlesWidget: leftTitles,
              )
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: !S.isNullOrEmpty(widget.model.xaxis.title) ? Text(widget.model.xaxis.title!, style: TextStyle(fontSize: 12),): null,
              sideTitles: SideTitles(
                interval: widget.model.xaxis.type == 'category' || widget.model.xaxis.type == 'raw' ? 1 : S.toDouble(widget.model.xaxis.interval),
                showTitles: true,
                reservedSize: 24,
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
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // save system constraints
    onLayout(constraints);

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // Busy / Loading Indicator
    busy ??= BusyView(BusyModel(widget.model, visible: widget.model.busy, observable: widget.model.busyObservable));

    Widget? view;

    // get the children
    List<Widget> children = widget.model.inflate();

    try {
        view = buildLineChart(widget.model.series);
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
