// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'dart:math';
import 'package:community_charts_flutter/community_charts_flutter.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/template/template.dart';
import 'package:fml/widgets/chart/chart_model.dart';
import 'package:fml/widgets/chart/series/chart_series_model.dart';
import 'package:fml/widgets/chart/axis/chart_axis_model.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/busy/busy_view.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart' as charts_flutter;
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:intl/intl.dart';

enum ChartType {
  TimeSeriesChart,
  BarChart,
  OrdinalComboChart,
  NumericComboChart,
  PieChart
}

/// Chart View
///
/// Builds a Chart View using [CHART.ChartModel], [SERIES.ChartSeriesModel], [AXIS.ChartAxisModel] and
/// [EXCERPT.Model] properties
class ChartView extends StatefulWidget implements IWidgetView
{
  @override
  final ChartModel model;
  ChartView(this.model) : super(key: ObjectKey(model));

  @override
  _ChartViewState createState() => _ChartViewState();
}

class _ChartViewState extends WidgetState<ChartView>
{
  Future<Template>? template;
  Future<ChartModel>? chartViewModel;
  BusyView? busy;
  ChartType? chartType;

  @override
  void initState()
  {
    super.initState();
    chartType = getChartType();
  }

  /// Identifies the chart type from the model attributes
  ///
  /// The logic needs to follow a specific ordinal flow here:
  ///  - Check for Date/Time Axis => [ChartType.TimeSeriesChart]
  ///  - Check if all Series are Bar Series => [ChartType.BarChart]
  ///  - Check if the type is `pie` => [ChartType.PieChart]
  ///  - Check if X axis is a Category or Numeric Axis
  ///   => [ChartType.OrdinalComboChart]
  ///   => [ChartType.NumericComboChart]
  ///  We don't support a fallback in the case your axis/series are unmatched
  ///  its important to show the data type syntax for template clarity
  ChartType? getChartType() {
    // This is a bit odd- time series needs to be identified first because if the
    // x axis is a date/time based axis you must use a TimeSeriesChart.
    // You can still have grouped bars in a TimeSeries but not in combo charts.
    // Check for pie type before letting the category axis determine a combo chart.
    if (widget.model.xaxis!.type == ChartAxisType.datetime ||
        widget.model.xaxis!.type == ChartAxisType.date ||
        widget.model.xaxis!.type == ChartAxisType.time) {
      // Determine if the X Axis is time based
      return ChartType.TimeSeriesChart;
    }

    ChartSeriesModel? nonBarSeries = widget.model.series.firstWhereOrNull((series) => series.type != 'bar');
    if (nonBarSeries == null) {
      // Exclusively BarSeries, can use BarChart
      return ChartType.BarChart;
    } else if (widget.model.type != null &&
        (widget.model.type!.toLowerCase() == 'pie' ||
            widget.model.type!.toLowerCase() == 'circle')) {
      return ChartType.PieChart;
    } else if (widget.model.xaxis!.type == ChartAxisType.category) {
      return ChartType.OrdinalComboChart;
    } else if (widget.model.xaxis!.type == ChartAxisType.numeric) {
      return ChartType.NumericComboChart;
    } else {
      Log().warning(
          'Unable to determine the type of chart required from model parameters');
      return null;
    }
  }

