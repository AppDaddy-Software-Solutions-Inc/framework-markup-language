// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'dart:math';
import 'package:fml/data/dotnotation.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:xml/xml.dart';
import 'package:xml2json/xml2json.dart';
import 'dart:convert';

class Data with ListMixin<dynamic>
{
  List<dynamic> _list = [];

  String? root;

  Data({dynamic data})
  {
    _list = [];
    if (data is List) {
      _list = data;
    } else if (data != null) {
      _list.add(data);
    }
  }

  @override
  void add(dynamic element) => _list.add(element);

  @override
  void addAll(Iterable<dynamic> iterable) => _list.addAll(iterable);

  @override
  void operator []=(int index, dynamic value) => _list[index] = value;

  @override
  dynamic operator [](int index) => _list[index];

  @override
  set length(int newLength) => _list.length = newLength;

  @override
  int get length => _list.length;

  // shallow copy clone of the list
  Data clone()
  {
    Data clone = Data();
    forEach((element)
    {
           if (element is List) {
             clone.add(_cloneList(element));
           } else if (element is Map) {
        clone.add(_cloneMap(element));
      } else {
        clone.add(element);
      }
    });
    return clone;
  }

  List _cloneList(List list)
  {
    List clone = [];
    for (var element in list) {
           if (element is List) {
             clone.add(_cloneList(element));
           } else if (element is Map) {
        clone.add(_cloneMap(element));
      } else {
        clone.add(element);
      }
    }
    return clone;
  }

  Map _cloneMap(Map map)
  {
    Map clone = {};
    map.forEach((key, value)
    {
           if (value is List) {
             clone[key] = _cloneList(value);
           } else if (value is Map) {
        clone[key] = _cloneMap(value);
      } else {
        clone[key] = value;
      }
    });
    return clone;
  }

  static Data from(dynamic value, {String? root})
  {
    Data? data;

    if (value is List)    data = Data(data: value);
    if (value is Data)    data = value;
    if (value is String)
    {
      if (value.trim().startsWith('<')) {
        data = Data.fromXml(value);
      } else
      {
        data = Data.fromJson(value);
      }
    }

    // default
    data ??= Data(data: data);

    // root should be supplied
    root ??= data.findRoot(root);

    // select sub-list
    if (root != null)
    {
      // convert root to dot notation
      DotNotation? dotnotation = DotNotation.fromString(root);

      // get sublist
      if (dotnotation != null) data = fromDotNotation(data, dotnotation);
    }

    // build default data set
    data ??= Data(data: null);

    // save root name
    data.root = root;
    
    return data;
  }

  static Data? fromXml(String xml)
  {
    try
    {
      final Xml2Json parser = Xml2Json();
      parser.parse(xml);
      return Data.fromJson(parser.toParkerWithAttrs());
    }
    catch(e)
    {
      Log().error('Unable to parse data document from string to xml document');
      return null;
    }
  }

  static Data? fromJson(String jsonString)
  {
    try
    {
       var json = jsonDecode(jsonString);

       List<Map<String, dynamic>> list = [];

       // list
       if (json is List) {
         for (var element in json) {
         if (element is Map) list.add(element as Map<String, dynamic>);
       }
       } else if (json is Map)
       {
         list.add(json as Map<String, dynamic>);
       }

       return Data(data: list);
    }
    catch(e)
    {
      Log().error('Invalid Format, unable to decode json string data.');
      return null;
    }
  }

  static String toJson(Data? data)
  {
    var json = "{}";
    try
    {
      if (data != null) json = jsonEncode(data);
    }
    catch(e)
    {
      Log().error('Invalid Format, unable to decode json string data.');
    }
    return json;
  }

