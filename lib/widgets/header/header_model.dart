// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';

import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/widgets/header/header_view.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

enum Animations {fade, none}

class HeaderModel extends DecoratedWidgetModel implements IViewableWidget
{
  // height default
  double get height => super.height ?? 200;

  // animation
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

  HeaderModel(WidgetModel parent, String? id) : super(parent, id);

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
    this.animation  = Xml.get(node: xml, tag: 'animation');
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Widget getView({Key? key}) => HeaderView(this);
}