  charts_flutter.BarChart buildBarChart(List<charts_flutter.Series<dynamic, String>> series) {
    // Determine if there is any grouping and/or stacking (grouped/stacked/groupedStacked)
    charts_flutter.BarGroupingType barGroupingType;
    ChartSeriesModel seriesModel = widget.model.series[0];
    // Based on the series if the series have both a group and stack, or neither,
    // but are only a single series set bargrouping to groupedStacked

    if ((seriesModel.group != null && seriesModel.stack != null) ||
        (seriesModel.group == null &&
            seriesModel.stack == null &&
            series.length == 1)) {
      barGroupingType = charts_flutter.BarGroupingType.groupedStacked;
    } else if (seriesModel.group != null) {
      barGroupingType = charts_flutter.BarGroupingType.grouped;
    } else if (seriesModel.stack != null) {
      barGroupingType = charts_flutter.BarGroupingType.stacked;
    } else {
      barGroupingType = charts_flutter.BarGroupingType.grouped;
    }

    List<charts_flutter.SeriesRendererConfig<String>> seriesRenderers = [];
    for (var s in widget.model.series) {
      Function configFunc = getSeriesRenderer(s, widget.model.xaxis!.type)!;
      charts_flutter.SeriesRendererConfig<String> config = configFunc(s);
      seriesRenderers.add(config);
    }

    return charts_flutter.BarChart(
      series,
      animate: widget.model.animated,
      behaviors: getBehaviors<String>(),
      primaryMeasureAxis: charts_flutter.NumericAxisSpec(
          renderSpec: charts_flutter.GridlineRendererSpec(
              lineStyle: charts_flutter.LineStyleSpec(
        dashPattern: [4, 4],
      ))),
      domainAxis: charts_flutter.AxisSpec<String>(
        renderSpec: charts_flutter.SmallTickRendererSpec(
          axisLineStyle: charts_flutter.LineStyleSpec(
              color: charts_flutter.ColorUtil.fromDartColor(
                  Theme.of(context).colorScheme.onBackground)),
          labelStyle: charts_flutter.TextStyleSpec(
              color: charts_flutter.ColorUtil.fromDartColor(
                  Theme.of(context).colorScheme.onBackground)),
          labelRotation: widget.model.xaxis!.labelrotation.abs() * -1,
          labelOffsetFromAxisPx:
              (sin(widget.model.xaxis!.labelrotation.abs() * (pi / 180)) * 80)
                      .ceil() +
                  (widget.model.horizontal == true
                      ? 28
                      : 8), // 80 is rough estimate of our text length
        ),
      ),
      barGroupingType: barGroupingType,
      vertical: widget.model.horizontal == true ? false : true,
      barRendererDecorator: charts_flutter.BarLabelDecorator<String>(
          labelPosition: charts_flutter.BarLabelPosition.inside,
          labelAnchor: charts_flutter.BarLabelAnchor.middle),
      customSeriesRenderers: seriesRenderers,
      selectionModels: [
        charts_flutter.SelectionModelConfig(
          type: charts_flutter.SelectionModelType.info,
          changedListener: _onSelectionChanged,
        )
      ],
    );
  }

  charts_flutter.NumericComboChart buildNumericChart(List<charts_flutter.Series> series) {
    List<charts_flutter.SeriesRendererConfig<num>> seriesRenderers = [];
    for (var s in widget.model.series) {
      if (s.type == 'bar' && s.stack != null) {
        Log().warning(
            'Stacked Bar Series are only compatible with Category type X Axis and each series must be type="bar"');
      }
      Function configFunc = getSeriesRenderer(s, widget.model.xaxis!.type)!;
      charts_flutter.SeriesRendererConfig<num> config = configFunc(s);
      seriesRenderers.add(config);
    }
    return charts_flutter.NumericComboChart(
      series as List<Series<dynamic, num>>,
      animate: widget.model.animated,
      behaviors: getBehaviors<num>(),
      primaryMeasureAxis: charts_flutter.NumericAxisSpec(
          renderSpec: charts_flutter.GridlineRendererSpec(
              lineStyle: charts_flutter.LineStyleSpec(
        dashPattern: [4, 4],
      ))),
      domainAxis: charts_flutter.AxisSpec<num>(
        renderSpec: charts_flutter.SmallTickRendererSpec(
          axisLineStyle: charts_flutter.LineStyleSpec(
              color: charts_flutter.ColorUtil.fromDartColor(
                  Theme.of(context).colorScheme.onBackground)),
          labelStyle: charts_flutter.TextStyleSpec(
              color: charts_flutter.ColorUtil.fromDartColor(
                  Theme.of(context).colorScheme.onBackground)),
          labelRotation: widget.model.xaxis!.labelrotation.abs() * -1,
          labelOffsetFromAxisPx:
              (sin(widget.model.xaxis!.labelrotation.abs() * (pi / 180)) * 80)
                      .ceil() +
                  8, // 80 is rough estimate of our text length
        ),
      ),
      customSeriesRenderers: seriesRenderers,
      selectionModels: [
        charts_flutter.SelectionModelConfig(
          type: charts_flutter.SelectionModelType.info,
          changedListener: _onSelectionChanged,
        )
      ],
    );
  }

