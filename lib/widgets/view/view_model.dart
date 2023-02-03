// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/viewable_widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/widgets/view/view.dart';

class ViewModel extends ViewableWidgetModel
{
  ViewModel(WidgetModel parent, String? id) : super(parent, id);

  static ViewModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    ViewModel? model;
    try
    {
      model = ViewModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'ViewModel');
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
  }

  Widget getView({Key? key}) => View(this);
}


