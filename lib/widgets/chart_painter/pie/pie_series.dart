// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fml/data/data.dart';
import 'package:fml/log/manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:fml/widgets/chart_painter/series/chart_series_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

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
class PieChartSeriesModel extends ChartPainterSeriesModel
{
  List<PieChartSectionData> pieDataPoint = [];

  PieChartSeriesModel(
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

  static PieChartSeriesModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    PieChartSeriesModel? model;
    try
    {
      xml = WidgetModel.prototypeOf(xml) ?? xml;
      model = PieChartSeriesModel(parent, Xml.get(node: xml, tag: 'id'));
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

  @override
  // we purposely don't want to do anything on change since there is no view
  // and the entire chart gets rebuilt
  void onPropertyChange(Observable observable) {}
  //
  // void plotLineCategoryPoints(dynamic uniqueXValueList){
  //
  //   for (var pointData in dataList) {
  //     //set the data of the series for databinding
  //     data = pointData;
  //     //ensure the value is in the list, it always should be.
  //     if (uniqueXValueList.contains(S.toInt(x))) {
  //       x = uniqueXValueList.toList().indexOf(S.toInt(x));
  //       //plot the point as a point object based on the desired function based on series and chart type.
  //       pointFromPieData();
  //     }
  //     data = null;
  //
  //   }
  //   dataList = null;
  // }

  void plotPoints(dynamic dataList){
    for (var i=0; i< dataList.length; i++) {
      //set the data of the series for databinding
      data = dataList[i];
      //plot the point as a point object based on the desired function based on series and chart type.
      plot();
    }
    dataList = null;
  }

  void plot(){
    PieChartSectionData point = PieChartSectionData(value: S.toDouble(y) ?? 0, title: x, radius: radius, color: color ?? ColorHelper.fromString('random'));
    pieDataPoint.add(point);
  }

}