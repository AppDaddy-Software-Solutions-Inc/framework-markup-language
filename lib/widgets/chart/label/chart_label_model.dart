// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/data/data.dart';
import 'package:fml/log/manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

/// ChartDataPoint Object
///
/// Holds the plot values for each data node in the series
class ChartDataLabel {
  final Color color;
  final String? anchor;
  final String? position;
  final String? direction;
  final dynamic label;
  final dynamic labelcolor;
  final int? labelsize;
  final dynamic startlabel;
  final dynamic endlabel;
  final dynamic x; final dynamic x1; final dynamic x2;
  final dynamic y; final dynamic y1; final dynamic y2;

  ChartDataLabel({
    this.color = Colors.transparent, this.anchor, this.position, this.direction, this.label, this.labelcolor, this.labelsize, this.startlabel, this.endlabel, this.x, this.x1, this.x2, this.y, this.y1, this.y2,
  });
}

/// Chart Labels [ChartLabelModel]
///
/// Defines the properties used to build Labels on the Charts
class ChartLabelModel extends WidgetModel
{

  List<ChartDataLabel> dataLabel = [];

  ChartLabelModel(
    WidgetModel parent,
    String? id, {
      dynamic color,
      dynamic anchor,
      dynamic position,
      dynamic direction,
      dynamic label,
      dynamic labelcolor,
      dynamic labelsize,
      dynamic startlabel,
      dynamic endlabel,
      dynamic x,
      dynamic x1,
      dynamic x2,
      dynamic y,
      dynamic y1,
      dynamic y2,
    }
  ) : super(parent, id) {
    this.color = color;
    this.anchor = anchor;
    this.position = position;
    this.direction = direction;
    this.label = label;
    this.labelcolor = labelcolor;
    this.labelsize = labelsize;
    this.startlabel = startlabel;
    this.endlabel = endlabel;
    this.x = x;
    this.x1 = x1;
    this.x2 = x2;
    this.y = y;
    this.y1 = y1;
    this.y2 = y2;
  }

  static ChartLabelModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    ChartLabelModel? model;
    try
    {
      model = ChartLabelModel(parent, Xml.get(node: xml, tag: 'id'));
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
    color = Xml.get(node: xml, tag: 'color');
    anchor = Xml.get(node: xml, tag: 'anchor');
    position = Xml.get(node: xml, tag: 'position');
    direction = Xml.get(node: xml, tag: 'direction');
    label = Xml.get(node: xml, tag: 'label');
    labelcolor = Xml.get(node: xml, tag: 'labelcolor');
    labelsize = Xml.get(node: xml, tag: 'labelsize');
    startlabel = Xml.get(node: xml, tag: 'startlabel');
    endlabel = Xml.get(node: xml, tag: 'endlabel');
    x = Xml.get(node: xml, tag: 'x');
    x1 = Xml.get(node: xml, tag: 'x1');
    x2 = Xml.get(node: xml, tag: 'x2');
    y = Xml.get(node: xml, tag: 'y');
    y1 = Xml.get(node: xml, tag: 'y1');
    y2 = Xml.get(node: xml, tag: 'y2');

    // Remove datasource listener. The parent chart will take care of this.
    if ((datasource != null) && (scope != null) && (scope!.datasources.containsKey(datasource))) scope!.datasources[datasource!]!.remove(this);
  }

  /// The [ChartLabel] background color
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
  Color get color => _color?.get() ?? Colors.transparent;