  charts_flutter.OrdinalComboChart buildOrdinalChart(List<charts_flutter.Series> series) {
    List<charts_flutter.SeriesRendererConfig<String>> seriesRenderers = [];
    for (var s in widget.model.series) {
      if (s.type == 'bar' && s.stack != null) {
        Log().warning(
            'Stacked Bar Series are only compatible with Category type X Axis and each series must be type="bar"');
      }
      Function configFunc = getSeriesRenderer(s, widget.model.xaxis!.type)!;
      charts_flutter.SeriesRendererConfig<String> config = configFunc(s);
      seriesRenderers.add(config);
    }
    return charts_flutter.OrdinalComboChart(
      series as List<Series<dynamic, String>>,
      animate: widget.model.animated,
      behaviors: getBehaviors<String>(),
      primaryMeasureAxis: charts_flutter.NumericAxisSpec(
          renderSpec: charts_flutter.GridlineRendererSpec(
              lineStyle: charts_flutter.LineStyleSpec(
        dashPattern: [4, 4],
      ))),
      domainAxis: charts_flutter.AxisSpec<String>(
        renderSpec: charts_flutter.SmallTickRendererSpec(
          axisLineStyle: charts_flutter.LineStyleSpec(
              color: charts_flutter.ColorUtil.fromDartColor(
                  Theme.of(context).colorScheme.onBackground)),
          labelStyle: charts_flutter.TextStyleSpec(
              color: charts_flutter.ColorUtil.fromDartColor(
                  Theme.of(context).colorScheme.onBackground)),
          labelRotation: widget.model.xaxis!.labelrotation.abs() * -1,
          labelOffsetFromAxisPx:
              (sin(widget.model.xaxis!.labelrotation.abs() * (pi / 180)) * 80)
                      .ceil() +
                  8, // 80 is rough estimate of our text length
        ),
      ),
      customSeriesRenderers: seriesRenderers,
      selectionModels: [
        charts_flutter.SelectionModelConfig(
          type: charts_flutter.SelectionModelType.info,
          changedListener: _onSelectionChanged,
        )
      ],
    );
  }

  charts_flutter.TimeSeriesChart buildTimeChart(List<charts_flutter.Series> series) {
    List<charts_flutter.SeriesRendererConfig<DateTime>> seriesRenderers = [];
    List<charts_flutter.TickSpec<DateTime>> ticks = [];
    SplayTreeMap<int, DateTime> ticksMap = SplayTreeMap<int, DateTime>();

    for (var s in widget.model.series) {
      if (s.type == 'bar' && s.stack != null) {
        Log().warning(
            'Stacked Bar Series are only compatible with Category type X Axis and each series must be type="bar"');
      }
      Function configFunc = getSeriesRenderer(s, widget.model.xaxis!.type)!;
      charts_flutter.SeriesRendererConfig<DateTime> config = configFunc(s);
      seriesRenderers.add(config);
      // Map all the x values for the ticks
      for (ChartDataPoint x in s.dataPoint) {
        DateTime? xDateTime = S.toDate(x.x);
        if (xDateTime != null) {
          int epoch = xDateTime.toUtc().millisecondsSinceEpoch;
          ticksMap[epoch] = xDateTime;
        } else {
          Log().warning(
              '${x.x.toString()} is not a DateTime value in the ${s.name.toString()} TimeSeries');
        }
      }
    }
    // Add all the mapped x values to the ticks list
    for (var v in ticksMap.values) {
      final DateFormat formatter =
          DateFormat(widget.model.xaxis!.format ?? 'yyyy/MM/dd');
      String? l;
      try {
        l = formatter.format(v);
      } catch(e) {}
      ticks.add(charts_flutter.TickSpec<DateTime>(v, label: l));
    }

    return charts_flutter.TimeSeriesChart(
      series as List<Series<dynamic, DateTime>>,
      animate: widget.model.animated,
      customSeriesRenderers: seriesRenderers,
      primaryMeasureAxis: charts_flutter.NumericAxisSpec(
          renderSpec: charts_flutter.GridlineRendererSpec(
              lineStyle: charts_flutter.LineStyleSpec(
        dashPattern: [4, 4],
      ))),
      behaviors: getBehaviors<DateTime>(),
      domainAxis: charts_flutter.DateTimeAxisSpec(
        renderSpec: charts_flutter.SmallTickRendererSpec(
          axisLineStyle: charts_flutter.LineStyleSpec(
              color: charts_flutter.ColorUtil.fromDartColor(
                  Theme.of(context).colorScheme.onBackground)),
          labelAnchor: charts_flutter.TickLabelAnchor.after,
          labelStyle: charts_flutter.TextStyleSpec(
              color: charts_flutter.ColorUtil.fromDartColor(
                  Theme.of(context).colorScheme.onBackground)),
          labelRotation: widget.model.xaxis!.labelrotation.abs() * -1,
          labelOffsetFromAxisPx:
              (sin(widget.model.xaxis!.labelrotation.abs() * (pi / 180)) * 80)
                      .ceil() +
                  8, // 80 is rough estimate of our text length
        ),
        tickProviderSpec: charts_flutter.StaticDateTimeTickProviderSpec(ticks),
      ),
      selectionModels: [
        charts_flutter.SelectionModelConfig(
          type: charts_flutter.SelectionModelType.info,
          changedListener: _onSelectionChanged,
        )
      ],
    );
  }

