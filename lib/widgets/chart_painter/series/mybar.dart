import 'package:fl_chart/fl_chart.dart';
import 'package:fml/widgets/chart_painter/series/chart_series_model.dart';
import 'package:fml/widgets/chart_painter/series/spot_interface.dart';

class MyBar extends BarChartGroupData implements ISpotInterface
{
  @override
  final ChartPainterSeriesModel series;

  @override
  final dynamic data;

  MyBar(this.series, this.data, {required int x, bool? groupVertically, List<BarChartRodData>? barRods, double? barsSpace,
      List<int>? showingTooltipIndicators}) :  super(x: x, groupVertically: groupVertically, barRods: barRods, barsSpace: barsSpace, showingTooltipIndicators: showingTooltipIndicators);
}