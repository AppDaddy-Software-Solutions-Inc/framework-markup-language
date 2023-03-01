// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/animation/animation_model.dart';
import 'package:fml/widgets/widget/viewable_widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/widgets/widget/widget_model.dart';

class DecoratedWidgetModel extends ViewableWidgetModel
{
  set _colors(dynamic v)
  {
      // build colors array
      if (v is String)
      {
        if (!Observable.isEvalSignature(v))
        {
          var s = v.split(',');
          if (s.length > 0) color  = s[0].trim();
          if (s.length > 1) color2 = s[1].trim();
          if (s.length > 2) color3 = s[2].trim();
          if (s.length > 3) color4 = s[3].trim();
        }
        else color = v;
      }
  }
  
  // color
  ColorObservable? _color;
  set color(dynamic v)
  {
    if (_color != null) _color!.set(v);
    else if (v != null) _color = ColorObservable(Binding.toKey(id, 'color'), v, scope: scope, listener: onPropertyChange);
  }
  Color? get color => _color?.get();

  // color2
  ColorObservable? _color2;
  set color2(dynamic v)
  {
    if (_color2 != null) _color2!.set(v);
    else if (v != null) _color2 = ColorObservable(Binding.toKey(id, 'color2'), v, scope: scope, listener: onPropertyChange);
  }
  Color? get color2 => _color2?.get();

  // color3
  ColorObservable? _color3;
  set color3(dynamic v)
  {
    if (_color3 != null) _color3!.set(v);
    else if (v != null) _color3 = ColorObservable(Binding.toKey(id, 'color3'), v, scope: scope, listener: onPropertyChange);
  }
  Color? get color3 => _color3?.get();

  // color4
  ColorObservable? _color4;
  set color4(dynamic v)
  {
    if (_color4 != null) _color4!.set(v);
    else if (v != null) _color4 = ColorObservable(Binding.toKey(id, 'color4'), v, scope: scope, listener: onPropertyChange);
  }
  Color? get color4 => _color4?.get();

  /// The opacity of the box and its children.
  DoubleObservable? _opacity;
  set opacity(dynamic v) {
    if (_opacity != null) {
      _opacity!.set(v);
    } else if (v != null) {
      _opacity = DoubleObservable(Binding.toKey(id, 'opacity'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double? get opacity => _opacity?.get();

  DecoratedWidgetModel(WidgetModel? parent, String? id, {Scope?  scope}) : super(parent, id, scope: scope);

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    // properties
    _colors = Xml.get(node: xml, tag: 'color');
    opacity = Xml.get(node: xml, tag: 'opacity');
  }
}