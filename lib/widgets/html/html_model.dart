// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/html/html_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';

class HtmlModel extends DecoratedWidgetModel implements IViewableWidget
{
  ///////////
  /* Value */
  ///////////
  StringObservable? _value;
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
  dynamic get value => _value?.get();

  HtmlModel(
      WidgetModel parent,
      String? id,
      {
        dynamic value,
      }) : super(parent, id)
  {
    if (value != null) this.value = value;
  }


  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {

    // deserialize 
    super.deserialize(xml);

    String? textvalue = Xml.get(node: xml, tag: 'value');
    if (textvalue == null) textvalue = Xml.getText(xml);

    // properties

    value = textvalue;

  }

  static HtmlModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    HtmlModel? model;
    try
    {
      model = HtmlModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'html.Model');
      model = null;
    }
    return model;
  }

  @override
  dispose()
  {
    Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  @override
  Widget getView({Key? key}) => HtmlView(this);
}