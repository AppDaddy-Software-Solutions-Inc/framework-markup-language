// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:fml/log/manager.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

/// XML Helpers
///
/// Helper functions that can be used by importing *xml.dart*
/// Example adding an attribute to an [XmlElement]  ```dart
/// XmlElement myNode = XmlElement();
/// ...
/// setAttribute(myNode, 'color', 'red');
/// ```
class Xml {
  /// Check if a String contains characters not allowed in Xml
  static bool hasIllegalCharacters(String? s) {
    if (s != null) {
      return (s.contains("<")) ||
          (s.contains(">")) ||
          (s.contains("&")) ||
          (s.contains("'")) ||
          (s.contains("\""));
    } else {
      return false;
    }
  }

  // Olajos - Added October 23, 2001
  static String? encodeIllegalCharacters(dynamic s) {
    if (s != null) {
      if (s is String) {
        s = s.replaceAll("<", "&lt;");
        s = s.replaceAll(">", "&gt;");
        s = s.replaceAll("'", "&apos;");
        s = s.replaceAll("\"", "&quot;");
      } else {
        return s.toString();
      }
    }
    return s;
  }

  /// Replaces invalid characters with a String
  static String replaceIllegalCharacters(String s, String v) {
    s = s.replaceAll("<", v);
    s = s.replaceAll(">", v);
    s = s.replaceAll("&", v);
    s = s.replaceAll("'", "*"); // TODO review this code
    s = s.replaceAll("\"", v);
    return s;
  }

  /// Returns a valid attribute structure `key="value"` from 2 strings
  ///
  /// Returns an empty String if invalid characters are present in either String
  static String toAttribute(String name, String value) {
    String xml = "";
    if ((!hasIllegalCharacters(name)) && (!hasIllegalCharacters(value))) {
      xml = " $name=\"$value\"";
    }
    return xml;
  }

  /// Takes an [XmlElement] and creates a map from the attributes and any children elements
  ///
  // TODO: Further describe this
  static Map<String, dynamic> toElementMap({required XmlElement node}) {
    Map<String, dynamic> map = <String, dynamic>{};

    try {
      ////////////////
      /* Attributes */
      ////////////////
      List<XmlAttribute> attributes = node.attributes;
      for (XmlAttribute attribute in attributes) {
        String value = attribute.value;
        String name = attribute.name.toString();
        map[name] = value;
      }

      //////////////
      /* Elements */
      //////////////
      List<XmlNode> children = node.children;
      for (XmlNode child in children) {
        if (child is XmlElement) {
          XmlElement e = child;
          String? value = e.value;
          String name = e.name.toString();
          map[name] = value;
        }
      }
    } catch (e) {
      Log().exception(e,
          caller:
              'xml.dart => Map<String,dynamic> toElementMap({XmlElement node})');
    }

    return map;
  }

  /// Returns a Xml Safe String for a node value.
  static String toElementValue(String value) {
    if (hasIllegalCharacters(value)) value = '<![CDATA[$value]]>';
    return value;
  }

  /// Returns a Xml Safe String for a node and its value
  static String toElement(String name, String value) {
    if (hasIllegalCharacters(name)) return '';
    if (hasIllegalCharacters(value)) value = '<![CDATA[$value]]>';
    return '<$name>$value</$name>';
  }

  /// Return the first [XmlElement] child from an [XmlNode]
  static XmlElement? firstElement({required XmlNode node}) {
    List<XmlNode> children = node.children;
    for (XmlNode child in children) {
      if (child is XmlElement) return child;
    }
    return null;
  }

  // TODO review function / function name
  static XmlElement? getRoot(XmlNode parent) {
    while (firstElement(node: parent) != null) {
      parent = firstElement(node: parent)!;
    }
    if ((parent.parent != null) && (parent.parent is XmlElement)) {
      return parent.parent as XmlElement?;
    }
    return parent as XmlElement?;
  }

  // TODO review function / function name
  static String getRootElement(XmlNode parent) {
    XmlElement? root = getRoot(parent);
    if (root != null) return root.name.toString();
    return 'Row';
  }