  charts_flutter.PieChart buildPieChart(List<charts_flutter.Series<dynamic, String>> series) {
    return charts_flutter.PieChart<String>(
      series,
      animate: widget.model.animated,
      behaviors: getBehaviors<String>(),
      defaultRenderer: charts_flutter.ArcRendererConfig(arcRendererDecorators: [
        charts_flutter.ArcLabelDecorator(labelPosition: charts_flutter.ArcLabelPosition.auto)
      ]),
      selectionModels: [
        charts_flutter.SelectionModelConfig(
          type: charts_flutter.SelectionModelType.info,
          changedListener: _onSelectionChanged,
        )
      ],
    );
  }

  /// Series Builder
  List<charts_flutter.Series>? buildSeriesList() {
    // Setup a list of series for each X Axis type
    List<charts_flutter.Series<dynamic, DateTime>> timeSeriesList = [];
    List<charts_flutter.Series<dynamic, num>> numericSeriesList = [];
    List<charts_flutter.Series<dynamic, String>> categorySeriesList = [];
    if (widget.model.xaxis == null || widget.model.yaxis == null) {
      Log().error(
          'Unable to build series list because of a null axis, x: ${widget.model.xaxis.toString()} y: ${widget.model.yaxis.toString()}');
      return null;
    }
    bool pureBar = false;

    ChartSeriesModel? nonBarSeries =
        widget.model.series.firstWhereOrNull((series) => series.type != 'bar');
    if (nonBarSeries == null) {
      pureBar = true;
    }
    // Loop through each series
    for (ChartSeriesModel series in widget.model.series) {
      // Auto group bar series if not specified
      if ((series.stack == null ||
              widget.model.xaxis!.type != ChartAxisType.category) &&
          series.group == null &&
          pureBar == true) series.group = 'defaultgrouping';
      // Build the data points
      List<ChartDataPoint> seriesData = [];
      bool xAllNull = true;
      bool yAllNull = true;
      // Loop through each point
      for (ChartDataPoint point in series.dataPoint) {
        // Parse x and y data values from the databroker string values
        if (!S.isNullOrEmpty(point.x)) {
          // y value can be null, creating a gap in the chart
          var xParsed;
          var yParsed;
          try {
            xParsed = parsePlotPoint(point.x, widget.model.xaxis!.type);
          } catch(e) {
            Log().error(
                'Unable to parse X axis plot point, chart id: ${widget.model.id.toString()} - series name: ${series.name.toString()} - $e');
            break;
          }
          try {
            yParsed = S.isNullOrEmpty(point.y)
                ? null
                : parsePlotPoint(point.y, widget.model.yaxis!.type);
          } catch(e) {
            Log().error(
                'Unable to parse Y axis plot point, chart id: ${widget.model.id.toString()} - series name: ${series.name.toString()} - $e');
            break;
          }
          // Parsed Values
          var xVal = xParsed;
          var yVal = yParsed;
          // Null Series Point Check
          if (xAllNull == true) xAllNull = xVal == null;
          if (yAllNull == true) yAllNull = yVal == null;
          // get label
          var label = S.isNullOrEmpty(point.label) ? null : point.label.trim();
          // Add to point list
          if (xVal != null && (series.labelled != true || label != null)) {
            seriesData.add(ChartDataPoint(
                x: xVal, y: yVal, color: point.color, label: label));
          }
          if (xVal == null) {
            Log().warning(
                'id: ${series.id.toString()} name: ${series.name.toString()} Has a null X value, only Y vals can be null, every point must have a non-null X value');
          }
        }
      }

      // Null Series Warning
      //if (xAllNull) Log().warning('id: ${series.id.toString()} name: ${series.name.toString()} X values are all null');
      //if (yAllNull) Log().warning('id: ${series.id.toString()} name: ${series.name.toString()} Y values are all null');

      switch (widget.model.xaxis!.type) {
        // Date/Time based X Axis
        case ChartAxisType.datetime:
        case ChartAxisType.date:
        case ChartAxisType.time:
          timeSeriesList.add(charts_flutter.Series(
              id: series.id,
              displayName: series.name ?? series.id,
              // seriesCategory: series.stack,
              areaColorFn: (dynamic plot, _) => charts_flutter.ColorUtil.fromDartColor(
                  (plot.color ?? series.color)?.withOpacity(0.1) ??
                      Colors.black12),
              colorFn: (dynamic plot, _) => charts_flutter.ColorUtil.fromDartColor(
                  plot.color ??
                      series.color ??
                      (ColorObservable.niceColors.length > _!
                          ? ColorObservable.niceColors[_]!
                          : Colors.black)),
              domainFn: (dynamic plot, _) => plot.x,
              measureFn: (dynamic plot, _) => plot.y,
              labelAccessorFn: (dynamic plot, _) =>
                  '${plot.label ?? (plot.y > 0 ? plot.y : '')}', // Unavailable outside of pie/bar charts
              data: seriesData)
            ..setAttribute(charts_flutter.rendererIdKey, getRendererKey(series)));
          break;
        // Numeric based X axis
        case ChartAxisType.numeric:
          numericSeriesList.add(charts_flutter.Series(
              id: series.id,
              displayName: series.name ?? series.id,
              // seriesCategory: series.stack,
              areaColorFn: (dynamic plot, _) => charts_flutter.ColorUtil.fromDartColor(
                  (plot.color ?? series.color)?.withOpacity(0.1) ??
                      Colors.black12),
              colorFn: (dynamic plot, _) => charts_flutter.ColorUtil.fromDartColor(
                  plot.color ??
                      series.color ??
                      (ColorObservable.niceColors.length > _!
                          ? ColorObservable.niceColors[_]!
                          : Colors.black)),
              domainFn: (dynamic plot, _) => plot.x,
              measureFn: (dynamic plot, _) => plot.y,
              labelAccessorFn: (dynamic plot, _) =>
                  '${plot.label ?? (plot.y > 0 ? plot.y : '')}', // Unavailable outside of pie/bar charts
              data: seriesData)
            ..setAttribute(charts_flutter.rendererIdKey, getRendererKey(series)));
          break;
        // Category/String based X axis
        case ChartAxisType.category:
          categorySeriesList.add(charts_flutter.Series(
              id: series.id,
              displayName: series.name ?? series.id,
              seriesCategory: series.stack,
              areaColorFn: (dynamic plot, _) => charts_flutter.ColorUtil.fromDartColor(
                  (plot.color ?? series.color)?.withOpacity(0.1) ??
                      Colors.black12),
              colorFn: (dynamic plot, _) => charts_flutter.ColorUtil.fromDartColor(
                  plot.color ??
                      series.color ??
                      (ColorObservable.niceColors.length > _!
                          ? ColorObservable.niceColors[_]!
                          : Colors.black)),
              domainFn: (dynamic plot, _) => plot.x,
              measureFn: (dynamic plot, _) => plot.y,
              labelAccessorFn: (dynamic plot, _) =>
                  '${plot.label ?? (plot.y > 0 ? plot.y : '')}', // Unavailable outside of pie/bar charts
              data: seriesData)
            ..setAttribute(charts_flutter.rendererIdKey, getRendererKey(series)));
          break;
        default:
          Log().warning(
              'Unable to determine Chart Series for id: ${widget.model.id}');
          break;
      }
    }
    // We return the series of the correct data type here
    switch (widget.model.xaxis!.type) {
      case ChartAxisType.datetime:
      case ChartAxisType.date:
      case ChartAxisType.time:
        return timeSeriesList;
      case ChartAxisType.numeric:
        return numericSeriesList;
      case ChartAxisType.category:
        return categorySeriesList;
      default:
        return null;
    }
  }

