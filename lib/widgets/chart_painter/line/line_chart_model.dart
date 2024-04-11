// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' hide Axis;
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/template/template.dart';
import 'package:fml/widgets/chart_painter/axis/chart_axis_model.dart';
import 'package:fml/widgets/chart_painter/series/chart_series_extended.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:xml/xml.dart';
import '../chart_model.dart';
import 'line_chart_view.dart';
import 'line_series.dart';

/// Chart [ChartModel]
///
/// Defines the properties used to build a Chart
class LineChartModel extends ChartPainterModel {
  ChartAxisModel xaxis = ChartAxisModel(null, null, ChartAxis.X);
  ChartAxisModel yaxis = ChartAxisModel(null, null, ChartAxis.Y);
  num? yMax;
  num? yMin;
  Map<int, dynamic> uniqueValueMap = {};
  final List<LineChartSeriesModel> series = [];
  List<LineChartBarData> lineDataList = [];

  @override
  bool get canExpandInfinitelyWide {
    if (hasBoundedWidth) return false;
    return true;
  }

  @override
  bool get canExpandInfinitelyHigh {
    if (hasBoundedHeight) return false;
    return true;
  }

  LineChartModel(
    super.parent,
    super.id, {
    dynamic type,
    dynamic showlegend,
    dynamic horizontal,
    dynamic animated,
    dynamic legendsize,
  }) {
    this.animated = animated;
    this.horizontal = horizontal;
    this.showlegend = showlegend;
    this.legendsize = legendsize;
    this.type = type?.trim()?.toLowerCase();

    busy = false;
  }

  static LineChartModel? fromTemplate(WidgetModel parent, Template template) {
    LineChartModel? model;
    try {
      XmlElement? xml =
          Xml.getElement(node: template.document!.rootElement, tag: "CHART");
      xml ??= template.document!.rootElement;
      model = LineChartModel.fromXml(parent, xml);
    } catch (e) {
      Log().exception(e, caller: 'chart.Model');
      model = null;
    }
    return model;
  }

  static LineChartModel? fromXml(WidgetModel parent, XmlElement xml) {
    LineChartModel? model;
    try {
      model = LineChartModel(parent, Xml.get(node: xml, tag: 'id'));
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
    //deserialize xml
    super.deserialize(xml);
    animated = Xml.get(node: xml, tag: 'animated');
    horizontal = Xml.get(node: xml, tag: 'horizontal');
    showlegend = Xml.get(node: xml, tag: 'showlegend');
    legendsize = Xml.get(node: xml, tag: 'legendsize');
    type = Xml.get(node: xml, tag: 'type');

    // Set Series
    this.series.clear();
    List<LineChartSeriesModel> series =
        findChildrenOfExactType(LineChartSeriesModel)
            .cast<LineChartSeriesModel>();
    for (var model in series) {
      // add the series to the list
      this.series.add(model);

      // register listener to the datasource
      IDataSource? source =
          (scope != null) ? scope!.getDataSource(model.datasource) : null;
      if (source != null) source.register(this);
    }

    // Set Axis
    List<ChartAxisModel> axis =
        findChildrenOfExactType(ChartAxisModel).cast<ChartAxisModel>();
    for (var axis in axis) {
      if (axis.axis == ChartAxis.X) xaxis = axis;

      if (axis.axis == ChartAxis.Y) yaxis = axis;
      yMax = toInt(yaxis.max);
      yMin = toInt(yaxis.min);
    }
  }

  /// Called when the databroker returns a successful result
  ///
  /// [ChartModel] overrides [WidgetModel]'s onDataSourceSuccess
  /// to populate the series data from the datasource and
  /// to populate the label data from the datasource data.
  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async {
    try {
      //here if the data strategy is category, we must fold all of the lists together and create a dummy key value map of every unique value, in order
      uniqueValues.clear();
      lineDataList.clear();
      for (var serie in series) {
        if (serie.datasource == source.id) {
          // build the datapoints for the series, passing in the chart type, index, and data
          if (xaxis.type == "raw") {
            serie.plotRawPoints(list, uniqueValues);
          } else if (xaxis.type == "category") {
            //with category, we may need to change the xValues to a map rather than a set for when multiple points are there
            serie.plotCategoryPoints(list, uniqueValues);
          } else if (xaxis.type == "date") {
            serie.plotDatePoints(list, format: xaxis.format);
          } else {
            serie.plotPoints(list);
          }
          notifyListeners('list', null);
        }

        uniqueValues.addAll(serie.xValues);

        serie.lineDataPoint.sort((a, b) => a.x.compareTo(b.x));
        serie.color ??= toColor('random');
        lineDataList.add(LineChartBarData(
            spots: serie.lineDataPoint,
            isCurved: serie.curved,
            belowBarData: BarAreaData(show: serie.showarea),
            dotData: FlDotData(show: serie.showpoints),
            barWidth: serie.type == 'point' || serie.showline == false
                ? 0
                : serie.stroke ?? 2,
            color: serie.color));
        serie.xValues.clear();
      }
    } catch (e) {
      Log().debug('Series onDataSourceSuccess() error');
      // DialogService().show(type: DialogType.error, title: phrase.error, description: e.message);
    }
    return true;
  }

  @override
  List<Widget> getTooltips(List<IExtendedSeriesInterface> spots) {
    List<Widget> views = [];
    for (var spot in spots) {
      var series =
          this.series.firstWhereOrNull((element) => element == spot.series);
      views.addAll(buildTooltip(series, spot));
    }
    return views;
  }

  @override
  Widget getView({Key? key}) {
    return getReactiveView(LineChartView(this));
  }
}
