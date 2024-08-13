import 'dart:async';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter/foundation.dart';
import 'package:dart_eval/dart_eval.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/helpers/uri.dart';
import 'package:fml/helpers/xml.dart';
import 'package:fml/observable/observable.dart';
import 'package:fml/observable/observables/string.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

mixin PluginMixin on Model {

  // cached plugin evc code
  static Map<String, Uint8List> plugins = <String, Uint8List>{};
  static Map<String, Runtime> runtimes = <String, Runtime>{};

  Uri? uri;
  String library = "";
  String method = "";
  String methodSignature = "";

  Completer<bool> initialized = Completer();
  dynamic error;
  StackTrace? trace;

  final List<Observable> _args = [];

  List<dynamic> get arguments {
    var args = [];
    for (var o in _args) {
      args.add($String(o.get()));
    }
    return args;
  }

  // bytes
  Uint8List? get plugin {
    if (uri?.url == null) return null;
    if (!plugins.containsKey(uri?.url)) return null;
    return plugins[uri?.url];
  }

  void onArgumentChange(Observable observable) {
      super.onPropertyChange(observable);
  }

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

    // set type and build arguments
    _buildArguments(methodSignature);

    // load the plugin
    loadPlugin();
  }

  Future loadPlugin() async {

    try {
      if (uri?.url != null) {
        final response = await http.get(uri!);
        if (response.statusCode == 200) {
          plugins[uri!.url] = response.bodyBytes;
        }
        else {
          throw("error: ${response.statusCode} ${response.reasonPhrase}");
        }
      }
      else {
        throw("Invalid plugin url");
      }
    }
    catch (e, trace) {
      error = "Error loading plugin from ${uri?.url} $e";
      this.trace = trace;
    }

    // mark complete
    initialized.complete(true);
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
}