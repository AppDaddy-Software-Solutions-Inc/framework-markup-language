// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/log/manager.dart';
import 'package:fml/navigation/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/system.dart';
import 'package:uuid/uuid.dart';
import 'package:validators/validators.dart';
import 'package:xml/xml.dart';
import 'package:fml/datasources/http/http.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/hive/form.dart' as DATABASE;
import 'package:fml/helper/helper_barrel.dart';

class Template
{
  final String? name;
  final XmlDocument? document;

  Template({this.name, this.document});

  static XmlDocument? _fromMemory(String url)
  {
    String? filename = Url.path(Url.toAbsolute(url));
    if (System().templates.containsKey(filename)) return System().templates[filename];
    return null;
  }

  static toMemory(String url, XmlDocument? document)
  {
    String? filename = Url.path(Url.toAbsolute(url));
    if (filename != null) System().templates[filename] = document;
  }

  static Future<String?> _fromDatabase(String key) async
  {
    String? template;
    try
    {
      // lookup from local hive
      DATABASE.Form? form = await DATABASE.Form.find(key);
      if (form != null) template = form.template;
    }
    catch (e)
    {
      Log().exception(e);
      template = null;
    }
    return template;
  }

  static Future<String?> _fromAssetsBundle(String url) async
  {
    String? template;
    try
    {
      // not supported on web
      if (isWeb) throw('Local Files not supported in Browser');

      // get template from asset bundle
      template = await rootBundle.loadString(url.replaceFirst("file://", "assets/"), cache: false);
    }
    catch (e)
    {
      Log().error("Can't find valid template $url in asset bundle. Error is $e");
    }
    return template;
  }

  static Future<String?> _fromServer(String url) async
  {
    String? template;
    try
    {
      // get template from remote server
      if (System().connected == true)
      {
        // get the template from the cloud
        HttpResponse response = await Http.get(url, refresh: true);
        if (!response.ok) throw '[${response.statusCode}] ${response.statusMessage}';
        template = response.body;
      }
      else
      {
        Log().debug("Unable to fetch template from serve not connected to the internet");
      }
    }
    catch (e)
    {
      Log().error("Can't find valid template $url on server. Error is $e");
    }
    return template;
  }

  static Future<String?> _fromDisk(String url) async
  {
    String? template;
    try
    {
      String? filename = Url.path(Url.toAbsolute(url));
      if (filename != null)
      {
        bool exists = System().fileExists(filename);
        if (exists) template = await System().readFile(filename);
      }
    }
    catch (e)
    {
      Log().exception(e);
      template = null;
    }
    return template;
  }

  static Future<bool> _toDisk(String url, String xml) async
  {
    String? filename = Url.path(Url.toAbsolute(url));
    if (filename != null)
    {
      Log().debug('Writing $filename to disk", object: "TEMPLATE"');
      return await System().writeFile(filename, xml);
    }
    return false;
  }

  factory Template.fromDocument({String? name, XmlDocument? xml, Map<String, String?>? parameters})
  {
    Template template = Template(name: name, document: xml);
    template = Template.fromTemplate(template: template, parameters: parameters);
    return template;
  }

  factory Template.fromTemplate({required Template template, Map<String, String?>? parameters})
  {
    try
    {
      // Convert Xml Document to Xml String
      String? xml = template.document.toString();

      // Replace Bindings in Xml
      if (parameters != null) xml = Binding.applyMap(xml, parameters, caseSensitive: false);

      // Replace System Parameters in Xml
      xml = Binding.applyMap(xml, System().queryParameters, caseSensitive: false);

      // Replace Config Parameters in Xml
      if (System().config != null) xml = Binding.applyMap(xml, System().config!.parameters, caseSensitive: false);

      // Replace System Uuid
      String s = Binding.toKey("SYSTEM", 'uuid')!;
      while (xml!.contains(s)) xml = xml.replaceFirst(s, Uuid().v4());

      // Convert Xml String to Xml Document
      XmlDocument document = XmlDocument.parse(xml);

      // return the new template
      template = Template(name: template.name, document: document);
    }
    catch (e)
    {
      Log().debug(e.toString());
    }

    return template;
  }

