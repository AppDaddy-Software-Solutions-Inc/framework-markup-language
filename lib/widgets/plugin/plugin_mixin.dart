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

enum PluginType {widget, function}

mixin PluginMixin on Model {

  late final PluginType type;

  // cached plugin evc code
  static final Map<String, Runtime> _runtimes = <String, Runtime>{};
  Runtime? get runtime {
    var key = uri?.url;
    if (isNullOrEmpty(key)) return null;
    if (!_runtimes.containsKey(key)) return null;
    return _runtimes[key];
  }

  set runtime(Runtime? value) {
    var key = uri?.url;
    if (isNullOrEmpty(key)) return;
    if (value == null) {
      _runtimes.remove(key);
    }
    else {
      _runtimes[key!] = value;
    }
  }

  Uri? uri;
  String library = "";
  String method = "";
  String methodSignature = "";

  Completer<bool> initialized = Completer();
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
  List<dynamic> get arguments => [$String(id), $Closure(_get), $Closure(_set)];

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {

    // deserialize
    super.deserialize(xml);

    // properties
    uri = URI.parse(Xml.get(node: xml, tag: 'url'));

    var library = Xml.get(node: xml, tag: 'import')?.trim() ?? "";
    if (!isNullOrEmpty(library) && !library.startsWith("package:")) library = "package:$library";
    this.library = library;

    // set function
    methodSignature = Xml.get(node: xml, tag: 'method')?.trim() ?? "";
    method = methodSignature.split("(").first.trim();
    if (!isNullOrEmpty(method) && !method.contains(".")) method = "$method.";
    method = method.trim();

    // load the plugin
    _load();
  }

  Future _load() async {

    try {

      if (uri == null) throw("Invalid plugin url");

      // cached?
      if (runtime == null) {

        // query
        final response = await http.get(uri!);

        // error?
        if (response.statusCode != 200) throw("error: ${response.statusCode} ${response.reasonPhrase}");

        // load the plugin
        var runtime = Runtime(ByteData.sublistView(response.bodyBytes));

        // load eval plugin
        runtime.addPlugin(flutterEvalPlugin);

        // save result
        this.runtime = runtime;
      }
    }

    catch (e, trace) {
      error = "Error loading plugin from ${uri?.url} $e";
      this.trace = trace;
    }

    // mark complete
    initialized.complete(true);
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

  void _execute() async {
    // not a function
    if (type != PluginType.function) return;

    // wait for runtime to load
    await initialized.future;

    if (runtime == null) return;

    try {

      // execute the dart code
      var result = runtime?.executeLib(library, method, arguments);

      // set value
      value = toStr(result);
    }
    catch(e) {
      if (kDebugMode) print(e);
    }
  }

  @override
  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async {

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