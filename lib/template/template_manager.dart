// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:fml/fml.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/phrase.dart';
import 'package:fml/system.dart';
import 'package:fml/template/template.dart';
import 'package:validators/validators.dart';
import 'package:xml/xml.dart';
import 'package:fml/datasources/http/http.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fml/hive/form.dart';
import 'package:fml/helpers/helpers.dart';

class TemplateManager
{
  // holds in-memory deserialized templates
  // primarily used for performance reasons
  HashMap<String, XmlDocument> templates = HashMap<String, XmlDocument>();

  static final TemplateManager _singleton = TemplateManager._init();
  factory TemplateManager()
  {
    return _singleton;
  }

  TemplateManager._init();

  Future<Template> fetch({required String url, Map<String, String?>? parameters, required bool refresh}) async
  {
    // template is a form saved in the database?
    if (isUUID(url)) return await _fetchFromDatabase(url, parameters);

    // template from embedded .js
    if (url == 'js2fml' && parameters != null) return await _fetchFromHtml(url, parameters);

    // parse the passed url
    var uri = URI.parse(url);
    if (uri == null) return fetchErrorTemplate(FetchResult(code: HttpStatus.badRequest, message: Phrases().missingOrInvalidURL, detail: url));
    url = uri.url;

    // get template from file
    if (uri.scheme == "file") return _fetchFromFile(url, parameters);

    // get template from server (default)
    return await _fetchFromServer(url, uri, parameters, refresh);
  }

  FetchResult _fromMemory(Uri uri)
  {
    if (templates.containsKey(uri.url)) return FetchResult(document: templates[uri.url]);
    return FetchResult(code: HttpStatus.notFound, message: Phrases().pageNotFound, detail: uri.url);
  }

  toMemory(String key, XmlDocument document) => _toMemory(key, document);
  _toMemory(String key, XmlDocument? document)
  {
    if (document != null) templates[key] = document;
  }

  Future<FetchResult> _fromDatabase(String key) async
  {
    try
    {
      // lookup from local hive
      Form? form = await Form.find(key);
      return form != null ? FetchResult(template: form.template) : FetchResult(code: HttpStatus.notFound, message: Phrases().formNotFound, detail: key);
    }
    catch(e)
    {
      Log().exception(e);
      return FetchResult(code: HttpStatus.internalServerError, message: "Error getting template from the Database", detail: e.toString());
    }
  }

  Future<FetchResult> _fromAssetsBundle(String url) async
  {
    try
    {
      // not supported on web
      if (FmlEngine.isWeb) throw('Local Files not supported in Browser');

      // get template from asset bundle
      var template = await rootBundle.loadString(url.replaceFirst("file://", "assets/"), cache: false);

      return FetchResult(template: template);
    }
    catch(e)
    {
      Log().exception(e);
      return FetchResult(code: HttpStatus.notFound, message: Phrases().assetNotFound, detail: "$url $e");
    }
  }

  Future<FetchResult> _fromDisk(String url) async
  {
    try
    {
      // not supported on web
      if (FmlEngine.isWeb)    throw('Local Files not supported in Browser');
      if (FmlEngine.isMobile) throw('Local Files not supported in Mobile');

      // get template from file
      Uri? uri = URI.parse(url);
      String? filepath = uri?.asFilePath();

      var template = await Platform.readFile(filepath);
      return template != null ? FetchResult(template: template) : FetchResult(code: HttpStatus.notFound, message: Phrases().fileNotFound, detail: url);
    }
    catch(e)
    {
      Log().exception(e);
      return FetchResult(code: HttpStatus.notFound, message: Phrases().fileNotFound, detail: "$url $e");
    }
  }

  Future<FetchResult> _fromServer(String url) async
  {
    // connected to the internet?
    if (System().connected)
    {
      // get the template from remote server
      HttpResponse? response;
      try
      {
        response = await Http.get(url, refresh: true, timeout: 60);
      }
      catch(e)
      {
        response = HttpResponse(url, statusCode: HttpStatus.badGateway, statusMessage: e.toString());
      }

      // ok
      if (response.ok) return FetchResult(template: response.body);

      // error
      Log().error("Error fetching template from $url. Error is ${response.statusCode} ${response.statusMessage}");

      var msg = Phrases().siteUnreachable;
      if (response.statusCode == HttpStatus.notFound) msg = Phrases().pageNotFound;

      return FetchResult(code: response.statusCode, message: "${response.statusCode} $msg", detail: url);
    }

    Log().debug("Unable to fetch template from server. No internet connection");
    return FetchResult(code: HttpStatus.gatewayTimeout, message: Phrases().notConnected, detail: Phrases().checkConnection);
  }