  /// Unique id for each series based off the FML id, fallback on the name attribute
  /// Importantly bar charts that have a group attribute must share the same render key
  String? getRendererKey(ChartSeriesModel series) {
    if (chartType == ChartType.BarChart || chartType == ChartType.PieChart) {
      return null;
    }
    return (series.type == 'bar' ? series.group : null) ?? series.id;
  }

  /// Parser for databroker data to convert it from a String to appropriate data type for the axis
  dynamic parsePlotPoint(String? val, ChartAxisType type) {
    if (type == ChartAxisType.category) {
      return val;
    } else if (type == ChartAxisType.numeric) {
      return num.tryParse(val!) ?? 0;
    } else if (type == ChartAxisType.date ||
        type == ChartAxisType.time ||
        type == ChartAxisType.datetime) {
      DateTime? formatted;
      formatted = S.toDate(val); //, format: 'yMd Hm');
      return formatted; //DateTime.tryParse(val);
    }
  }

  /// Each series needs a specific type of renderer, this method passes back a
  /// function that builds the specific type needed with the correct attributes
  Function? getSeriesRenderer(ChartSeriesModel series, ChartAxisType type) {
    dynamic rendererConfig;
    // if (chartType == ChartType.BarChart)
    //   type = 'category';
    switch (series.type) {
      case 'bar':
        if (type == ChartAxisType.category) {
          rendererConfig = buildCategoryBarRenderer;
        } else if (type == ChartAxisType.datetime ||
            type == ChartAxisType.date ||
            type == ChartAxisType.time) {
          rendererConfig = buildDateTimeBarRenderer;
        } else if (type == ChartAxisType.numeric) {
          rendererConfig = buildNumericBarRenderer;
        }
        break;
      case 'line':
        if (type == ChartAxisType.category) {
          rendererConfig = buildCategoryLineRenderer;
        } else if (type == ChartAxisType.datetime ||
            type == ChartAxisType.date ||
            type == ChartAxisType.time) {
          rendererConfig = buildDateTimeLineRenderer;
        } else if (type == ChartAxisType.numeric) {
          rendererConfig = buildNumericLineRenderer;
        }
        break;
      case 'point':
        if (type == ChartAxisType.category) {
          rendererConfig = buildCategoryPointRenderer;
        } else if (type == ChartAxisType.datetime ||
            type == ChartAxisType.date ||
            type == ChartAxisType.time) {
          rendererConfig = buildDateTimePointRenderer;
        } else if (type == ChartAxisType.numeric) {
          rendererConfig = buildNumericPointRenderer;
        }
        break;
    }
    return rendererConfig;
  }

