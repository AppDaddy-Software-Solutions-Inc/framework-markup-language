// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:community_charts_common/community_charts_common.dart';
import 'package:flutter/material.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/template/template.dart';
import 'package:fml/widgets/chart_painter/chart_model.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/busy/busy_view.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:charts_painter/chart.dart';
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


  
  Chart buildBarChart(seriesData){
    ChartData data = ChartData([seriesData], axisMax: 20, axisMin: 0);
    Chart chart = Chart(
        state: ChartState(data: data, itemOptions: BarItemOptions(barItemBuilder: (itemBuilderData) {
      // Setting the different color based if the item is from first or second list
      return BarItem(color: itemBuilderData.listIndex == 0 ? Colors.red : Colors.blue);
    }),

        ));

    return chart;
  }

  Chart buildLineChart(seriesData){
    ChartData data = ChartData([seriesData], axisMax: 20, axisMin: 0);
    Chart chart = Chart(
        state: ChartState(data: data,
          backgroundDecorations: [SparkLineDecoration(
          id: 'first_line_fill',
          smoothPoints: false,
          fill: false,
          lineColor: Theme.of(context)
              .colorScheme
              .secondary,
          listIndex: 0,
        ),], itemOptions:

        BubbleItemOptions( maxBarWidth: 5, bubbleItemBuilder: (itemBuilderData) {
          // Setting the different color based if the item is from first or second list
          return BubbleItem(color: itemBuilderData.listIndex == 0 ? Colors.red : Colors.blue);
        }),

        ));

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