  static _toXml(XmlElement node, dynamic data, {String? name})
  {
    // map
    if (data is Map)
    {
      data.forEach((key, value)
      {
        key = key.toString();
        if (value is Map)
        {
          var element = XmlElement(XmlName(key));
          node.children.add(element);
          _toXml(element,value);
        }

        else if (value is List)
        {
          _toXml(node, value, name: key);
        }

        else
        {
          value = value.toString();
          if (key.startsWith("_"))
          {
            key = key.replaceFirst("_", "");
            var attribute = XmlAttribute(XmlName(key),value);
            node.attributes.add(attribute);
          }
          else
          {
            if (key == "value")
            {
              node.innerText = value;
            }
            else
            {
              var element = XmlElement(XmlName(key));
              element.innerText = value;
              node.children.add(element);
            }
          }
        }
      });
    }

    // list
    else if (data is List)
    {
      for (var item in data)
      {
        var element = XmlElement(XmlName(name ?? "NODEX"));
        node.children.add(element);
        _toXml(element, item);
      }
    }
  }

  static String toXml(Data? data)
  {
    var root = data?.root?.split(".")[0];
    var xml = XmlElement(XmlName(root ?? "ROOT"));
    try
    {
      if (data != null) _toXml(xml, data, name: data.root?.split(".").last);
    }
    catch(e)
    {
      Log().error('Invalid Format, unable to decode json string data.');
    }
    return xml.toXmlString();
  }

  static Data? fromDotNotation(Data data, DotNotation dotnotation)
  {
    try
    {
      if (data.isEmpty) return null;

      dynamic myData = data;
      if (dotnotation.isEmpty) return myData;

      // parse list
      for (NotationSegment? property in dotnotation) {
        if (property != null)
      {
        if (myData is Map)
        {
          if (!myData.containsKey(property.name))
          {
            myData = null;
            break;
          }
          myData = myData[property.name];
        }

        else if (myData is List)
        {
          if (myData.length < property.offset)
          {
            myData = null;
            break;
          }
          myData = myData[property.offset];
          if ((myData is Map) && (myData.containsKey(property.name))) myData = myData[property.name];
        }

        else
        {
          myData = null;
          break;
        }
      }
      }

      return Data(data: myData);
    }
    catch(e)
    {
      return null;
    }
  }

  // legacy support pre version 0.9.0
  String? findRoot(String? name)
  {
    String? root;
    if (_list.isNotEmpty)
    {
      // find first repeat instance in the tree
      if (name == null)
      {
        bool done = false;
        dynamic node = _list.first;
        while (!done)
        {
          if (node is Map)
          {
            if (node.entries.isEmpty) done = true;
            if (node.entries.length >  1) done = true;
            if (node.entries.length == 1)
            {
              var name = node.keys.first;
              root = (root == null) ? name : "$root.$name";
              node = node.values.first;
              if ((node is Map) && (node.entries.isNotEmpty) && (node.values.first is String)) done = true;
            }
          }
          else {
            done = true;
          }
        }
        return root;
      }

      // find named map entry
      else
      {
        bool done = false;
        dynamic node = _list.first;
        while (!done)
        {
          if (node is Map)
          {
            var nodename = node.keys.first;
            root = (root == null) ? nodename : "$root.$nodename";
            if (node.containsKey(name)) done = true;
            node = node.values.first;
          }
          else {
            done = true;
          }
        }
        return root;
      }
    }
    return null;
  }

  static Future<String> toCsv(Data data) async
  {
      final buffer = StringBuffer();
      String string = "";

      int i = 0;
      try
      {
        // Build Header
        List<String> header = [];
        List<String> columns = [];
        if (data.isNotEmpty){
        if (data.first is Map) {
          (data.first as Map).forEach((key, value)
        {
          columns.add(key);
          String h = key.toString();
          h.replaceAll('"', '""');
          h = h.contains(',') ? '"$h"' : h;
          header.add(h);
        });
        }}

        // Output Header
        buffer.write('${header.join(", ")}\n');

        // Output Data
        if (columns.isNotEmpty) {
          for (var map in data) {
          i++;
          List<String> row = [];
          for (var column in columns) {
            String value = map.containsKey(column) ? map[column].toString() : '';
            value.replaceAll('"', '""');
            value = value.contains(',') ? '"$value"' : value;
            row.add(value);
          }
          buffer.write('${row.join(", ")}\n');
        }
        }

        // eof
        string = buffer.toString();
        string = string.replaceFirst('\n', '\r\n', string.lastIndexOf('\n'));
      }
      catch(e)
      {
        Log().debug('Error - Creating CSV column[$i]');
        Log().exception(e);
      }
      return string;
  }