  charts_flutter.SeriesRendererConfig<String> buildCategoryBarRenderer(
      ChartSeriesModel series) {
    return charts_flutter.BarRendererConfig(
      customRendererId: series.group ?? series.id,
    );
  }

  charts_flutter.SeriesRendererConfig<DateTime> buildDateTimeBarRenderer(
      ChartSeriesModel series) {
    return charts_flutter.BarRendererConfig(customRendererId: series.group ?? series.id);
  }

  charts_flutter.SeriesRendererConfig<num> buildNumericBarRenderer(
      ChartSeriesModel series) {
    return charts_flutter.BarRendererConfig(
      customRendererId: series.group ?? series.id,
    );
  }

  charts_flutter.SeriesRendererConfig<String> buildCategoryLineRenderer(
      ChartSeriesModel series) {
    return charts_flutter.LineRendererConfig(
        customRendererId: series.id,
        includeLine: series.showline,
        includePoints: series.showpoints,
        includeArea: series.showarea,
        radiusPx: series.radius,
        strokeWidthPx: series.stroke ?? 2);
  }

  charts_flutter.SeriesRendererConfig<DateTime> buildDateTimeLineRenderer(
      ChartSeriesModel series) {
    return charts_flutter.LineRendererConfig(
        customRendererId: series.id,
        includeLine: series.showline,
        includePoints: series.showpoints,
        includeArea: series.showarea,
        radiusPx: series.radius,
        strokeWidthPx: series.stroke ?? 2);
  }

