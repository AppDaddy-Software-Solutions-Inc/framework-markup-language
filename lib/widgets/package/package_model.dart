import 'dart:async';
import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eval/flutter_eval.dart';
import 'package:fml/eval/eval.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/helpers/uri.dart';
import 'package:fml/helpers/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

class PackageModel extends Model {

  final Completer<bool> initialized = Completer<bool>();

  Runtime? _runtime;
  String? _name;
  String? _dart;
  String? _url;
  bool _defer = false;

  dynamic error;
  StackTrace? trace;

  PackageModel(super.parent, super.id);

  static PackageModel fromXml(Model parent, XmlElement xml) {
    var model = PackageModel(parent, Xml.get(node: xml, tag: 'id'));
    model.deserialize(xml);
    return model;
  }

  static Future<bool> load(XmlElement xml, bool refresh) async {
    var model = PackageModel(null, Xml.get(node: xml, tag: 'id'));
    return await model.tryLoad(xml, refresh);
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {

    // deserialize
    super.deserialize(xml);

    // properties
    _name = Xml.get(node: xml, tag: 'name')?.trim();
    _url  = Xml.get(node: xml, tag: 'url');
    _dart = Xml.get(node: xml, tag: 'dart');

    // load the plugin
    _loadPlugin(false);
  }

  // this function is called by thge template manger for loading
  // packages ahead of template deserialization
  Future<bool> tryLoad(XmlElement xml, bool refresh) async {

    // properties
    _defer = toBool(Xml.get(node: xml, tag: 'name')) ?? false;
    _name = Xml.get(node: xml, tag: 'name')?.trim();
    _url  = Xml.get(node: xml, tag: 'url');
    _dart = Xml.get(node: xml, tag: 'dart');

    // load the plugin in the background
    if (_defer) {
      _loadPlugin(refresh);
      return true;
    }

    // wait for the plugin to load
    return await _loadPlugin(refresh);
  }

  Future<bool> _loadPlugin(bool refresh) async {

    bool loaded = true;

    try {

      // cache key
      dynamic cacheKey = _url?.hashCode ?? _dart?.hashCode;

      // cached?
      if (System.plugins.containsKey(cacheKey)) {
        _runtime = System.plugins[cacheKey];
      }

      // force reload?
      if (refresh) {
        _runtime = null;
      }

      // load the plugin?
      if (_runtime == null) {

        // is url?
        if (!isNullOrEmpty(_url)) {

          // parse the url
          var uri = URI.parse(_url);

          if (uri != null) {

            // get the evc bytes from remote
            final response = await http.get(uri);

            // error?
            if (response.statusCode != 200) throw("error: ${response.statusCode} ${response.reasonPhrase}");

            // set the bytes
            var bytes = response.bodyBytes;

            // load the plugin
            _runtime = Runtime(ByteData.sublistView(bytes));

            // load eval plugin
            _runtime!.addPlugin(flutterEvalPlugin);

            // cache the plugin
            System.plugins[cacheKey] = _runtime!;
          }
        }

        // dart code
        else if (!isNullOrEmpty(_dart)) {

          var parts = _name?.replaceFirst("package:", "").split("/");
          var name = (parts?.isNotEmpty ?? true) ? parts!.first : "";
          var file = (parts?.isNotEmpty ?? true) ? parts!.length > 1 ? parts.last : ""  : "";

          final compiler = Compiler();
          compiler.addPlugin(flutterEvalPlugin);
          final program = compiler.compile({name : { file : _dart! }});

          var bytes = program.write();

          // load the plugin
          _runtime = Runtime(ByteData.sublistView(bytes));

          // load eval plugin
          _runtime!.addPlugin(flutterEvalPlugin);

          // cache the plugin
          System.plugins[cacheKey] = _runtime!;
        }
      }
    }

    catch (e, trace) {
      error = "Error loading plugin from $_name \n\n $e";
      this.trace = trace;
      loaded = false;
    }

    // mark complete
    initialized.complete(true);

    return loaded;
  }

  dynamic _wrap(dynamic value) {

    // null?
    if (value == null) return const $null();

    // String?
    if (value is String) return $String(value);

    // Boolean?
    if (value is bool) return $bool(value);

    // Integer?
    if (value is int) return $int(value);

    // Double?
    if (value is double) return $double(value);

    // Color?
    if (value is Color) return $String(toStr(value) ?? "");

    // Function?
    if (value is Function) {

      // Callback functions must be of type "EvalCallableFunc"
      // EvalCallableFunc => $Value? Function(Runtime runtime, $Value? target, List<$Value?> args)
     return (value is EvalCallableFunc) ? $Closure(value) : const $null();
    }

    // otherwise return the value
    return value;
  }

  dynamic _unwrap(dynamic value) {
    if (value is $Value) {
      value = value.$reified;
    }
    return value;
  }

  // {setter} call back function
  // must be EvalCallableFunc => $Value? Function(Runtime runtime, $Value? target, List<$Value?> args)
  $Value? _getCallback(Runtime runtime, $Value? target, List<$Value?> args) {

    String? key = toStr(_unwrap(args.isNotEmpty ? args.first : null));
    dynamic val;

    if (key != null) {
      var binding = Binding.fromString(key);
      if (binding != null) {
        var observable = scope?.getObservable(binding);
        val = observable?.get();
      }
    }
    return _wrap(val);
  }

  // {getter} call back function
  // must be EvalCallableFunc => $Value? Function(Runtime runtime, $Value? target, List<$Value?> args)
  $Value? _setCallback(Runtime runtime, $Value? target, List<$Value?> args) {

    String? key = toStr(_unwrap(args.isNotEmpty ? args.first : null));
    dynamic val = _unwrap(args.isNotEmpty && args.length > 1 ? args[1] : null);

    if (key != null) {
      var binding = Binding.fromString(key);
      if (binding != null) {
        var observable = scope?.getObservable(binding);
        observable?.set(val);
      }
    }
    return const $null();
  }

  Widget _errorBuilder(dynamic exception, StackTrace? stackTrace) {

    var msg = "Oops something went wrong loading plugin";
    if (exception != null) msg = "$msg \n\n $exception";
    if (stackTrace != null) msg = "$msg \n\n $stackTrace";
    var view = Tooltip(message: msg, child: const Icon(Icons.error_outline, color: Colors.red, size: 24));
    return view;
  }

  dynamic call(String method, List<dynamic> arguments) {

    try {

      // format the package name
      var package = _name ?? "";
      if (!package.toLowerCase().trim().startsWith("package:")) {
        package = "package:$package";
      }

      // wrap the arguments to pass to the plugin
      var args = [];
      for (var arg in arguments) {
        args.add(_wrap(arg));
      }

      // execute the dart code
      if (method.split(".").length == 1) {
        method = "$method.";
      }

      var result = _runtime?.executeLib(package, method, args);

      // return the result
      return _unwrap(result);
    }
    catch(error, trace) {

      if (kDebugMode) print("Error calling $method in package $_name\n\n $error \n\n $trace");
    }
    return null;
  }

  Widget? build(String? id, Scope? scope, String? plugin) {

    Map<String?, dynamic> variables = {};

    // get bindings?
    var bindings = Binding.getBindings(plugin, scope: scope) ?? [];
    for (var binding in bindings) {

      // get binding source
      var observable = scope?.getObservable(binding);
      var value = binding.translate(observable?.get() ?? "");
      variables[binding.signature] = value;
    }

    // this is necessary for plugin functions
    variables["{\$id}"] = id;
    variables["{\$scope}"] = scope;
    variables["{\$get}"] = _getCallback;
    variables["{\$set}"] = _setCallback;
    var view = Eval.evaluate(plugin, variables: variables);

    // error?
    if (view is! Widget) {
      var error = this.error ?? "Failed to create widget from plugin='$plugin'";
      view = _errorBuilder(error, trace);
    }

    return view;
  }

  @override
  Future<dynamic> execute(
      String caller,
      String propertyOrFunction,
      List<dynamic> arguments) async {

    var method = "${caller.split(".").last.trim()}.${propertyOrFunction.trim()}";
    var result = await call(method, arguments);
    return result;
  }
}

