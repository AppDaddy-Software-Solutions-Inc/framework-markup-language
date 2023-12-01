import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/chart_painter/series/chart_series_model.dart';

abstract class IExtendedSeriesInterface
{
  dynamic get data;
  ChartPainterSeriesModel get series;
}

class BarChartGroupDataExtended extends BarChartGroupData implements IExtendedSeriesInterface
{
  @override
  final ChartPainterSeriesModel series;

  @override
  final dynamic data;

  BarChartGroupDataExtended(this.series, this.data, {required int x, bool? groupVertically, List<BarChartRodData>? barRods, double? barsSpace,
    List<int>? showingTooltipIndicators}) :  super(x: x, groupVertically: groupVertically, barRods: barRods, barsSpace: barsSpace, showingTooltipIndicators: showingTooltipIndicators);
}

class BarChartRodDataExtended extends BarChartRodData implements IExtendedSeriesInterface
{
  @override
  final ChartPainterSeriesModel series;

  @override
  final dynamic data;

  BarChartRodDataExtended(this.series, this.data, {
    double? fromY,
    required double toY,
    Color? color,
    Gradient? gradient,
    double? width,
    BorderRadius? borderRadius,
    List<int>? borderDashArray,
    BorderSide? borderSide,
    BackgroundBarChartRodData? backDrawRodData,
    List<BarChartRodStackItem>? rodStackItems,
  }) :  super(
      fromY: fromY,
      toY: toY,
      color: color,
      gradient: gradient,
      width: width,
      borderRadius: borderRadius,
      borderDashArray: borderDashArray,
      borderSide: borderSide,
      backDrawRodData: backDrawRodData,
      rodStackItems: rodStackItems);
}

class BarChartRodStackItemExtended extends BarChartRodStackItem implements IExtendedSeriesInterface
{
  @override
  final ChartPainterSeriesModel series;

  @override
  final dynamic data;

  BarChartRodStackItemExtended(this.series, this.data,
      double fromY,
      double toY,
      Color color,
      [BorderSide border = const BorderSide(width: 0)]) :  super(
      fromY,
      toY,
      color,
      border);
}

class PieChartSectionDataExtended extends PieChartSectionData implements IExtendedSeriesInterface
{
  @override
  final ChartPainterSeriesModel series;

  @override
  final dynamic data;

  PieChartSectionDataExtended(this.series, this.data, {
    double? value,
    Color? color,
    double? radius,
    bool? showTitle,
    TextStyle? titleStyle,
    String? title,
    BorderSide? borderSide,
    Widget? badgeWidget,
    double? titlePositionPercentageOffset,
    double? badgePositionPercentageOffset,
  }) :  super(
      value: value,
      color: color,
      radius: radius,
      showTitle: showTitle,
      titleStyle: titleStyle,
      title: title,
      borderSide: borderSide,
      badgeWidget: badgeWidget,
      titlePositionPercentageOffset: titlePositionPercentageOffset,
      badgePositionPercentageOffset: badgePositionPercentageOffset);
}

class FlSpotExtended extends FlSpot implements IExtendedSeriesInterface
{
  @override
  final ChartPainterSeriesModel series;

  @override
  final dynamic data;

  FlSpotExtended(this.series, this.data, double x, double y) :  super(x,y);
}

