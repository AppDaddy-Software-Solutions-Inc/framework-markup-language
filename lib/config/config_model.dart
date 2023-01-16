// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/helper/string.dart';
import 'package:fml/helper/xml.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/template/template.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:xml/xml.dart';
import 'package:fml/helper/url.dart';

class ConfigModel
{
  ConfigModel();

  String? xml;
  Map<String, String?> settings   = Map<String,String?>();
  Map<String, String?> parameters = Map<String,String?>();

  static Future<ConfigModel?> fromXml(WidgetModel? parent, XmlElement xml) async
  {
    ConfigModel? model;
    try
    {
      model = ConfigModel();
      model.deserialize(xml);
      model.xml = xml.toXmlString();
    }
    catch(e)
    {
      Log().debug(e.toString());
      model = null;
    }
    return model;
  }

  static Future<ConfigModel?> fromUrl(WidgetModel? parent, String url) async
  {
    Uri? uri = Url.parse(url);
    if (uri != null)
    {
      var template = await Template.fetchTemplate(url: "${uri.domain}/config.xml", refresh: true);
      if (template != null) return fromXml(parent, template.rootElement);
    }
    return null;
  }

  void deserialize(XmlElement xml) async
  {
    XmlElement? e = Xml.getChildElement(node: xml, tag: "CONFIG");
    if (e == null) return;

    // settings
    for (dynamic node in e.children)
    if (node is XmlElement)
    {
      String key   = node.localName;
      String? value = Xml.get(node: node, tag: 'value');

      if (S.isNullOrEmpty(value)) value = Xml.getText(node);
      if (!S.isNullOrEmpty(key) && (key.toLowerCase() != 'parameter')) settings[key] = value;
    }

    // parameters
    List<XmlElement>? nodes = Xml.getChildElements(node: xml, tag: 'parameter');
    if (nodes != null)
    nodes.forEach((element)
    {
      String? key   = Xml.get(node: element, tag: 'key');
      String? value = Xml.get(node: element, tag: 'value');
      if (S.isNullOrEmpty(value)) value = Xml.getText(element);
      if (!S.isNullOrEmpty(key)) parameters[key!] = value ?? "";
    });
  }

  String? get(String key)
  {
    if (S.isNullOrEmpty(key)) return null;
    return settings.containsKey(key) ? settings[key] : null;
  }

  void set(String key, String value)
  {
    if (S.isNullOrEmpty(key)) return null;
    settings[key] = value;
  }
}