  charts_flutter.SeriesRendererConfig<num> buildNumericLineRenderer(
      ChartSeriesModel series) {
    return charts_flutter.LineRendererConfig(
        customRendererId: series.id,
        includeLine: series.showline,
        includePoints: series.showpoints,
        includeArea: series.showarea,
        radiusPx: series.radius,
        strokeWidthPx: series.stroke ?? 2);
  }

  charts_flutter.SeriesRendererConfig<String> buildCategoryPointRenderer(
      ChartSeriesModel series) {
    return charts_flutter.PointRendererConfig(
        customRendererId: series.id,
        radiusPx: series.radius,
        strokeWidthPx: series.stroke ?? 0);
  }

  charts_flutter.SeriesRendererConfig<DateTime> buildDateTimePointRenderer(
      ChartSeriesModel series) {
    return charts_flutter.PointRendererConfig(
        customRendererId: series.id,
        radiusPx: series.radius,
        strokeWidthPx: series.stroke ?? 0);
  }

  charts_flutter.SeriesRendererConfig<num> buildNumericPointRenderer(
      ChartSeriesModel series) {
    return charts_flutter.PointRendererConfig(
        customRendererId: series.id,
        radiusPx: series.radius,
        strokeWidthPx: series.stroke ?? 0);
  }

  /// Event called when a point selection changes
  _onSelectionChanged(charts_flutter.SelectionModel model) {
    final selectedDatum = model.selectedDatum;

    dynamic domain;
    dynamic selectedSeriesId;

    // We get the model that updated with a list of [SeriesDatum] which is
    // simply a pair of series & datum.
    if (selectedDatum.isNotEmpty) {
      try {
        domain = selectedDatum.first.datum.x;
        selectedSeriesId = selectedDatum.first.series.id;
        // measure = selectedDatum.first.datum.y; // Not accurate with multi series as it doesn't know which series you selected
        // Get the series model by matching to the selected series id
        ChartSeriesModel? selectedSeries = widget.model.series
            .firstWhereOrNull((s) => s.id == selectedSeriesId);
        if (selectedSeries != null && selectedDatum.isNotEmpty){
          // Loop through the selected series datum
          for (int i = 0; i < selectedDatum[0].series.data.length; i++) {
            // Match the selected x value to the selected series, set the
            //model.selected observable for binding to the data point and stop looping
            if (selectedDatum[0].series.data[i].x == domain) {
              Map seriesData = selectedSeries.data[i];
              // We also add the series id to the data set
              seriesData['series'] = selectedSeriesId;
              widget.model.selected = seriesData;
              break;
            }
          }}
      } catch(e) {
        Log().warning(
            'Unable to set Chart Series Point selection$e');
      }
    }
    // print('Approximate Series Clicked on [${selectedSeriesId}]: x: ${domain.toString()}, y: ${measure.toString()}'); // Only works for single series
    // measures.forEach((key, value) {
    //   print('key: ${key.toString()}, x: ${domain.toString()}, y: ${measure.toString()}');
    // });
    // print(widget.model.selected[0]?.join(','));
  }

