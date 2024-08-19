import 'dart:convert';
import 'package:fml/data/dotnotation.dart';
import 'package:xml/xml.dart';
import 'package:xml2json/xml2json.dart';

class Json {
  static String escape(String text) {
    var text1 = text.replaceAll('\n', '\\\\n');
    text1 = text1.replaceAll(r'\', r'\\');
    text1 = text1.replaceAll(r'"', r'\"');
    text1 = text1.replaceAll('\r', '\\\\r');
    text1 = text1.replaceAll('\t', '\\\\t');
    text1 = text1.replaceAll('\b', '\\\\f');
    return text1;
  }

  static String encode(Object? data) {
    var json = "{}";
    try {
      if (data != null) json = jsonEncode(data);
    } catch (e) {
      json = "{}";
    }
    return json;
  }

  static dynamic decode(String json) {
    try {
      return jsonDecode(json);
    } catch (e) {
      return null;
    }
  }

  static String? fromXml(String xml) {
    try {
      final Xml2Json parser = Xml2Json();
      parser.parse(xml);
     var newXml = parser.toParkerWithAttrs();
      return newXml;
    } catch (e) {
      return null;
    }
  }

  static String toXml(dynamic data,
      {String? defaultRootName, String? defaultNodeName}) {
    var root =
        XmlElement(XmlName(defaultRootName ?? defaultRootName ?? "ROOT"));
    _toXml(root, data, defaultNodeName: defaultNodeName);
    return root.toXmlString();
  }

  static void _toXml(XmlElement node, dynamic data, {String? defaultNodeName}) {
    // map
    if (data is Map) {
      data.forEach((key, value) {
        key = key.toString();
        if (value is Map) {
          var element = XmlElement(XmlName(key));
          node.children.add(element);
          _toXml(element, value);
        } else if (value is List) {
          _toXml(node, value, defaultNodeName: key);
        } else {
          value = value.toString();
          if (key.startsWith("_")) {
            key = key.replaceFirst("_", "");
            var attribute = XmlAttribute(XmlName(key), value);
            node.attributes.add(attribute);
          } else {
            if (key == "value") {
              node.innerText = value;
            } else {
              var element = XmlElement(XmlName(key));
              element.innerText = value;
              node.children.add(element);
            }
          }
        }
      });
    }

    // list
    else if (data is List) {
      for (var item in data) {
        var element = XmlElement(XmlName(defaultNodeName ?? "NODE"));
        node.children.add(element);
        _toXml(element, item);
      }
    }
  }

  static dynamic read(dynamic data, String? tag) {
    if (data == null || (data is List && data.isEmpty) || tag == null) {
      return null;
    }

    // Get Dot Notation
    DotNotation? dotNotation = DotNotation.fromString(tag);

    if (data is List<dynamic>) data = data.isNotEmpty ? data[0] : null;

    if (dotNotation != null) {
      for (NotationSegment? property in dotNotation) {
        if (property != null) {
          if (data is Map) {
            // attributes are named with an underscore
            // to make it easier for the user, we first look for the
            // property by name, then if not found, look for it by _name
            var name = property.name;
            var myName = "_$name";
            if (!data.containsKey(name) && (!data.containsKey(myName))) {
              data = null;
              break;
            }
            data = data.containsKey(name) ? data[name] : data[myName];

            if ((data is Map) && (property.offset > 0)) data = null;
            if ((data is List) && (property.offset > data.length)) data = null;
            if ((data is List) &&
                (property.offset < data.length) &&
                (property.offset >= 0)) data = data[property.offset];
          } else if (data is List) {
            if (data.length < property.offset) {
              data = null;
              break;
            }
            data = data[property.offset];
            if ((data is Map) && (data.containsKey(property.name))) {
              data = data[property.name];
            }
          } else {
            data = null;
            break;
          }
        }
      }
    }

    // this is a very odd case. if the element contains attributes, the element value will be put into a
    // map field called "value" and its attributes will be mapped to underscore (_) names _attributename
    if ((data is Map) && (data.containsKey('value'))) data = data['value'];

    // return result;
    return data;
  }

  static void write(dynamic data, String? tag, dynamic value) {
    // get segments
    DotNotation? segments = DotNotation.fromString(tag);
    if (segments == null || segments.isEmpty) return;

    // build map segments
    for (int i = 0; i < segments.length - 1; i++) {
      var property = segments[i];
      if (data is Map) {
        if (property.offset > 0) {
          data = null;
          break;
        }
        if (!data.containsKey(property.name)) data[property.name] = "";
        data = data[property.name];
      }
      if (data is List) {
        if (property.offset > data.length) {
          data = null;
          break;
        }
        if (property.offset < data.length && property.offset >= 0) {
          data = data[property.offset];
        }
      }
    }

    // single element list
    // added by olajos 16 nov 2023
    if (data is List && data.length == 1 && data[0] is Map) {
      data = data[0];
    }

    // write the value
    var name = segments.last.name;
    if (data is Map) {
      data[name] = value;
    }
  }

  // shallow copy clone of the list
  static dynamic copy(dynamic original, {bool withValues = true}) {
    if (original is List) {
      var clone = [];
      for (var element in original) {
        if (element is List) {
          clone.add(_copyList(element, withValues: withValues));
        } else if (element is Map) {
          clone.add(_copyMap(element, withValues: withValues));
        } else {
          clone.add(element);
        }
      }
      return clone;
    }

    if (original is Map) {
      return _copyMap(original, withValues: withValues);
    }

    return [];
  }

  static List _copyList(List list, {bool withValues = true}) {
    List clone = [];
    for (var element in list) {
      if (element is List) {
        clone.add(_copyList(element, withValues: withValues));
      } else if (element is Map) {
        clone.add(_copyMap(element, withValues: withValues));
      } else {
        clone.add(element);
      }
    }
    return clone;
  }

  static Map _copyMap(Map map, {bool withValues = true}) {
    Map clone = {};
    map.forEach((key, value) {
      if (value is List) {
        clone[key] = _copyList(value);
      } else if (value is Map) {
        clone[key] = _copyMap(value, withValues: withValues);
      } else {
        clone[key] = withValues ? value : "";
      }
    });
    return clone;
  }
}