  static Future<Template> fetch({required String url, Map<String, String?>? parameters, bool? refresh = false}) async
  {
    Log().debug('Getting template ' + url);

    String? template;
    bool isFileUrl = (url.toLowerCase().trim().startsWith("file://") && url.toLowerCase().trim().endsWith(".xml"));

    // get template from file
    if (template == null && !isFileUrl)
    {
      // requested template is a form?
      if (isUUID(url)) template = await _fromDatabase(url);

      // get template from server
      if (template == null && (refresh == true || System.refresh))
      {
        // get template
        template = await _fromServer(url);

        // save to local storage
        if (template != null) _toDisk(url, template);
      }

      // get template from memory
      if (template == null)
      {
        XmlDocument? document = _fromMemory(url);
        if (document != null) return Template.fromDocument(name: url, xml: document, parameters: parameters);
      }

      // get template from disk
      if (template == null) template = await _fromDisk(url);

      // get template from database (web)
      if (template == null) template = await _fromDatabase(url);

      // get template from server
      if (template == null)
      {
        // get template
        template = await _fromServer(url);

        // save to local storage
        if (template != null) _toDisk(url, template);
      }
    }

    // local template
    else
    {
      // from assets archive
      if (template == null) template = await _fromAssetsBundle(url);

      // from file
      if (template == null) template = await _fromDisk(url);
    }

    // not found - build error template
    bool error = (template == null);
    if (error) template = _buildErrorTemplate('Template $url not found!');

    // parse the document
    XmlDocument? document;
    try
    {
      document = XmlDocument.parse(template!);
    }
    on  Exception catch(e)
    {
      error = true;
      template = _buildErrorTemplate('Template Syntax is Invalid', e.toString());
      document = Xml.tryParse(template);
    }

    // process includes
    if (document != null) await _processIncludes(document, parameters);

    // cache in memory after processing include files
    if ((document != null) && (!error)) await toMemory(url, document);

    // return the template
    return Template.fromDocument(name: url, xml: document, parameters: parameters);
  }

  static Future<bool> _processIncludes(XmlDocument document, Map<String, String?>? parameters) async
  {
    Iterable<XmlElement> includes = document.findAllElements("INCLUDE", namespace: "*");
    for (XmlElement element in includes)
    {
      // exclude?
      bool exclude = WidgetModel.excludeFromTemplate(element, System().scope);
      if (!exclude)
      {
        // get template segment
        String url = Binding.applyMap(Xml.get(node: element, tag: 'url'), parameters, caseSensitive: false)!;

        // fetcgh the include template
        XmlElement? include = await _getIncludeTemplate(url);

        // inject include segment into document
        if (include != null)
        {
          int position = element.parent!.children.indexOf(element);
          try
          {
            List<XmlElement> nodes = [];

            // include must always be wrapped in a parent that is ignored, often <FML>
            for (dynamic node in include.children)
              if (node is XmlElement) nodes.add(node.copy());

            element.parent!.children.insertAll(position, nodes);
          }
          catch (e)
          {
            Log().debug(e.toString());
          }
        }
      }

      ///////////////////////////////
      /* Remove Node from Document */
      ///////////////////////////////
      element.parent!.children.remove(element);
    }
    return true;
  }

  static Future<XmlElement?> _getIncludeTemplate(String url) async
  {
    // decode url
    Uri uri = Uri.parse(url);
    if (!uri.hasAuthority) uri = Uri.parse(System().domain! + '/' + url);
    String templateName = uri.path;

    // parameters
    Map<String, String> parameters = Map<String, String>();
    parameters.addAll(uri.queryParameters);

    // fetch the template
    var template = await Template.fetch(url: templateName, parameters: parameters);

    // return template xml
    return (template.document != null) ? template.document!.rootElement : null;
  }

  static String? _buildErrorTemplate(String err1, [String? err2])
  {
    String backbutton = NavigationManager().pages.length > 1 ? '<BUTTON onclick="back()" value="go back" type="text" color="#35363A" />' : '';

    String xml = '''
    <ERROR linkable="true">
      <BOX width="100%" height="100%" color1="white" color2="grey" start="topleft" end="bottomright" center="true">
        <ICON icon="error_outline" size="128" color="red" />
        <PAD top="30" />
        <TEXT id="e1" size="26" color="#35363A" bold="true">
        <VALUE><![CDATA[$err1]]></VALUE>
        </TEXT> 
        <PAD top="10" visible="=!noe({e2})" />
        <TEXT id="e2" visible="=!noe({e2})" size="20" color="#35363A">
        <VALUE><![CDATA[$err2]]></VALUE>
        </TEXT> 
        <PAD top="30" />
        $backbutton
      </BOX>
    </ERROR>
    ''';
    return xml;
  }
}
