/**
// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:fml/widgets/chart_syncfusion/chart_view.dart' as VIEW;
import 'package:fml/helper/helper_barrel.dart';

/// Cartesian Chart
///
/// Function to build the Cartesian Chart View
SfCartesianChart cartesianChart(VIEW.SFChartProperties chartProps, Function buildAxis, Function setZoomX, Function setZoomY, Function cartesianSeriesBuilder,
    List<VIEW.SFSeriesProperties> chartSFSeriesPropertiesList, Function tooltipBuilder, AssetImage? bg) {
  return SfCartesianChart(
    series: cartesianSeriesBuilder(chartSFSeriesPropertiesList),
//    title: ChartTitle(text: chartProps.chartTitle, alignment: ChartAlignment.center,backgroundColor: chartProps.chartTitleBackgroundColor ?? Colors.transparent, textStyle: TextStyle( color: chartProps.chartTitleColor, fontFamily: 'Roboto', fontStyle: FontStyle.normal, fontSize: chartProps.chartTitleFontSize)),
    legend: Legend(
      textStyle: TextStyle(color: chartProps.legendColor),
      isVisible: chartProps.legend,
      height: "40",
      padding: 10.0,
      width: "100%",
      position: chartProps.legendposition ?? LegendPosition.bottom, // LegendPosition.bottom,
      overflowMode: LegendItemOverflowMode.scroll,
    ),
    plotAreaBackgroundColor: chartProps.plotBackgroundColor,
    plotAreaBackgroundImage: null, // This is broken in ^18.3.40 //const AssetImage('background-gy.png'), //bg != null ? (bg) : null,
    tooltipBehavior:
        (chartProps.tooltipEnabled == true)
            ? TooltipBehavior(
                enable: chartProps.tooltipEnabled,
                activationMode: ActivationMode.singleTap,
                tooltipPosition: TooltipPosition.auto,
                builder: tooltipBuilder as Widget Function(dynamic, dynamic, dynamic, int, int)?,
              )
            : null,
    zoomPanBehavior: chartProps.zoomPanEnabled! ? zoomPanBehavior : null,
    onZooming: (args) {
      if (args.axis!.name == "X axis") {
        setZoomX(args.currentZoomFactor, args.currentZoomPosition);
      }
      else if (args.axis!.name == "Y axis") {
        setZoomY(args.currentZoomFactor, args.currentZoomPosition);
      }
    },
    onZoomEnd: (args) {
      if (args.axis!.name == "X axis") {
        setZoomX(args.currentZoomFactor, args.currentZoomPosition);
      }
      else if (args.axis!.name == "Y axis") {
        setZoomY(args.currentZoomFactor, args.currentZoomPosition);
      }
    },
    primaryXAxis: buildAxis(chartProps.xAxis, 'x'),
    primaryYAxis: buildAxis(chartProps.yAxis, 'y'),
  );
}

/// Circle Chart
///
/// Function to build the Circle Chart View
SfCircularChart circleChart(
    chartProps, circularSeriesBuilder, chartSFSeriesPropertiesList, Function tooltipBuilder) {
  return SfCircularChart(
      backgroundColor: chartProps.plotBackgroundColor ?? Colors.transparent,
//      title: ChartTitle(text: chartProps.chartTitle, alignment: ChartAlignment.center, backgroundColor: chartProps.chartTitleBackgroundColor ?? Colors.transparent, textStyle: TextStyle(color: chartProps.chartTitleColor, fontFamily: 'Roboto', fontStyle: FontStyle.normal, fontSize: chartProps.chartTitleFontSize)),
      legend: Legend(
        isVisible: chartProps.legend, //propsSFChart.legend,
        textStyle: TextStyle(color: chartProps.legendColor),
        position: chartProps?.legendposition ?? LegendPosition.bottom, // LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.scroll,
      ),
      tooltipBehavior:
      (chartProps.tooltipEnabled == true)
          ? TooltipBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        tooltipPosition: TooltipPosition.auto,
        builder: tooltipBuilder as Widget Function(dynamic, dynamic, dynamic, int, int)?,
      )
          : null,
      series: circularSeriesBuilder(chartSFSeriesPropertiesList));
}

/// Zoom/Pan settings
final ZoomPanBehavior zoomPanBehavior = ZoomPanBehavior(
  enablePanning: true,
  // Performs zooming on double tap
  enableDoubleTapZooming: false,
  // Mobile only pinch zooming
  enablePinching: true,
  // Desktop/Web/Mobile selection zooming
  enableSelectionZooming: true,
  enableMouseWheelZooming: true,
  selectionRectBorderColor: Colors.yellow,
  selectionRectBorderWidth: 1,
  selectionRectColor: Colors.yellow,
);

/// Numeric Axis
///
/// Function to build the Numeric Axis
NumericAxis numericAxis(VIEW.Axis axis) {
  return NumericAxis(
    name: axis.name,
    minimum: S.toDouble(axis.minimum),
    maximum: S.toDouble(axis.maximum),
    visibleMinimum: S.toDouble(axis.visibleMinimum),
    visibleMaximum: S.toDouble(axis.visibleMaximum),
    interval: axis.interval,
    // decimalPlaces: 1,
    // rangePadding: ChartRangePadding.none,
    zoomFactor: axis.zoomFactor,
    zoomPosition: axis.zoomPosition,
    labelRotation: axis.labelRotation,
    title: AxisTitle(
      text: axis.title,
      textStyle: TextStyle(
        color: axis.fontColor,
        fontFamily: 'Roboto',
        fontSize: ((axis.fontSize ?? 12) + 4).toDouble(),
      ),
    ),
    labelStyle: TextStyle(
        color: axis.fontColor,
        fontFamily: 'Roboto',
        fontSize: axis.fontSize!.toDouble(),
        fontWeight: FontWeight.w500),
    minorGridLines: MinorGridLines(
      width: 0.5,
      color: axis.gridColor,
    ),
    majorGridLines: MajorGridLines(
      width: 0.5,
      color: axis.gridColor,
    ),
    majorTickLines: MajorTickLines(
      width: 1,
      color: axis.gridColor,
    ),
  );
}

/// DateTime Axis
///
/// Function to build the DateTime Axis
DateTimeAxis dateTimeAxis(axis) {

  Map<String, DateTimeIntervalType> intervalType = const {
    "seconds": DateTimeIntervalType.seconds,
    "second": DateTimeIntervalType.seconds,
    "minutes": DateTimeIntervalType.minutes,
    "minute": DateTimeIntervalType.minutes,
    "hours": DateTimeIntervalType.hours,
    "hour": DateTimeIntervalType.hours,
    "days": DateTimeIntervalType.days,
    "day": DateTimeIntervalType.days,
    "months": DateTimeIntervalType.months,
    "month": DateTimeIntervalType.months,
    "years": DateTimeIntervalType.years,
    "year": DateTimeIntervalType.years,
  };

  return DateTimeAxis(
    name: axis.name,
    dateFormat: axis.format != null ? DateFormat(axis.format) : (S.fromEnum(axis.dataType) == 'date' ? DateFormat.yMd() : (S.fromEnum(axis.dataType) == 'time' ? DateFormat.jm() : DateFormat.yMd().add_Hm())),
    // TODO: add more support for min/max/interval to DateTimeAxis
    // https://help.syncfusion.com/flutter/chart/axis-types#customizing-range-1
    // doubles should work
    // https://help.syncfusion.com/flutter/cartesian-charts/axis-types#double-range-support
    minimum: axis.minimum,
    maximum: axis.maximum,
    visibleMinimum: axis.visibleMinimum,
    visibleMaximum: axis.visibleMaximum,
    interval: axis.interval,
    intervalType: intervalType[axis?.intervalType] ?? DateTimeIntervalType.auto,
//    dateFormat: DateFormat???,
    zoomFactor: axis.zoomFactor,
    zoomPosition: axis.zoomPosition,
    labelRotation: axis.labelRotation,
    title: AxisTitle(
      text: axis.title,
      textStyle: TextStyle(
        color: axis.fontColor,
        fontFamily: 'Roboto',
        fontSize: ((axis?.fontSize ?? 12) + 4).toDouble(),
      ),
    ),
    labelStyle: TextStyle(
        color: axis.fontColor,
        fontFamily: 'Roboto',
        fontSize: axis.fontSize.toDouble(),
        fontWeight: FontWeight.w500),
    minorGridLines: MinorGridLines(
      width: 0.5,
      color: axis.gridColor,
    ),
    majorGridLines: MajorGridLines(
      width: 0.5,
      color: axis.gridColor,
    ),
    majorTickLines: MajorTickLines(
      width: 1,
      color: axis.gridColor,
    ),
  );
}

/// Category Axis
///
/// Function to build the Category Axis
CategoryAxis categoryAxis(dynamic axis) {
  return CategoryAxis(
    name: axis.name,
    zoomFactor: axis.zoomFactor,
    zoomPosition: axis.zoomPosition,
    labelRotation: axis.labelRotation,
    title: AxisTitle(
      text: axis.title,
      textStyle: TextStyle(
        color: axis.fontColor,
        fontFamily: 'Roboto',
        fontSize: ((axis?.fontSize ?? 12) + 4).toDouble(),
      ),
    ),
    labelPlacement: LabelPlacement.betweenTicks,
    labelStyle: TextStyle(
        color: axis.fontColor,
        fontFamily: 'Roboto',
        fontSize: ((axis?.fontSize ?? 12) + 4).toDouble(),
        fontWeight: FontWeight.w500),
    minorGridLines: MinorGridLines(
      width: 0.5,
      color: axis.gridColor,
    ),
    majorGridLines: MajorGridLines(
      width: 0.5,
      color: axis.gridColor,
    ),
    majorTickLines: MajorTickLines(
      width: 1,
      color: axis.gridColor,
    ),
  );
}

/// Logarithmic Axis
///
/// WIP
/// Function to build the Logarithmic Axis
LogarithmicAxis? logarithmicAxis(axis) {
  return // No implementation as of now
      null; // LogarithmicAxis();
}

/// Bar Series
///
/// Function to build a Bar Series
ColumnSeries barSeries(VIEW.SFSeriesProperties seriesProps, VIEW.SFChartProperties? chartProps) {
  return ColumnSeries<VIEW.SFChartDataPoint, dynamic>(
    dataSource: seriesProps.chartData,
    xValueMapper: (VIEW.SFChartDataPoint data, _) => data.x,
    yValueMapper: (VIEW.SFChartDataPoint data, _) => data.y,
    pointColorMapper: (VIEW.SFChartDataPoint data, _) => data.color,
    name: seriesProps.name,
    color: seriesProps.color,
    enableTooltip: seriesProps.tooltips,
    borderRadius: BorderRadius.all(Radius.circular(1)),
    animationDuration: seriesProps.animated
        ? (chartProps!.zoomPanEnabled! ? 0 : 1000)
        : 0,
  );
}

/// Stacked Bar Series
///
/// Function to build a Stacked Bar Series
StackedColumnSeries stackedbarSeries(VIEW.SFSeriesProperties seriesProps, VIEW.SFChartProperties? chartProps) {
  return StackedColumnSeries<VIEW.SFChartDataPoint, dynamic>(
    dataSource: seriesProps.chartData,
    xValueMapper: (VIEW.SFChartDataPoint data, _) => data.x,
    yValueMapper: (VIEW.SFChartDataPoint data, _) => data.y,
    pointColorMapper: (VIEW.SFChartDataPoint data, _) => data.color,
    name: seriesProps.name,
    color: seriesProps.color,
    enableTooltip: seriesProps.tooltips,
    animationDuration: seriesProps.animated
        ? (chartProps!.zoomPanEnabled! ? 0 : 1000)
        : 0,
  );
}

/// Percent Stacked Bar Series
///
/// Function to build a Percent Stacked Bar Series
StackedColumn100Series percentstackedbarSeries(VIEW.SFSeriesProperties seriesProps, VIEW.SFChartProperties? chartProps) {
  return StackedColumn100Series<VIEW.SFChartDataPoint, dynamic>(
    dataSource: seriesProps.chartData,
    xValueMapper: (VIEW.SFChartDataPoint data, _) => data.x,
    yValueMapper: (VIEW.SFChartDataPoint data, _) => data.y,
    pointColorMapper: (VIEW.SFChartDataPoint data, _) => data.color,
    name: seriesProps.name,
    color: seriesProps.color,
    enableTooltip: seriesProps.tooltips,
    animationDuration: seriesProps.animated
        ? (chartProps!.zoomPanEnabled! ? 0 : 1000)
        : 0,
  );
}

/// Side Bar Series
///
/// Function to build a Side Bar Series
BarSeries sidebarSeries(VIEW.SFSeriesProperties seriesProps, VIEW.SFChartProperties? chartProps) {
  return BarSeries<VIEW.SFChartDataPoint, dynamic>(
    dataSource: seriesProps.chartData,
    xValueMapper: (VIEW.SFChartDataPoint data, _) => data.x,
    yValueMapper: (VIEW.SFChartDataPoint data, _) => data.y,
    pointColorMapper: (VIEW.SFChartDataPoint data, _) => data.color,
    name: seriesProps.name,
    color: seriesProps.color,
    enableTooltip: seriesProps.tooltips,
    animationDuration: seriesProps.animated
        ? (chartProps!.zoomPanEnabled! ? 0 : 1000)
        : 0,
  );
}

/// Area Series
///
/// Function to build an Area Series
AreaSeries areaSeries(VIEW.SFSeriesProperties seriesProps, VIEW.SFChartProperties chartProps) {
  Color areaCol = seriesProps.color ?? Colors.blue;
  LinearGradient gradient = LinearGradient(
      begin: Alignment.bottomCenter, end: Alignment.topCenter,
      stops: [0.0, 0.35, 1.0],
      colors: [
        chartProps.plotBackgroundColor ?? areaCol.withOpacity(0.0),
        areaCol.withOpacity(0.4),
        (seriesProps.stroke != null || seriesProps.size != null)
            ? areaCol.withOpacity(0.65)
            : areaCol,
      ]
  );
  return AreaSeries<VIEW.SFChartDataPoint, dynamic>(
    dataSource: seriesProps.chartData,
    xValueMapper: (VIEW.SFChartDataPoint data, _) => data.x,
    yValueMapper: (VIEW.SFChartDataPoint data, _) => data.y,
    name: seriesProps.name,
    gradient: gradient,
    borderColor: seriesProps.color,
    borderWidth: seriesProps.stroke ?? seriesProps.size ?? 3,
    enableTooltip: seriesProps.tooltips,
    animationDuration: seriesProps.animated
        ? (chartProps.zoomPanEnabled! ? 0 : 1000)
        : 0,
  );
}

/// Spline Series
///
/// Function to build a Spline Series
SplineSeries splineSeries(VIEW.SFSeriesProperties seriesProps, VIEW.SFChartProperties? chartProps) {
  return SplineSeries<VIEW.SFChartDataPoint, dynamic>(
    dataSource: seriesProps.chartData,
    xValueMapper: (VIEW.SFChartDataPoint data, _) => data.x,
    yValueMapper: (VIEW.SFChartDataPoint data, _) => data.y,
    pointColorMapper: (VIEW.SFChartDataPoint data, _) => data.color,
    name: seriesProps.name,
    color: seriesProps.color,
    width: seriesProps.stroke ?? seriesProps.size ?? null,
    enableTooltip: seriesProps.tooltips,
    animationDuration: seriesProps.animated
        ? (chartProps!.zoomPanEnabled! ? 0 : 1000)
        : 0,
  );
}

/// Line Series
///
/// Function to build a Line Series
LineSeries lineSeries(VIEW.SFSeriesProperties seriesProps, VIEW.SFChartProperties? chartProps) {
  return LineSeries<VIEW.SFChartDataPoint, dynamic>(
    dataSource: seriesProps.chartData,
    xValueMapper: (VIEW.SFChartDataPoint data, _) => data.x,
    yValueMapper: (VIEW.SFChartDataPoint data, _) => data.y,
    pointColorMapper: (VIEW.SFChartDataPoint data, _) => data.color,
    name: seriesProps.name,
    color: seriesProps.color,
    width: seriesProps.stroke ?? seriesProps.size ?? null,
    enableTooltip: seriesProps.tooltips,
    animationDuration: seriesProps.animated
        ? (chartProps!.zoomPanEnabled! ? 0 : 1000)
        : 0,
  );
}

/// Stacked Fast Line Series
///
/// Function to build a Fast Line Series
FastLineSeries fastlineSeries(VIEW.SFSeriesProperties seriesProps, VIEW.SFChartProperties? chartProps) {
  return FastLineSeries<VIEW.SFChartDataPoint, dynamic>(
    dataSource: seriesProps.chartData,
    xValueMapper: (VIEW.SFChartDataPoint data, _) => data.x,
    yValueMapper: (VIEW.SFChartDataPoint data, _) => data.y,
    name: seriesProps.name,
    color: seriesProps.color,
    animationDuration: seriesProps.animated
        ? (chartProps!.zoomPanEnabled! ? 0 : 1000)
        : 0,
  );
}

/// Scatter Plot Series
///
/// Function to build a Scatter Plot Series
ScatterSeries plotSeries(VIEW.SFSeriesProperties seriesProps, VIEW.SFChartProperties? chartProps) {
  return ScatterSeries<VIEW.SFChartDataPoint, dynamic>(
    dataSource: seriesProps.chartData,
    xValueMapper: (VIEW.SFChartDataPoint data, _) => data.x,
    yValueMapper: (VIEW.SFChartDataPoint data, _) => data.y,
    pointColorMapper: (VIEW.SFChartDataPoint data, _) => data.color,
    name: seriesProps.name,
    color: seriesProps.color,
    markerSettings: MarkerSettings(
        height: seriesProps.size ?? seriesProps.stroke ?? 15,
        width: seriesProps.size ?? seriesProps.stroke ?? 15,
        // Scatter will render in diamond shape
        shape: DataMarkerType.circle),
    enableTooltip: seriesProps.tooltips,
    animationDuration: seriesProps.animated
        ? (chartProps!.zoomPanEnabled! ? 0 : 1000)
        : 0,
  );
}

/// Waterfall Series
///
/// Function to build a Waterfall Series
WaterfallSeries waterfallSeries(VIEW.SFSeriesProperties seriesProps, VIEW.SFChartProperties? chartProps) {
  return WaterfallSeries<VIEW.SFChartDataPoint, dynamic>(
    dataSource: seriesProps.chartData,
    xValueMapper: (VIEW.SFChartDataPoint data, _) => data.x,
    yValueMapper: (VIEW.SFChartDataPoint data, _) => data.y,
    pointColorMapper: (VIEW.SFChartDataPoint data, _) => data.color,
    name: seriesProps.name,
    color: seriesProps.color,
    enableTooltip: seriesProps.tooltips,
    animationDuration: seriesProps.animated ? (chartProps!.zoomPanEnabled! ? 0 : 1000) : 0,
    dataLabelMapper: (VIEW.SFChartDataPoint data, _) =>
    seriesProps.labelType?.toLowerCase() == 'string' ? data.label : null,
    dataLabelSettings: DataLabelSettings(
        borderRadius: 3,
        isVisible: seriesProps.labelled,
        useSeriesColor: true,
        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 4),
        labelPosition: ChartDataLabelPosition.inside,
        // If a label doesn't fit it will pop out (Circular)
        // labelAlignment: ChartDataLabelAlignment.top,
        // (Cartesian)
        connectorLineSettings: ConnectorLineSettings(
          // Type of the connector line
            type: ConnectorType.line // curve
        ),
        builder: seriesProps.labelType?.toLowerCase() == 'widget'
            ? (dynamic data, dynamic point, dynamic series, int pointIndex,
            int seriesIndex) {
          return Container(
              child: data.label ?? SizedBox.shrink());
        }
            : null),
    markerSettings: MarkerSettings(isVisible: false, height: 10, shape: DataMarkerType.verticalLine),
    // intermediateSumPredicate: (VIEW.SFChartDataPoint data, _) => true,
    // totalSumPredicate: (VIEW.SFChartDataPoint data, _) => true,
  );
}

/// Label Series
///
/// Function to build a Label Series
ScatterSeries labelSeries(VIEW.SFSeriesProperties seriesProps, VIEW.SFChartProperties? chartProps) {
  return ScatterSeries<VIEW.SFChartDataPoint, dynamic>(
      dataSource: seriesProps.chartData,
      xValueMapper: (VIEW.SFChartDataPoint data, _) => data.x,
      yValueMapper: (VIEW.SFChartDataPoint data, _) => data.y,
      pointColorMapper: (VIEW.SFChartDataPoint data, _) => data.color,
      name: seriesProps.name,
      color: seriesProps.color,
      enableTooltip: seriesProps.tooltips,
      animationDuration: seriesProps.animated
          ? (chartProps!.zoomPanEnabled! ? 0 : 1000)
          : 0,
      opacity: 1.0,
      // hide points when showing labels

      emptyPointSettings: EmptyPointSettings(color: Colors.transparent, mode:EmptyPointMode.gap),
      dataLabelMapper: (VIEW.SFChartDataPoint data, _) =>
          seriesProps.labelType?.toLowerCase() == 'string' ? data.label : null,
      dataLabelSettings: DataLabelSettings(
        borderRadius: 3,
        isVisible: seriesProps.labelled,
        useSeriesColor: true,
        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 4),
        labelPosition: ChartDataLabelPosition.inside,
        // If a label doesn't fit it will pop out (Circular)
        // labelAlignment: ChartDataLabelAlignment.top,
        // (Cartesian)
        connectorLineSettings: ConnectorLineSettings(
            // Type of the connector line
            type: ConnectorType.line // curve
            ),
        builder: seriesProps.labelType?.toLowerCase() == 'widget'
            ? (dynamic data, dynamic point, dynamic series, int pointIndex,
                int seriesIndex) {
                return Container(
                    child: data.label ?? SizedBox.shrink());
              }
            : null),
      markerSettings: MarkerSettings(
        isVisible: false,
        height: 10,
        shape: DataMarkerType.verticalLine, //DataMarkerType.invertedTriangle,
      ));
}

/// Pie Series
///
/// Function to build a Pie Series
PieSeries pieSeries(VIEW.SFSeriesProperties seriesProps) {
  return PieSeries<VIEW.SFChartDataPoint, dynamic>(
      dataSource: seriesProps.chartData,
      xValueMapper: (VIEW.SFChartDataPoint data, _) => data.x,
      yValueMapper: (VIEW.SFChartDataPoint data, _) => data.y,
      pointColorMapper: (VIEW.SFChartDataPoint data, _) => data.color,
      animationDuration: seriesProps.animated ? 1000 : 0,
      name: seriesProps.name,
      enableTooltip: seriesProps.tooltips,
      explode: seriesProps.type == 'explodedpie' ? true : false,
      // broken on mobile
      explodeAll: seriesProps.type == 'explodedpie' ? true : false,
      // We can customize the data labels to display lots of information directly from the dataSource
      // dataLabelMapper: (SFChartDataPoint data, _) => '${data.x} (${data.y.toString()}%)',
      dataLabelSettings: DataLabelSettings(
        isVisible: true,
        useSeriesColor: false,
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelPosition: ChartDataLabelPosition.inside,
      ));
}

/// Doughnut Series
///
/// Function to build a Doughnut Series
DoughnutSeries doughnutSeries(VIEW.SFSeriesProperties seriesProps) {
  return DoughnutSeries<VIEW.SFChartDataPoint, dynamic>(
      dataSource: seriesProps.chartData,
      xValueMapper: (VIEW.SFChartDataPoint data, _) => data.x,
      yValueMapper: (VIEW.SFChartDataPoint data, _) => data.y,
      pointColorMapper: (VIEW.SFChartDataPoint data, _) => data.color,
      animationDuration: seriesProps.animated ? 1000 : 0,
      name: seriesProps.name,
      enableTooltip: seriesProps.tooltips,
      explode: seriesProps.type == 'explodeddoughnut' ? true : false,
      // broken on mobile
      explodeAll: seriesProps.type == 'explodeddoughnut' ? true : false,
      radius: '80%',
      // default
      innerRadius: '70%',
      // Reducing the outer radius to leave room for labels outside
      // We can customize the data labels to display lots of information directly from the dataSource
      dataLabelSettings: DataLabelSettings(
        isVisible: true,
        useSeriesColor: false,
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelPosition: ChartDataLabelPosition.inside,
      ));
}

/// Radial Bar Series
///
/// Function to build a Radial Bar Series
RadialBarSeries radialSeries(VIEW.SFSeriesProperties seriesProps) {
  return RadialBarSeries<VIEW.SFChartDataPoint, dynamic>(
      dataSource: seriesProps.chartData,
      xValueMapper: (VIEW.SFChartDataPoint data, _) => data.x,
      yValueMapper: (VIEW.SFChartDataPoint data, _) => data.y,
      pointColorMapper: (VIEW.SFChartDataPoint data, _) => data.color,
      animationDuration: seriesProps.animated ? 1000 : 0,
      name: seriesProps.name,
      enableTooltip: seriesProps.tooltips,
      maximumValue: 15,
      // Would be nice to get a max value from the data set
      trackColor: Colors.grey[500]!.withOpacity(0.3), //Colors.black26,
      trackOpacity: 0.5,
      innerRadius: '10%',
      // Set this smaller for larger data sets/smaller screens
      gap: '0',
      // Reducing the outer radius to leave room for labels outside
      // We can customize the data labels to display lots of information directly from the dataSource
      dataLabelSettings: DataLabelSettings(
        isVisible: true,
        useSeriesColor: false,
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ));
}
**/