  /// Takes an [XmlElement] and creates a map from the attributes and any children elements
  ///
  // TODO: Further describe this
  static Map<dynamic, dynamic> toMap({required XmlElement node}) {
    Map<dynamic, dynamic> map = <dynamic, dynamic>{};

    try {
      //////////////////
      /* Remember Xml */
      //////////////////
      map["xml"] = node.toXmlString();

      ////////////////
      /* Attributes */
      ////////////////
      List<XmlAttribute> attributes = node.attributes;
      for (XmlAttribute attribute in attributes) {
        String value = attribute.value.trim();
        String name = attribute.name.toString();
        map[name] = value;
      }

      //////////////
      /* Elements */
      //////////////
      List<XmlNode> children = node.children;
      for (XmlNode child in children) {
        if (child is XmlElement) {
          XmlElement e = child;
          String? value = e.value?.trim();
          String name = e.name.toString();
          map[name] = hasChildElements(child)
              ? child.outerXml.toString().trim()
              : value;
        } else if (child is XmlText) {
          XmlText e = child;
          String value = e.value.trim();
          String name = node.localName;
          map[name] = value;
        } else if (child is XmlCDATA) {
          XmlCDATA e = child;
          String value = e.innerText.trim();
          String name = node.localName;
          map[name] = value;
        }
      }
    } catch (e) {
      Log().exception(e,
          caller: 'xml.dart => Map<dynamic,dynamic> toMap({XmlElement node})');
    }
    return map;
  }

  /// Returns a map of every [XmlElement] from a [XmlDocument] given a String root
  static List<Map<dynamic, dynamic>>? toMapList(
      {XmlDocument? document, String? root}) {
    List<Map<dynamic, dynamic>>? list;
    if (document == null) return null;

    try {
      if (isNullOrEmpty(root)) root = getRootElement(document.rootElement);
      Iterable<XmlElement> nodes =
          document.findAllElements(root!, namespace: "*");
      for (XmlNode node in nodes) {
        Map<dynamic, dynamic> map = toMap(node: node as XmlElement);
        list ??= [];
        list.add(map);
      }
    } catch (e) {
      Log().exception(e,
          caller:
              'xml.dart => List<Map<dynamic,dynamic>> toMapList({XmlDocument document, String root})');
    }

    return list;
  }

  /// Returns a single depth XmlDocument from a flat map
  ///
  /// ```dart
  /// XmlDocument temp = fromMap(map: {'TEXT': 'Line 1', 'TEXT': 'Line2', 'BUTTON': 'Click Me' }, rootName: 'TEMPLATE');
  /// ```
  static XmlDocument fromMap({Map? map, String rootName = 'ROOT'}) {
    XmlDocument document = XmlDocument();
    XmlElement root = XmlElement(XmlName(rootName));
    document.children.add(root);

    map?.forEach((key, value) {
      if (value != null) {
        try {
          XmlElement node = XmlElement(XmlName(key.toString()));
          node.children.add(XmlCDATA(value.toString()));
          root.children.add(node);
        } catch (e) {
          Log().exception(e,
              caller:
                  "xml.dart => XmlDocument fromMap({Map map, String rootName = 'ROOT'})");
        }
      }
    });
    return document;
  }

  /// Given an [XmlElement] and an attribute tag(name) we will get the attribute value
  static String? attribute({required XmlElement node, required String tag}) {
    String? v;
    try {
      v = node.getAttribute(tag);
      // v ??= node.getAttribute(tag.toLowerCase());
      // v ??= node.getAttribute(tag.toUpperCase());
    } catch (e) {
      v = null;
      Log().exception(e,
          caller:
              'xml.dart => String attribute({XmlElement node, String tag})');
    }
    return v;
  }

  /// Given an [XmlElement] and an attribute tag(name) we will return true if exists
  static bool hasAttribute({required XmlElement node, required String tag}) {
    try {
      if (node.getAttributeNode(tag) != null) return true;
      //if (node.getAttributeNode(tag.toLowerCase()) != null) return true;
      //if (node.getAttributeNode(tag.toUpperCase()) != null) return true;
    } catch (e) {
      Log().exception(e,
          caller:
              'xml.dart => String attribute({XmlElement node, String tag})');
    }
    return false;
  }

