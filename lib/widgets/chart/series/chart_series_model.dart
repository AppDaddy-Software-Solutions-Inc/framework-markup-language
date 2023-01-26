// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/log/manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

/// Chart Series Types
enum ChartSeriesType {
  area, line, bar, stack, plot, waterfall, label, pie
}

/// ChartDataPoint Object
///
/// Holds the plot values for each data node in the series
class ChartDataPoint {
  final Color? color; final dynamic label; final dynamic x; final dynamic y;
  ChartDataPoint({this.x, this.y, this.color, this.label});
}

/// Chart Series [ChartSeriesModel]
///
/// Defines the properties used to build a Charts's Series
class ChartSeriesModel extends WidgetModel
{
  List<ChartDataPoint> dataPoint = [];
  String? type = 'bar';

  ChartSeriesModel(
    WidgetModel parent,
    String? id, {
      dynamic x,
      dynamic y,
      dynamic color,
      dynamic stroke,
      dynamic radius,
      dynamic size,
      dynamic label,
      dynamic labelled,
      dynamic labelType,
      String? type,
      dynamic tooltips,
      dynamic animated,
      dynamic name,
      dynamic group,
      dynamic stack,
      dynamic showarea,
      dynamic showline,
      dynamic showpoints,
    }
  ) : super(parent, id) {
    this.x = x;
    this.y = y;
    this.color = color;
    this.stroke = stroke;
    this.radius = radius;
    this.size = size;
    this.label = label;
    this.labelled = labelled;
    this.labelType = labelType;
    this.type = type;
    this.tooltips = tooltips;
    this.animated = animated;
    this.name = name;
    this.group = group;
    this.stack = stack;
    this.showarea = showarea;
    this.showline = showline;
    this.showpoints = showpoints;
  }

  static ChartSeriesModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    ChartSeriesModel? model;
    try
    {
      model = ChartSeriesModel(parent, Xml.get(node: xml, tag: 'id'));
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
    x           = Xml.get(node: xml, tag: 'x');
    y           = Xml.get(node: xml, tag: 'y');
    color       = Xml.get(node: xml, tag: 'color');
    stroke      = Xml.get(node: xml, tag: 'stroke');
    radius      = Xml.get(node: xml, tag: 'radius');
    size        = Xml.get(node: xml, tag: 'size');
    type        = Xml.get(node: xml, tag: 'type');
    label       = Xml.get(node: xml, tag: 'label');
    labelled    = Xml.get(node: xml, tag: 'labelled');
    labelType   = Xml.get(node: xml, tag: 'labelType');
    tooltips    = Xml.get(node: xml, tag: 'tooltips');
    animated    = Xml.get(node: xml, tag: 'animated');
    name        = Xml.get(node: xml, tag: 'name');
    group       = Xml.get(node: xml, tag: 'group');
    stack       = Xml.get(node: xml, tag: 'stack');
    showarea    = Xml.get(node: xml, tag: 'showarea');
    showline    = Xml.get(node: xml, tag: 'showline');
    showpoints  = Xml.get(node: xml, tag: 'showpoints');

    // Remove datasource listener. The parent chart will take care of this.
    if ((datasource != null) && (scope != null) && (scope!.datasources.containsKey(datasource))) scope!.datasources[datasource!]!.remove(this);

    // Setup the Series type and some internal properties for supporting it
    if (type != null) type = type?.trim().toLowerCase() ?? null;
    switch (S.toEnum(type, ChartSeriesType.values)) {
      case ChartSeriesType.area:
        this.type = S.fromEnum(ChartSeriesType.area);
        break;

      case ChartSeriesType.bar:
        this.type = S.fromEnum(ChartSeriesType.bar);
        break;

      case ChartSeriesType.label:
        this.type = S.fromEnum(ChartSeriesType.label);
        break;

      case ChartSeriesType.line:
        this.type = S.fromEnum(ChartSeriesType.line);
        break;

      case ChartSeriesType.pie:
        this.type = S.fromEnum(ChartSeriesType.pie);
        break;

      case ChartSeriesType.plot:
        this.type = S.fromEnum(ChartSeriesType.plot);
        break;

      case ChartSeriesType.waterfall:
        this.type = S.fromEnum(ChartSeriesType.waterfall);
        break;

      default:
        Log().warning('Unknown ChartSeriesType: $type');
        break;
    }
  }

