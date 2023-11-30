import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/chart_painter/series/chart_series_model.dart';
import 'package:fml/widgets/chart_painter/series/spot_interface.dart';

class MyPie extends PieChartSectionData implements ISpotInterface
{
  @override
  final ChartPainterSeriesModel series;

  @override
  final dynamic data;


  MyPie(this.series, this.data, {
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