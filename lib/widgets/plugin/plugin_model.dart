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

  String? _package;
  @override
  String? get packageName => _package;

  String? _class;
  @override
  String? get packageClass => _class;

  @override
  PackageModel? get packageModel {
    if (_package == null) return null;
    var model = scope?.findModel(_package!);
    if (model is PackageModel) return model;
    return null;
  }

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

    // field is a plugin package?
    _package = Xml.get(node: xml, tag: fromEnum('package'))?.trim();
    _class   = Xml.get(node: xml, tag: fromEnum('class'))?.trim();
  }

  @override
  Widget getView({Key? key}) {

    // no package defined
    if (packageModel == null) return const Offstage();

    // custom package view
    var view = PluginView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}