  /// Changes an [XmlElement] attribute value
  static void setAttribute(XmlElement node, String tag, String? value) {
    try {
      value ??= "";
      value.replaceAll('"', "&quot;");
      value.replaceAll("'", "&quot;");

      XmlAttribute? a = node.getAttributeNode(tag);
      if (a == null) {
        node.attributes.add(XmlAttribute(XmlName(tag), value));
      } else {
        a.value = value;
      }
    } catch (e) {
      Log().exception(e,
          caller:
              'xml.dart => String attribute({XmlElement node, String tag})');
    }
  }

  /// Changes an [XmlElement] attribute value
  static XmlElement? removeAttribute(XmlElement? node, String tag) {
    try {
      if (node != null) {
        var attribute = node.attributes
            .firstWhereOrNull((attribute) => attribute.name.local == tag);
        //var attribute = node.attributes.firstWhereOrNull((attribute) => attribute.name.local == tag || attribute.name.local.toLowerCase() == tag || attribute.name.local.toUpperCase() == tag);
        if (attribute != null) node.attributes.remove(attribute);
      }
    } catch (e) {
      Log().exception(e,
          caller: 'xml.dart => removeAttribute({XmlElement node, String tag})');
    }
    return node;
  }

  /// Changes an [XmlElement] attribute value
  static void changeAttributeName(XmlElement node, String tag, String name) {
    try {
      XmlAttribute? a = node.getAttributeNode(tag);
      if (a != null) {
        var value = a.value;
        node.removeAttribute(tag);
        setAttribute(node, name, value);
      }
    } catch (e) {
      Log().exception(e,
          caller:
              'xml.dart => String attribute({XmlElement node, String tag})');
    }
  }

  /// Returns the value of a child [XmlElement] element
  static String? element(
      {required XmlElement node,
      required String tag,
      bool innerXmlAsText = false}) {
    String? v;
    try {
      XmlElement? child = getChildElement(node: node, tag: tag);
      //child ??= getChildElement(node: node, tag: tag.toLowerCase());
      //child ??= getChildElement(node: node, tag: tag.toUpperCase());
      if (child != null) v = getText(child, innerXmlAsText: innerXmlAsText);
    } catch (e) {
      v = null;
      Log().exception(e,
          caller: 'xml.dart => String element({XmlElement node, String tag})');
    }
    return v;
  }

  /// Returns the value of a child [XmlElement] element
  static bool hasElement({required XmlElement node, required String tag}) {
    try {
      if (getChildElement(node: node, tag: tag) != null) return true;
      //if (getChildElement(node: node, tag: tag.toUpperCase()) != null) return true;
      //if (getChildElement(node: node, tag: tag.toLowerCase()) != null) return true;
    } catch (e) {
      Log().exception(e,
          caller: 'xml.dart => String element({XmlElement node, String tag})');
    }
    return false;
  }

  /// Gets the value of a attribute else a child element
  static String? get(
      {XmlElement? node, String? tag, bool innerXmlAsText = false}) {
    String? v;
    if (node == null || tag == null) return v;
    try {
      v ??= attribute(node: node, tag: tag);
      v ??= element(node: node, tag: tag, innerXmlAsText: innerXmlAsText);
    } catch (e) {
      v = null;
      Log().exception(e,
          caller: 'xml.dart => String get({XmlElement node, String tag})');
    }
    return v;
  }

  /// Gets the value of a attribute else a child element
  static bool has({required XmlElement node, required String tag}) {
    try {
      if (hasAttribute(node: node, tag: tag)) return true;
      if (hasElement(node: node, tag: tag)) return true;
    } catch (e) {
      Log().exception(e,
          caller: 'xml.dart => String get({XmlElement node, String tag})');
    }
    return false;
  }

  /// Returns true if there is 1 or more child [XmlElement]s
  static bool hasChildElements(XmlElement node) {
    try {
      var elements = node.children
          .where((element) => element.nodeType == XmlNodeType.ELEMENT);
      return elements.isNotEmpty;
    } catch (e) {
      Log().exception(e,
          caller: 'xml.dart => bool hasChildElements({XmlElement node})');
    }
    return false;
  }

