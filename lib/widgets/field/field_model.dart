// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/widgets/form/form_field_model.dart';
import 'package:fml/widgets/form/form_field_interface.dart';
import 'package:fml/widgets/package/package_model.dart';
import 'package:fml/widgets/plugin/plugin_interface.dart';
import 'package:fml/widgets/plugin/plugin_view.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/helpers/helpers.dart';

enum ValueTypes { string, int, integer, double, bool, boolean, blob, list }

class FieldModel extends FormFieldModel implements IFormField, IPlugin {

  ValueTypes type = ValueTypes.string;

  bool readonly = false;
  int? precision;

  // name of the package constructor
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

  dynamic _value;

  @override
  set value(dynamic v) {

    if (_value != null) {
      _value!.set(v);
      return;
    }

    switch (type) {

      case ValueTypes.string:
        _value = StringObservable(Binding.toKey(id, 'value'), v,
            scope: scope,
            listener: onPropertyChange,
            setter: readonly ? (dynamic value, {Observable? setter}) => v : null);
        break;

      case ValueTypes.int:
      case ValueTypes.integer:
        _value = IntegerObservable(Binding.toKey(id, 'value'), v,
            scope: scope,
            listener: onPropertyChange,
            readonly: readonly);
        break;

      case ValueTypes.double:
        _value = DoubleObservable(Binding.toKey(id, 'value'), v,
            scope: scope,
            listener: onPropertyChange,
            setter: precision != null ? (dynamic value, {Observable? setter}) => toDouble(value, precision: precision) : null,
            readonly: readonly);
        break;

      case ValueTypes.bool:
      case ValueTypes.boolean:
        _value = BooleanObservable(Binding.toKey(id, 'value'), v,
            scope: scope,
            listener: onPropertyChange,
            readonly: readonly);
        break;

      case ValueTypes.list:
        _value = ListObservable(Binding.toKey(id, 'value'), v,
            scope: scope,
            listener: onPropertyChange,
            readonly: readonly);
        break;

      case ValueTypes.blob:
        _value = StringObservable(Binding.toKey(id, 'value'), null,
            scope: scope,
            listener: onPropertyChange,
            readonly: readonly);
        _value.set(v);
        break;
    }
  }

  @override
  dynamic get value => dirty ? _value?.get() : _value?.get() ?? defaultValue;

  FieldModel(
      Model super.parent,
      super.id, {
      this.type = ValueTypes.string,
      dynamic value,
  }) {
    if (value != null) this.value = value;
  }

  static FieldModel fromXml(Model parent, XmlElement xml) {

    var type = toEnum(Xml.get(node: xml, tag: 'type')?.trim().toLowerCase(), ValueTypes.values) ?? ValueTypes.string;
    FieldModel model = FieldModel(parent, Xml.get(node: xml, tag: 'id'), type: type);
    model.deserialize(xml);

    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {

    // deserialize
    super.deserialize(xml);

    // properties
    value = Xml.get(node: xml, tag: fromEnum('value'));
    readonly = toBool(Xml.get(node: xml, tag: 'readonly')?.trim().toLowerCase()) ?? false;
    precision = toInt(Xml.get(node: xml, tag: 'precision'));

    // field is a plugin package?
    _package = Xml.get(node: xml, tag: fromEnum('package'))?.trim();
    _class   = Xml.get(node: xml, tag: fromEnum('class'))?.trim();
  }

  @override
  void onPropertyChange(Observable observable) {

    // intercept value setter on backing plugin
    if (observable == _value && packageModel != null) {
      disableNotifications();
      answer(value);
      enableNotifications();
      return;
    }
    super.onPropertyChange(observable);
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
