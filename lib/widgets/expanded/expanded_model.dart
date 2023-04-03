// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/expanded/expanded_view.dart';
import 'package:fml/helper/common_helpers.dart';

class ExpandedModel extends DecoratedWidgetModel 
{
  ExpandedModel(WidgetModel parent, String?  id, {dynamic flex}) : super(parent, id)
  {
    this.flex = flex;
  }

  static ExpandedModel? fromXml(WidgetModel parent, XmlElement xml, {String? type})
  {
    ExpandedModel? model;
    try
    {
      model = ExpandedModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'expanded.Model');
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
    flex = Xml.get(node: xml, tag: 'flex');
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Widget getView({Key? key}) => getReactiveView(ExpandedView(this));
}