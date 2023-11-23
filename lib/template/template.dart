// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/log/manager.dart';
import 'package:fml/navigation/navigation_manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/system.dart';
import 'package:fml/template/template_manager.dart';
import 'package:validators/validators.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

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
      xml = Binding.applyMap(xml, System.app?.queryParameters, caseSensitive: false);

      // Replace config parameters
      xml = Binding.applyMap(xml, System.app?.configParameters, caseSensitive: false);

      // Replace System Uuid
      String s = Binding.toKey(System.myId, 'uuid')!;
      while (xml!.contains(s)) {
        xml = xml.replaceFirst(s, newId());
      }

      // Convert Xml String to Xml Document
      XmlDocument document = XmlDocument.parse(xml);

      // return the new template
      template = Template(name: template.name, document: document);
    }
    catch(e)
    {
      Log().debug(e.toString());
    }

    return template;
  }

  static Future<XmlDocument?> fetchTemplate({required String url, Map<String, String?>? parameters, required bool refresh}) async
  {
    // saved document
    if (isUUID(url)) return await fetchSaved(url: url);

    if (url == '.js' && parameters != null) {
      XmlDocument? document = TemplateManager().fromJs(parameters['templ8']);
      // if (document != null) return document;
      if (document != null) return Template.fromDocument(name: url, xml: document, parameters: parameters).document;
      return null;
    }

    Log().debug('Getting template $url');

    // parse the url
    var uri = URI.parse(url);
    if (uri == null) return null;

    // use qualified url
    url = uri.url;

    String? template;

    // auto refresh
    refresh = refresh || (System.app?.autoRefresh ?? false);

    // get template from file
    if (uri.scheme != "file")
    {
      // get template from server
      if (refresh == true)
      {
        // get template
        template = await TemplateManager().fromServer(url);

        // save to local storage
        if (template != null && (System.app?.cacheContent ?? false)) TemplateManager().toDisk(url, template);
      }

      // get template from memory
      if (template == null)
      {
        XmlDocument? document = TemplateManager().fromMemory(url);
        if (document != null) return document;
      }

      // get template from disk
      template ??= await TemplateManager().fromDisk(url);

      // get template from database (web)
      template ??= await TemplateManager().fromDatabase(url);

      // get template from server
      if (template == null)
      {
        // get template
        template = await TemplateManager().fromServer(url);

        // save to local storage
        if (template != null && (System.app?.cacheContent ?? false)) TemplateManager().toDisk(url, template);
      }
    }

    // local template
    else
    {
      // from assets archive
      template ??= await TemplateManager().fromAssetsBundle(url);

      // from disk
      template ??= await TemplateManager().fromDisk(url);
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
    Log().debug('Getting saved template $url');

    String? template;

    // get template from database (web)
    template ??= await TemplateManager().fromDatabase(url);

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
    String xml404 = errorTemplate('Page Not Found', null, url);

    // parse the error template created
    try
    {
      document = XmlDocument.parse(xml404);
    }
    on  Exception catch(e)
    {
      xml404 = errorTemplate('Error on Page', url, e.toString());
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
      }

      // remove the node from the document
      element.parent!.children.remove(element);
    }
    return true;
  }

  static String errorTemplate(String err1, [String? err2, String? err3])
  {
    String backbutton = NavigationManager().pages.length > 1 ? '<BUTTON onclick="back()" type="outlined" color="white" ><BOX expand="false" pad="8"><ICON icon="arrow_back" color="white" size="40" /></BOX></BUTTON>' : '';

    String xml = '''
    <ERROR linkable="true">
      <BOX width="100%" height="100%" color="#add4de" layout="stack">
        
        <POS bottom="0" right="0">
          <IMAGE url="assets/assets/images/404.png" width="={SYSTEM.screenwidth} &lt; 700 ? '100%' : '50%'"/>
        </POS>
        
        <BOX pad="20" center="true">
        
        <TEXT id="e1" halign="center" size="={SYSTEM.screenwidth} &gt; 700 ? '80' : '50'" color="white" bold="true">
        <VALUE><![CDATA[$err1]]></VALUE>
        </TEXT> 
        <TEXT id="e2" halign="center" size="={SYSTEM.screenwidth} &gt; 700 ? '80' : '50'" color="white" visible="=!noe({e2})">
        <VALUE><![CDATA[$err2]]></VALUE>
        </TEXT>
        <TEXT id="e3" halign="center" size="={SYSTEM.screenwidth} &gt; 700 ? '80' : '50'" color="white"  visible="=!noe({e2})">
        <VALUE><![CDATA[$err3]]></VALUE>
        </TEXT> 
        <BOX height="20"/>
        $backbutton
       
        <BOX height="80"/>
        </BOX>

      </BOX>
    </ERROR>
    ''';
    return xml;
  }
}
