// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/helpers/xml.dart';
import 'package:fml/widgets/plugin/plugin_mixin.dart';
import 'package:fml/widgets/plugin/plugin_widget_view.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';

class PluginWidgetModel extends ViewableModel with PluginMixin {

  PluginWidgetModel(super.parent, super.id);

  static PluginWidgetModel fromXml(Model parent, XmlElement xml) {
    var model = PluginWidgetModel(parent, Xml.get(node: xml, tag: 'id'));
    model.deserialize(xml);
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {

    // deserialize
    super.deserialize(xml);
  }

  @override
  Widget getView({Key? key}) {
    var view = PluginWidgetView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}

