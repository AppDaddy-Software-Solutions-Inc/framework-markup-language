// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' hide Axis;
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/template/template.dart';
import 'package:fml/widgets/chart_painter/chart_model.dart';
import 'package:fml/widgets/chart_painter/pie/pie_chart_view.dart';
import 'package:fml/widgets/chart_painter/pie/pie_series.dart';
import 'package:fml/widgets/chart_painter/series/chart_series_extended.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:xml/xml.dart';

/// Chart [ChartModel]
///
/// Defines the properties used to build a Chart
class PieChartModel extends ChartPainterModel
{
  final List<PieChartSeriesModel> series = [];

  // for some reason, it seems important to keep this as List<PieChartSectionData>
  // rather than List<MyPie>. The pie chart appears briefly, the disappears otherwise.
  List<PieChartSectionData> pieData = [];

  @override
  bool get canExpandInfinitelyWide
  {
    if (hasBoundedWidth) return false;
    return true;
  }

  @override
  bool get canExpandInfinitelyHigh
  {
    if (hasBoundedHeight) return false;
    return true;
  }

  PieChartModel(WidgetModel parent, String? id,
      {
        dynamic type,
        dynamic showlegend,
        dynamic horizontal,
        dynamic centerRadius,
        dynamic spacing,
        dynamic animated,
        dynamic selected,
        dynamic legendsize,
      }) : super(parent, id) {
    this.selected         = selected;
    this.centerRadius     = centerRadius;
    this.spacing          = spacing;
    this.animated         = animated;
    this.horizontal       = horizontal;
    this.showlegend       = showlegend;
    this.legendsize       = legendsize;
    this.type             = type?.trim()?.toLowerCase();

    busy = false;
  }

  static PieChartModel? fromTemplate(WidgetModel parent, Template template)
  {
    PieChartModel? model;
    try
    {
      XmlElement? xml = Xml.getElement(node: template.document!.rootElement, tag: "CHART");
      xml ??= template.document!.rootElement;
      model = PieChartModel.fromXml(parent, xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'chart.Model');
      model = null;
    }
    return model;
  }

  static PieChartModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    PieChartModel? model;
    try
    {
      model = PieChartModel(parent, Xml.get(node: xml, tag: 'id'));
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
    spacing         = Xml.get(node: xml, tag: 'spacing');
    centerRadius    = Xml.get(node: xml, tag: 'centerradius');

    // Set Series
    this.series.clear();
    List<PieChartSeriesModel> series = findChildrenOfExactType(PieChartSeriesModel).cast<PieChartSeriesModel>();
    for (var model in series)
    {
      // add the series to the list
      this.series.add(model);

      // register listener to the datasource
      IDataSource? source = (scope != null) ? scope!.getDataSource(model.datasource) : null;
      if (source != null) source.register(this);
    }

  }

  /// Sets the font size of the legend labels
  DoubleObservable? _centerRadius;
  set centerRadius (dynamic v)
  {
    if (_centerRadius != null)
    {
      _centerRadius!.set(v);
    }
    else if (v != null)
    {
      _centerRadius = DoubleObservable(Binding.toKey(id, 'centerradius'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double? get centerRadius => _centerRadius?.get();

  /// Sets the font size of the legend labels
  DoubleObservable? _spacing;
  set spacing (dynamic v)
  {
    if (_spacing != null)
    {
      _spacing!.set(v);
    }
    else if (v != null)
    {
      _spacing = DoubleObservable(Binding.toKey(id, 'spacing'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double? get spacing => _spacing?.get();


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
      // here if the data strategy is category, we must fold all of the lists together and create a dummy key value map of every unique value, in order
      uniqueValues.clear();

      // clear data
     // pieData.clear();

      for (var serie in series)
      {
        // build the datapoints for the series, passing in the chart type, index, and data
        if (serie.datasource == source.id)
        {
          var points = serie.plotPoints(list);

          // add the built x values to a unique list to map to indeces
          uniqueValues.addAll(serie.xValues);

          pieData.addAll(points);

          serie.xValues.clear();
        }
      }

      notifyListeners('list', null);
    }
    catch(e)
    {
      Log().debug('Series onDataSourceSuccess() error');
      // DialogService().show(type: DialogType.error, title: phrase.error, description: e.message);
    }
    return true;
  }

  @override
  List<Widget> getTooltips(List<IExtendedSeriesInterface> spots)
  {
    List<Widget> views = [];
    for (var spot in spots)
    {
      var series = this.series.firstWhereOrNull((element) => element == spot.series);
      views.addAll(buildTooltip(series, spot));
    }
    return views;
  }

  @override
  Widget getView({Key? key})
  {
    return getReactiveView(PieChartView(this));
  }
}