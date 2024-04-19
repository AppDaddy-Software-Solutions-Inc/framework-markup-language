// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'dart:math';
import 'package:community_charts_common/community_charts_common.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/helpers/time.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/template/template.dart';
import 'package:fml/widgets/chart/chart_model.dart';
import 'package:fml/widgets/chart/label/chart_label_model.dart';
import 'package:fml/widgets/chart/series/chart_series_model.dart';
import 'package:fml/widgets/chart/axis/chart_axis_model.dart';
import 'package:fml/widgets/viewable/viewable_widget_view.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts_flutter;
import 'package:fml/widgets/viewable/viewable_widget_state.dart';

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
class ChartView extends StatefulWidget implements ViewableWidgetView {
  @override
  final ChartModel model;
  ChartView(this.model) : super(key: ObjectKey(model));

  @override
  State<ChartView> createState() => _ChartViewState();
}

class _ChartViewState extends ViewableWidgetState<ChartView> {
  Future<Template>? template;
  Future<ChartModel>? chartViewModel;
  Widget? busy;
  ChartType? chartType;

  @override
  void initState() {
    super.initState();
    chartType = getChartType();
  }

  /// Identifies the chart type from the model attributes
  ///
  /// The logic needs to follow a specific ordinal flow here:
  ///  - Check for Date/Time Axis => [ChartType.timeSeriesChart]
  ///  - Check if all Series are Bar Series => [ChartType.BarChart]
  ///  - Check if the type is `pie` => [ChartType.pieChart]
  ///  - Check if X axis is a Category or Numeric Axis
  ///   => [ChartType.ordinalComboChart]
  ///   => [ChartType.numericComboChart]
  ///  We don't support a fallback in the case your axis/series are unmatched
  ///  its important to show the data type syntax for template clarity
  ChartType? getChartType() {
    ChartSeriesModel? pieSeries = widget.model.series.firstWhereOrNull(
        (series) =>
            series.type?.toLowerCase() == 'pie' ||
            series.type?.toLowerCase() == 'circle');
    ChartSeriesModel? nonBarSeries =
        widget.model.series.firstWhereOrNull((series) => series.type != 'bar');
    ChartSeriesModel? stackedSeries = widget.model.series.firstWhereOrNull(
        (series) => series.type == 'bar' && series.stack != null);
    if (pieSeries != null ||
        widget.model.type != null &&
            (widget.model.type!.toLowerCase() == 'pie' ||
                widget.model.type!.toLowerCase() == 'circle')) {
      return ChartType.pieChart;
    } else if (stackedSeries == null &&
        (widget.model.xaxis.type == ChartAxisType.datetime ||
            widget.model.xaxis.type == ChartAxisType.date ||
            widget.model.xaxis.type == ChartAxisType.time)) {
      // Determine if the X Axis is time based, timebased charts override other base chart types.
      //
      // Bar charts cannot have a timeSeries axis if they are stacked/grouped&stacked,
      // they will be converted to category axis and built as BarCharts in that case.
      return ChartType.timeSeriesChart;
    } else if (nonBarSeries == null) {
      // Aside from BarCharts built as timeSeriesCharts all other barcharts must be a
      // String (category) x axis as per the library restriction on series value type.
      if (widget.model.xaxis.type != ChartAxisType.category) {
        widget.model.xaxis.type = ChartAxisType.category;
      }
      return ChartType.barChart;
    } else if (widget.model.xaxis.type == ChartAxisType.category) {
      return ChartType.ordinalComboChart;
    } else if (widget.model.xaxis.type == ChartAxisType.numeric) {
      return ChartType.numericComboChart;
    } else {
      Log().warning(
          'Unable to determine the type of chart required from model parameters');
      return null;
    }
  }

  /// Measure/Y Axis Specifications
  charts_flutter.NumericAxisSpec yNumericAxisSpec({int? ticks}) =>
      charts_flutter.NumericAxisSpec(
        tickProviderSpec: charts_flutter.BasicNumericTickProviderSpec(
            zeroBound: !widget.model.yaxis.truncate,
            dataIsInWholeNumbers: true,
            desiredTickCount: ticks),
        viewport:
            widget.model.yaxis.min != null && widget.model.yaxis.max != null
                ? charts_flutter.NumericExtents(toNum(widget.model.yaxis.min!)!,
                    toNum(widget.model.yaxis.max!)!)
                : null,
        renderSpec: charts_flutter.SmallTickRendererSpec(
          // GridlineRendererSpec(
          tickLengthPx: 4,
          lineStyle: const charts_flutter.LineStyleSpec(dashPattern: []),
          labelStyle: charts_flutter.TextStyleSpec(
              fontSize: widget.model.yaxis.labelvisible == false
                  ? 0
                  : widget.model.yaxis.labelsize,
              color: charts_flutter.ColorUtil.fromDartColor(
                  Theme.of(context).colorScheme.onBackground)),
        ),
      );

  charts_flutter.NumericAxisSpec xNumComboAxisSpec({int? ticks}) =>
      charts_flutter.NumericAxisSpec(
        tickProviderSpec: charts_flutter.BasicNumericTickProviderSpec(
            dataIsInWholeNumbers: false, desiredTickCount: ticks),
        viewport:
            widget.model.yaxis.min != null && widget.model.yaxis.max != null
                ? charts_flutter.NumericExtents(toNum(widget.model.yaxis.min!)!,
                    toNum(widget.model.yaxis.max!)!)
                : null,
        renderSpec: charts_flutter.SmallTickRendererSpec(
          axisLineStyle: charts_flutter.LineStyleSpec(
              color: charts_flutter.ColorUtil.fromDartColor(
                  Theme.of(context).colorScheme.onBackground)),
          labelStyle: charts_flutter.TextStyleSpec(
              fontSize: widget.model.xaxis.labelvisible == false
                  ? 0
                  : widget.model.xaxis.labelsize,
              color: charts_flutter.ColorUtil.fromDartColor(
                  Theme.of(context).colorScheme.onBackground)),
          labelRotation: widget.model.xaxis.labelrotation.abs() * -1,
          labelOffsetFromAxisPx:
              (sin(widget.model.xaxis.labelrotation.abs() * (pi / 180)) * 80)
                      .ceil() +
                  8, // 80 is rough estimate of our text length
          labelOffsetFromTickPx: 10,
          labelJustification: TickLabelJustification.inside,
        ),
      );

