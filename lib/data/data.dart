// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'package:fml/data/dotnotation.dart';
import 'package:fml/helper/xml.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:xml2json/xml2json.dart';
import 'dart:convert';

class Data with ListMixin<dynamic>
{
  List<dynamic> _list = [];

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
      } else {
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

    return (data != null) ? data : Data(data: data);
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

  static Data? fromDotNotation(Data data, DotNotation dotnotation)
  {
    try
    {
      if (data.isEmpty) return null;

      dynamic _data = data;
      if (dotnotation.isEmpty) return _data;

      // parse list
      for (NotationSegment? property in dotnotation) {
        if (property != null)
      {
        if (_data is Map)
        {
          if (!_data.containsKey(property.name))
          {
            _data = null;
            break;
          }
          _data = _data[property.name];
        }

        else if (_data is List)
        {
          if (_data.length < property.offset)
          {
            _data = null;
            break;
          }
          _data = _data[property.offset];
          if ((_data is Map) && (_data.containsKey(property.name))) _data = _data[property.name];
        }

        else
        {
          _data = null;
          break;
        }
      }
      }

      return Data(data: _data);
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
            var _name = "_$name";
            if (!data.containsKey(name) && (!data.containsKey(_name)))
            {
              data = null;
              break;
            }
            data = data.containsKey(name) ? data[name] : data[_name];

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

  static dynamic writeValue(dynamic data, String? tag, dynamic value)
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

  static String? replaceValue(String? string, dynamic data)
  {
    // replace bindings
    List<Binding>? bindings = Binding.getBindings(string);
    if (bindings != null){
      for (Binding binding in bindings)
      {
        // fully qualified data binding name (data.value.x.y.)
        if ((binding.source.toLowerCase() == 'data'))
        {
          String signature = binding.property + (binding.dotnotation?.signature != null ? ".${binding.dotnotation!.signature}" : "");
          String value = Xml.encodeIllegalCharacters(readValue(data,signature)) ?? "";
          string = string!.replaceAll(binding.signature, value);
        }
      }}
    return string;
  }
}