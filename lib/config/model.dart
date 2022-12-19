// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:xml/xml.dart';
import 'package:fml/helper/helper_barrel.dart';

class ConfigModel
{
  ConfigModel();

  Map<String, String?> settings   = Map<String,String?>();
  Map<String?, String> parameters = Map<String?,String>();

  static ConfigModel? fromXml(WidgetModel? parent, XmlElement xml)
  {
    ConfigModel? model;
    try
    {
      model = ConfigModel();
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().debug(e.toString());
      model = null;
    }
    return model;
  }

  void deserialize(XmlElement xml) async
  {
    //////////////
    /* Settings */
    //////////////
    for (dynamic node in xml.children)
    if (node is XmlElement)
    {
      String key   = node.localName;
      String? value = Xml.get(node: node, tag: 'value');

      if (S.isNullOrEmpty(value)) value = Xml.getText(node);
      if (!S.isNullOrEmpty(key) && (key.toLowerCase() != 'parameter')) settings[key] = value;
    }

    ////////////////
    /* Parameters */
    ////////////////
    List<XmlElement>? nodes = Xml.getChildElements(node: xml, tag: 'parameter');
    if (nodes != null)
    nodes.forEach((element)
    {
      String? key   = Xml.get(node: element, tag: 'key');
      String? value = Xml.get(node: element, tag: 'value');
      if (S.isNullOrEmpty(value)) value = Xml.getText(element);
      if (!S.isNullOrEmpty(key)) parameters[key] = value ?? "";
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