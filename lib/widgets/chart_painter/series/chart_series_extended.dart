import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/chart_painter/series/chart_series_model.dart';

abstract class IExtendedSeriesInterface {
  dynamic get data;
  ChartPainterSeriesModel get series;
}

class BarChartGroupDataExtended extends BarChartGroupData
    implements IExtendedSeriesInterface {
  @override
  final ChartPainterSeriesModel series;

  @override
  final dynamic data;

  BarChartGroupDataExtended(this.series, this.data,
      {required super.x,
      super.groupVertically,
      super.barRods,
      super.barsSpace,
      super.showingTooltipIndicators});
}

class BarChartRodDataExtended extends BarChartRodData
    implements IExtendedSeriesInterface {
  @override
  final ChartPainterSeriesModel series;

  @override
  final dynamic data;

  BarChartRodDataExtended(
    this.series,
    this.data, {
    super.fromY,
    required super.toY,
    super.color,
    super.gradient,
    super.width,
    super.borderRadius,
    super.borderDashArray,
    super.borderSide,
    super.backDrawRodData,
    super.rodStackItems,
  });
}

class BarChartRodStackItemExtended extends BarChartRodStackItem
    implements IExtendedSeriesInterface {
  @override
  final ChartPainterSeriesModel series;

  @override
  final dynamic data;

  BarChartRodStackItemExtended(
      this.series, this.data, double fromY, double toY, Color color,
      [BorderSide border = const BorderSide(width: 0)])
      : super(fromY, toY, color, border);
}

class PieChartSectionDataExtended extends PieChartSectionData
    implements IExtendedSeriesInterface {
  @override
  final ChartPainterSeriesModel series;

  @override
  final dynamic data;

  PieChartSectionDataExtended(
    this.series,
    this.data, {
    super.value,
    super.color,
    super.radius,
    super.showTitle,
    super.titleStyle,
    super.title,
    super.borderSide,
    super.badgeWidget,
    super.titlePositionPercentageOffset,
    super.badgePositionPercentageOffset,
  });
}

class FlSpotExtended extends FlSpot implements IExtendedSeriesInterface {
  @override
  final ChartPainterSeriesModel series;

  @override
  final dynamic data;

  const FlSpotExtended(this.series, this.data, double x, double y) : super(x, y);
}
