import 'dart:async';
import 'dart:ui';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_eval/flutter_eval.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/helpers/uri.dart';
import 'package:fml/helpers/xml.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/string.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;


mixin PluginMixin on Model {

  bool get isPlugin => (_uri != null && _library != null && _method != null);

  // cached plugin evc code
  static Map<String, Runtime>? _runtimes;

  // runtime
  Runtime? get runtime => (_runtimes?.containsKey(_uri?.url) ?? false) ? _runtimes![_uri?.url] : null;
  set _runtime(Runtime value) {
    _runtimes ??= <String, Runtime>{};
    _runtimes![_uri?.url ?? ""] = value;
  }

  Uri? _uri;

  String? _library;
  String get library => _library ?? "";

  String? _method;
  String get method => _method ?? "";

  Completer<bool>? initialized;
  dynamic error;
  StackTrace? trace;

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

  // standard arguments to pass to the plugin
  List<dynamic> get arguments => isPlugin ? [$String(id), $Closure(_get), $Closure(_set)] : [];

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {

    // deserialize
    super.deserialize(xml);

    // properties
    _uri = URI.parse(Xml.get(node: xml, tag: 'url'));

    var library = Xml.get(node: xml, tag: 'import')?.trim();
    if (!isNullOrEmpty(library) && !library!.startsWith("package:")) library = "package:$library";
    _library = library;

    // set function
    var method = Xml.get(node: xml, tag: 'method')?.trim();
    _method = method?.split("(").first.trim();
    if (!isNullOrEmpty(_method) && !_method!.contains(".")) _method = "$_method.";
    _method = _method?.trim();

    // load the plugin
    if (isPlugin) _load();
  }

  Future _load() async {

    initialized ??= Completer<bool>();

    try {

      if (_uri == null) throw("Invalid plugin url");

      // cached?
      if (runtime == null) {

        // query
        final response = await http.get(_uri!);

        // error?
        if (response.statusCode != 200) throw("error: ${response.statusCode} ${response.reasonPhrase}");

        // load the plugin
        var runtime = Runtime(ByteData.sublistView(response.bodyBytes));

        // load eval plugin
        runtime.addPlugin(flutterEvalPlugin);

        // save result
        _runtime = runtime;
      }
    }

    catch (e, trace) {
      error = "Error loading plugin from ${_uri?.url} $e";
      this.trace = trace;
    }

    // mark complete
    initialized!.complete(true);
  }

  $Value? _get(Runtime runtime, $Value? target, List<$Value?> args) {

    var key = args.isNotEmpty ? toStr(args.first) : null;
    dynamic value;

    if (key != null) {
      value = get(key);
    }

    if (value == null) return const $null();
    if (value is String) return $String(value);
    if (value is bool) return $bool(value);
    if (value is int) return $int(value);
    if (value is double) return $double(value);
    if (value is Color) return $String(toStr(value) ?? "");
    //if (value is List) return (value as List);
    return const $null();
  }

  dynamic get(String key)
  {
    var b = Binding.fromString(key);
    if (b != null) {
      var o = scope?.getObservable(b);
      return o?.get();
    }
    return null;
  }

  $Value? _set(Runtime runtime, $Value? target, List<$Value?> args) {

    var key   = args.isNotEmpty ? toStr(args.first) : null;
    var value = args.isNotEmpty  && args.length > 1 ? args[1]!.$value : null;

    if (key != null) {
      set(key, value);
    }
    return null;
  }

  void set(String key, dynamic value)
  {
    var b = Binding.fromString(key);
    if (b != null) {
      var o = scope?.getObservable(b);
      o?.set(value);
    }
  }
}