// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/column/column_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/padding/padding_view.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/helpers/helpers.dart';

class PaddingModel extends ColumnModel {
  @override
  bool get expand => false;

  PaddingModel(super.parent, super.id);

  static PaddingModel? fromXml(WidgetModel parent, XmlElement xml) {
    PaddingModel? model;
    try {
      // build model
      model = PaddingModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'padding.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);

    // properties
    marginTop = Xml.get(node: xml, tag: 'top');
    marginRight = Xml.get(node: xml, tag: 'right');
    marginBottom = Xml.get(node: xml, tag: 'bottom');
    marginLeft = Xml.get(node: xml, tag: 'left');

    var all = Xml.get(node: xml, tag: 'all');
    if (all != null) {
      marginTop = all;
      marginRight = all;
      marginBottom = all;
      marginLeft = all;
    }

    var horizontal =
        Xml.get(node: xml, tag: 'horizontal') ?? Xml.get(node: xml, tag: 'hor');
    if (horizontal != null) {
      marginRight = horizontal;
      marginLeft = horizontal;
    }

    var vertical =
        Xml.get(node: xml, tag: 'vertical') ?? Xml.get(node: xml, tag: 'ver');
    if (vertical != null) {
      marginTop = vertical;
      marginBottom = vertical;
    }
  }

  @override
  Widget getView({Key? key}) => getReactiveView(PaddingView(this));
}
