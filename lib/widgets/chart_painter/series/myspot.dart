import 'package:fl_chart/fl_chart.dart';
import 'package:fml/widgets/chart_painter/series/chart_series_model.dart';
import 'package:fml/widgets/chart_painter/series/spot_interface.dart';

class MySpot extends FlSpot implements ISpotInterface
{
  @override
  final ChartPainterSeriesModel series;

  @override
  final dynamic data;

  MySpot(this.series, this.data, double x, double y) :  super(x,y);
}