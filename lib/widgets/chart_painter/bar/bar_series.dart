// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fml/data/data.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/chart_painter/series/chart_series_extended.dart';
import 'package:fml/widgets/chart_painter/series/chart_series_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

/// ChartDataPoint Object
///
/// Holds the plot values for each data node in the series
class ChartDataPoint {
  final Color? color;
  final dynamic label;
  final dynamic x;
  final dynamic y;

  ChartDataPoint({this.x, this.y, this.color, this.label});
}

/// Chart Series [BarChartSeriesModel]
///
/// Defines the properties used to build a Charts's Series
class BarChartSeriesModel extends ChartPainterSeriesModel {
  List<BarChartGroupData> barDataPoint = [];
  List<BarChartRodData> rodDataPoint = [];
  List<BarChartRodStackItem> stackDataPoint = [];
  var previousColor;
  Color? currentColor;

  BarChartSeriesModel(
    super.parent,
    super.id, {
    dynamic x,
    dynamic y,
    dynamic color,
    dynamic stroke,
    dynamic radius,
    dynamic size,
    dynamic label,
    dynamic type,
    dynamic animated,
    dynamic name,
    dynamic group,
    dynamic stack,
    dynamic showarea,
    dynamic showline,
    dynamic showpoints,
  }) {
    data = Data();
    this.x = x;
    this.y = y;
    this.color = color;
    this.stroke = stroke;
    this.radius = radius;
    this.size = size;
    this.label = label;
    this.name = name;
    this.group = group;
    this.stack = stack;
    this.showarea = showarea;
    this.showline = showline;
    this.showpoints = showpoints;
  }

