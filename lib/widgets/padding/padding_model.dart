// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/viewable_widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/padding/padding_view.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class PaddingModel extends ViewableWidgetModel 
{
  PaddingModel(WidgetModel parent, String? id, {Scope? scope}): super(parent, id, scope: scope);

  static PaddingModel? fromXml(WidgetModel parent, XmlElement xml) {
    PaddingModel? model;
    try {
// build model
      model = PaddingModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch(e) {
      Log().exception(e,
           caller: 'padding.Model');
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
    padtop    = Xml.get(node: xml, tag: 'top');
    padright  = Xml.get(node: xml, tag: 'right');
    padbottom = Xml.get(node: xml, tag: 'bottom');
    padleft   = Xml.get(node: xml, tag: 'left');

    var all = Xml.get(node: xml, tag: 'all');
    if (all != null)
    {
      padtop=all;
      padright=all;
      padbottom=all;
      padleft=all;
    }

    var horizontal = Xml.get(node: xml, tag: 'horizontal') ?? Xml.get(node: xml, tag: 'hor');
    if (horizontal != null)
    {
     padright=horizontal;
     padleft=horizontal;
    }

    var vertical = Xml.get(node: xml, tag: 'vertical') ?? Xml.get(node: xml, tag: 'ver');
    {
    padtop=vertical;
    padbottom=vertical;
    }
  }

  @override
  dispose() {
// Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Widget getView({Key? key}) => getReactiveView(PaddingView(this));
}
