// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart' hide Axis;
import 'package:fml/data/data.dart';
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/template/template.dart';
import 'package:fml/widgets/chart/series/chart_series_model.dart';
import 'package:fml/widgets/chart/axis/chart_axis_model.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:fml/widgets/layout/layout_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/chart/chart_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:xml/xml.dart';

/// Chart [ChartModel]
///
/// Defines the properties used to build a Chart
class ChartModel extends DecoratedWidgetModel  {
  ChartAxisModel? xaxis; // = ChartAxisModel(null, null, Axis.X, title: null, fontsize: null, fontcolor: Colors.white, type: ChartAxisModel.type_category);
  ChartAxisModel? yaxis; // = ChartAxisModel(null, null, Axis.Y, title: null, fontsize: null, fontcolor: Colors.white, type: ChartAxisModel.type_numeric);
  final List<ChartSeriesModel> series = [];

  bool get isVerticallyExpanding   => true;
  bool get isHorizontallyExpanding => true;

  // parent is not a layout model or parent is laid out
  bool get _parentLayoutComplete => parent is! LayoutModel || (parent as LayoutModel).layoutComplete;

  @override
  bool get visible => super.visible && _parentLayoutComplete;

  ChartModel(WidgetModel parent, String? id,
    {
      dynamic type,
      dynamic showlegend,
      dynamic horizontal,
      dynamic animated,
      dynamic selected,
    }) : super(parent, id) {
    this.selected         = selected;
    this.animated         = animated;
    this.horizontal       = horizontal;
    this.showlegend       = showlegend;
    this.type             = type?.trim()?.toLowerCase();
    busy = false;

    // register a listener to parent layout complete
    if (parent is LayoutModel) parent.layoutCompleteObservable?.registerListener(onParentLayoutComplete);
  }

  // listens to parent layout complete
  // before displaying chart
  void onParentLayoutComplete(Observable observable)
  {
    if (_parentLayoutComplete) notifyListeners(observable.key, observable.get());
  }

  @override
  removeAllListeners()
  {
    super.removeAllListeners();
    if (parent is LayoutModel) (parent as LayoutModel).layoutCompleteObservable?.removeListener(onParentLayoutComplete);
  }

  static ChartModel? fromTemplate(WidgetModel parent, Template template)
  {
    ChartModel? model;
    try
    {
      XmlElement? xml = Xml.getElement(node: template.document!.rootElement, tag: "CHART");
      xml ??= template.document!.rootElement;
      model = ChartModel.fromXml(parent, xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'chart.Model');
      model = null;
    }
    return model;
  }

  static ChartModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    ChartModel? model;
    try
    {
      model = ChartModel(parent, Xml.get(node: xml, tag: 'id'));
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
    type            = Xml.get(node: xml, tag: 'type');

    // Get Series
    this.series.clear();
    List<ChartSeriesModel> series = findChildrenOfExactType(ChartSeriesModel).cast<ChartSeriesModel>();
      series.forEach((model)
      {
        // add the series to the list
        this.series.add(model);

        // register listener to the datasource
        IDataSource? source = (scope != null) ? scope!.getDataSource(model.datasource) : null;
        if (source != null) source.register(this);
      });

    // Get Axis
    List<ChartAxisModel> axis = findChildrenOfExactType(ChartAxisModel).cast<ChartAxisModel>();
    axis.forEach((axis)
    {
      if (axis.axis == ChartAxis.X) xaxis = axis;
      if (axis.axis == ChartAxis.Y) yaxis = axis;
    });
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
  String? get type => _type?.get();

  /// Called when the databroker returns a successful result
  ///
  /// [ChartModel] overrides [WidgetModel]'s onDataSourceSuccess
  /// to populate the series data with the databroker's data
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async
  {
    try
    {
        series.forEach((series) {
          if (series.datasource == source.id) {
            series.dataPoint.clear();
            if (list != null)
              list.forEach((p) {
                ChartDataPoint point = series.point(p);
                if ((point.x != null) && (point.y != null))
                  series.dataPoint.add(point);
              });
            series.data = list;
          }
        });
      notifyListeners('list', null);
    }
    catch(e)
    {
      Log().debug('Series onDataSourceSuccess() error');
      // DialogService().show(type: DialogType.error, title: phrase.error, description: e.message);
    }
    return true;
  }

  Widget getView({Key? key})
  {
    return getReactiveView(ChartView(this));
  }
}