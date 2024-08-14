// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/helpers/xml.dart';
import 'package:fml/widgets/plugin/plugin_mixin.dart';
import 'package:fml/widgets/plugin/plugin_view.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';

class PluginModel extends ViewableModel with PluginMixin {

  PluginModel(super.parent, super.id);

  static PluginModel fromXml(Model parent, XmlElement xml) {

    var model = PluginModel(parent, Xml.get(node: xml, tag: 'id'));
    model.deserialize(xml);
    return model;
  }

  @override
  Widget getView({Key? key}) {
    var view = PluginView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}

