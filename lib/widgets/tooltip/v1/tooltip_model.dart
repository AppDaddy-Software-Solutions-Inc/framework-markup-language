// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/widgets/tooltip/v1/tooltip_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class TooltipModel extends DecoratedWidgetModel 
{
  // background color
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
  Color? get backgroundcolor =>  _backgroundcolor?.get();

  // label
  StringObservable? _label;
  set label(String? v)
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

  TooltipModel(WidgetModel super.parent, super.id, {dynamic label, dynamic color})
  {
    this.label = label;
    this.color = color;
  }

  static TooltipModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    TooltipModel? model;
    try
    {
      model = TooltipModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'tooltip.Model');
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
    label = Xml.get(node: xml, tag: 'label');
    label ??= Xml.get(node: xml, tag: 'text'); // backwards compatibility
    label ??= Xml.get(node: xml, tag: 'value'); // backwards compatibility
    backgroundcolor = Xml.get(node: xml, tag: 'backgroundcolor');
  }

  @override
  Widget getView({Key? key}) => getReactiveView(TooltipView(this));
}
