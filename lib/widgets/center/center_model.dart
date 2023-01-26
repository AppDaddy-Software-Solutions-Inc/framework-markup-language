// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';

import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/center/center_view.dart';
import 'package:fml/helper/common_helpers.dart';

/// Center [CenterModel]
///
/// DEPRECATED
/// Defines the properties used to build a centered [CENTER.CenterView]
class CenterModel extends DecoratedWidgetModel implements IViewableWidget
{
  CenterModel(WidgetModel parent, String?  id, {dynamic flex}) : super(parent, id); // ; {key: value}

  static CenterModel? fromXml(WidgetModel parent, XmlElement xml, {String? type})
  {
    CenterModel? model;
    try
    {
      model = CenterModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().debug(e.toString());
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) async
  {
    // deserialize
    super.deserialize(xml);

    // properties
    // flex = Xml.get(node: xml, tag: 'flex);
  }

  @override
  dispose()
  {
    Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  //////////////////
  /* Constrained? */
  //////////////////
  bool isConstrained(String dimension)
  {
    return true;
  }

  Widget getView({Key? key}) => CenterView(this);
}