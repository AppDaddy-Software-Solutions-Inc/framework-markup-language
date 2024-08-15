import 'dart:async';
import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eval/flutter_eval.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/helpers/uri.dart';
import 'package:fml/helpers/xml.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

mixin PackageMixin on Model {

  Completer<bool>? _initialized;

  Runtime? _runtime;
  String? _name;
  String? _dart;
  String? _url;

  dynamic error;
  StackTrace? trace;

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
    _loadPlugin();
  }

  Future<void> _loadPlugin() async {

    _initialized ??= Completer<bool>();

    try {

      // cached?
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

            // save result
            //framework?.addPackage(package, runtime);
          }
        }

        // dart code
        else if (!isNullOrEmpty(_dart)) {

          //var parts = _package!.replaceFirst("package:", "").split("/");
          //var name = parts.isNotEmpty ? parts.first : "";
          //var file = parts.length > 1 ? parts.last  : "";

          final compiler = Compiler();
          compiler.addPlugin(flutterEvalPlugin);
          final program = compiler.compile({'name' : { 'file' : 'package' }});

          var bytes = program.write();

          // load the plugin
          _runtime = Runtime(ByteData.sublistView(bytes));

          // load eval plugin
          _runtime!.addPlugin(flutterEvalPlugin);

          // save result
          //framework?.addPackage(package, runtime);
        }
      }
    }

    catch (e, trace) {
      error = "Error loading plugin from $_name \n\n $e";
      this.trace = trace;
    }

    // mark complete
    _initialized!.complete(true);
  }

  $Value _wrap(dynamic value) {
    if (value == null) return const $null();
    if (value is String) return $String(value);
    if (value is bool) return $bool(value);
    if (value is int) return $int(value);
    if (value is double) return $double(value);
    if (value is Color) return $String(toStr(value) ?? "");
    //if (value is List) return (value as List);
    return const $null();
  }

  $Value? _get(Runtime runtime, $Value? target, List<$Value?> args) {

    var key = args.isNotEmpty ? toStr(args.first) : null;
    dynamic value;

    if (key != null) {
      value = get(key);
    }
    return _wrap(value);
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

  Widget _errorBuilder(dynamic exception, StackTrace? stackTrace) {

    var msg = "Oops something went wrong loading plugin";
    msg = "$msg \n\n $exception \n\n $stackTrace";
    var view = Tooltip(message: msg, child: const Icon(Icons.error_outline, color: Colors.red, size: 24));
    return view;
  }

  Future<dynamic> call(String method, dynamic arguments) async {
    try {

      // format the package name
      var package = _name ?? "";
      if (!package.toLowerCase().trim().startsWith("package:")) {
        package = "package:$package";
      }

      // execute the dart code
      var result = _runtime?.executeLib(package, method, [toStr("Jeff")]);

      // set value
      return toStr(result);

    }
    catch(error, trace) {

      if (kDebugMode) print("Error calling $method in package $_name\n\n $error \n\n $trace");
    }
    return null;
  }

  Future<Widget?> view(String? className, {dynamic arguments}) async {

    Widget? view;

    try {

      // wait for evc code to load
      await _initialized?.future;

      // error during build?
      if (error != null) return _errorBuilder(error,trace);

      var args =[$String(id), $Closure(_get), $Closure(_set)];

      // format the package name
      var package = _name ?? "";
      if (package.toLowerCase().trim().startsWith("package:")) {
        package = "package:$package";
      }

      // format class name
      className ??= ".";

      // format the
      view = _runtime?.executeLib(package, className, args);
    }
    catch(error, trace) {
      view =_errorBuilder(error,trace);
    }

    return view;
  }


  @override
  Future<dynamic> execute(
      String caller,
      String propertyOrFunction,
      List<dynamic> arguments) async {

    var method = "${caller.split(".").last.trim()}.${propertyOrFunction.trim()}";
    return await call(method, arguments);
  }
}

