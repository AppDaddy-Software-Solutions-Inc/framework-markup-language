// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter/foundation.dart';
import 'package:fml/helpers/xml.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observable.dart';
import 'package:fml/observable/observables/string.dart';
import 'package:fml/widgets/plugin/plugin_mixin.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';

class PluginEvalModel extends Model with PluginMixin {

  PluginEvalModel(super.parent, super.id);

  // value
  dynamic _value;
  set value(dynamic v) {
    if (_value != null) {
      _value!.set(v);
    }
    else if (v != null) {
      _value = StringObservable(Binding.toKey(id, 'value'), v,
          scope: scope,
          listener: onPropertyChange);
    }
  }
  dynamic get value => _value?.get();

  @override
  void onArgumentChange(Observable observable) {
    _execute();
  }

  static PluginEvalModel fromXml(Model parent, XmlElement xml) {
    var model = PluginEvalModel(parent, Xml.get(node: xml, tag: 'id'));
    model.deserialize(xml);
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {

    // deserialize
    super.deserialize(xml);
  }

  void _execute() async {

    try {

      // wait for evc code to load
      await initialized.future;

      // get bytes
      if (plugin == null)  return null;

      // execute the plugin
      var runtime = Runtime(ByteData.sublistView(plugin!));

      // execute the dart code
      var result = runtime.executeLib(library, method, arguments);

      // decode
      if (result is $String) {
        result = result.$value;
      }
      value = result;
    }
    catch(e) {
      if (kDebugMode) print(e);
    }
  }

  @override
  Future<bool?> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    if (scope == null) return null;

    var function = propertyOrFunction.toLowerCase().trim();

    switch (function) {
    // fire event handler
      case 'execute':
        _execute();
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }
}