  Future<bool> _toDisk(String url, String xml) async
  {
    var uri = URI.parse(url);
    if (uri != null)
    {
      var filepath = uri.asFilePath();
      return await Platform.writeFile(filepath, xml);
    }
    return false;
  }

  Future<Template> _fetchFromDatabase(String url, Map<String, String?>? parameters) async
  {
    Log().info("Querying template from the database");

    // get template from database (web)
    var result = await _fromDatabase(url);

    // parse the template
    if (result.isSuccess) result = _parse(result.template);

    // return the error page
    if (result.isFail) fetchErrorTemplate(result);

    // return template
    return Template.fromXmlDocument(name: url, xml: result.document, parameters: parameters);
  }

  Future<Template> _fetchFromHtml(String url, Map<String, String?> parameters) async
  {
    Log().info("Querying template from the js");

    var key = 'templ8';
    if (parameters.containsKey(key))
    {
      // parse the template
      var result = _parse(parameters['templ8']);

      // return the error page
      if (result.isFail) fetchErrorTemplate(result);

      // return template
      return Template.fromXmlDocument(name: url, xml: result.document);
    }

    // return the error page
    return fetchErrorTemplate(FetchResult(code: HttpStatus.notFound));
  }

  Future<Template> _fetchFromFile(String url, Map<String, String?>? parameters) async
  {
    Log().info("Querying template from the assets or file");

    // from assets archive
    var result = await _fromAssetsBundle(url);

    // from disk
    if (result.isFail) result = await _fromDisk(url);

    // return the error page
    if (result.isFail) return fetchErrorTemplate(result);

    // parse the template
    if (result.isSuccess) result = _parse(result.template);

    // return template
    return Template.fromXmlDocument(name: url, xml: result.document, parameters: parameters);
  }

  Future<Template> _fetchFromServer(String url, Uri uri, Map<String, String?>? parameters, bool refresh) async
  {
    Log().info("Querying template from $url");

    // auto refresh??
    refresh = refresh || (System.app?.autoRefresh ?? false);

    // templates are cached (written back to disk)
    // for performance reasons
    bool cache = System.app?.cacheContent ?? false;

    var result = FetchResult();

    // get template from server
    if (refresh)
    {
      // get template
      result = await _fromServer(url);

      // save to local storage
      if (result.isSuccess && cache) _toDisk(url, result.template!);
    }

    // get template from memory
    if (result.isFail)
    {
      result = _fromMemory(uri);
      if (result.isSuccess) return Template.fromXmlDocument(name: url, xml: result.document, parameters: parameters);
    }

    // get template from disk
    if (result.isFail) result = await _fromDisk(url);

    // get template from database (web)
    if (result.isFail) result = await _fromDatabase(url);

    // get template from server
    if (result.isFail) result = await _fromServer(url);

    // save to local storage
    if (result.isSuccess && cache) _toDisk(url, result.template!);

    // not found?
    if (result.isFail) return fetchErrorTemplate(result);

    // parse the template
    if (result.isSuccess) result = _parse(result.template);

    // invalid fml syntax
    if (result.isFail) return fetchErrorTemplate(result);

    // process includes
    await _processIncludes(result.document!, parameters, refresh);

    // cache to memory
    await _toMemory(url, result.document);

    // return template
    return Template.fromXmlDocument(name: url, xml: result.document, parameters: parameters);
  }

  Future<Template> fetchErrorTemplate(FetchResult result) async
  {
    var color1 = toStr(toColor(System.theme.onBackground));
    var color2 = toStr(toColor(System.theme.primary));

    String back = '''
    <BUTTON onclick="back()" type="outlined" pas="8" color="$color1">
        <ICON icon="arrow_back" size="40" color="$color1"/>
    </BUTTON>''';

    // default error template
    String fml = '''
    <ERROR ${Template.errorPageAttribute}="true" linkable="true" layout="column" padding="20" center="true">
        
        <BOX center="true" expand="false">
        
          <ICON icon="${result.icon}" size="200" color="$color2" margin="20"/>
          
          <TEXT id="e1" halign="center" size="={SYSTEM.screenwidth} &gt; 700 ? '32' : '24'" bold="true">
            <value><![CDATA[${result.message}]]></value>
          </TEXT>           
          
          <BOX height="20"/>              
          $back      
          <BOX height="20"/>
          
          <TEXT id="e2" selectable="true" halign="center" size="={SYSTEM.screenwidth} &gt; 700 ? '24' : '16'" visible="=!noe({e2})">
            <value><![CDATA[${result.detail}]]></value>
          </TEXT>
                   
        </BOX>
    </ERROR>''';

    // fetch custom error template from the server?
    if (!isNullOrEmpty(System.app?.errorPage)) fml = await _fetchErrorPageFromServer(result, back) ?? fml;

    return Template.fromFml(fml: fml);
  }