  /// start, end, middle/center
  StringObservable? _anchor;
  set anchor (dynamic v) {
    if (_anchor != null) {
      _anchor!.set(v);
    }
    else if (v != null) {
      _anchor = StringObservable(Binding.toKey(id, 'anchor'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String get anchor => _anchor?.get() ?? 'middle';

  /// auto, inside, outside, margin
  StringObservable? _position;
  set position (dynamic v) {
    if (_position != null) {
      _position!.set(v);
    }
    else if (v != null) {
      _position = StringObservable(Binding.toKey(id, 'position'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String get position => _position?.get() ?? 'auto';

  /// vertical / horizontal
  StringObservable? _direction;
  set direction (dynamic v) {
    if (_direction != null) {
      _direction!.set(v);
    }
    else if (v != null) {
      _direction = StringObservable(Binding.toKey(id, 'direction'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get direction => _direction?.get();
  
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

  /// The [ChartLabel]'s Label Text color
  ColorObservable? _labelcolor;
  set labelcolor (dynamic v)
  {
    if (_labelcolor != null)
    {
      _labelcolor!.set(v);
    }
    else if (v != null)
    {
      _labelcolor = ColorObservable(Binding.toKey(id, 'labelcolor'), v, scope: scope, listener: onPropertyChange);
    }
  }
  Color? get labelcolor => _labelcolor?.get();

  /// Sets the label size of each label
  IntegerObservable? _labelsize;
  set labelsize (dynamic v)
  {
    if (_labelsize != null)
    {
      _labelsize!.set(v);
    }
    else if (v != null)
    {
      _labelsize = IntegerObservable(Binding.toKey(id, 'labelsize'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int? get labelsize => _labelsize?.get();

  StringObservable? _startlabel;
  set startlabel (dynamic v)
  {
    if (_startlabel != null)
    {
      _startlabel!.set(v);
    }
    else if (v != null)
    {
      _startlabel = StringObservable(Binding.toKey(id, 'startlabel'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get startlabel => _startlabel?.get();

  StringObservable? _endlabel;
  set endlabel (dynamic v)
  {
    if (_endlabel != null)
    {
      _endlabel!.set(v);
    }
    else if (v != null)
    {
      _endlabel = StringObservable(Binding.toKey(id, 'endlabel'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get endlabel => _endlabel?.get();
  
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

  StringObservable? _x1;
  set x1 (dynamic v)
  {
    if (_x1 != null)
    {
      _x1!.set(v);
    }
    else if (v != null)
    {
      _x1 = StringObservable(Binding.toKey(id, 'x1'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get x1 => _x1?.get();

  StringObservable? _x2;
  set x2 (dynamic v)
  {
    if (_x2 != null)
    {
      _x2!.set(v);
    }
    else if (v != null)
    {
      _x2 = StringObservable(Binding.toKey(id, 'x2'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get x2 => _x2?.get();
  
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

  StringObservable? _y1;
  set y1 (dynamic v)
  {
    if (_y1 != null)
    {
      _y1!.set(v);
    }
    else if (v != null)
    {
      _y1 = StringObservable(Binding.toKey(id, 'y1'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get y1 => _y1?.get();

  StringObservable? _y2;
  set y2 (dynamic v)
  {
    if (_y2 != null)
    {
      _y2!.set(v);
    }
    else if (v != null)
    {
      _y2 = StringObservable(Binding.toKey(id, 'y2'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get y2 => _y2?.get();

  ChartDataLabel chartLabel(dynamic data)
  {
    dynamic color = replaceFromDataMap(_color, data) ?? Colors.transparent;
    dynamic anchor = replaceFromDataMap(_anchor, data);
    dynamic position = replaceFromDataMap(_position, data);
    dynamic direction = replaceFromDataMap(_direction, data);
    dynamic labelcolor = replaceFromDataMap(_labelcolor, data);
    dynamic labelsize = replaceFromDataMap(_labelsize, data);
    dynamic label = replaceFromDataMap(_label, data);
    dynamic startlabel = replaceFromDataMap(_startlabel, data);
    dynamic endlabel = replaceFromDataMap(_endlabel, data);
    dynamic x = replaceFromDataMap(_x, data);
    dynamic x1 = replaceFromDataMap(_x1, data);
    dynamic x2 = replaceFromDataMap(_x2, data);
    dynamic y = replaceFromDataMap(_y, data);
    dynamic y1 = replaceFromDataMap(_y1, data);
    dynamic y2 = replaceFromDataMap(_y2, data);

    return ChartDataLabel(
      color: color, anchor: anchor, position: position, direction: direction,
      labelcolor: labelcolor, labelsize: labelsize,
      label: label, startlabel: startlabel, endlabel: endlabel,
      x: x, x1: x1, x2: x2,
      y: y, y1: y1, y2: y2,
    );
  }

  dynamic replaceFromDataMap(Observable? observable, dynamic data)
  {
    // Null value
    if (observable == null) {
      return null;
    }
    // Static value does not contain bindings or evals, no need to replace
    // anything just return the value
    else if (observable.signature == null || (observable.bindings == null || observable.bindings!.isEmpty)) {
      return observable.value;
    }

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
