// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart' hide Axis;
import 'package:fml/log/manager.dart';
import 'package:fml/template/template.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/chart/series/chart_series_model.dart';
import 'package:fml/widgets/chart_painter/series/chart_series_extended.dart';
import 'package:fml/widgets/chart_painter/series/chart_series_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:xml/xml.dart';

/// Chart [ChartModel]
///
/// Defines the properties used to build a Chart
class ChartPainterModel extends BoxModel {
  List uniqueValues = [];

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

  /// The title of the whole chart
  StringObservable? _title;
  set title(dynamic v) {
    if (_title != null) {
      _title!.set(v);
    } else if (v != null) {
      _title = StringObservable(Binding.toKey(id, 'title'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get title => _title?.get();

  ChartPainterModel(
    WidgetModel super.parent,
    super.id, {
    dynamic type,
    dynamic showlegend,
    dynamic title,
    dynamic horizontal,
    dynamic animated,
    dynamic selected,
    dynamic legendsize,
  }) : super(scope: Scope(parent: parent.scope)) {
    this.selected = selected;
    this.title = title;
    this.animated = animated;
    this.horizontal = horizontal;
    this.showlegend = showlegend;
    this.legendsize = legendsize;
    this.type = type?.trim()?.toLowerCase();

    busy = false;
  }

  static ChartPainterModel? fromTemplate(
      WidgetModel parent, Template template) {
    ChartPainterModel? model;
    try {
      XmlElement? xml =
          Xml.getElement(node: template.document!.rootElement, tag: "CHART");
      xml ??= template.document!.rootElement;
      model = ChartPainterModel.fromXml(parent, xml);
    } catch (e) {
      Log().exception(e, caller: 'chart.Model');
      model = null;
    }
    return model;
  }

  static ChartPainterModel? fromXml(WidgetModel parent, XmlElement xml) {
    ChartPainterModel? model;
    try {
      model = ChartPainterModel(parent, Xml.get(node: xml, tag: 'id'));
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
    //* Deserialize */
    super.deserialize(xml);

    /////////////////
    //* Properties */
    /////////////////
    selected = Xml.get(node: xml, tag: 'selected');
    animated = Xml.get(node: xml, tag: 'animated');
    horizontal = Xml.get(node: xml, tag: 'horizontal');
    showlegend = Xml.get(node: xml, tag: 'showlegend');
    legendsize = Xml.get(node: xml, tag: 'legendsize');
    type = Xml.get(node: xml, tag: 'type');
    title = Xml.get(node: xml, tag: 'title');
  }

  /// Contains the data map from the row (point) that is selected
  ListObservable? _selected;
  set selected(dynamic v) {
    if (_selected != null) {
      _selected!.set(v);
    } else if (v != null) {
      _selected = ListObservable(Binding.toKey(id, 'selected'), null,
          scope: scope, listener: onPropertyChange);
      _selected!.set(v);
    }
  }

  get selected => _selected?.get();

  setSelected(dynamic v) {
    if (_selected == null) {
      _selected =
          ListObservable(Binding.toKey(id, 'selected'), null, scope: scope);
      _selected!.registerListener(onPropertyChange);
    }
    _selected?.set(v, notify: false);
  }

  /// If the chart should animate it's series
  BooleanObservable? _animated;
  set animated(dynamic v) {
    if (_animated != null) {
      _animated!.set(v);
    } else if (v != null) {
      _animated = BooleanObservable(Binding.toKey(id, 'animated'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get animated => _animated?.get() ?? false;

  /// If the chart should display horizontally
  BooleanObservable? _horizontal;
  set horizontal(dynamic v) {
    if (_horizontal != null) {
      _horizontal!.set(v);
    } else if (v != null) {
      _horizontal = BooleanObservable(Binding.toKey(id, 'horizontal'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get horizontal => _horizontal?.get() ?? false;

  /// If not false displays a legend of each [ChartSeriesModel] `id`, you can put top/bottom/left/right to signify a placement
  StringObservable? _showlegend;
  set showlegend(dynamic v) {
    if (_showlegend != null) {
      _showlegend!.set(v);
    } else if (v != null) {
      _showlegend = StringObservable(Binding.toKey(id, 'showlegend'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String get showlegend => _showlegend?.get() ?? 'bottom';

  /// Sets the font size of the legend labels
  IntegerObservable? _legendsize;
  set legendsize(dynamic v) {
    if (_legendsize != null) {
      _legendsize!.set(v);
    } else if (v != null) {
      _legendsize = IntegerObservable(Binding.toKey(id, 'legendsize'), v,
          scope: scope, listener: onPropertyChange);
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
  set type(dynamic v) {
    if (_type != null) {
      _type!.set(v);
    } else if (v != null) {
      _type = StringObservable(Binding.toKey(id, 'type'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String get type => _type?.get() ?? 'line';

  /// Called when the databroker returns a successful result
  ///
  /// [ChartModel] overrides [WidgetModel]'s onDataSourceSuccess
  /// to populate the series data from the datasource and
  /// to populate the label data from the datasource data.

  // must be implemented
  List<Widget> getTooltips(List<IExtendedSeriesInterface> spots) =>
      throw UnimplementedError("Not implemented");

  // build the tooltip view
  List<Widget> buildTooltip(
      ChartPainterSeriesModel? series, IExtendedSeriesInterface spot) {
    List<Widget> views = [];
    if (series == null) return views;

    // get series tooltip
    var tip = series.tooltip;
    if (tip != null) {
      // bind the data to the tip
      tip.data = spot.data;
      views.add(tip.getView());
    }

    return views;
  }

  @override
  Widget getView({Key? key}) => const Offstage();
}
