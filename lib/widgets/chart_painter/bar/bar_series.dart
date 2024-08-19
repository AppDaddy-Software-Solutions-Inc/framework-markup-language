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
  var previousGroup;

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
    dynamic width,
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
    this.width = width;
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
    width = Xml.get(node: xml, tag: 'width');

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
      }
        else {
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
        width: width,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radius ?? 2), topRight: Radius.circular(radius ?? 2)),
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
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radius ?? 2), topRight: Radius.circular(radius ?? 2)),
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
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radius ?? 2), topRight: Radius.circular(radius ?? 2)),
          color: color ?? toColor('random'))
    ]);
    barDataPoint.add(point);
  }

  void pointFromGYWaterfallBarData() {

    BarChartGroupDataExtended point;
    double fromY = toDouble(Data.read(data, "y0")) ?? 0;
    double toY = toDouble(Data.read(data, "y")) ?? 0;
    Color? color = toColor(Data.read(data, "color"));

      //get the current group color and track the group for single datasets
        point =
            BarChartGroupDataExtended(this, data, x: toInt(x) ?? 0, barRods: [
              BarChartRodDataExtended(this, data,
                  //borderSide: BorderSide(width: 2, strokeAlign: 1.0,),
                  backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      fromY: fromY == toY ? fromY + 0.05 : 0 ,
                      toY:  fromY == toY ? toY - 0.05 : 0 ,
                      color: color ?? toColor('random')),
                  fromY: fromY,
                  toY: toY,
                  width: width,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(radius ?? 2), topRight: Radius.circular(radius ?? 2)),
                  color: color ?? toColor('random'))
            ]);
      barDataPoint.add(point);
  }

  void pointFromGroupedBarData() {
    if (y == null) return;
    BarChartRodDataExtended point = BarChartRodDataExtended(this, data,
        fromY: toDouble(y0) ?? 0,
        toY: toDouble(y) ?? 0,
        color: color ?? toColor('random'),
      width: width,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius ?? 2), topRight: Radius.circular(radius ?? 2)),);


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

  addWaterfallData(dynamic data) {
    var d = data;
  }
}
