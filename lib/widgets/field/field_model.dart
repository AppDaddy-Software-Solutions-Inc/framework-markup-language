// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/widgets/field/field_view.dart';
import 'package:fml/widgets/form/form_field_model.dart';
import 'package:fml/widgets/form/form_field_interface.dart';
import 'package:fml/widgets/package/package_mixin.dart';
import 'package:fml/widgets/package/package_model.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/helpers/helpers.dart';

class FieldModel extends FormFieldModel with PackageMixin implements IFormField {

  // name of the package constructor
  String? _package;
  String? _class;
  PackageModel? get _plugin => framework?.packages[_package];

  /// the value of the input. If not set to "" initially, the value will not be settable through events.
  StringObservable? _value;
  @override
  set value(dynamic v) {
    if (_value != null) {
      _value!.set(v);
    } else if (v != null ||
        Model.isBound(this, Binding.toKey(id, 'value'))) {
      _value = StringObservable(Binding.toKey(id, 'value'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  @override
  dynamic get value => dirty ? _value?.get() : _value?.get() ?? defaultValue;

  FieldModel(
    Model super.parent,
    super.id, {
    dynamic value,
  }) {
    if (value != null) this.value = value;
  }

  static FieldModel? fromXml(Model parent, XmlElement xml) {
    FieldModel? model;
    try {
      model = FieldModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'field.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);
    value = Xml.get(node: xml, tag: fromEnum('value'));

    var plugin = Xml.get(node: xml, tag: fromEnum('package'))?.trim().split(".");
    if (plugin != null && plugin.isNotEmpty) {
      _package = plugin.first.trim();
      if (plugin.length > 1)
        _class = plugin[1].trim();
    }
  }

  @override
  void set(String key, dynamic value)
  {
    // value?
    var binding = Binding.fromString(key);
    if (binding != null) {
      var o = scope?.getObservable(binding);
      if (o == _value) {
        disableNotifications();
        answer(value);
        enableNotifications();
        return;
      }
    }

    // other property
    super.set(key, value);
  }

  @override
  dynamic get(String key)
  {
    // value?
    var binding = Binding.fromString(key);
    if (binding != null) {
      var o = scope?.getObservable(binding);
      if (o == _value) {
        return value ?? initialValue ?? "";
      }
    }

    // other property
    return super.get(key);
  }

  Future<Widget> plugin()  async {

    // no package defined
    if (_plugin == null) return const Offstage();

    // build the view
    var view = await _plugin?.view(_class) ?? const Offstage();

    return view;
  }

  @override
  Widget getView({Key? key}) {

    // no package defined
    if (plugin == null) return const Offstage();

    // custom package view
    var view = FieldView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}
