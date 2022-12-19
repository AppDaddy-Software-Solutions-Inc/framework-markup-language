// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';

import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/widgets/header/header_view.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/helper/helper_barrel.dart';

enum Animations {fade, none}

class HeaderModel extends DecoratedWidgetModel implements IViewableWidget
{
  ///////////////
  /* animation */
  ///////////////
  Animations? _animation;
  Animations get animation => _animation ?? Animations.none;
  set animation (dynamic v)
  {
    if (v is Animations) _animation = v;
    if (v is String)
    {
      Animations? a = S.toEnum(v, Animations.values);
      if (a != null) _animation = a;
    }
  }

  /////////////
  /* height */
  /////////////
  double? _height;
  set height (dynamic v)
  {
    if (v is String) v = S.toDouble(v);
    _height = v;
  }
  double? get height
  {
    return _height;
  }
  
  ////////////////
  /* Min Extent */
  ////////////////
  double? _minextent;
  set minextent (dynamic v)
  {
    if (v is String) v = S.toDouble(v);
    _minextent = v;
  }
  double get minextent
  {
    return _minextent ?? 0;
  }

  ///////////////
  /* Max extent */
  ///////////////
  double? _maxextent;
  set maxextent (dynamic v)
  {
    if (v is String) v = S.toDouble(v);
    _maxextent = v;
  }
  double get maxextent
  {
    return _maxextent ?? 200;
  }

  HeaderModel(
    WidgetModel parent,
    String? id,
   {dynamic color,
    dynamic animation,
     dynamic height,
    dynamic minheight = 0.0,
    dynamic maxheight = 50.0,
  }) : super(parent, id)
  {
    this.color = color;
    this.animation = animation;
    this.height = height;
    this.maxextent = maxheight;
    this.minextent = minheight;
  }

  static HeaderModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    HeaderModel? model;
    try
    {
      model = HeaderModel(parent, null);
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'header.Model');
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

    // properties
    this.minextent  = Xml.get(node: xml, tag: 'minheight');
    this.maxextent  = Xml.get(node: xml, tag: 'maxheight');
    this.animation  = Xml.get(node: xml, tag: 'animation');
  }

  @override
  dispose()
  {
    Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Widget getView({Key? key}) => HeaderView(this);
}