// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/package/package_model.dart';
import 'package:fml/widgets/plugin/plugin_interface.dart';
import 'package:fml/widgets/plugin/plugin_view.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/helpers/helpers.dart';

class PluginModel extends ViewableModel implements IPlugin {

  @override
  PackageModel? get package {
    if (_package == null) return null;
    var model = scope?.findModel(_package!);
    if (model is PackageModel) return model;
    return null;
  }
  String? _package;

  // holds the plugin eval string
  @override
  String? get plugin => _plugin;
  String? _plugin;

  PluginModel(Model super.parent, super.id);

  static PluginModel fromXml(Model parent, XmlElement xml) {

    PluginModel model = PluginModel(parent, Xml.get(node: xml, tag: 'id'));
    model.deserialize(xml);
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {

    // deserialize
    super.deserialize(xml);

    // plugin properties
    _plugin = Xml.get(node: xml, tag: fromEnum('plugin'))?.trim();
    _package = _plugin?.split(".").first.trim();
  }

  @override
  Widget? build() => package?.build(id, scope, plugin);

  @override
  Widget getView({Key? key}) {
    var view = PluginView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}
