// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/helpers/xml.dart';
import 'package:fml/widgets/form/form_field_interface.dart';
import 'package:fml/widgets/form/form_field_model.dart';
import 'package:fml/widgets/plugin/plugin_field_view.dart';
import 'package:fml/widgets/plugin/plugin_mixin.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';

class PluginFieldModel extends FormFieldModel with PluginMixin implements IFormField {

  PluginFieldModel(super.parent, super.id);

  static PluginFieldModel fromXml(Model parent, XmlElement xml) {
    var model = PluginFieldModel(parent, Xml.get(node: xml, tag: 'id'));
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
    var view = PluginFieldView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}

