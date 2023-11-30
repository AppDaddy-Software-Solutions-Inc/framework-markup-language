// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/template/template.dart';
import 'package:fml/widgets/chart_painter/pie/pie_chart_model.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/busy/busy_view.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fml/widgets/widget/widget_state.dart';

/// Chart View
///
/// Builds a Chart View using [CHART.ChartModel], [SERIES.ChartSeriesModel], [AXIS.ChartAxisModel] and
/// [EXCERPT.Model] properties
class PieChartView extends StatefulWidget implements IWidgetView
{
  @override
  final PieChartModel model;
  PieChartView(this.model) : super(key: ObjectKey(model));

  @override
  State<PieChartView> createState() => _PieChartViewState();
}

class _PieChartViewState extends WidgetState<PieChartView>
{
  Future<Template>? template;
  Future<PieChartModel>? chartViewModel;
  BusyView? busy;
  OverlayEntry? tooltip;

  PieChart buildPieChart(seriesData)
  {
    PieChart chart = PieChart(widget.model.pieData);
    return chart;
  }

  @override
  didChangeDependencies()
  {
    super.didChangeDependencies();
    hideTooltip();
  }

  @override
  void didUpdateWidget(dynamic oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    hideTooltip();
  }

  @override
  dispose()
  {
    hideTooltip();
    super.dispose();
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

    try
    {
        view = buildPieChart(widget.model.series);
    } catch(e) {
      Log().exception(e, caller: 'chart_view builder() ');
      view = Center(child: Icon(Icons.add_chart));
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

  void showTooltip(List<Widget> views, double x, double y)
  {
    // remove old tooltip
    hideTooltip();

    // show new tooltip
    if (views.isNotEmpty)
    {
      tooltip = OverlayEntry(builder: (context) => Positioned(left: x, top: y, child: Column(children: views, mainAxisSize: MainAxisSize.min)));
      Overlay.of(context).insert(tooltip!);
    }
  }

  void hideTooltip()
  {
    // remove old tooltip
    try
    {
      tooltip?.remove();
      tooltip?.dispose();
    }
    catch(e){}
  }
}
