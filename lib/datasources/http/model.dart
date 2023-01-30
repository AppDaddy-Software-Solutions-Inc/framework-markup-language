// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:io';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/base/model.dart';
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/datasources/http/http.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/phrase.dart';
import 'package:fml/hive/post.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

enum Methods {get, put, post, patch, delete}
enum Types   {background, foreground, either}

class HttpModel extends DataSourceModel implements IDataSource
{
  // headers
  Map<String, String>? headers;

  bool? foreground = false;
  bool? background = false;

  // method
  StringObservable? _method;
  set method(dynamic v)
  {
    if (_method != null)
    {
      _method!.set(v);
    }
    else if (v != null)
    {
      _method = StringObservable(Binding.toKey(id, 'method'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get method => _method?.get();

  // timeout
  IntegerObservable? _timeout;
  set timeout(dynamic v)
  {
    if (_timeout != null)
    {
      _timeout!.set(v);
    }
    else if (v != null)
    {
      _timeout = IntegerObservable(Binding.toKey(id, 'timetoidle'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int get timeout => _timeout?.get() ?? defaultTimeout;

  // url
  StringObservable? _url;
  set url(dynamic v)
  {
    if (_url != null)
    {
      _url!.set(v);
    }
    else if (v != null)
    {
      _url = StringObservable(Binding.toKey(id, 'url'), v, scope: scope, listener: onPropertyChange);
      _url!.registerListener(onUrlChange);
    }
  }
  String? get url => _url?.get();

  HttpModel(WidgetModel parent, String? id) : super(parent, id);

  static HttpModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    HttpModel? model;
    try
    {
      model = HttpModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'iframe.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {

    // deserialize
    super.deserialize(xml);

    // properties
    method     = Xml.attribute(node: xml, tag: 'method');
    timeout    = Xml.get(node: xml, tag: 'timeout');
    url        = Xml.get(node: xml, tag: 'url');
    foreground = S.toBool(Xml.get(node: xml, tag: 'foreground'));
    background = S.toBool(Xml.get(node: xml, tag: 'background'));

    // build headers
    var headers = Xml.getChildElements(node: xml, tag: 'header');
    if (headers != null)
    for (var node in headers)
    {
      // set headers
      if (this.headers == null) this.headers = Map<String,String>();
      String? key   = Xml.get(node: node, tag: 'key');
      String? value = Xml.get(node: node, tag: 'value');
      if (!S.isNullOrEmpty(key) && !S.isNullOrEmpty(value)) this.headers![key!] = value!;
    }
  }

  onUrlChange(Observable observable)
  {
    if ((initialized == true) && (autoexecute == true) && (enabled != false)) start();
  }

  Future<bool> start({bool refresh: false, String? key}) async
  {
    if (enabled == false) return false;

    busy = true;
    await _start(refresh, key);
    busy = false;
    return true;
  }

  Future<bool> _start(bool refresh, String? key) async
  {
    bool ok = true;

    // replace file references
    String? body = await scope?.replaceFileReferences(this.body);

    // unresolved bindings?
    var url = this.url;
    if (Binding.hasBindings(url)) return ok;

    // lookup data in hive cache
    var cached = await super.fromHive(url, refresh);
    if (cached != null) return await super.onResponse(Data.from(cached, root: root), code: HttpStatus.ok);

    // determine posting type
    Types type = Types.foreground;
    if (foreground == true) type = Types.foreground;
    if (background == true) type = Types.background;
    if (foreground == true && background == true) type = Types.either;

    // web is always in the foreground
    if (isWeb) type = Types.foreground;
    if ((type == Types.either) && (System().connected)) type = Types.foreground;

    // process in the background
    if (type == Types.background)
    {
      // remember headers
      Map<String, String> headers = Http.encodeHeaders(this.headers);

      // save transaction
      Post post = Post(key: Uuid().v4(), formKey: key, status: Post.statusINCOMPLETE, method: S.fromEnum(this.method), url: this.url, headers: headers, body: body, date: DateTime.now().millisecondsSinceEpoch, attempts: 0);
      bool ok = await post.insert();
      if (ok) System().postmaster.start();
      return true;
    }

    // post in the foreground
    if ((type == Types.foreground) && (!System().connected))
    {
        await System.toast(phrase.checkConnection);
        return false;
    }

    busy = true;

    HttpResponse? response;
    Methods method = S.toEnum(this.method, Methods.values) ?? Methods.get;
    switch (method)
    {
      case Methods.get:
        response = await Http.get(url!, headers: headers, timeout: timeout);
        break;

      case Methods.post:
        response = await Http.post(url!, body ?? '', headers: headers, timeout: timeout);
        break;

      case Methods.put:
        response = await Http.put(url!, body ?? '', headers: headers, timeout: timeout);
        break;

      case Methods.patch:
        response = await Http.patch(url!, body, headers: headers, timeout: timeout);
        break;

      case Methods.delete:
        response = await Http.delete(url!, headers: headers, timeout: timeout);
        break;
    }

    // convert body to data
    Data data = Data.from(response.body, root: root);

    // format status message
    // changed by olajos - January 28, 2023
    String? msg = response.statusMessage;
    if (data.isEmpty && response.body is String) msg = response.body;
    if (S.isNullOrEmpty(msg)) msg = (response.statusCode == HttpStatus.ok) ? "ok" : "error #${response.statusCode ?? 0}";

    // save response data to the hive cache
    if (response.statusCode == HttpStatus.ok) toHive(url, response.body);

    // process response
    if (response.statusCode != HttpStatus.ok)
         return await super.onException(data, code: response.statusCode, message: msg);
    else return await super.onResponse(data,  code: response.statusCode, message: msg);
  }

  @override
  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async
  {
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    bool refresh = S.toBool(S.item(arguments,0)) ?? false;
    switch (function)
    {
      case "start" : return await start(refresh: refresh);
      case "fire" : return await start(refresh: refresh);
      // case "stop" : return await stop(); // missing implementation
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }
}
