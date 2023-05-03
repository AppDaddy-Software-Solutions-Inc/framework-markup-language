// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/form/form_field_model.dart';
import 'package:fml/widgets/form/iFormField.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/scribble/scribble_view.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

// enum PointType { tap, move }
//
// class Point
// {
//   Offset offset;
//   PointType type;
//   Point(this.offset, this.type);
// }

class ScribbleModel extends FormFieldModel implements IFormField
{
  ///////////
  /* Value */
  ///////////
  StringObservable? _value;
  @override
  set value (dynamic v)
  {
    if (_value != null)
    {
      _value!.set(v);
    }
    else
    {
      if ((v != null) || (WidgetModel.isBound(this, Binding.toKey(id, 'value')))) _value = StringObservable(Binding.toKey(id, 'value'), v, scope: scope, listener: onPropertyChange);
    }
  }
  @override
  dynamic get value => _value?.get() ?? defaultValue;


  ///////////////////
  /* Default Value */
  ///////////////////
  @override
  dynamic get defaultValue => null;

  ///////////
  /* hint */
  ///////////
  StringObservable? _hint;
  set hint (dynamic v)
  {
    if (_hint != null)
    {
      _hint!.set(v);
    }
    else if (v != null)
    {
      _hint = StringObservable(Binding.toKey(id, 'hint'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get hint => _hint?.get();

  ///////////////
  /* font size */
  ///////////////
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

  ///////////////////
  /* font weight */
  ///////////////////
  StringObservable? _weight;
  set weight (dynamic v)
  {
    if (_weight != null)
    {
      _weight!.set(v);
    }
    else if (v != null)
    {
      _weight = StringObservable(Binding.toKey(id, 'weight'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get weight => _weight?.get();

  ////////////////
  /* font style */
  ////////////////
  StringObservable? _style;
  set style (dynamic v)
  {
    if (_style != null)
    {
      _style!.set(v);
    }
    else if (v != null)
    {
      _style = StringObservable(Binding.toKey(id, 'style'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get style => _style?.get();

  ScribbleModel(
    WidgetModel parent,
    String? id,
   {dynamic mandatory,
    dynamic editable,
    dynamic enabled,
    dynamic value,
    dynamic height,
    dynamic width,
    dynamic hint,
    dynamic size,
    dynamic color,
    dynamic weight,
    dynamic style,
    dynamic post,
    }) : super(parent, id)
  {
    if (width  != null) this.width  = width;
    if (height != null) this.height = height;

    if (mandatory != null) this.mandatory = mandatory;
    if (editable  != null) this.editable  = editable;
    if (enabled   != null) this.enabled   = enabled;
    if (value     != null) this.value     = value;
    if (hint      != null) this.hint      = hint;
    if (size      != null) this.size      = size;
    if (color     != null) this.color     = color;
    if (weight    != null) this.weight    = weight;
    if (style     != null) this.style     = style;
    if (post      != null) this.post      = post;

    alarming = false;
    dirty    = false;
  }

  static ScribbleModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    ScribbleModel? model;
    try
    {
      model = ScribbleModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'scribble.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {

    // deserialize 
    super.deserialize(xml);

    // set properties
    value      = Xml.get(node: xml, tag: 'value');
    hint       = Xml.get(node: xml, tag: 'hint');
    size       = Xml.get(node: xml, tag: 'size');
    weight     = Xml.get(node: xml, tag: 'weight');
    style      = Xml.get(node: xml, tag: 'style');
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  @override
  Widget getView({Key? key}) => getReactiveView(ScribbleView(this));
}

class SignatureModel extends ViewableWidgetModel
{

  final List<Point> points = [];
  Color backgroundColor;
  Color penColor;
  double penStrokeWidth;

  SignatureModel(WidgetModel parent, String? id, {
    List<Point>? points,
    double? width,
    double? height,
    this.backgroundColor = Colors.grey,
    this.penColor = Colors.black,
    this.penStrokeWidth = 3.0}) : super(parent, id)
  {
    if ((points != null) && (points.isNotEmpty)) this.points.addAll(points);
    if (width  != null) this.width  = width;
    if (height != null) this.height = height;
  }
}