// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/template/template_manager.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class ConfigModel {

  ConfigModel();

  String? xml;
  Map<String, String?> settings = <String, String?>{};
  Map<String, String?> parameters = <String, String?>{};

  XmlElement? firebase;

  static Future<ConfigModel?> fromXml(XmlElement xml) async {
    ConfigModel? model;
    try {
      model = ConfigModel();
      model.deserialize(xml);
      model.xml = xml.toXmlString();
    } catch (e) {
      Log().debug(e.toString());
      model = null;
    }
    return model;
  }

  static Future<ConfigModel?> fromUrl(String url) async {
    Uri? uri = URI.parse(url);
    if (uri != null) {
      uri = uri.setPage("config.xml");
      var template = await TemplateManager().fetch(url: uri.url, refresh: true);

      // deserialize the returned template
      if (template.document != null && !template.isAutoGeneratedErrorPage) {
        return fromXml(template.document!.rootElement);
      }
    }
    return null;
  }

  factory ConfigModel.fromMap(Map<String, dynamic> settings) {

    var model = ConfigModel();
    settings.forEach((k, v)
    {
      var value = toStr(v);
      if (value != null) model.set(k, value);
    });
    return model;
  }

  void deserialize(XmlElement xml) async {
    XmlElement? e = Xml.getChildElement(node: xml, tag: "CONFIG");
    if (e == null) return;

    // settings
    for (dynamic node in e.children) {

      if (node is XmlElement) {
        String key = node.localName;
        String? value = Xml.get(node: node, tag: 'value');

        // firebase segment?
        if (key.toUpperCase() == 'FIREBASE') {
          firebase = node.copy();
        }

        // other
        else {
          if (isNullOrEmpty(value)) value = Xml.getText(node);
          if (!isNullOrEmpty(key) && (key.toLowerCase() != 'parameter')) {
            settings[key] = value;
          }
        }
      }
    }

    // parameters
    List<XmlElement>? nodes = Xml.getChildElements(node: xml, tag: 'PARAMETER');
    if (nodes != null) {
      for (var element in nodes) {
        String? key = Xml.get(node: element, tag: 'key');
        String? value = Xml.get(node: element, tag: 'value');
        if (isNullOrEmpty(value)) value = Xml.getText(element);
        if (!isNullOrEmpty(key)) parameters[key!] = value ?? "";
      }
    }
  }

  String? get(String key) {
    if (isNullOrEmpty(key)) return null;
    return settings.containsKey(key) ? settings[key] : null;
  }

  void set(String key, String value) {
    if (isNullOrEmpty(key)) return;
    settings[key] = value;
  }
}
