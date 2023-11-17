// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' hide Axis;
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/template/template.dart';
import 'package:fml/widgets/chart_painter/bar/bar_series.dart';
import 'package:fml/widgets/chart_painter/chart_model.dart';
import 'package:fml/widgets/chart_painter/axis/chart_axis_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/chart_painter/bar/bar_chart_view.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:xml/xml.dart';

/// Chart [ChartModel]
///
/// Defines the properties used to build a Chart
class BarChartModel extends ChartPainterModel
{
  List<BarChartGroupData> barDataList = [];
  final List<BarChartSeriesModel> series = [];
  ChartAxisModel xaxis = ChartAxisModel(null, null, ChartAxis.X);
  ChartAxisModel yaxis = ChartAxisModel(null, null, ChartAxis.Y);
  num yMax = 0;
  num yMin = 0;

  BarChartModel(WidgetModel? parent, String? id,
      {
        dynamic type,
        dynamic showlegend,
        dynamic horizontal,
        dynamic animated,
        dynamic selected,
        dynamic legendsize,
      }) : super(parent, id) {
    this.selected         = selected;
    this.animated         = animated;
    this.horizontal       = horizontal;
    this.showlegend       = showlegend;
    this.legendsize       = legendsize;
    this.type             = type?.trim()?.toLowerCase();

    busy = false;
  }

  static BarChartModel? fromTemplate(WidgetModel parent, Template template)
  {
    BarChartModel? model;
    try
    {
      XmlElement? xml = Xml.getElement(node: template.document!.rootElement, tag: "BARCHART");
      xml ??= template.document!.rootElement;
      model = BarChartModel.fromXml(parent, xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'chart.Model');
      model = null;
    }
    return model;
  }

  static BarChartModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    BarChartModel? model;
    try
    {
      model = BarChartModel(parent, Xml.get(node: xml, tag: 'id'));
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

    /////////////////
    //* Properties */
    /////////////////
    selected        = Xml.get(node: xml, tag: 'selected');
    animated        = Xml.get(node: xml, tag: 'animated');
    horizontal      = Xml.get(node: xml, tag: 'horizontal');
    showlegend      = Xml.get(node: xml, tag: 'showlegend');
    legendsize      = Xml.get(node: xml, tag: 'legendsize');
    type            = Xml.get(node: xml, tag: 'type');

    // Set Series
    this.series.clear();
    List<BarChartSeriesModel> series = findChildrenOfExactType(BarChartSeriesModel).cast<BarChartSeriesModel>();
    for (var model in series)
    {
      // add the series to the list
      this.series.add(model);

      // register listener to the datasource
      IDataSource? source = (scope != null) ? scope!.getDataSource(model.datasource) : null;
      if (source != null) source.register(this);
    }


    // Set Axis
    List<ChartAxisModel> axis = findChildrenOfExactType(ChartAxisModel).cast<ChartAxisModel>();
    for (var axis in axis) {
      if (axis.axis == ChartAxis.X) xaxis = axis;

      if (axis.axis == ChartAxis.Y) yaxis = axis;
      yMax = toInt(yaxis.max) ?? 0;
      yMin = toInt(yaxis.min) ?? 0;
    }
  }

  /// Called when the databroker returns a successful result
  ///
  /// [ChartModel] overrides [WidgetModel]'s onDataSourceSuccess
  /// to populate the series data from the datasource and
  /// to populate the label data from the datasource data.
  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async
  {
    try
    {
      //here if the data strategy is category, we must fold all of the lists together and create a dummy key value map of every unique value, in order
      uniqueValues.clear();
      barDataList.clear();
      for (var serie in series) {

          serie.xValues.clear();
          // build the datapoints for the series, passing in the chart type, index, and data
          if (source.id == serie.datasource) {
            serie.xValues.clear();
            serie.plotPoints(list, uniqueValues);
          }
          if (serie.type == 'stacked' || serie.type == 'grouped') {
            uniqueValues.add(serie.name);
          }
          uniqueValues.addAll(serie.xValues);
          // add the built x values to a unique list to map to indeces

          barDataList.addAll(serie.barDataPoint);

          notifyListeners('list', null);


      }
    }
    catch(e)
    {
      Log().debug('Series onDataSourceSuccess() error');
      // DialogService().show(type: DialogType.error, title: phrase.error, description: e.message);
    }
    return true;
  }

  @override
  Widget getView({Key? key})
  {
    return getReactiveView(BarChartView(this));
  }
}