  static BarChartSeriesModel? fromXml(Model parent, XmlElement xml) {
    BarChartSeriesModel? model;
    try {
      model = BarChartSeriesModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'chart.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);

    // properties
    x = Xml.get(node: xml, tag: 'x');
    y = Xml.get(node: xml, tag: 'y');
    color = Xml.get(node: xml, tag: 'color');
    stroke = Xml.get(node: xml, tag: 'stroke');
    radius = Xml.get(node: xml, tag: 'radius');
    size = Xml.get(node: xml, tag: 'size');
    type = Xml.get(node: xml, tag: 'type');
    label = Xml.get(node: xml, tag: 'label');
    name = Xml.get(node: xml, tag: 'name');
    group = Xml.get(node: xml, tag: 'group');
    stack = Xml.get(node: xml, tag: 'stack');
    showarea = Xml.get(node: xml, tag: 'showarea');
    showline = Xml.get(node: xml, tag: 'showline');
    showpoints = Xml.get(node: xml, tag: 'showpoints');

    // Remove datasource listener. The parent chart will take care of this.
    if ((datasource != null) &&
        (scope != null) &&
        (scope!.datasources.containsKey(datasource))) {
      scope!.datasources[datasource!]!.remove(this);
    }

    // Setup the Series type and some internal properties for supporting it
    if (type != null) type = type?.trim().toLowerCase();
  }

  /// bar width
  DoubleObservable? width_;
  set width(dynamic v) {
    if (width_ != null) {
      width_!.set(v);
    } else if (v != null) {
      width_ = DoubleObservable(Binding.toKey(id, 'width'), v, scope: scope);
    }
  }

  double get width => width_?.get() ?? 3.5;

  @override
  // we purposely don't want to do anything on change since there is no view
  // and the entire chart gets rebuilt
  void onPropertyChange(Observable observable) {}

  //This function takes in the function related to the type of point plotted
  void plotPoints(dynamic dataList, List uniqueValues) {
    xValues.clear();
    barDataPoint.clear();

    var type = this.type?.toLowerCase().trim();

    switch (type) {
      case 'stacked':
        stackDataPoint.clear();
        plotFunction = pointFromStackedBarData;
        break;

      case 'grouped':
        rodDataPoint.clear();
        plotFunction = pointFromGroupedBarData;
        barDataPoint.add(BarChartGroupDataExtended(this, data,
            x: uniqueValues.length, barRods: rodDataPoint));
        break;

      case 'waterfall':
        plotFunction = pointFromWaterfallBarData;
        break;

      // this case is specific to how goodyear visualises their waterfall data.
      case 'gywaterfall':
        plotFunction = pointFromGYWaterfallBarData;
        break;

      case 'bar':
      default:
        plotFunction = pointFromBarData;
        break;
    }

    int len = uniqueValues.length;
    for (var i = 0; i < dataList.length; i++) {
      //set the data of the series for databinding
      data = dataList[i];

      if (type == 'bar' || type == 'waterfall' || type == null || type == "gywaterfall") {
        xValues.add(x);
        x = len;
        len += 1;
      } else {
        x = len;
      }
      plotFunction!();
    }

    if (type == 'stacked') {
      stackDataPoint.sort((b, a) => a.toY.compareTo(b.toY));
      barDataPoint.add(BarChartGroupDataExtended(this, data,
          x: uniqueValues.length,
          barRods: [
            BarChartRodDataExtended(this, data,
                toY: stackDataPoint[0].toY,
                color: Colors.transparent,
                rodStackItems: stackDataPoint)
          ]));
    }

    dataList = null;
  }

  void pointFromBarData() {
    if (y == null) return;
    BarChartGroupDataExtended point =
        BarChartGroupDataExtended(this, data, x: toInt(x) ?? 0, barRods: [
      BarChartRodDataExtended(this, data,
          fromY: toDouble(y0) ?? 0,
          toY: toDouble(y) ?? 0,
          width: width,
          color: color ?? toColor('random'))
    ]);
    barDataPoint.add(point);
  }

  void pointFromWaterfallBarData() {
    if (y == null) return;
    BarChartGroupDataExtended point =
        BarChartGroupDataExtended(this, data, x: toInt(x) ?? 0, barRods: [
      BarChartRodDataExtended(this, data,
          fromY: barDataPoint.isNotEmpty
              ? barDataPoint[(barDataPoint.length - 1)].barRods[0].toY
              : 0,
          toY: toDouble(y) ?? 0,
          width: width,
          color: color ?? toColor('random'))
    ]);
    barDataPoint.add(point);
  }

  void pointFromGYWaterfallBarData() {
    if (y == null) return;




    //get the previous toY value
    double? prevY = barDataPoint.isNotEmpty
        ? barDataPoint.last.barRods[0].fromY
        : 0;

    //if the barDataPoints y value is 0, and the previous toY value is 0, then we set this toY to 100
    //this is to ensure that the waterfall chart starts at 100
    if (toDouble(y) == 0 && prevY == 0) {
      prevY = 100;
    }



    //get the expected Y value of this point; If it is 0, then we use the previous toY
    double? thisY;
    if(prevY == 0){
      thisY = barDataPoint.last.barRods[0].fromY - (toDouble(y) ?? 0);
    } else {
      thisY = prevY - (toDouble(y) ?? 0);
    }


    //get the current group color and track the group for single datasets
    if(previousColor != color ){
      BarChartGroupDataExtended point;
      if(previousColor == null) {
        point =
            BarChartGroupDataExtended(this, data, x: toInt(x) ?? 0, barRods: [
              BarChartRodDataExtended(this, data,
                  //borderSide: BorderSide(width: 2, strokeAlign: 1.0,),
                  fromY: 0,
                  toY: 100,
                  width: width,
                  color: color ?? toColor('random'))
            ]);
        barDataPoint.add(point);
      } else {
        point =
            BarChartGroupDataExtended(this, data, x: toInt(x) ?? 0, barRods: [
              BarChartRodDataExtended(this, data,
                  //borderSide: BorderSide(width: 2, strokeAlign: 1.0,),
                  fromY: 0,
                  toY: barDataPoint.last.barRods[0].fromY,
                  width: width,
                  color: barDataPoint.last.barRods[0].color ?? toColor('random'))
            ]);
        barDataPoint.add(point);
      }

    }

    previousColor = color;


    BarChartGroupDataExtended point =
    BarChartGroupDataExtended(this, data, x: toInt(x) ?? 0, barRods: [
      BarChartRodDataExtended(this, data,
          //borderSide: BorderSide(width: 2, strokeAlign: 1.0,),
          backDrawRodData: BackgroundBarChartRodData(
              show: true,
              fromY: prevY == thisY? thisY + 0.05 : thisY,
              toY:   prevY ==  thisY? prevY - 0.05 : prevY,
              color: color ?? currentColor ?? toColor('random')),
          fromY: thisY,
          toY: prevY,
          width: width,
          color: color ?? toColor('random'))
    ]);


    barDataPoint.add(point);
  }

  void pointFromGroupedBarData() {
    if (y == null) return;
    BarChartRodDataExtended point = BarChartRodDataExtended(this, data,
        fromY: toDouble(y0) ?? 0,
        toY: toDouble(y) ?? 0,
        color: color ?? toColor('random'));
    rodDataPoint.add(point);
  }

  void pointFromStackedBarData() {
    //barchartrodstackitem allows stacking within series group.
    BarChartRodStackItemExtended point = BarChartRodStackItemExtended(
        this,
        data,
        toDouble(y0) ?? 0,
        toDouble(y) ?? 0,
        color ?? toColor('random') ?? Colors.blue);
    stackDataPoint.add(point);
  }
}
