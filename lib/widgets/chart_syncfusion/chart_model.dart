/**
// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/dialog/service.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/phrase.dart';
import 'package:flutter/material.dart';
import 'package:fml/template/template.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';

import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/chart_syncfusion/series/chart_series_model.dart';
import 'package:fml/widgets/chart_syncfusion/axis/chart_axis_model.dart' as sfAXIS;
import 'package:fml/widgets/chart_syncfusion/chart_view.dart';
import 'package:fml/widgets/widget/widget_model.dart'       ;
import 'package:fml/widgets/column/column_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

/// Chart [ChartModel]
///
/// Defines the properties used to build a Chart
class ChartModel extends DecoratedWidgetModel implements IViewableWidget
{
  final List<ChartSeriesModel> series = [];
  sfAXIS.ChartAxisModel xaxis = sfAXIS.ChartAxisModel(null, null, sfAXIS.Axis.X, title: null, fontsize: null, fontcolor: Colors.white, type: sfAXIS.AxisType.category);
  sfAXIS.ChartAxisModel yaxis = sfAXIS.ChartAxisModel(null, null, sfAXIS.Axis.Y, title: null, fontsize: null, fontcolor: Colors.white, type: sfAXIS.AxisType.numeric);

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

  /// Background color behind the plot
  ColorObservable? _backgroundcolor;
  set backgroundcolor (dynamic v)
  {
    if (_backgroundcolor != null)
    {
      _backgroundcolor!.set(v);
    }
    else if (v != null)
    {
      _backgroundcolor = ColorObservable(Binding.toKey(id, 'backgroundcolor'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get backgroundcolor => _backgroundcolor?.get();

  /// Background image behind the plot
  StringObservable? _backgroundimage;
  set backgroundimage (dynamic v)
  {
    if (_backgroundimage != null)
    {
      _backgroundimage!.set(v);
    }
    else if (v != null)
    {
      _backgroundimage = StringObservable(Binding.toKey(id, 'backgroundimage'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get backgroundimage => _backgroundimage?.get()?.toLowerCase();

  /// Legend color
  ColorObservable? _legendcolor;
  set legendcolor (dynamic v)
  {
    if (_legendcolor != null)
    {
      _legendcolor!.set(v);
    }
    else if (v != null)
    {
      _legendcolor = ColorObservable(Binding.toKey(id, 'legendcolor'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get legendcolor => _legendcolor?.get();

  /// Legend position
  StringObservable? _legendposition;
  set legendposition (dynamic v)
  {
    if (_legendposition != null)
    {
      _legendposition!.set(v);
    }
    else if (v != null)
    {
      _legendposition = StringObservable(Binding.toKey(id, 'legendposition'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String get legendposition => _legendposition?.get() ?? 'bottom';

  /// If true displays a legend of the series names and colors
  BooleanObservable? _showlegend;
  set showlegend (dynamic v)
  {
    if (_showlegend != null)
    {
      _showlegend!.set(v);
    }
    else if (v != null)
    {
      _showlegend = BooleanObservable(Binding.toKey(id, 'showlegend'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool? get showlegend => _showlegend?.get();

  /// Prevents ability to zoom into the chart
  BooleanObservable? _disablezoom;
  set disablezoom (dynamic v)
  {
    if (_disablezoom != null)
    {
      _disablezoom!.set(v);
    }
    else if (v != null)
    {
      _disablezoom = BooleanObservable(Binding.toKey(id, 'disablezoom'), v, scope: scope, listener: onPropertyChange);
    }
  }

  bool? get disablezoom => _disablezoom?.get();

  ChartModel(WidgetModel parent, String? id,
      {
        dynamic type,
        dynamic backgroundcolor,
        dynamic backgroundimage,
        dynamic legendcolor,
        dynamic legendposition,
        dynamic showlegend,
        dynamic disablezoom}) : super(parent, id)
  {
    // instantiate busy observable
    busy = false;

    ///////////////////////////
    //* New Scoped Container */
    ///////////////////////////
    this.type             = type;
    this.backgroundimage  = backgroundimage;
    this.backgroundcolor  = backgroundcolor;
    this.legendcolor      = legendcolor;
    this.legendposition   = legendposition;
    this.showlegend       = showlegend;
    this.disablezoom      = disablezoom;
  }

  static ChartModel? fromTemplate(WidgetModel parent, Template template)
  {
    ChartModel? model;
    try
    {
      XmlElement? xml = Xml.getElement(node: template.document!.rootElement, tag: "CHART");
      if (xml == null) xml = template.document!.rootElement;
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
    type            = Xml.get(node: xml, tag: 'type');
    backgroundimage = Xml.get(node: xml, tag: 'backgroundimage');
    backgroundcolor = Xml.get(node: xml, tag: 'backgroundcolor');
    legendcolor     = Xml.get(node: xml, tag: 'legendcolor');
    legendposition  = Xml.get(node: xml, tag: 'legendposition');
    showlegend      = Xml.get(node: xml, tag: 'showlegend');
    disablezoom     = Xml.get(node: xml, tag: 'disablezoom');

    // Build Series
    this.series.clear();
    List<dynamic> series = findChildrenOfExactType(ChartSeriesModel);
      series.forEach((model)
      {
        // add the series to the list
        this.series.add(model);

        // register listener to the datasource
        IDataSource? source = scope?.getDataSource(model.datasource);
        source?.register(this);
      });

    // Build Axis
    List<sfAXIS.ChartAxisModel> axis = findChildrenOfExactType(sfAXIS.ChartAxisModel).cast<sfAXIS.ChartAxisModel>();
    axis.forEach((axis)
    {
      if (axis.axis == sfAXIS.Axis.X) this.xaxis = axis;
      if (axis.axis == sfAXIS.Axis.Y) this.yaxis = axis;
    });
  }

  _build(IDataSource source, Data? list) async
  {
    try
    {
        this.series.forEach((series)
        {
          if (series.datasource == source.id)
          {
            series.points.clear();
            if (list != null)
              list.forEach((element)
              {
                Point point = series.point(element);
                if ((point.x != null) && (point.y != null)) series.points.add(point);
              });
          }
        });
      notifyListeners('list', null);
    }
    on Exception catch(e)
    {
      DialogService().show(type: DialogType.error, title: phrase.error, description: e.toString());
    }
  }

  /// Build the widget tooltips
  ColumnModel? buildTooltip(dynamic sfSeries, int offset)
  {
    ColumnModel? model;
    List series = this.series;
    try
    {
      ChartSeriesModel? s; // series.firstWhere((e) => e == sfSeries);
      for (int i = 0; i < series.length; i++)
      {
        if (series[i].sfSeries == sfSeries)
        {
          s = series[i];
          break;
        }
      }

      if (s != null)
      {
        IDataSource? source;
        if (scope != null) source = scope!.getDataSource(s.datasource);
        if (source != null)
        {
          dynamic data = source.data!.elementAt(offset);
          s.selected = offset;

          // apply data to Json data
          String? prototype = Json.replace(s.tooltipTemplate, data);

          // parse document
          XmlDocument? document = Xml.tryParse(prototype);
          if (document != null)
          {
            model = ColumnModel.fromXml(parent, document.rootElement);
          }
          return model;
        }
      }
      else {
        Log().debug('Unable to build tooltips');
      }
    }
    catch(e)
    {
      DialogService().show(type: DialogType.error, title: phrase.error, description: e.toString());
    }
    return model;
  }

  setZoomX(double factor, double position) {
    xaxis.zoomfactor = factor;
    xaxis.zoomposition = position > 1 ? 1 : position < 0 ? 0 : position;
  }

  setZoomY(double factor, double position) {
    yaxis.zoomfactor = factor;
    yaxis.zoomposition = position > 1 ? 1 : position < 0 ? 0 : position;
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async
  {
    await _build(source, list);
    return true;
  }

  @override
  onDataSourceBusy(IDataSource source, bool busy)
  {
    if (busy == false)
      series.forEach((element)
      {
        if ((element.datasource != null) && (scope != null) && (scope!.datasources.containsKey(element.datasource)) && (scope!.datasources[element.datasource!]!.busy == true))
        {
          busy = true;
        }
      });
    this.busy = busy;
  }

  Widget getView({Key? key})
  {
    return getReactiveView(ChartView(this));
  }
}
**/