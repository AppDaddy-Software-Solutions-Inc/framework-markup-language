// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'package:fml/data/dotnotation.dart';
import 'package:fml/log/manager.dart';
import 'package:xml2json/xml2json.dart';
import 'dart:convert';

class Data with ListMixin<dynamic>
{
  List<dynamic> _list = [];

  Data({dynamic data})
  {
    _list = [];
    if (data is List)
         _list = data;
    else if (data != null) _list.add(data);
  }

  @override
  void add(dynamic value) => _list.add(value);

  @override
  void addAll(Iterable<dynamic> values) => _list.addAll(values);

  @override
  void operator []=(int index, dynamic value) => _list[index] = value;

  @override
  dynamic operator [](int index) => _list[index];

  @override
  set length(int newLength) => _list.length = newLength;

  @override
  int get length => _list.length;

  static Data fromData(dynamic value, {String? root})
  {
    Data? data;

    if (value is List)    data = Data(data: value);
    if (value is Data)    data = value;
    if (value is String)
    {
      if (value.trim().startsWith('<'))
           data = Data.fromXml(value);
      else data = Data.fromJson(value);
    }

    // default
    if (data == null) data = Data(data: data);

    // root should be supplied
    if (root == null) root = data.findRoot(root);

    // select sub-list
    if (root != null)
    {
      // convert root to dot notation
      DotNotation? dotnotation = DotNotation.fromString(root);

      // get sublist
      if (dotnotation != null) data = data.fromDotNotation(dotnotation);
    }

    return data!;
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
       if (json is List)
       json.forEach((element)
       {
         if (element is Map) list.add(element as Map<String, dynamic>);
       });

       // map
       else if (json is Map)
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

  Data? fromDotNotation(DotNotation dotnotation)
  {
    try
    {
      if (this.isEmpty) return null;

      dynamic data = _list;
      if (dotnotation.isEmpty) return data;

      // parse list
      for (NotationSegment? property in dotnotation)
      if (property != null)
      {
        if (data is Map)
        {
          if (!data.containsKey(property.name))
          {
            data = null;
            break;
          }
          data = data[property.name];
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

      return Data(data: data);
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
            if (node.entries.length == 0) done = true;
            if (node.entries.length >  1) done = true;
            if (node.entries.length == 1)
            {
              var name = node.keys.first;
              root = (root == null) ? name : "$root.$name";
              node = node.values.first;
              if ((node is Map) && (node.entries.isNotEmpty) && (node.values.first is String)) done = true;
            }
          }
          else done = true;
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
          else done = true;
        }
        return root;
      }
    }
    return null;
  }

  Future<String> toCsv() async
  {
      final buffer = StringBuffer();
      String string = "";

      int i = 0;
      try
      {
        // Build Header
        List<String> header = [];
        List<String> columns = [];
        if (isNotEmpty)
        if (first is Map)
        (first as Map).forEach((key, value)
        {
          columns.add(key);
          String h = key.toString();
          h.replaceAll('"', '""');
          h = h.contains(',') ? '"' + h + '"' : h;
          header.add(h);
        });

        // Output Header
        buffer.write(header.join(", ") + '\n');

        // Output Data
        if (columns.isNotEmpty)
        forEach((map)
        {
          i++;
          List<String> row = [];
          columns.forEach((column) {
            String value = map.containsKey(column) ? map[column].toString() : '';
            value.replaceAll('"', '""');
            value = value.contains(',') ? '"' + value + '"' : value;
            row.add(value);
          });
          buffer.write(row.join(", ") + '\n');
        });

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
}