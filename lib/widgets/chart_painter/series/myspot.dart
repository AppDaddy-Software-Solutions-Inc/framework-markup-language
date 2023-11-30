import 'package:fl_chart/fl_chart.dart';
import 'package:fml/widgets/chart_painter/series/chart_series_model.dart';

class MySpot extends FlSpot
{
  final dynamic data;
  final ChartPainterSeriesModel series;

  MySpot(double x, double y, this.series, this.data) :  super(x,y);
}