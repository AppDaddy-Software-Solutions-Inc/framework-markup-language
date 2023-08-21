// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' hide Axis;
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/template/template.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/chart_painter/series/chart_series_model.dart';
import 'package:fml/widgets/chart_painter/axis/chart_axis_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/chart_painter/chart_view.dart' as painter;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:xml/xml.dart';

/// Chart [ChartModel]
///
/// Defines the properties used to build a Chart
class ChartPainterModel extends BoxModel
{
  ChartAxisModel xaxis = ChartAxisModel(null, null, ChartAxis.X);
  ChartAxisModel yaxis = ChartAxisModel(null, null, ChartAxis.Y);
  num yMax = 0;
  num yMin = 0;
  Set<dynamic> uniqueValues = {};
  final List<ChartPainterSeriesModel> series = [];
  List<LineChartBarData> lineDataList = [];
  List<BarChartGroupData> barDataList = [];
  PieChartData? pieDataList;

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

  ChartPainterModel(WidgetModel? parent, String? id,
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

  static ChartPainterModel? fromTemplate(WidgetModel parent, Template template)
  {
    ChartPainterModel? model;
    try
    {
      XmlElement? xml = Xml.getElement(node: template.document!.rootElement, tag: "CHART");
      xml ??= template.document!.rootElement;
      model = ChartPainterModel.fromXml(parent, xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'chart.Model');
      model = null;
    }
    return model;
  }

  static ChartPainterModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    ChartPainterModel? model;
    try
    {
      model = ChartPainterModel(parent, Xml.get(node: xml, tag: 'id'));
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
    List<ChartPainterSeriesModel> series = findChildrenOfExactType(ChartPainterSeriesModel).cast<ChartPainterSeriesModel>();
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
      yMax = S.toInt(yaxis.max) ?? 0;
      yMin = S.toInt(yaxis.min) ?? 0;
    }
  }

  /// Contains the data map from the row (point) that is selected
  ListObservable? _selected;
  set selected(dynamic v)
  {
    if (_selected != null)
    {
      _selected!.set(v);
    }
    else if (v != null)
    {
      _selected = ListObservable(Binding.toKey(id, 'selected'), null, scope: scope, listener: onPropertyChange);
      _selected!.set(v);
    }
  }
  get selected => _selected?.get();

  setSelected(dynamic v)
  {
    if (_selected == null)
    {
      _selected = ListObservable(Binding.toKey(id, 'selected'), null, scope: scope);
      _selected!.registerListener(onPropertyChange);
    }
    _selected?.set(v, notify:false);
  }

  /// If the chart should animate it's series
  BooleanObservable? _animated;
  set animated (dynamic v)
  {
    if (_animated != null)
    {
      _animated!.set(v);
    }
    else if (v != null)
    {
      _animated = BooleanObservable(Binding.toKey(id, 'animated'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get animated => _animated?.get() ?? false;

  /// If the chart should display horizontally
  BooleanObservable? _horizontal;
  set horizontal (dynamic v)
  {
    if (_horizontal != null)
    {
      _horizontal!.set(v);
    }
    else if (v != null)
    {
      _horizontal = BooleanObservable(Binding.toKey(id, 'horizontal'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get horizontal => _horizontal?.get() ?? false;

  /// If not false displays a legend of each [ChartSeriesModel] `id`, you can put top/bottom/left/right to signify a placement
  StringObservable? _showlegend;
  set showlegend (dynamic v)
  {
    if (_showlegend != null)
    {
      _showlegend!.set(v);
    }
    else if (v != null)
    {
      _showlegend = StringObservable(Binding.toKey(id, 'showlegend'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String get showlegend => _showlegend?.get() ?? 'bottom';

  /// Sets the font size of the legend labels
  IntegerObservable? _legendsize;
  set legendsize (dynamic v)
  {
    if (_legendsize != null)
    {
      _legendsize!.set(v);
    }
    else if (v != null)
    {
      _legendsize = IntegerObservable(Binding.toKey(id, 'legendsize'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int? get legendsize => _legendsize?.get();

  /// Type of chart (`cartesian` or `circle`) defaults to `cartesian`
  ///
  /// Charts have 2 types circle and cartesian
  /// Circle charts are single series charts and Cartesian are multi series
  /// Cartesian chart types: area, spline, line, fastline, bar, stackedbar,
  /// percentstackedbar, sidebar, waterfall plot and label
  /// Circle chart types: pie, doughnut, explodedpie, explodeddoughnut, radial
  /// and radialbar
  StringObservable? _type;
  set type (dynamic v)
  {
    if (_type != null)
    {
      _type!.set(v);
    }
    else if (v != null)
    {
      _type = StringObservable(Binding.toKey(id, 'type'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String get type => _type?.get() ?? 'line';

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
      int i = 0;
      //here if the data strategy is category, we must fold all of the lists together and create a dummy key value map of every unique value, in order
      uniqueValues.clear();
      for (var serie in series) {
        if (serie.datasource == source.id) {
          // build the datapoints for the series, passing in the chart type, index, and data
          serie.determinePlotFunctions(type, i);
          serie.iteratePoints(list, plotOnFirstPass: false);
          // add the built x values to a unique list to map to indeces
          uniqueValues.addAll(serie.xValues);
         //   //
        }
        i++;
        //plot only if the chart data type is category
        if(type == 'line') {
          serie.plotLineCategoryPoints(uniqueValues);
          lineDataList.add(LineChartBarData(spots: serie.lineDataPoint,
              dotData: FlDotData(show: serie.showpoints),
              barWidth: serie.type == 'point' || serie.showline == false ? 0 : 2,
              color: serie.color ?? ColorHelper.fromString('random')));
        } else if (type == 'bar'){
          serie.plotLineCategoryPoints(uniqueValues);
          barDataList.addAll(serie.barDataPoint);
        } else if (type == 'pie'){
          pieDataList;

        }
          serie.xValues.clear();
      }
      uniqueValues.clear();
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
  Widget getView({Key? key})
  {
    return getReactiveView(painter.ChartView(this));
  }
}