  /// Given a tag(name) returns the first child element of a [XmlElement] that matches
  static XmlElement? getChildElement(
      {required XmlElement node, required String tag}) {
    try {
      Iterable<XmlElement> nodes;

      nodes = node.findElements(tag, namespace: "*");
      if (nodes.isNotEmpty) return nodes.first;

      //nodes = node.findElements(tag.toUpperCase(), namespace: "*");
      //if (nodes.isNotEmpty) return nodes.first;

      //nodes = node.findElements(tag.toLowerCase(), namespace: "*");
      //if (nodes.isNotEmpty) return nodes.first;
    } catch (e) {
      Log().exception(e,
          caller:
              'xml.dart => XmlElement getChildElement({XmlElement node, String tag})');
    }
    return null;
  }

  /// Given a tag(name) returns all child elements of a [XmlElement] that match
  static List<XmlElement>? getChildElements(
      {required XmlElement node, required String tag}) {
    try {
      //String lower = tag.toLowerCase();
      //String upper = tag.toUpperCase();

      List<XmlElement> list = [];

      var nodes = node.findElements(tag, namespace: "*");
      if (nodes.isNotEmpty) list.addAll(nodes);

      ///////////////
      /* Lowercase */
      ////////////////
      //if (tag != lower)
      //{
      //  nodes = node.findElements(lower, namespace: "*");
      //  if (nodes.isNotEmpty) list.addAll(nodes);
      //}

      ///////////////
      /* Uppercase */
      ///////////////
      //if (tag != upper)
      //{
      // nodes = node.findElements(upper, namespace: "*");
      // if (nodes.isNotEmpty) list.addAll(nodes);
      //}

      return list;
    } catch (e) {
      Log().exception(e,
          caller:
              'xml.dart => XmlElement getChildElement({XmlElement node, String tag})');
    }
    return null;
  }

  /// Returns the nearest [XmlElement] matching the tag(name) from a parent [XmlElement]
  static XmlElement? getElement(
      {required XmlElement node, required String tag}) {
    try {
      Iterable<XmlElement> nodes;

      nodes = node.findAllElements(tag, namespace: "*");
      if (nodes.isNotEmpty) return nodes.first;

      //nodes = node.findAllElements(tag.toUpperCase(), namespace: "*");
      //if (nodes.isNotEmpty) return nodes.first;

      //nodes = node.findAllElements(tag.toLowerCase(), namespace: "*");
      //if (nodes.isNotEmpty) return nodes.first;
    } catch (e) {
      Log().exception(e,
          caller:
              'xml.dart => XmlElement getElement({XmlElement node, String tag})');
    }
    return null;
  }

  /// Given an [XmlNode] this will return the raw [XmlNodeType.TEXT] String
  static String? getText(XmlNode? node, {bool innerXmlAsText = false}) {
    // node is text or cdata
    if (node?.nodeType == XmlNodeType.TEXT ||
        node?.nodeType == XmlNodeType.CDATA) return node?.value;

    // return node inner xml as text
    if (innerXmlAsText) {
      bool isText = (node?.children.firstWhereOrNull((child) =>
              (child is XmlCDATA || child is XmlText || child is XmlComment)
                  ? false
                  : true) ==
          null);
      var text = isText ? node?.innerText.trim() : node?.innerXml.trim();
      //text = text?.replaceAll('\r', '').replaceAll('\t', '').replaceAll('\n', '').trim();
      return text;
    }

    // traverse child nodes
    if ((node?.children.isNotEmpty == true)) {
      String? text;
      for (XmlNode n in node!.children) {
        String? s;
        if ((n.nodeType == XmlNodeType.TEXT) ||
            (n.nodeType == XmlNodeType.CDATA)) s = n.value;
        if (s != null) text = (text ?? '') + s.trim();
      }
      return text;
    }
    return null;
  }

  /// Takes in a String of valid XML and returns it as a [XmlDocument] containing all the xml package objects
  static XmlDocument? tryParse(String? xml, {bool silent = false}) {
    XmlDocument? document;
    try {
      if (xml != null) document = XmlDocument.parse(xml);
    } catch (e) {
      document = null;
      //if (silent != true) System().toast(title: 'Error Parsing Xml in TryParse', description: e.toString());
      Log()
          .exception(e, caller: 'xml.dart => XmlDocument tryParse(String xml)');
    }
    return document;
  }

  static dynamic tryParseException(String? xml) {
    XmlDocument? document;
    try {
      if (xml != null) document = XmlDocument.parse(xml);
    } catch (e) {
      return Exception(e.toString());
    }
    return document;
  }
}