  /// The x coordinate
  StringObservable? _x;
  set x (dynamic v)
  {
    if (_x != null)
    {
      _x!.set(v);
    }
    else if (v != null)
    {
      _x = StringObservable(Binding.toKey(id, 'x'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get x => _x?.get();

  /// The y coordinate
  StringObservable? _y;
  set y (dynamic v)
  {
    if (_y != null)
    {
      _y!.set(v);
    }
    else if (v != null)
    {
      _y = StringObservable(Binding.toKey(id, 'y'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get y => _y?.get();

  /// The [ChartDataPoint]'s label
  StringObservable? _label;
  set label (dynamic v)
  {
    if (_label != null)
    {
      _label!.set(v);
    }
    else if (v != null)
    {
      _label = StringObservable(Binding.toKey(id, 'label'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get label => _label?.get();

  /// The [ChartDataPoint]'s color
  ColorObservable? _color;
  set color (dynamic v)
  {
    if (_color != null)
    {
      _color!.set(v);
    }
    else if (v != null)
    {
      _color = ColorObservable(Binding.toKey(id, 'color'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get color => _color?.get();

  /// Line type (`spline`, `line` and `fastline`) stroke width
  DoubleObservable? stroke_;
  set stroke (dynamic v)
  {
    if (stroke_ != null)
    {
      stroke_!.set(v);
    }
    else if (v != null)
    {
      stroke_ = DoubleObservable(Binding.toKey(id, 'stroke'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double? get stroke => stroke_?.get();

  /// Line/Point type radius width
  DoubleObservable? radius_;
  set radius (dynamic v)
  {
    if (radius_ != null)
    {
      radius_!.set(v);
    }
    else if (v != null)
    {
      radius_ = DoubleObservable(Binding.toKey(id, 'radius'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double get radius => radius_?.get() ?? 3.5;

  /// Plot type (`plot`) size
  DoubleObservable? _size;
  set size (dynamic v)
  {
    if (_size != null)
    {
      _size!.set(v);
    }
    else if (v != null)
    {
      _size = DoubleObservable(Binding.toKey(id, 'size'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double? get size => _size?.get();
  
  /// Set to true if you want to show the area under the line series
  BooleanObservable? _showarea;
  set showarea (dynamic v)
  {
    if (_showarea != null)
    {
      _showarea!.set(v);
    }
    else if (v != null)
    {
      _showarea = BooleanObservable(Binding.toKey(id, 'showarea'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get showarea => _showarea?.get() ?? false;


  /// Set to false if you want to hide the line in the line series
  BooleanObservable? _showline;
  set showline (dynamic v)
  {
    if (_showline != null)
    {
      _showline!.set(v);
    }
    else if (v != null)
    {
      _showline = BooleanObservable(Binding.toKey(id, 'showline'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get showline => _showline?.get() ?? true;

  /// Set to false if you want to hide the points on the line series
  BooleanObservable? _showpoints;
  set showpoints (dynamic v)
  {
    if (_showpoints != null)
    {
      _showpoints!.set(v);
    }
    else if (v != null)
    {
      _showpoints = BooleanObservable(Binding.toKey(id, 'showpoints'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get showpoints => _showpoints?.get() ?? true;

  /// Set to true if you want to label a non label type series
  BooleanObservable? _labelled;
  set labelled (dynamic v)
  {
    if (_labelled != null)
    {
      _labelled!.set(v);
    }
    else if (v != null)
    {
      _labelled = BooleanObservable(Binding.toKey(id, 'labelled'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool? get labelled => _labelled?.get();


  /// Can be a 'string' or a 'widget', default is string
  StringObservable? _labelType;
  set labelType (dynamic v) {
    if (_labelType != null) {
      _labelType!.set(v);
    }
    else if (v != null) {
      _labelType = StringObservable(Binding.toKey(id, 'labelType'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get labelType => _labelType?.get();

  /// If true points will have a tooltip appear on hover
  BooleanObservable? _tooltips;
  set tooltips (dynamic v)
  {
    if (_tooltips != null)
    {
      _tooltips!.set(v);
    }
    else if (v != null)
    {
      _tooltips = BooleanObservable(Binding.toKey(id, 'tooltips'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool? get tooltips => _tooltips?.get();

  /// If true the series animates on build
  BooleanObservable? _animated; // Kind funky with state rebuilds
  set animated (dynamic v)
  {
    if (_animated != null)
    {
      _animated!.set(v);
    }
    else if (v != null) {
      _animated = BooleanObservable(Binding.toKey(id, 'animated'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool? get animated => _animated?.get();

  /// The series name, will be displayed in the legend if it is visible
  StringObservable? _name;
  set name (dynamic v)
  {
    if (_name != null)
    {
      _name!.set(v);
    }
    else if (v != null)
    {
      _name = StringObservable(Binding.toKey(id, 'name'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get name => _name?.get();
  
  /// The series group, allows multiple bar series to be displayed beside each other if they match
  StringObservable? _group;
  set group (dynamic v)
  {
    if (_group != null)
    {
      _group!.set(v);
    }
    else if (v != null)
    {
      _group = StringObservable(Binding.toKey(id, 'group'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get group => _group?.get();

  /// The series stack, allows multiple bar series to be displayed on top each other if they match
  StringObservable? _stack;
  set stack (dynamic v)
  {
    if (_stack != null)
    {
      _stack!.set(v);
    }
    else if (v != null)
    {
      _stack = StringObservable(Binding.toKey(id, 'stack'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get stack => _stack?.get();

  /// n/a
  IntegerObservable? _selected;
  set selected (dynamic v)
  {
    if (_selected != null)
    {
      _selected!.set(v);
    }
    else if (v != null)
    {
      _selected = IntegerObservable(Binding.toKey(id, 'selected'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int? get selected => _selected?.get();

  ChartDataPoint point(dynamic data)
  {
    // dynamic color = replace(_color,data); // _color.set(_color?.applyMap(map)); // run eval(s)
    dynamic color;
    if (_color != null && _color!.bindings != null && _color!.bindings!.length > 0)
      color = replace(_color,data); // _color.set(_color?.applyMap(map)); // run eval(s)
    else if (_color != null && _color!.value != null)
      color = _color!.value;
    dynamic x     = replace(_x,data);
    dynamic y     = replace(_y,data);
    dynamic label = replace(_label,data);
    return ChartDataPoint(x: x, y: y, color: color, label: label);
  }

  dynamic replace(Observable? observable, dynamic data)
  {
    if (observable == null) return null;
    else if (observable.signature == null) return observable.value;

    // apply data to Json data
    dynamic value = Data.replaceValue(observable.signature, data);

    // evaluate
    if (observable.isEval == true) value = Observable.doEvaluation(value);

    // set observable value
    observable.set(value);

    // return value
    return observable.get();
  }
}