  charts_flutter.AxisSpec<String> xStringAxisSpec() =>
      charts_flutter.AxisSpec<String>(
        renderSpec: charts_flutter.SmallTickRendererSpec(
          axisLineStyle: charts_flutter.LineStyleSpec(
              color: charts_flutter.ColorUtil.fromDartColor(
                  Theme.of(context).colorScheme.onBackground)),
          labelStyle: charts_flutter.TextStyleSpec(
              fontSize: widget.model.xaxis.labelvisible == false
                  ? 0
                  : widget.model.xaxis.labelsize,
              color: charts_flutter.ColorUtil.fromDartColor(
                  Theme.of(context).colorScheme.onBackground)),
          labelRotation: widget.model.xaxis.labelrotation.abs() * -1,
          labelOffsetFromAxisPx:
              (sin(widget.model.xaxis.labelrotation.abs() * (pi / 180)) * 80)
                      .ceil() +
                  (widget.model.horizontal
                      ? 28
                      : 8), // 80 is rough estimate of our text length
          labelOffsetFromTickPx: 10,
        ),
      );

  charts_flutter.AxisSpec<DateTime> xDateTimeAxisSpec(
      List<charts_flutter.TickSpec<DateTime>> ticks) {
    return charts_flutter.DateTimeAxisSpec(
      renderSpec: charts_flutter.SmallTickRendererSpec(
        axisLineStyle: charts_flutter.LineStyleSpec(
            color: charts_flutter.ColorUtil.fromDartColor(
                Theme.of(context).colorScheme.onBackground)),
        labelAnchor: charts_flutter.TickLabelAnchor.after,
        labelStyle: charts_flutter.TextStyleSpec(
            fontSize: widget.model.xaxis.labelvisible == false
                ? 0
                : widget.model.xaxis.labelsize,
            color: charts_flutter.ColorUtil.fromDartColor(
                Theme.of(context).colorScheme.onBackground)),
        labelRotation: widget.model.xaxis.labelrotation.abs() * -1,
        labelOffsetFromAxisPx:
            (sin(widget.model.xaxis.labelrotation.abs() * (pi / 180)) * 80)
                    .ceil() +
                (widget.model.horizontal
                    ? 28
                    : 8), // 80 is rough estimate of our text length
        labelOffsetFromTickPx: 10,
      ),
      tickProviderSpec: charts_flutter.StaticDateTimeTickProviderSpec(ticks),
    );
  }

  List<charts_flutter.TickSpec<DateTime>> dateTimeTickBuilder(
      List<DateTime> tickData,
      {String? interval,
      String? format}) {
    // Axis Ticks
    List<charts_flutter.TickSpec<DateTime>> ticks = [];
    // Utilize a TUD to define our interval
    TimeUnitDuration tud = DT.getTUDurationFromString(interval ?? '0');

    // Check if we need to draw interval ticks/ have enough data to display the interval
    if (tud.amount == 0 || tickData.length < 2) {
      for (DateTime v in tickData) {
        ticks.add(charts_flutter.TickSpec(v,
            label: format != null ? DT.formatDateTime(v, format) : null));
      }
      return ticks;
    }

    // Build the interval ticks with min/max and every interval between
    DateTime firstTick = tickData.first;
    DateTime lastTick = tickData.last;
    // ensure min is <= max
    if (DT.isAfter(firstTick, lastTick)) {
      firstTick = lastTick;
    }
    // Establish the axis bounds based on the min/max and the interval
    firstTick = DT.floor(firstTick, tud.timeUnit);
    lastTick = DT.ceil(lastTick, tud.timeUnit);
    // Set the first tick to min DateTime
    DateTime tick = firstTick;
    // Add all the interval ticks starting at min
    while (DT.isBefore(tick, lastTick)) {
      ticks.add(charts_flutter.TickSpec(tick,
          label: format != null ? DT.formatDateTime(tick, format) : null));
      tick = DT.add(tick, tud);
    }
    // Add the last (max) DateTime tick
    ticks.add(charts_flutter.TickSpec(lastTick,
        label: format != null ? DT.formatDateTime(lastTick, format) : null));

    return ticks;
  }

  charts_flutter.BarChart buildBarChart(
      List<charts_flutter.Series<dynamic, String>> series) {
    // Determine if there is any grouping and/or stacking (grouped/stacked/groupedStacked)
    charts_flutter.BarGroupingType barGroupingType;
    ChartSeriesModel seriesModel = widget.model.series[0];
    // Based on the series if the series have both a group and stack, or neither,
    // but are only a single series set bargrouping to groupedStacked
    num yMin = double.infinity;
    num yMax = double.negativeInfinity;
    int? yTicksCount;

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
      Function configFunc = getSeriesRenderer(s, widget.model.xaxis.type);
      charts_flutter.SeriesRendererConfig<String> config = configFunc(s);
      seriesRenderers.add(config);
      // Calculate Numeric Y Axis Ticks
      if (widget.model.yaxis.interval != null && s.dataPoint.isNotEmpty) {
        num ySeriesMin = s.dataPoint.fold(
            toNum(s.dataPoint[0].y) ?? yMin,
            (num previous, ChartDataPoint current) =>
                previous < (toNum(current.y) ?? yMin)
                    ? previous
                    : (toNum(current.y) ?? yMin));
        yMin = ySeriesMin < yMin ? ySeriesMin : yMin;

        num ySeriesMax = s.dataPoint.fold(
            toNum(s.dataPoint[0].y) ?? yMin,
            (num previous, ChartDataPoint current) =>
                previous > (toNum(current.y) ?? yMin)
                    ? previous
                    : (toNum(current.y) ?? yMin));
        yMax = ySeriesMax > yMax ? ySeriesMax : yMax;
      }
    }

    // Determine Y Axis Ticks dynamically based on the value range and interval
    if (widget.model.yaxis.interval != null) {
      num range = (toNum(widget.model.yaxis.max) ?? yMax) -
          (toNum(widget.model.yaxis.min) ?? yMin);
      if (range.isFinite) {
        yTicksCount =
            (range / (toNum(widget.model.yaxis.interval) ?? 1) + 1).ceil();
      }
    }