  static dynamic readValue(dynamic data, String? tag)
  {
    if (data == null || (data is List && data.isEmpty) || tag == null) return null;

    // Get Dot Notation
    DotNotation? dotNotation = DotNotation.fromString(tag);

    if (data is List<dynamic>) data = data.isNotEmpty ? data[0] : null;

    if (dotNotation != null){
      for (NotationSegment? property in dotNotation) {
        if (property != null)
        {
          if (data is Map)
          {
            // attributes are named with an underscore
            // to make it easier for the user, we first look for the
            // property by name, then if not found, look for it by _name
            var name  = property.name;
            var myName = "_$name";
            if (!data.containsKey(name) && (!data.containsKey(myName)))
            {
              data = null;
              break;
            }
            data = data.containsKey(name) ? data[name] : data[myName];

            if ((data is Map)  && (property.offset > 0)) data = null;
            if ((data is List) && (property.offset > data.length)) data = null;
            if ((data is List) && (property.offset < data.length) && (property.offset >= 0))  data = data[property.offset];
          }

          else if (data is List)
          {
            if (data.length < property.offset)
            {
              data = null;
              break;
            }
            data = data[property.offset];
            if ((data is Map) && (data.containsKey(property.name))) data = data[property.name];
          }

          else
          {
            data = null;
            break;
          }
        }
      }}

    // this is a very odd case. if the element contains attributes, the element value will be put into a
    // map field called "value" and its attributes will be mapped to underscore (_) names _attributename
    if ((data is Map) && (data.containsKey('value'))) data = data['value'];

    // return result;
    return data;
  }

  static writeValue(dynamic data, String? tag, dynamic value)
  {
    // get segments
    DotNotation? segments = DotNotation.fromString(tag);
    if (segments == null || segments.isEmpty) return data;

    // build map segments
    for (int i = 0; i < segments.length - 1; i++)
    {
      var property = segments[i];
      if (data is Map)
      {
        if (property.offset > 0)
        {
          data = null;
          break;
        }
        if (!data.containsKey(property.name)) data[property.name] = "";
        data = data[property.name];
      }
      if (data is List)
      {
        if (property.offset > data.length)
        {
          data = null;
          break;
        }
        if (property.offset < data.length && property.offset >= 0) data = data[property.offset];
      }
    }

    // write the value
    var name = segments.last.name;
    if (data is Map) data[name] = value;
  }


  static Map<String?, dynamic> readValues(List<Binding>? bindings, dynamic data)
  {
    Map<String?, dynamic> values = <String?, dynamic>{};
    List<String?> processed = [];
    if (bindings != null) {
      for (Binding binding in bindings) {
        // fully qualified data binding name (datasource.data.field1.field2.field3...fieldn)
        if ((binding.source == 'data')) {
          String? signature = binding.property +
              (binding.dotnotation?.signature != null ? ".${binding.dotnotation!
                  .signature}" : "");
          if (!processed.contains(binding.signature)) {
            processed.add(binding.signature);
            var value = readValue(data, signature) ?? "";
            values[binding.signature] = value;
          }
        }
      }
    }
      return values;
  }

  static Data testData(int rows)
  {
    Data data = Data();
    for (int i = 0; i < rows; i++)
    {
      var row = <String, dynamic>{};
      row["index"] = "$i";
      row["user"]  = "";
      row["age"]   = Random().nextInt(100);
      row["first"] = names[Random().nextInt(names.length)];
      row["last"]  = surnames[Random().nextInt(surnames.length)];
      row["city"]  = cities[Random().nextInt(cities.length)];
      row["job"]   = jobs[Random().nextInt(jobs.length)];
      row["company"]   = companies[Random().nextInt(companies.length)];
      data.add(row);
    }
    return data;
  }

  static List<String> cities = ["Kingston","Ottawa","Montreal","Toronto"];
  static List<String> names   = ["Joe","Jeff","Bill","Jeremy"];
  static List<String> surnames = ["Smith","Jones","Olajos","Green"];
  static List<String> jobs = ["Butcher","Baker","Candle Stick Maker","Engineer","Plumber","Electrician","Accountant"];
  static List<String> companies = ["DuPont","Goodyear"];
}