  Future<String?> _fetchErrorPageFromServer(FetchResult result, String back) async
  {
    if (System.app?.errorPage == null) return null;

    var url = System.app!.errorPage!;
    var template = await fetch(url: url, refresh: false);
    if (template.document == null || template.isAutoGeneratedErrorPage) return null;

    var node = template.document!.rootElement;
    var xml  = node.toString();
    xml = xml.replaceAll("{message}", result.message ?? "");
    xml = xml.replaceAll("{detail}", result.detail ?? "");
    xml = xml.replaceAll("{code}", toStr(result.code) ?? "");
    xml = xml.replaceAll("{back}", back);

    var doc = Xml.tryParse(xml);
    if (doc != null)
    {
      var node = doc.rootElement;
      Xml.setAttribute(node, Template.errorPageAttribute, "true");
      Xml.setAttribute(node, "linkable", "true");
      return node.toString();
    }
    return null;
  }

  FetchResult _parse(String? template)
  {
    if (template == null) return FetchResult(template: template, code: HttpStatus.noContent, message: Phrases().errorParsingTemplate);
    try
    {
      var document = XmlDocument.parse(template);
      return FetchResult(template: template, document: document);
    }
    catch(e)
    {
      return FetchResult(template: template, code: HttpStatus.noContent, message: Phrases().errorParsingTemplate, detail: e.toString());
    }
  }

  Future<bool> _processIncludes(XmlDocument document, Map<String, String?>? parameters, bool refresh) async
  {
    Iterable<XmlElement> includes = document.findAllElements("INCLUDE", namespace: "*");
    for (XmlElement element in includes)
    {
      // exclude?
      bool exclude = excludeFromTemplate(element, System().scope);
      if (!exclude)
      {
        // get template segment
        String url = Binding.applyMap(Xml.get(node: element, tag: 'url'), parameters, caseSensitive: false)!;

        // fetch the include template
        Uri? uri = Uri.tryParse(url);
        if (uri != null)
        {
          // parameters
          Map<String, String> parameters = <String, String>{};
          parameters.addAll(uri.queryParameters);

          // fetch the template
          var template = await fetch(url: url, parameters: parameters, refresh: refresh);

          // inject include segment into document
          int position = element.parent!.children.indexOf(element);
          try
          {
            // include must always be wrapped in a parent that is ignored, often <FML>
            List<XmlElement> nodes = [];
            XmlElement? include = template.document!.rootElement;
            for (dynamic node in include.children) {
              if (node is XmlElement) nodes.add(node.copy());
            }
            element.parent!.children.insertAll(position, nodes);
          }
          catch(e)
          {
            Log().debug("Error parsing include file $url. Error is $e");
          }
        }
      }

      // remove the node from the document
      element.parent!.children.remove(element);
    }
    return true;
  }
}

class FetchResult
{
  late final int code;
  final String? message;
  final String? detail;
  final String? template;
  XmlDocument? document;

  bool get isSuccess => code == HttpStatus.ok && template != null;
  bool get isFail => !isSuccess;

  FetchResult({code, this.message, this.detail, this.template, this.document})
  {
    this.code = code ?? HttpStatus.ok;
  }

  String get icon
  {
    switch (code)
    {
      case HttpStatus.ok:
        return "check_circle_outline";

     // page not found
      case HttpStatus.notFound:
        return "search_off";

      // not connected
      case HttpStatus.gatewayTimeout:
        return "cloud_off";

      // user rights
      case HttpStatus.unauthorized:
        return "no_encryption_outlined";

      // remote http call failed
      case HttpStatus.badGateway:
        return "mood_bad";

      // parse error
      case HttpStatus.noContent:
        return "bug_report_outlined";

      default: return "error_outline";
    }
  }
}

