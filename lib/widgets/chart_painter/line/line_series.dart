// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fml/data/data.dart';
import 'package:fml/log/manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:fml/widgets/chart_painter/series/chart_series_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
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

/// Chart Series [ChartSeriesModel]
///
/// Defines the properties used to build a Charts's Series
class LineChartSeriesModel extends ChartPainterSeriesModel
{
  List<FlSpot> lineDataPoint = [];
  Map<int, dynamic> xValueMap = {};
  @override

  LineChartSeriesModel(
      WidgetModel parent,
      String? id, {
        dynamic x,
        dynamic y,
        dynamic color,
        dynamic stroke,
        dynamic radius,
        dynamic size,
        dynamic label,
        dynamic tooltips,
        dynamic animated,
        dynamic name,
        dynamic group,
        dynamic stack,
        dynamic showarea,
        dynamic showline,
        dynamic showpoints,
      }
      ) : super(parent, id)
  {
    data = Data();
    this.x = x;
    this.y = y;
    this.color = color;
    this.stroke = stroke;
    this.radius = radius;
    this.size = size;
    this.label = label;
    this.tooltips = tooltips;
    this.name = name;
    this.group = group;
    this.stack = stack;
    this.showarea = showarea;
    this.showline = showline;
    this.showpoints = showpoints;
  }

  static LineChartSeriesModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    LineChartSeriesModel? model;
    try
    {
      xml = prototypeOf(xml) ?? xml;
      model = LineChartSeriesModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'chart.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    //* Deserialize */
    super.deserialize(xml);

    // properties
    x           = Xml.get(node: xml, tag: 'x');
    y           = Xml.get(node: xml, tag: 'y');
    color       = Xml.get(node: xml, tag: 'color');
    stroke      = Xml.get(node: xml, tag: 'stroke');
    radius      = Xml.get(node: xml, tag: 'radius');
    size        = Xml.get(node: xml, tag: 'size');
    type        = Xml.get(node: xml, tag: 'type');
    label       = Xml.get(node: xml, tag: 'label');
    tooltips    = Xml.get(node: xml, tag: 'tooltips');
    name        = Xml.get(node: xml, tag: 'name');
    group       = Xml.get(node: xml, tag: 'group');
    stack       = Xml.get(node: xml, tag: 'stack');
    showarea    = Xml.get(node: xml, tag: 'showarea');
    showline    = Xml.get(node: xml, tag: 'showline');
    showpoints  = Xml.get(node: xml, tag: 'showpoints');

    // Remove datasource listener. The parent chart will take care of this.
    if ((datasource != null) && (scope != null) && (scope!.datasources.containsKey(datasource))) scope!.datasources[datasource!]!.remove(this);

    // Setup the Series type and some internal properties for supporting it
    if (type != null) type = type?.trim().toLowerCase();
  }

  void plotCategoryPoints(dynamic dataList, List uniqueValues){
    xValues.clear();
    lineDataPoint.clear();
    int len = uniqueValues.length - 1;
    for (var i=0; i< dataList.length; i++) {
      //set the data of the series for databinding
      data = dataList[i];

      if(uniqueValues.isNotEmpty && uniqueValues.contains(x)) {
        x = uniqueValues.indexOf(x);
      }
      else {
        xValues.add(x);
        x = len + 1;
        len += 1;
      }
        //plot the point as a point object based on the desired function based on series and chart type.
        plot();
    }
    dataList = null;
  }

  void plotRawPoints(dynamic dataList, List uniqueValues){
    xValues.clear();
    lineDataPoint.clear();
    int len = uniqueValues.length;
    for (var i=0; i< dataList.length; i++) {
      //set the data of the series for databinding
      data = dataList[i];
      xValues.add(x);
      x = len;
      len += 1;
      plot();
    }
    dataList = null;
  }

  void plotDatePoints(dynamic dataList, {String? format}){
    xValues.clear();
    lineDataPoint.clear();
    for (var i=0; i< dataList.length; i++) {
      //set the data of the series for databinding
      data = dataList[i];
          x = toDate(x, format: format ?? 'yyyy/MM/dd')?.millisecondsSinceEpoch;
          //plot the point as a point object based on the desired function based on series and chart type.
        plot();
    }
    dataList = null;
  }

  void plotPoints(dynamic dataList){
    xValues.clear();
    lineDataPoint.clear();
    for (var i=0; i< dataList.length; i++) {
      //set the data of the series for databinding
      data = dataList[i];
      //plot the point as a point object based on the desired function based on series and chart type.
      plot();
    }
    dataList = null;
  }

  void plot(){
    FlSpot point = FlSpot(toDouble(x) ?? 0, toDouble(y) ?? 0);
    lineDataPoint.add(point);
  }
}
