/**
// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/log/manager.dart';
import 'package:fml/event/event.dart' ;
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'dart:ui' as UI;
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:fml/template/template.dart';
import 'package:fml/widgets/column/column_view.dart' as COLUMN;
import 'package:fml/widgets/column/column_model.dart' as COLUMN;
import 'package:fml/widgets/busy/busy_view.dart' as BUSY;
import 'package:fml/widgets/busy/busy_model.dart' as BUSY;
import 'package:syncfusion_flutter_charts/charts.dart'  as SFCHARTS;
import 'package:fml/widgets/chart_syncfusion/chart_model.dart' as CHART;
import 'package:fml/widgets/chart_syncfusion/series/chart_series_model.dart' as SERIES;
import 'package:fml/widgets/chart_syncfusion/axis/chart_axis_model.dart' as AXIS;
import 'package:fml/widgets/chart_syncfusion/excerpts/functions.dart' as EXCERPT;
import 'package:uuid/uuid.dart';
import 'package:fml/helper/helper_barrel.dart';

import 'axis/chart_axis_model.dart';

/// Chart View
///
/// Builds a Chart View using [CHART.ChartModel], [SERIES.ChartSeriesModel], [AXIS.ChartAxisModel] and
/// [EXCERPT.Model] properties
class ChartView extends StatefulWidget
{
  final CHART.ChartModel model;
  ChartView(this.model) : super(key: ObjectKey(model));

  @override
  _ChartViewState createState() => _ChartViewState();
}

/// [CHART.ChartModel] properties object we process pass to the builder function in [EXCERPT.Model]
class SFChartProperties {
  SFChartProperties({this.plotBackgroundColor, this.plotBackgroundImage, this.legend, this.legendColor, this.legendposition, this.annotations, this.xAxis, this.yAxis, this.zoomPanEnabled, this.tooltipEnabled = true});
  final plotBackgroundImage;
  final plotBackgroundColor;
  final bool? legend;
  final legendColor;
  final legendposition;
  final List<SFCHARTS.CartesianChartAnnotation>? annotations;
  final Axis? xAxis;
  final Axis? yAxis;
  final bool? zoomPanEnabled;
  final bool tooltipEnabled;
}

/// [SERIES.ChartSeriesModel] properties object we process pass to the builder function in [EXCERPT.Model]
class SFSeriesProperties {
  SFSeriesProperties(this.name, this.type, this.chartData, {this.key, this.color, this.stroke, this.size, this.labelled = false, this.labelType, this.tooltips, this.animated = false});
  final String? key;
  final String? name;
  final String? type;
  final List<SFChartDataPoint> chartData;
  final UI.Color? color;
  final double? stroke;
  final double? size;
  final bool labelled;
  final String? labelType;
  final bool? tooltips;
  final bool animated;
}

/// [AXIS.ChartAxisModel] properties object we process pass to the builder function in [EXCERPT.Model]
class Axis {
  Axis({this.axis, this.dataType, this.format, this.name, this.minimum, this.maximum, this.visibleMinimum, this.visibleMaximum, this.interval, this.title, this.labelRotation, this.fontSize, this.fontColor, this.gridColor, this.intervalType, this.decimalPlaces, this.zoomFactor, this.zoomPosition});
  final String?    axis;
  final AxisType?  dataType;
  final String?    name;
  final String?    minimum;
  final String?    maximum;
  final String?    visibleMinimum;
  final String?    visibleMaximum;
  final dynamic   interval;
  final String?    intervalType;
  final String?    title;
  final int?       labelRotation;
  final int?       fontSize;
  final UI.Color?  fontColor;
  final UI.Color?  gridColor;
  final dynamic   decimalPlaces;
  final double?    zoomFactor;
  final double?    zoomPosition;
  final String?    format;
}

/// SFChartDataPoint object to extend the information stored in a point for custom labels and colors
class SFChartDataPoint {
  SFChartDataPoint(this.x, this.y, {this.label, this.color});
  final dynamic x;
  final dynamic y;
  final dynamic label;
  final UI.Color? color;
}

class _ChartViewState extends State<ChartView> implements IModelListener
{
  Future<Template>? template;
  Future<CHART.ChartModel>? chartViewModel;
  BUSY.BusyView? busy;

  var xAxis;
  var yAxis;

  bool canHide = false;

  
  @override
  void initState()
  {
    super.initState();

    // register model listener
    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();
  }

  @override
  didChangeDependencies()
  {
    // register event listeners

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(ChartView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.model != widget.model))
    {

      // de-register old model listener
      oldWidget.model.removeListener(this);

      // register model listener
      widget.model.registerListener(this);
    }
  }

  @override
  void dispose()
  {
    // de-register model listener
    widget.model.removeListener(this);

    // de-register event listeners

    super.dispose();
  }

  /// onZoom event handling function
  void onZoom(Event event)
  {
    Log().info('Chart Zoom Event');
    event.handled = true;
    if (event.parameters != null) {
      if (event.parameters!['zoom'] == 'reset') {
        EXCERPT.zoomPanBehavior.reset();
      }
      else if (event.parameters!['zoom'] == 'out') {
        EXCERPT.zoomPanBehavior.zoomOut();
      }
      else if (event.parameters!['zoom'] == 'in') {
        EXCERPT.zoomPanBehavior.zoomIn();
      }
    }
  }

  /// onMaximize event handling function
  void onMaximize(Event event)
  {
    event.handled = true;
  }
  
  /// Callback function for when the model changes, used to force a rebuild with setState()
  onModelChange(WidgetModel model,{String? property, dynamic value})
  {
    if (this.mounted) setState((){});
  }

  /// Callback function to build a tooltip
  Widget tooltipBuilder(dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex)
  {
    COLUMN.ColumnModel? model = widget.model.buildTooltip(series, pointIndex);
    return COLUMN.ColumnView(model ?? COLUMN.ColumnModel(null, Uuid().v1()));
  }

  /// Parser for databroker data to convert it from a String to appropriate data type if need be
  dynamic parsePlotPoint(String? val, AXIS.AxisType type) {
    if (type == AxisType.category) {
      return val;
    } else if (type == AxisType.numeric) {
      return num.tryParse(val!) ?? 0;
    } else if (type == AXIS.AxisType.date || type == AXIS.AxisType.time || type == AXIS.AxisType.datetime) {
      DateTime? formatted;
      formatted = S.toDate(val, format: 'yMd Hm');
      return formatted; //DateTime.tryParse(val);
    }
  }

  /// Legend Position
  SFCHARTS.LegendPosition stringToLegendPosition(String pos) {
    pos = pos.toLowerCase();
    switch (pos) {
      case 'top':
        return SFCHARTS.LegendPosition.top;
      case 'bottom':
        return SFCHARTS.LegendPosition.bottom;
      case 'left':
        return SFCHARTS.LegendPosition.left;
      case 'right':
        return SFCHARTS.LegendPosition.right;
      default:
        return SFCHARTS.LegendPosition.bottom;
    }
  }

  /// Chart View Builder Function
  ///
  /// Preprocesses of all the chart properties into interchangable variables
  /// Call the appropriate chart type builder function with correct parameters
  /// Returns the fully plotted Chart based on this [ChartView]'s values.
  buildSFChart({AssetImage? plotBg, String? chartType, BuildContext? context})
  {

    // Determine if chart type is Cartesian or Pie based
    bool isCartesianChartType = chartType?.toLowerCase() != 'circle' && chartType?.toLowerCase() != 'circular' && chartType?.toLowerCase() != 'pie';
    Log().info('isCartesianType: $isCartesianChartType');

    //////////////////
    /* Chart Series */
    //////////////////
    SFChartProperties? propsSFChart;                       // Chart Properties
    List<SFSeriesProperties> chartSFSeriesPropertiesList; // Series Properties
    chartSFSeriesPropertiesList = [];

    // Loop through each series
    for (SERIES.ChartSeriesModel series in widget.model.series) {
        List<SFChartDataPoint> chartSFSeriesList = [];
        // Loop through each point
        for (SERIES.Point plot in series.points) {
          // Parse x and y data values from the databroker string values
          if (!S.isNullOrEmpty(plot.x)) { // y value can be null, creating a gap in the chart
            var xParsed;
            var yParsed;
            try {
              xParsed = parsePlotPoint(plot.x, widget.model.xaxis.type);
            } catch(e) { Log().error(e.toString()); Log().info("chart view source parsing x val: ${plot.x?.toString() ?? 'null'}"); break; }
            try {
              yParsed = S.isNullOrEmpty(plot.y) ? null : parsePlotPoint(plot.y, widget.model.yaxis.type);
            } catch(e) { Log().error(e.toString()); Log().info("chart view source parsing y val: ${plot.y?.toString() ?? 'null'}"); break; }
            var xVal = xParsed;
            var yVal = yParsed;
            // get label
            var label = S.isNullOrEmpty(plot.label) ? null : plot.label.trim();
            // Add to point list
            if (series.labelled != true || label != null)
              chartSFSeriesList.add(SFChartDataPoint(xVal, yVal,
                  color: plot.color,
                  label: label));
          }
        }
        // Set series color
        UI.Color? seriesColor = series.color; // ?? Colors.transparent
        // Add to series list
        chartSFSeriesPropertiesList.add(
            SFSeriesProperties(
              series.name, series.type, chartSFSeriesList,
              key: widget.model.id, // key
              color: seriesColor,
              stroke: series.stroke,
              size: series.size,
              labelled: series.labelled ?? false,
              labelType: series.labelType ?? "string",
              tooltips: series.tooltips ?? false,
              animated: series.animated ?? false,
            )
        );
    }

    /// X Axis view properties
    var xAxisProps = Axis(
      axis:           'x',
      dataType:       widget.model.xaxis.type,
      name:           'X axis', // do not change without modifying all usages
      minimum:        widget.model.xaxis.minimum,
      maximum:        widget.model.xaxis.maximum,
      visibleMinimum: widget.model.xaxis.visibleminimum,
      visibleMaximum: widget.model.xaxis.visiblemaximum,
      interval:       widget.model.xaxis.interval,
      intervalType:   widget.model.xaxis.intervaltype,
      title:          widget.model.xaxis.title,
      format:         widget.model.xaxis.format,
      labelRotation:  widget.model.xaxis.labelrotation,
      fontSize:       widget.model.xaxis.fontsize,
      fontColor:      widget.model.xaxis.fontcolor ?? Theme.of(context!).colorScheme.onBackground,
      gridColor:      widget.model.xaxis.gridcolor ?? Theme.of(context!).colorScheme.surfaceVariant,
      decimalPlaces:   1,
      zoomFactor:     widget.model.xaxis.zoomfactor,
      zoomPosition:   widget.model.xaxis.zoomposition,
    );

    /// Y Axis view properties
    var yAxisProps = Axis(
      axis:           'y',
      dataType:       widget.model.yaxis.type,
      name:           'Y axis', // do not change without modifying all usages
      minimum:        widget.model.yaxis.minimum,
      maximum:        widget.model.yaxis.maximum,
      visibleMinimum: widget.model.yaxis.visibleminimum,
      visibleMaximum: widget.model.yaxis.visiblemaximum,
      interval:       widget.model.yaxis.interval,
      title:          widget.model.yaxis.title,
      labelRotation:  widget.model.yaxis.labelrotation,
      fontSize:       widget.model.yaxis.fontsize,
      fontColor:      widget.model.yaxis.fontcolor ?? Theme.of(context!).colorScheme.onBackground,
      gridColor:      widget.model.yaxis.gridcolor ?? Theme.of(context!).colorScheme.onInverseSurface,
      decimalPlaces:   1,
      zoomFactor:     widget.model.yaxis.zoomfactor,
      zoomPosition:   widget.model.yaxis.zoomposition,
    );

    if (widget.model.series.isEmpty) Log().debug("Error: empty series [ chart.view ]");

    propsSFChart = SFChartProperties(
      xAxis: xAxisProps,
      yAxis: yAxisProps,
      plotBackgroundColor: widget.model.backgroundcolor ?? Colors.transparent,
      plotBackgroundImage: widget.model.backgroundimage,
      legend: widget.model.showlegend ?? true,
      legendColor: widget.model.legendcolor ?? Theme.of(context!).colorScheme.primaryContainer,
      legendposition: stringToLegendPosition(widget.model.legendposition),
      tooltipEnabled: true,
      zoomPanEnabled: widget.model.disablezoom == null ? true : (!widget.model.disablezoom!),
      annotations: null, // we handle these outside of syncfusion charts or with a plot // ANNOTATIONS.buildAnnotations([]),
    );

    final SFChartProperties? chartProps = propsSFChart; // grab chartProps for series properties use

    /// Axis builder function
    SFCHARTS.ChartAxis? buildAxis(axis, String whichAxis) {
      var aAxis;
      switch(axis.dataType) {
        case AxisType.numeric:
          aAxis = EXCERPT.numericAxis(axis);
          break;
        case AxisType.category:
          aAxis = EXCERPT.categoryAxis(axis);
          break;
        case AxisType.date:
        case AxisType.datetime:
        case AxisType.time:
          aAxis = EXCERPT.dateTimeAxis(axis);
          break;
        case AxisType.logarithmic:
          aAxis = EXCERPT.logarithmicAxis(axis);
          break;
      // Defaults handled by respective axis
      }
      whichAxis == 'x' ? xAxis = aAxis : yAxis = aAxis;
      return aAxis;
    }

    /// Cartesian Series Builder Function
    List<SFCHARTS.CartesianSeries<dynamic, dynamic>> cartesianSeriesBuilder(List<SFSeriesProperties> chartSFSeriesPropertiesList) {
      List<SFCHARTS.CartesianSeries> cartesianSeries = [];

      for (int i = 0; i < chartSFSeriesPropertiesList.length; i++) {
        SFSeriesProperties seriesProps = chartSFSeriesPropertiesList[i];
        switch (seriesProps.type) {
          case 'bar':
            var s = EXCERPT.barSeries(seriesProps, chartProps);
            widget.model.series[i].setSFSeries(s);
            cartesianSeries.add(s);
            break;
          case 'stackedbar':
            var s = EXCERPT.stackedbarSeries(seriesProps, chartProps);
            widget.model.series[i].setSFSeries(s);
            cartesianSeries.add(s);
            break;
          case 'percentstackedbar':
            var s = EXCERPT.percentstackedbarSeries(seriesProps, chartProps);
            widget.model.series[i].setSFSeries(s);
            cartesianSeries.add(s);
            break;
          case 'waterfall':
            var s = EXCERPT.waterfallSeries(seriesProps, chartProps);
            widget.model.series[i].setSFSeries(s);
            cartesianSeries.add(s);
            break;
          case 'sidebar':
            var s = EXCERPT.sidebarSeries(seriesProps, chartProps);
            widget.model.series[i].setSFSeries(s);
            cartesianSeries.add(s);
            break;
          case 'area':
            var s = EXCERPT.areaSeries(seriesProps, chartProps!);
            widget.model.series[i].setSFSeries(s); // needed for tooltips
            cartesianSeries.add(s);
            break;
          case 'spline':
            var s = EXCERPT.splineSeries(seriesProps, chartProps);
            widget.model.series[i].setSFSeries(s); // needed for tooltips
            cartesianSeries.add(s);
            break;
          case 'line':
            var s = EXCERPT.lineSeries(seriesProps, chartProps);
            widget.model.series[i].setSFSeries(s); // needed for tooltips
            cartesianSeries.add(s);
            break;
          case 'fastline':
            var s = EXCERPT.fastlineSeries(seriesProps, chartProps);
            widget.model.series[i].setSFSeries(s);
            cartesianSeries.add(s);
            break;
          case 'plot':
            var s = EXCERPT.plotSeries(seriesProps, chartProps);
            widget.model.series[i].setSFSeries(s);
            cartesianSeries.add(s);
            break;
          case 'label':
            var s = EXCERPT.labelSeries(seriesProps, chartProps);
            widget.model.series[i].setSFSeries(s);
            cartesianSeries.add(s);
            break;
          default:
            Log().debug('Unable to determine cartesian series type');
            break;
        }
      }
      return cartesianSeries;
    }

    /// Circle Series Builder Function
    List<SFCHARTS.CircularSeries<dynamic, dynamic>> circularSeriesBuilder(List<SFSeriesProperties> chartSFSeriesPropertiesList) {
      List<SFCHARTS.CircularSeries> circularSeries = [];

      for (int i = 0; i < chartSFSeriesPropertiesList.length; i++)
      {
        SFSeriesProperties seriesProps = chartSFSeriesPropertiesList[i];
        switch (seriesProps.type) {
          case 'pie':
          case 'explodedpie':
            circularSeries.add(EXCERPT.pieSeries(seriesProps));
            break;
          case 'doughnut':
          case 'explodeddoughnut':
            circularSeries.add(EXCERPT.doughnutSeries(seriesProps));
            break;
          case 'radial':
          case 'radialbar':
            circularSeries.add(EXCERPT.radialSeries(seriesProps));
            break;
          default:
            Log().debug('Unable to determine circular series type');
            break;
        }
      }
      return circularSeries;
    }

    /// Chart Builder Function
    try {
      var chart = (isCartesianChartType == true ?
      EXCERPT.cartesianChart(chartProps!, buildAxis, widget.model.setZoomX, widget.model.setZoomY, cartesianSeriesBuilder, chartSFSeriesPropertiesList, tooltipBuilder, plotBg)
          : EXCERPT.circleChart(chartProps, circularSeriesBuilder, chartSFSeriesPropertiesList, tooltipBuilder)); // var chart

      return chart;
    } catch (e) {
      Log().exception(e, caller: 'chart -> buildSFChart()');
      return Container();
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Set Build Constraints in the [WidgetModel]
      widget.model.minwidth  = constraints.minWidth;
      widget.model.maxwidth  = constraints.maxWidth;
      widget.model.minheight = constraints.minHeight;
      widget.model.maxheight = constraints.maxHeight;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    List<Widget> children = [];

    // Background image
    var backgroundImage;
    if (!S.isNullOrEmpty(widget.model.backgroundimage)) backgroundImage = AssetImage(widget.model.backgroundimage!); // backgroundImage = System().getImage(widget.model.backgroundimage, fade: false, fit: "cover");

    // Build Chart
    var chart = buildSFChart(plotBg: backgroundImage ?? null, chartType: widget.model.type, context: context);
    // Prioritize chart ux interactions
    chart = Listener(behavior: HitTestBehavior.opaque, child: chart);
    if (chart != null) children.add(new SafeArea(child: chart));

    // Add children
    if (widget.model.children != null)
      widget.model.children!.forEach((model)
      {
        if (model is IViewableWidget) {
          children.add((model as IViewableWidget).getView());
        }
      });

    /// Busy / Loading Indicator
    if (busy == null) busy = BUSY.BusyView(BUSY.BusyModel(widget.model, visible: widget.model.busy, observable: widget.model.busyObservable));
    children.add(Center(child: busy));

    // Display children over chart
    Widget view = Stack(children: children, fit: StackFit.loose);

    //////////////////
    /* Constrained? */
    //////////////////
    if (true) //  Always constrain based on parent constraints
        {
      Map<String,double?> constraints = widget.model.constraints;
      view = ConstrainedBox(child: Padding(padding: EdgeInsets.only(bottom: 30.0), child: view), constraints: BoxConstraints(
          minHeight: constraints.minHeight!, maxHeight: constraints.maxHeight!,
          minWidth: constraints.minWidth!, maxWidth: constraints.maxWidth!));
    }

    return view;
  }
}
**/