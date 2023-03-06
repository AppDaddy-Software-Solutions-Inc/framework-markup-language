// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/string.dart';
import 'package:fml/widgets/tooltip/v2/tooltip_view.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

class TooltipModel extends DecoratedWidgetModel implements IViewableWidget
{
  // top, bottom, left, right
  StringObservable? _position;
  set position(dynamic v)
  {
    if (_position != null)
    {
      _position!.set(v);
    }
    else if (v != null)
    {
      _position = StringObservable(Binding.toKey(id, 'position'), v, scope: scope);
    }
  }
  String? get position => _position?.get();
  
  TooltipModel(WidgetModel parent, String? id) : super(parent, id);

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
    position = Xml.get(node: xml, tag: 'position');
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Widget getView({Key? key}) => TooltipView(this);
}
