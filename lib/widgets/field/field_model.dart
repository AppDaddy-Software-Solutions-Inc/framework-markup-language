// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/cupertino.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/widgets/form/form_field_model.dart';
import 'package:fml/widgets/form/form_field_interface.dart';
import 'package:fml/widgets/plugin/plugin_mixin.dart';
import 'package:fml/widgets/plugin/plugin_view.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/helpers/helpers.dart';

class FieldModel extends FormFieldModel with PluginMixin implements IFormField {

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

  @override
  Widget getView({Key? key}) {
    if (uri == null) return const Offstage();
    return PluginView(this);
  }
}
