// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eval/flutter_eval.dart';
import 'package:dart_eval/dart_eval.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/helpers/uri.dart';
import 'package:fml/helpers/xml.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observable.dart';
import 'package:fml/observable/observables/string.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

enum PluginTypes {widget, eval}

class PluginModel extends ViewableModel {

  late final PluginTypes _type;

  Uri? _uri;
  String _import = "";
  String _function = "";

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

  final List<Observable> _args = [];

  PluginModel(super.parent, super.id);

  static PluginModel fromXml(Model parent, XmlElement xml) {

    var model = PluginModel(parent, Xml.get(node: xml, tag: 'id'));
    model.deserialize(xml);
    return model;
  }

  void onArgumentChange(Observable observable) {
    if (_type == PluginTypes.eval) {
      _execute();
    }
    else {
      super.onPropertyChange(observable);
    }
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {

    // deserialize
    super.deserialize(xml);

    // properties
    _uri = URI.parse(Xml.get(node: xml, tag: 'url'));

    var import = Xml.get(node: xml, tag: 'import')?.trim() ?? "";
    if (!isNullOrEmpty(import) && !import.startsWith("package:")) import = "package:$import";
    _import = import;

    // set function
    var function = Xml.get(node: xml, tag: 'function')?.trim() ?? "";
    _function = function.split("(").first.trim();
    if (!isNullOrEmpty(_function) && !_function.contains(".")) _function = "$_function.";
    _function = _function.trim();

    var multipart = _function.split(".").where((part) => !isNullOrEmpty(part)).length > 1;

    // set the type
    _type = multipart ? PluginTypes.eval : PluginTypes.widget;

    // set type and build arguments
    _buildArguments(function);
  }

  void _buildArguments(String function) {
    var l = function.indexOf("(");
    var r = function.lastIndexOf(")");
    if (l > 0 && l < r && (r - l > 1)) {
      var args = function.substring(l+1,r).split(",");
      for (var arg in args) {
        if (!isNullOrEmpty(arg)) {
          String? s = arg.trim().toLowerCase();
          if (s == 'null') s = null;
          var o = StringObservable(null, s, scope: scope, listener: onArgumentChange);
          _args.add(o);
        }
      }
    }
  }

  void _execute() async {
    try {
      if (_uri == null) return;
      final response = await http.get(_uri!);
      var runtime = Runtime(ByteData.sublistView(response.bodyBytes));

      var args = [];
      for (var o in _args) {
        args.add($String(o.get()));
      }
      var v = runtime.executeLib(_import, _function, args);
      if (v is $String) {
        v = v.$value;
      }
      value = v;
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

  Widget? view;

  @override
  Widget getView({Key? key}) {

    if (view != null) return view!;

    // eval?
    if (_type == PluginTypes.eval) {
      view = const Offstage();
      return view!;
    }

    if (_uri == null) return const Text("Missing or invalid url");
    if (isNullOrEmpty(_import)) return const Text("Missing import");
    if (isNullOrEmpty(_function)) return const Text("Missing function");

    // build the widget
    var args = [];
    for (var o in _args) {
      args.add(o.get());
    }

    view = RuntimeWidget(uri: _uri!, library: _import, function: _function, args: args);

    return view ?? const Offstage();
  }
}