  /// Returns additional chart behaviors based on model settings
  List<charts_flutter.ChartBehavior<T>> getBehaviors<T>() {
    List<charts_flutter.ChartBehavior<T>> behaviors = [];
    if (chartType != ChartType.PieChart) behaviors.add(charts_flutter.PanAndZoomBehavior());
    if (widget.model.showlegend != 'false' && chartType != ChartType.PieChart) {
      behaviors.add(
          charts_flutter.SeriesLegend(position: legendPosition(widget.model.showlegend,),
              entryTextStyle: charts_flutter.TextStyleSpec(
              color: charts_flutter.Color.fromHex(code: '#${Theme.of(context).colorScheme.onBackground.value.toRadixString(16).toString().substring(2)}'),
    ),
          ));
    }
    if (widget.model.showlegend != 'false' && chartType == ChartType.PieChart) {
      behaviors.add(charts_flutter.DatumLegend(
        position: legendPosition(widget.model.showlegend),
        entryTextStyle: charts_flutter.TextStyleSpec(
          color: charts_flutter.Color.fromHex(code: '#${Theme.of(context).colorScheme.onBackground.value.toRadixString(16).toString().substring(2)}'),
        ),
        outsideJustification: charts_flutter.OutsideJustification.middleDrawArea,
        horizontalFirst: true,
        desiredMaxColumns: 4,
        cellPadding: EdgeInsets.only(right: 4.0, bottom: 4.0),
      ));
    }
    if (widget.model.xaxis!.title != null) {
      behaviors.add(charts_flutter.ChartTitle(widget.model.xaxis!.title!,
          titleStyleSpec: charts_flutter.TextStyleSpec(
            color: charts_flutter.Color.fromHex(code: '#${Theme.of(context).colorScheme.onBackground.value.toRadixString(16).toString().substring(2)}'),
          ),
          behaviorPosition: widget.model.horizontal == true
              ? charts_flutter.BehaviorPosition.start
              : charts_flutter.BehaviorPosition.bottom,
          titleOutsideJustification: charts_flutter.OutsideJustification.middleDrawArea));
    }
    if (widget.model.yaxis!.title != null) {
      behaviors.add(charts_flutter.ChartTitle(widget.model.yaxis!.title!,
          titleStyleSpec: charts_flutter.TextStyleSpec(
            color: charts_flutter.Color.fromHex(code: '#${Theme.of(context).colorScheme.onBackground.value.toRadixString(16).toString().substring(2)}'),
          ),
          behaviorPosition: widget.model.horizontal == true
              ? charts_flutter.BehaviorPosition.bottom
              : charts_flutter.BehaviorPosition.start,
          titleOutsideJustification: charts_flutter.OutsideJustification.middleDrawArea));
    }
    return behaviors;
  }

  // Gets the legend position based on the model string
  charts_flutter.BehaviorPosition legendPosition(String? pos) {
    switch (pos) {
      case 'left':
      case 'start':
        return charts_flutter.BehaviorPosition.start;
      case 'right':
      case 'end':
        return charts_flutter.BehaviorPosition.end;
      case 'top':
        return charts_flutter.BehaviorPosition.top;
      case 'bottom':
      case 'true':
      default:
        return charts_flutter.BehaviorPosition.bottom;
    }
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

    chartType = getChartType();
    List<charts_flutter.Series>? series = buildSeriesList();

    switch (chartType) {
      case ChartType.BarChart:
        view = buildBarChart(series as List<Series<dynamic, String>>);
        break;
      case ChartType.NumericComboChart:
        view = buildNumericChart(series!);
        break;
      case ChartType.OrdinalComboChart:
        view = buildOrdinalChart(series!);
        break;
      case ChartType.PieChart:
        view = buildPieChart((series as List<charts_flutter.Series<dynamic, String>>));
        break;
      case ChartType.TimeSeriesChart:
        view = buildTimeChart(series!);
        break;
      default:
        view = Icon(Icons.add_chart);
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
    view = applyConstraints(view, widget.model.constraints.tightestOrDefault);

    return view;
  }
}
