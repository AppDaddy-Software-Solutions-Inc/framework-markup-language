// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/log/manager.dart';
import 'package:fml/navigation/navigation_manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/system.dart';
import 'package:fml/template/template_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:validators/validators.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/helper/common_helpers.dart';

class Template
{
  final String? name;
  final XmlDocument? document;

  Template({this.name, this.document});

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

      // Replace query parameters
      xml = Binding.applyMap(xml, Application?.queryParameters, caseSensitive: false);

      // Replace config parameters
      xml = Binding.applyMap(xml, Application?.configParameters, caseSensitive: false);

      // Replace System Uuid
      String s = Binding.toKey(System.Id, 'uuid')!;
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

  static Future<XmlDocument?> fetchTemplate({required String url, Map<String, String?>? parameters, required bool refresh}) async
  {
    // saved document
    if (isUUID(url)) return await fetchSaved(url: url);

    Log().debug('Getting template ' + url);

    // parse the url
    var uri = URI.parse(url);
    if (uri == null) return null;

    // use qualified url
    url = uri.url;

    String? template;

    // auto refresh
    refresh = refresh || (Application?.autoRefresh ?? false);

    // get template from file
    if (uri.scheme != "file")
    {
      // get template from server
      if (refresh == true)
      {
        // get template
        template = await TemplateManager().fromServer(url);

        // save to local storage
        if (template != null && (Application?.cacheContent ?? false)) TemplateManager().toDisk(url, template);
      }

      // get template from memory
      if (template == null)
      {
        XmlDocument? document = TemplateManager().fromMemory(url);
        if (document != null) return document;
      }

      // get template from disk
      if (template == null) template = await TemplateManager().fromDisk(url);

      // get template from database (web)
      if (template == null) template = await TemplateManager().fromDatabase(url);

      // get template from server
      if (template == null)
      {
        // get template
        template = await TemplateManager().fromServer(url);

        // save to local storage
        if (template != null && (Application?.cacheContent ?? false)) TemplateManager().toDisk(url, template);
      }
    }

    // local template
    else
    {
      // from assets archive
      if (template == null) template = await TemplateManager().fromAssetsBundle(url);

      // from disk
      if (template == null) template = await TemplateManager().fromDisk(url);
    }

    // nothing to process
    if (template == null)
    {
      Log().error("Template $url not found!");
      return null;
    }

    var document = Xml.tryParse(template);

    // process includes
    if (document != null) await _processIncludes(document, parameters, refresh);

    // cache in memory after processing include files
    if (document != null) await TemplateManager().toMemory(url, document);

    // return the template
    return Template.fromDocument(name: url, xml: document, parameters: parameters).document;
  }

  static Future<XmlDocument?> fetchSaved({required String url}) async
  {
    Log().debug('Getting saved template ' + url);

    String? template;

    // get template from database (web)
    if (template == null) template = await TemplateManager().fromDatabase(url);

    return Xml.tryParse(template);
  }


  static Future<Template> fetch({required String url, Map<String, String?>? parameters, required bool refresh}) async
  {
    Log().debug('Building template');

    // get the template
    XmlDocument? document = await fetchTemplate(url: url, refresh: refresh);

    // deserialize
    if (document != null) return Template.fromDocument(name: url, xml: document, parameters: parameters);

    // not found - build error template
    String? xml404 = _buildErrorTemplate('Page Not Found', null, "$url");

    // parse the error template created
    try
    {
      document = XmlDocument.parse(xml404!);
    }
    on  Exception catch(e)
    {
      xml404 = _buildErrorTemplate('Error on Page', '$url', e.toString());
      document = Xml.tryParse(xml404);
    }

    // return the error template
    return Template.fromDocument(name: url, xml: document, parameters: parameters);
  }

  static Future<bool> _processIncludes(XmlDocument document, Map<String, String?>? parameters, bool refresh) async
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

        // fetch the include template
        Uri? uri = Uri.tryParse(url);
        if (uri != null)
        {
          // parameters
          Map<String, String> parameters = Map<String, String>();
          parameters.addAll(uri.queryParameters);

          // fetch the template
          var template = await Template.fetchTemplate(url: url, parameters: parameters, refresh: refresh);

          // inject include segment into document
          if (template != null)
          {
            int position = element.parent!.children.indexOf(element);
            try
            {
              // include must always be wrapped in a parent that is ignored, often <FML>
              List<XmlElement> nodes = [];
              XmlElement? include = template.document!.rootElement;
              for (dynamic node in include.children)
                if (node is XmlElement) nodes.add(node.copy());
              element.parent!.children.insertAll(position, nodes);
            }
            catch (e)
            {
              Log().debug("Error parsing include file $url. Error is $e");
            }
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

  static String? _buildErrorTemplate(String err1, [String? err2, String? err3])
  {
    String backbutton = NavigationManager().pages.length > 1 ? '<BUTTON onclick="back()" value="go back" type="text" color="#35363A" />' : '';

    String xml = '''
    <ERROR linkable="true">
      <BOX width="100%" height="100%" color1="white" color2="grey" start="topleft" end="bottomright" center="true">
        <ICON icon="error_outline" size="128" color="red" />
        <PAD top="30" />
        <CENTER>
        <TEXT id="e1" size="26" color="#35363A" bold="true">
        <VALUE><![CDATA[$err1]]></VALUE>
        </TEXT> 
        </CENTER>
        <PAD top="10" visible="=!noe({e2})" />
        <TEXT id="e2" visible="=!noe({e2})" size="16" color="red">
        <VALUE><![CDATA[$err2]]></VALUE>
        </TEXT> 
        <PAD top="10" visible="=!noe({e3})" />
        <TEXT id="e3" visible="=!noe({e3})" size="16" color="#35363A">
        <VALUE><![CDATA[$err3]]></VALUE>
        </TEXT> 
        <PAD top="30" />
        $backbutton
      </BOX>
    </ERROR>
    ''';
    return xml;
  }
}
