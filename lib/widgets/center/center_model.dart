// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

/// Center [CenterModel]
///
/// DEPRECATED
/// Defines the properties used to build a centered [CENTER.CenterView]
class CenterModel extends BoxModel
{
  @override
  bool get expand => true;

  @override
  String? get layout => "column";

  @override
  bool get center => true;

  CenterModel(WidgetModel super.parent, super.id, {dynamic flex}); // ; {key: value}

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

  @override
  Widget getView({Key? key}) => getReactiveView(BoxView(this));
}