    return charts_flutter.BarChart(
      series,
      animate: widget.model.animated,
      behaviors: getBehaviors<String>(),
      primaryMeasureAxis: yNumericAxisSpec(ticks: yTicksCount),
      domainAxis: xStringAxisSpec(),
      barGroupingType: barGroupingType,
      vertical: widget.model.horizontal ? false : true,
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

  charts_flutter.NumericComboChart buildNumericChart(
      List<charts_flutter.Series> series) {
    List<charts_flutter.SeriesRendererConfig<num>> seriesRenderers = [];
    num xMin = double.infinity;
    num xMax = double.negativeInfinity;
    num yMin = double.infinity;
    num yMax = double.negativeInfinity;
    int? xTicksCount;
    int? yTicksCount;
    for (var s in widget.model.series) {
      if (s.type == 'bar' && s.stack != null) {
        Log().warning(
            'Stacked Bar Series are only compatible with Category type X Axis and each series must be type="bar"');
      }
      Function configFunc = getSeriesRenderer(s, widget.model.xaxis.type);
      charts_flutter.SeriesRendererConfig<num> config = configFunc(s);
      seriesRenderers.add(config);

      // Calculate Numeric X Axis Ticks
      if (widget.model.xaxis.interval != null && s.dataPoint.isNotEmpty) {
        num xSeriesMin = s.dataPoint.fold(
            toNum(s.dataPoint[0].x) ?? xMin,
            (num previous, ChartDataPoint current) =>
                previous < (toNum(current.x) ?? xMin)
                    ? previous
                    : (toNum(current.x) ?? xMin));
        xMin = xSeriesMin < xMin ? xSeriesMin : xMin;

        num xSeriesMax = s.dataPoint.fold(
            toNum(s.dataPoint[0].x) ?? xMin,
            (num previous, ChartDataPoint current) =>
                previous > (toNum(current.x) ?? xMin)
                    ? previous
                    : (toNum(current.x) ?? xMin));
        xMax = xSeriesMax > xMax ? xSeriesMax : xMax;
      }
      // Calculate Numeric Y Axis Ticks
      if (widget.model.yaxis.interval != null && s.dataPoint.isNotEmpty) {
        num ySeriesMin = s.dataPoint.fold(
            toNum(s.dataPoint[0].y) ?? yMin,
            (num previous, ChartDataPoint current) =>
                previous < (toNum(current.y) ?? yMin)
                    ? previous
                    : (toNum(current.y) ?? yMin));
        yMin = ySeriesMin < yMin ? ySeriesMin : yMin;

        num ySeriesMax = s.dataPoint.fold(
            toNum(s.dataPoint[0].y) ?? yMin,
            (num previous, ChartDataPoint current) =>
                previous > (toNum(current.y) ?? yMin)
                    ? previous
                    : (toNum(current.y) ?? yMin));
        yMax = ySeriesMax > yMax ? ySeriesMax : yMax;
      }
    }

    // Determine Y Axis Ticks dynamically based on the value range and interval
    if (widget.model.yaxis.interval != null) {
      num range = (toNum(widget.model.yaxis.max) ?? yMax) -
          (toNum(widget.model.yaxis.min) ?? yMin);
      if (range.isFinite) {
        yTicksCount =
            (range / (toNum(widget.model.yaxis.interval) ?? 1) + 1).ceil();
      }
    }
    // Determine X Axis Ticks dynamically based on the value range and interval
    if (widget.model.xaxis.interval != null) {
      num range = (toNum(widget.model.xaxis.max) ?? xMax) -
          (toNum(widget.model.xaxis.min) ?? xMin);
      if (range.isFinite) {
        xTicksCount =
            (range / (toNum(widget.model.xaxis.interval) ?? 1) + 1).ceil();
      }
    }

    return charts_flutter.NumericComboChart(
      series as List<Series<dynamic, num>>,
      animate: widget.model.animated,
      behaviors: getBehaviors<num>(),
      primaryMeasureAxis: yNumericAxisSpec(ticks: yTicksCount),
      domainAxis: xNumComboAxisSpec(ticks: xTicksCount),
      customSeriesRenderers: seriesRenderers,
      selectionModels: [
        charts_flutter.SelectionModelConfig(
          type: charts_flutter.SelectionModelType.info,
          changedListener: _onSelectionChanged,
        )
      ],
    );
  }

  charts_flutter.OrdinalComboChart buildOrdinalChart(
      List<charts_flutter.Series> series) {
    List<charts_flutter.SeriesRendererConfig<String>> seriesRenderers = [];
    num yMin = double.infinity;
    num yMax = double.negativeInfinity;
    int? yTicksCount;
    for (var s in widget.model.series) {
      if (s.type == 'bar' && s.stack != null) {
        Log().warning(
            'Stacked Bar Series are only compatible with Category type X Axis and each series must be type="bar"');
      }
      Function configFunc = getSeriesRenderer(s, widget.model.xaxis.type);
      charts_flutter.SeriesRendererConfig<String> config = configFunc(s);
      seriesRenderers.add(config);
      // Calculate Numeric Y Axis Ticks
      if (widget.model.yaxis.interval != null && s.dataPoint.isNotEmpty) {
        num ySeriesMin = s.dataPoint.fold(
            toNum(s.dataPoint[0].y) ?? yMin,
            (num previous, ChartDataPoint current) =>
                previous < (toNum(current.y) ?? yMin)
                    ? previous
                    : (toNum(current.y) ?? yMin));
        yMin = ySeriesMin < yMin ? ySeriesMin : yMin;

        num ySeriesMax = s.dataPoint.fold(
            toNum(s.dataPoint[0].y) ?? yMin,
            (num previous, ChartDataPoint current) =>
                previous > (toNum(current.y) ?? yMin)
                    ? previous
                    : (toNum(current.y) ?? yMin));
        yMax = ySeriesMax > yMax ? ySeriesMax : yMax;
      }
    }

    // Determine Y Axis Ticks dynamically based on the value range and interval
    if (widget.model.yaxis.interval != null) {
      num range = (toNum(widget.model.yaxis.max) ?? yMax) -
          (toNum(widget.model.yaxis.min) ?? yMin);
      if (range.isFinite) {
        yTicksCount =
            (range / (toNum(widget.model.yaxis.interval) ?? 1) + 1).ceil();
      }
    }

    return charts_flutter.OrdinalComboChart(
      series as List<Series<dynamic, String>>,
      animate: widget.model.animated,
      behaviors: getBehaviors<String>(),
      primaryMeasureAxis: yNumericAxisSpec(ticks: yTicksCount),
      domainAxis: xStringAxisSpec(),
      customSeriesRenderers: seriesRenderers,
      selectionModels: [
        charts_flutter.SelectionModelConfig(
          type: charts_flutter.SelectionModelType.info,
          changedListener: _onSelectionChanged,
        ),
      ],
    );
  }

  charts_flutter.TimeSeriesChart buildTimeChart(
      List<charts_flutter.Series> series) {
    List<charts_flutter.SeriesRendererConfig<DateTime>> seriesRenderers = [];
    List<charts_flutter.TickSpec<DateTime>> xTicks = [];
    SplayTreeMap<int, DateTime> ticksMap = SplayTreeMap<int, DateTime>();
    num yMin = double.infinity;
    num yMax = double.negativeInfinity;
    int? yTicksCount;

    // get x values for all series to determine min and max values
    for (var s in widget.model.series) {
      if (s.type == 'bar' && s.stack != null) {
        Log().warning(
            'Stacked Bar Series are only compatible with Category type X Axis and each series must be type="bar"');
      }
      Function configFunc = getSeriesRenderer(
          s, /*widget.model.xaxis.type ??*/ ChartAxisType.datetime);
      charts_flutter.SeriesRendererConfig<DateTime> config = configFunc(s);
      seriesRenderers.add(config);
      // Map all the x values for the ticks
      for (ChartDataPoint x in s.dataPoint) {
        DateTime? xDateTime = toDate(x.x);
        if (xDateTime != null) {
          int epoch = xDateTime.toUtc().millisecondsSinceEpoch;
          // Ignore date/time data ticks before the min datetime on the x axis
          if (widget.model.xaxis.min != null &&
              DT.isBefore(xDateTime, toDate(widget.model.xaxis.min!)!)) {
            continue;
          }
          // Ignore date/time data ticks after the max datetime on the x axis
          if (widget.model.xaxis.max != null &&
              DT.isAfter(xDateTime, toDate(widget.model.xaxis.max!)!)) {
            continue;
          }
          ticksMap[epoch] = xDateTime;
        } else {
          Log().warning(
              '${x.x.toString()} is not a DateTime value in the ${s.name.toString()} TimeSeries');
        }
      }
      // Calculate Numeric Y Axis Ticks
      if (widget.model.yaxis.interval != null && s.dataPoint.isNotEmpty) {
        num ySeriesMin = s.dataPoint.fold(
            toNum(s.dataPoint[0].y) ?? yMin,
            (num previous, ChartDataPoint current) =>
                previous < (toNum(current.y) ?? yMin)
                    ? previous
                    : (toNum(current.y) ?? yMin));
        yMin = ySeriesMin < yMin ? ySeriesMin : yMin;

        num ySeriesMax = s.dataPoint.fold(
            toNum(s.dataPoint[0].y) ?? yMin,
            (num previous, ChartDataPoint current) =>
                previous > (toNum(current.y) ?? yMin)
                    ? previous
                    : (toNum(current.y) ?? yMin));
        yMax = ySeriesMax > yMax ? ySeriesMax : yMax;
      }
    }

    // Statically build each X Axis datetime tick
    xTicks = dateTimeTickBuilder(
        ticksMap.entries.map((entry) => entry.value).toList(),
        interval: widget.model.xaxis.interval.toString().trim(),
        format: widget.model.xaxis.format);

    // Determine Y Axis Ticks dynamically based on the value range and interval
    if (widget.model.yaxis.interval != null) {
      num range = (toNum(widget.model.yaxis.max) ?? yMax) -
          (toNum(widget.model.yaxis.min) ?? yMin);
      if (range.isFinite) {
        yTicksCount =
            (range / (toNum(widget.model.yaxis.interval) ?? 1) + 1).ceil();
      }
    }

    return charts_flutter.TimeSeriesChart(
      series as List<Series<dynamic, DateTime>>,
      animate: widget.model.animated,
      customSeriesRenderers: seriesRenderers,
      behaviors: getBehaviors<DateTime>(),
      primaryMeasureAxis: yNumericAxisSpec(ticks: yTicksCount),
      domainAxis: xDateTimeAxisSpec(xTicks),
      selectionModels: [
        charts_flutter.SelectionModelConfig(
          type: charts_flutter.SelectionModelType.info,
          changedListener: _onSelectionChanged,
        )
      ],
    );
  }

  charts_flutter.PieChart buildPieChart(
      List<charts_flutter.Series<dynamic, String>> series) {
    charts_flutter.ArcRendererConfig<String>? labelRendererWithData;
    // Flex: I Added this based on a bug Isaac reported where the arc label renderer without data held up
    // other paint jobs using the same data, ie a MAP drawn after a pie chart using the same datasource.
    if (series.isNotEmpty && series[0].data.isNotEmpty) {
      labelRendererWithData =
          charts_flutter.ArcRendererConfig(arcRendererDecorators: [
        charts_flutter.ArcLabelDecorator(
            labelPosition: charts_flutter.ArcLabelPosition.auto)
      ]);
    }
    return charts_flutter.PieChart<String>(
      series,
      animate: widget.model.animated,
      behaviors: getBehaviors<String>(),
      defaultRenderer: labelRendererWithData,
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

    bool pureBar = false;

    ChartSeriesModel? nonBarSeries =
        widget.model.series.firstWhereOrNull((series) => series.type != 'bar');
    if (nonBarSeries == null) {
      // Exclusively BarSeries
      pureBar = true;
    }
    // Loop through each series
    for (ChartSeriesModel series in widget.model.series) {
      if (series.datasource == null) {
        Log().error(
            'id: ${series.id.toString()} name: ${series.name.toString()} needs a data source attribute');
        return null;
      }
      // Auto group bar series if not specified
      if ((series.stack == null ||
              widget.model.xaxis.type != ChartAxisType.category) &&
          series.group == null &&
          pureBar == true) series.group = 'defaultgrouping';
      // Build the data points
      List<ChartDataPoint> seriesData = [];
      bool xAllNull = true;
      bool yAllNull = true;
      // Loop through each point
      for (ChartDataPoint point in series.dataPoint) {
        // Parse x and y data values from the databroker string values
        if (!isNullOrEmpty(point.x)) {
          // y value can be null, creating a gap in the chart
          dynamic xParsed;
          dynamic yParsed;
          try {
            xParsed = parsePlotPoint(point.x, widget.model.xaxis.type);
          } catch (e) {
            Log().error(
                'Unable to parse X axis plot point, chart id: ${widget.model.id.toString()} - series name: ${series.name.toString()} - $e');
            break;
          }
          try {
            yParsed = isNullOrEmpty(point.y)
                ? null
                : parsePlotPoint(point.y, widget.model.yaxis.type);
          } catch (e) {
            Log().error(
                'Unable to parse Y axis plot point, chart id: ${widget.model.id.toString()} - series name: ${series.name.toString()} - $e');
            break;
          }
          // Null Series Point Check
          if (xAllNull == true) xAllNull = xParsed == null;
          if (yAllNull == true) yAllNull = yParsed == null;
          // Ignore date/time data points before the min datetime on the x axis
          if ((widget.model.xaxis.type == ChartAxisType.datetime ||
                  widget.model.xaxis.type == ChartAxisType.date ||
                  widget.model.xaxis.type == ChartAxisType.time) &&
              widget.model.xaxis.min != null &&
              xParsed != null &&
              DT.isBefore(xParsed, toDate(widget.model.xaxis.min!)!)) {
            continue;
          }
          // Ignore date/time data points after the max datetime on the x axis
          if ((widget.model.xaxis.type == ChartAxisType.datetime ||
                  widget.model.xaxis.type == ChartAxisType.date ||
                  widget.model.xaxis.type == ChartAxisType.time) &&
              widget.model.xaxis.max != null &&
              xParsed != null &&
              DT.isAfter(xParsed, toDate(widget.model.xaxis.max!)!)) {
            continue;
          }
          // get label
          var label = point.label?.trim();
          // Add to point list
          if (xParsed != null) {
            seriesData.add(ChartDataPoint(
                x: xParsed, y: yParsed, color: point.color, label: label));
          }
          if (xParsed == null) {
            Log().warning(
                'id: ${series.id.toString()} name: ${series.name.toString()} Has a null X value, only Y vals can be null, every point must have a non-null X value');
          }
        }
      }

      // Null Series Warning
      //if (xAllNull) Log().warning('id: ${series.id.toString()} name: ${series.name.toString()} X values are all null');
      //if (yAllNull) Log().warning('id: ${series.id.toString()} name: ${series.name.toString()} Y values are all null');

      switch (widget.model.xaxis.type) {
        // Date/Time based X Axis
        case ChartAxisType.datetime:
        case ChartAxisType.date:
        case ChartAxisType.time:
          timeSeriesList.add(charts_flutter.Series(
              id: series.id,
              displayName: series.name ?? series.id,
              // seriesCategory: series.stack,
              areaColorFn: (dynamic plot, _) =>
                  charts_flutter.ColorUtil.fromDartColor(
                      (plot.color ?? series.color)?.withOpacity(0.1) ??
                          Colors.black12),
              colorFn: (dynamic plot, _) =>
                  charts_flutter.ColorUtil.fromDartColor(plot.color ??
                      series.color ??
                      (ColorHelper.niceColors.length > _!
                          ? ColorHelper.niceColors[_]!
                          : Colors.black)),
              domainFn: (dynamic plot, _) => plot.x,
              measureFn: (dynamic plot, _) => plot.y,
              labelAccessorFn: (dynamic plot, _) =>
                  drawLabel(plot), // Unavailable outside of pie/bar charts
              data: seriesData)
            ..setAttribute(
                charts_flutter.rendererIdKey, getRendererKey(series)));
          break;
        // Numeric based X axis
        case ChartAxisType.numeric:
          numericSeriesList.add(charts_flutter.Series(
              id: series.id,
              displayName: series.name ?? series.id,
              // seriesCategory: series.stack,
              areaColorFn: (dynamic plot, _) =>
                  charts_flutter.ColorUtil.fromDartColor(
                      (plot.color ?? series.color)?.withOpacity(0.1) ??
                          Colors.black12),
              colorFn: (dynamic plot, _) =>
                  charts_flutter.ColorUtil.fromDartColor(plot.color ??
                      series.color ??
                      (ColorHelper.niceColors.length > _!
                          ? ColorHelper.niceColors[_]!
                          : Colors.black)),
              domainFn: (dynamic plot, _) => plot.x,
              measureFn: (dynamic plot, _) => plot.y,
              labelAccessorFn: (dynamic plot, _) =>
                  drawLabel(plot), // Unavailable outside of pie/bar charts
              data: seriesData)
            ..setAttribute(
                charts_flutter.rendererIdKey, getRendererKey(series)));
          break;
        // Category/String based X axis
        case ChartAxisType.category:
          categorySeriesList.add(charts_flutter.Series(
              id: series.id,
              displayName: series.name ?? series.id,
              seriesCategory: series.stack,
              areaColorFn: (dynamic plot, _) =>
                  charts_flutter.ColorUtil.fromDartColor(
                      (plot.color ?? series.color)?.withOpacity(0.1) ??
                          Colors.black12),
              colorFn: (dynamic plot, _) =>
                  charts_flutter.ColorUtil.fromDartColor(plot.color ??
                      series.color ??
                      (ColorHelper.niceColors.length > _!
                          ? ColorHelper.niceColors[_]!
                          : Colors.black)),
              domainFn: (dynamic plot, _) => plot.x,
              measureFn: (dynamic plot, _) => plot.y,
              labelAccessorFn: (dynamic plot, _) =>
                  drawLabel(plot), // Unavailable outside of pie/bar charts
              data: seriesData)
            ..setAttribute(
                charts_flutter.rendererIdKey, getRendererKey(series)));
          break;
        default:
          Log().warning(
              'Unable to determine Chart Series for id: ${widget.model.id}');
          break;
      }
    }
    // We return the series of the correct data type here
    switch (widget.model.xaxis.type) {
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

  String drawLabel(plot) {
    return '${plot.label ?? (plot.y > 0 ? plot.y : '')}';
  }

  /// Unique id for each series based off the FML id, fallback on the name attribute
  /// Importantly bar charts that have a group attribute must share the same render key
  String? getRendererKey(ChartSeriesModel series) {
    if (chartType == ChartType.barChart || chartType == ChartType.pieChart) {
      return null;
    }
    return (series.type == 'bar' ? series.group : null) ?? series.id;
  }

  /// Parser for databroker data to convert it from a String to appropriate data type for the axis
  dynamic parsePlotPoint(String? val, ChartAxisType type) {
    if (type == ChartAxisType.category) {
      return val;
    } else if (type == ChartAxisType.numeric) {
      return toNum(val!) ?? 0;
      // return num.tryParse(val!) ?? 0;
    } else if (type == ChartAxisType.date ||
        type == ChartAxisType.time ||
        type == ChartAxisType.datetime) {
      DateTime? formatted;
      formatted = toDate(val); //, format: 'yMd Hm');
      return formatted; //DateTime.tryParse(val);
    }
  }

  /// Each series needs a specific type of renderer, this method passes back a
  /// function that builds the specific type needed with the correct attributes
  Function getSeriesRenderer(ChartSeriesModel series, ChartAxisType? type) {
    dynamic rendererConfig;
    // if (chartType == ChartType.barChart)
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
    return charts_flutter.BarRendererConfig(
        customRendererId: series.group ?? series.id);
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
        if (selectedSeries != null && selectedDatum.isNotEmpty) {
          // Loop through the selected series datum
          for (int i = 0; i < selectedDatum[0].series.data.length; i++) {
            // Match the selected x value to the selected series, set the
            //model.selected observable for binding to the data point and stop looping
            if (selectedDatum[0].series.data[i].x == domain) {
              // points ordered by closest to the selection matching the x axis
              List<Map> closestToSelection = [];

              for (var nearest in selectedDatum) {
                Map seriesData = {};
                // We also add the series id to the data set
                seriesData['_id'] = selectedSeriesId;
                seriesData['_x'] = nearest.series.data[i].x;
                seriesData['_y'] = nearest.series.data[i].y;
                seriesData['_label'] = nearest.series.data[i].label;
                closestToSelection.add(seriesData);
              }

              // stop listening during build
              widget.model.removeListener(this);
              widget.model.selected = closestToSelection;
              // start listening to model changes
              widget.model.registerListener(this);

              break;
            }
          }
        }
      } catch (e) {
        Log().warning('Unable to set Chart Series Point selection$e');
      }
    } else {
      // delselect
      // stop listening during build
      widget.model.removeListener(this);
      widget.model.selected = null;
      // start listening to model changes
      widget.model.registerListener(this);
    }
    // print('Approximate Series Clicked on [${selectedSeriesId}]: x: ${domain.toString()}, y: ${measure.toString()}'); // Only works for single series
    // measures.forEach((key, value) {
    //   print('key: ${key.toString()}, x: ${domain.toString()}, y: ${measure.toString()}');
    // });
    // print(widget.model.selected[0]?.join(','));
  }

  /// Returns Chart Annotations (labels) from the [ChartLabelModel]
  List<RangeAnnotationSegment<dynamic>> getLabels<T>() {
    List<RangeAnnotationSegment<dynamic>> annotations = [];

    for (ChartLabelModel labels in widget.model.labels) {
      // Loop through each label from the dataset
      for (ChartDataLabel label in labels.dataLabel) {
        // Check label has a positional value
        if (isNullOrEmpty(label.x) &&
            isNullOrEmpty(label.x1) &&
            isNullOrEmpty(label.x2) &&
            isNullOrEmpty(label.y) &&
            isNullOrEmpty(label.y1) &&
            isNullOrEmpty(label.y2)) {
          continue;
        }

        bool hasX = false;
        bool hasY = false;
        bool hasX2 = false;
        bool hasY2 = false;

        // Determine which labels to parse before parsing the label data
        hasX = labels.x != null || labels.x1 != null || labels.x2 != null;
        hasY = labels.y != null || labels.y1 != null || labels.y2 != null;
        hasX2 = labels.x2 != null;
        hasY2 = labels.y2 != null;

        dynamic xParsed;
        dynamic x1Parsed;
        dynamic x2Parsed;
        dynamic yParsed;
        dynamic y1Parsed;
        dynamic y2Parsed;

        try {
          if (hasX && !isNullOrEmpty(label.x)) {
            xParsed = parsePlotPoint(label.x, widget.model.xaxis.type);
          }
          if (hasX && !isNullOrEmpty(label.x1)) {
            x1Parsed = parsePlotPoint(label.x1, widget.model.xaxis.type);
          }
          if (hasX && hasX2 && !isNullOrEmpty(label.x2)) {
            x2Parsed = parsePlotPoint(label.x2, widget.model.xaxis.type);
          }
          if (hasY && !isNullOrEmpty(label.y)) {
            yParsed = parsePlotPoint(label.y, widget.model.yaxis.type);
          }
          if (hasY && !isNullOrEmpty(label.y1)) {
            y1Parsed = parsePlotPoint(label.y1, widget.model.yaxis.type);
          }
          if (hasY && hasY2 && !isNullOrEmpty(label.y2)) {
            y2Parsed = parsePlotPoint(label.y2, widget.model.yaxis.type);
          }
        } catch (e) {
          Log().error(
              'Unable to parse label location: x: ${label.x.toString()}, x1: ${label.x1.toString()}, x2: ${label.x2.toString()}, y: ${label.y.toString()}, y1: ${label.y1.toString()}, y2: ${label.y2.toString()}, $e');
          break;
        }

        // Build the annotations (labels) and use the parameters to determine
        // annotation type and style
        charts_flutter.RangeAnnotationSegment<T> annotation;
        charts_flutter.AnnotationLabelAnchor anchor;
        charts_flutter.AnnotationLabelPosition position;
        charts_flutter.AnnotationLabelDirection? direction;
        charts_flutter.RangeAnnotationAxisType axis;

        // Anchor is the placement on the cross axis
        switch (label.anchor?.toLowerCase()) {
          case 'center':
          case 'middle':
            anchor = charts_flutter.AnnotationLabelAnchor.middle;
            break;
          case 'start':
            anchor = charts_flutter.AnnotationLabelAnchor.start;
            break;
          case 'end':
            anchor = charts_flutter.AnnotationLabelAnchor.end;
            break;
          default:
            anchor = charts_flutter.AnnotationLabelAnchor.middle;
            break;
        }

        // Position is the placement on the main axis relative to the chart
        switch (label.position?.toLowerCase()) {
          case 'inside':
            position = charts_flutter.AnnotationLabelPosition.inside;
            break;
          case 'outside':
            position = charts_flutter.AnnotationLabelPosition.outside;
            break;
          case 'margin':
            position = charts_flutter.AnnotationLabelPosition.margin;
            break;
          default:
            position = charts_flutter.AnnotationLabelPosition.auto;
            break;
        }

        switch (label.direction?.toLowerCase()) {
          case 'horizontal':
            direction = charts_flutter.AnnotationLabelDirection.horizontal;
            break;
          case 'vertical':
            direction = charts_flutter.AnnotationLabelDirection.vertical;
            break;
          default:
            direction = charts_flutter.AnnotationLabelDirection.auto;
        }

        if (hasX) {
          axis = RangeAnnotationAxisType.domain;
        } else if (hasY) {
          axis = RangeAnnotationAxisType.measure;
        } else {
          continue;
        }

        if (axis == RangeAnnotationAxisType.measure) {
          annotation = charts_flutter.RangeAnnotationSegment<num>(
              hasX ? xParsed ?? x1Parsed : yParsed ?? y1Parsed,
              hasX
                  ? x2Parsed ?? x1Parsed ?? xParsed
                  : y2Parsed ?? y1Parsed ?? yParsed,
              axis,
              startLabel: label.startlabel ?? '',
              middleLabel: label.label ?? '',
              endLabel: label.endlabel ?? '',
              labelAnchor: anchor, // middle/start/end
              labelPosition:
                  position, // AnnotationLabelPosition.auto/inside/outside/margin
              labelDirection: direction, // horizontal/vertical
              color: charts_flutter.Color(
                  r: label.color.red,
                  g: label.color.green,
                  b: label.color.blue,
                  a: label.color.alpha),
              labelStyleSpec: charts_flutter.TextStyleSpec(
                  fontSize: label.labelsize ?? 12,
                  color: label.labelcolor != null
                      ? charts_flutter.Color(
                          r: label.labelcolor.red,
                          g: label.labelcolor.green,
                          b: label.labelcolor.blue,
                          a: label.labelcolor.alpha)
                      : charts_flutter.Color(
                          r: Theme.of(context).colorScheme.onSurfaceVariant.red,
                          g: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .green,
                          b: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .blue,
                          a: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .alpha))) as RangeAnnotationSegment<T>;
        } else if (axis == RangeAnnotationAxisType.domain) {
          switch (widget.model.xaxis.type) {
            case ChartAxisType.date:
            case ChartAxisType.time:
            case ChartAxisType.datetime:
              annotation = charts_flutter.RangeAnnotationSegment<DateTime>(
                  hasX ? xParsed ?? x1Parsed : yParsed ?? y1Parsed,
                  hasX
                      ? x2Parsed ?? x1Parsed ?? xParsed
                      : y2Parsed ?? y1Parsed ?? yParsed,
                  axis,
                  startLabel: label.startlabel ?? '',
                  middleLabel: label.label ?? '',
                  endLabel: label.endlabel ?? '',
                  labelAnchor: anchor, // middle/start/end
                  labelPosition:
                      position, // AnnotationLabelPosition.auto/inside/outside/margin
                  labelDirection: direction, // horizontal/vertical
                  color: charts_flutter.Color(
                      r: label.color.red,
                      g: label.color.green,
                      b: label.color.blue,
                      a: label.color.alpha),
                  labelStyleSpec: charts_flutter.TextStyleSpec(
                      fontSize: label.labelsize ?? 12,
                      color: label.labelcolor != null
                          ? charts_flutter.Color(
                              r: label.labelcolor.red,
                              g: label.labelcolor.green,
                              b: label.labelcolor.blue,
                              a: label.labelcolor.alpha)
                          : charts_flutter.Color(
                              r: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .red,
                              g: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .green,
                              b: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .blue,
                              a: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .alpha))) as RangeAnnotationSegment<T>;
              break;
            case ChartAxisType.category:
              annotation = charts_flutter.RangeAnnotationSegment<String>(
                  hasX ? xParsed ?? x1Parsed : yParsed ?? y1Parsed,
                  hasX
                      ? x2Parsed ?? x1Parsed ?? xParsed
                      : y2Parsed ?? y1Parsed ?? yParsed,
                  axis,
                  startLabel: label.startlabel ?? '',
                  middleLabel: label.label ?? '',
                  endLabel: label.endlabel ?? '',
                  labelAnchor: anchor, // middle/start/end
                  labelPosition:
                      position, // AnnotationLabelPosition.auto/inside/outside/margin
                  labelDirection: direction, // horizontal/vertical
                  color: charts_flutter.Color(
                      r: label.color.red,
                      g: label.color.green,
                      b: label.color.blue,
                      a: label.color.alpha),
                  labelStyleSpec: charts_flutter.TextStyleSpec(
                      fontSize: label.labelsize ?? 12,
                      color: label.labelcolor != null
                          ? charts_flutter.Color(
                              r: label.labelcolor.red,
                              g: label.labelcolor.green,
                              b: label.labelcolor.blue,
                              a: label.labelcolor.alpha)
                          : charts_flutter.Color(
                              r: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .red,
                              g: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .green,
                              b: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .blue,
                              a: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .alpha))) as RangeAnnotationSegment<T>;
              break;
            case ChartAxisType.numeric:
              annotation = charts_flutter.RangeAnnotationSegment<num>(
                  hasX ? xParsed ?? x1Parsed : yParsed ?? y1Parsed,
                  hasX
                      ? x2Parsed ?? x1Parsed ?? xParsed
                      : y2Parsed ?? y1Parsed ?? yParsed,
                  axis,
                  startLabel: label.startlabel ?? '',
                  middleLabel: label.label ?? '',
                  endLabel: label.endlabel ?? '',
                  labelAnchor: anchor, // middle/start/end
                  labelPosition:
                      position, // AnnotationLabelPosition.auto/inside/outside/margin
                  labelDirection: direction, // horizontal/vertical
                  color: charts_flutter.Color(
                      r: label.color.red,
                      g: label.color.green,
                      b: label.color.blue,
                      a: label.color.alpha),
                  labelStyleSpec: charts_flutter.TextStyleSpec(
                      fontSize: label.labelsize ?? 12,
                      color: label.labelcolor != null
                          ? charts_flutter.Color(
                              r: label.labelcolor.red,
                              g: label.labelcolor.green,
                              b: label.labelcolor.blue,
                              a: label.labelcolor.alpha)
                          : charts_flutter.Color(
                              r: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .red,
                              g: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .green,
                              b: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .blue,
                              a: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .alpha))) as RangeAnnotationSegment<T>;
              break;
            default:
              continue;
          }
        } else {
          continue;
        }

        annotations.add(annotation);
      }
    }
    return annotations;
  }

  /// Returns additional chart behaviors based on model settings
  List<charts_flutter.ChartBehavior<T>> getBehaviors<T>() {
    List<charts_flutter.ChartBehavior<T>> behaviors = [];
    // if (chartType != ChartType.pieChart) behaviors.add(charts_flutter.PanAndZoomBehavior());

    if (widget.model.showlegend != 'false' && chartType != ChartType.pieChart) {
      behaviors.add(charts_flutter.SeriesLegend(
        position: legendPosition(
          widget.model.showlegend,
        ),
        entryTextStyle: charts_flutter.TextStyleSpec(
            fontSize: widget.model.legendsize,
            color: charts_flutter.Color.fromHex(
                code:
                    '#${Theme.of(context).colorScheme.onBackground.value.toRadixString(16).toString().substring(2)}')),
      ));
    }

    if (widget.model.showlegend != 'false' && chartType == ChartType.pieChart) {
      behaviors.add(charts_flutter.DatumLegend(
        position: legendPosition(widget.model.showlegend),
        entryTextStyle: charts_flutter.TextStyleSpec(
          color: charts_flutter.Color.fromHex(
              code:
                  '#${Theme.of(context).colorScheme.onBackground.value.toRadixString(16).toString().substring(2)}'),
        ),
        outsideJustification:
            charts_flutter.OutsideJustification.middleDrawArea,
        horizontalFirst: true,
        desiredMaxColumns: 4,
        cellPadding: const EdgeInsets.only(right: 4.0, bottom: 4.0),
      ));
    }

    if (widget.model.xaxis.title != null) {
      behaviors.add(charts_flutter.ChartTitle(widget.model.xaxis.title!,
          titleStyleSpec: charts_flutter.TextStyleSpec(
            color: charts_flutter.Color.fromHex(
                code:
                    '#${Theme.of(context).colorScheme.onBackground.value.toRadixString(16).toString().substring(2)}'),
          ),
          behaviorPosition: widget.model.horizontal
              ? charts_flutter.BehaviorPosition.start
              : charts_flutter.BehaviorPosition.bottom,
          titleOutsideJustification:
              charts_flutter.OutsideJustification.middleDrawArea));
    }

    if (widget.model.yaxis.title != null) {
      behaviors.add(charts_flutter.ChartTitle(widget.model.yaxis.title!,
          titleStyleSpec: charts_flutter.TextStyleSpec(
            color: charts_flutter.Color.fromHex(
                code:
                    '#${Theme.of(context).colorScheme.onBackground.value.toRadixString(16).toString().substring(2)}'),
          ),
          behaviorPosition: widget.model.horizontal
              ? charts_flutter.BehaviorPosition.bottom
              : charts_flutter.BehaviorPosition.start,
          titleOutsideJustification:
              charts_flutter.OutsideJustification.middleDrawArea));
    }

    behaviors.add(charts_flutter.LinePointHighlighter(
        drawFollowLinesAcrossChart: true,
        dashPattern: const [3, 2],
        selectionModelType: charts_flutter.SelectionModelType.info,
        showHorizontalFollowLine:
            charts_flutter.LinePointHighlighterFollowLineType.nearest,
        showVerticalFollowLine:
            charts_flutter.LinePointHighlighterFollowLineType.nearest,
        symbolRenderer: charts_flutter.CircleSymbolRenderer(isSolid: true)));
    behaviors.add(charts_flutter.SelectNearest(
        eventTrigger: charts_flutter.SelectionTrigger.tapAndDrag));

    List<RangeAnnotationSegment<dynamic>>? labelBehaviors = [];
    labelBehaviors = getLabels<dynamic>();
    if (labelBehaviors.isNotEmpty) {
      behaviors.add(charts_flutter.RangeAnnotation<T>(
          labelBehaviors.cast<AnnotationSegment<Object>>()));
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
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // Busy / Loading Indicator
    busy ??= BusyModel(widget.model,
            visible: widget.model.busy, observable: widget.model.busyObservable)
        .getView();

    Widget view;

    // get the children
    List<Widget> children = widget.model.inflate();

    chartType = getChartType();
    List<charts_flutter.Series>? series = buildSeriesList();

    try {
      switch (chartType) {
        case ChartType.barChart:
          view = buildBarChart(series as List<Series<dynamic, String>>);
          break;
        case ChartType.numericComboChart:
          view = buildNumericChart(series!);
          break;
        case ChartType.ordinalComboChart:
          view = buildOrdinalChart(series!);
          break;
        case ChartType.pieChart:
          if (series == null || series.isEmpty) {
            view = const Center(child: Icon(Icons.add_chart));
          } else if (series[0].data.isNotEmpty) {
            view = buildPieChart(
                (series as List<charts_flutter.Series<dynamic, String>>));
          } else {
            view = const Center(child: Icon(Icons.add_chart));
          }
          break;
        case ChartType.timeSeriesChart:
          view = buildTimeChart(series!);
          break;
        default:
          view = const Center(child: Icon(Icons.add_chart));
      }
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

    // apply visual transforms
    view = applyTransforms(view);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.tightestOrDefault);

    return view;
  }
}
