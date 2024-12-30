// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'package:fml/data/dotnotation.dart';
import 'package:fml/helpers/json.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';

class Data with ListMixin<dynamic> {
  List<dynamic> _list = [];

  String? root;

  Data({dynamic data}) {
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
  Data clone() => Data(data: Json.copy(_list));

  static Data from(dynamic value, {String? root}) {
    Data? data;

    if (value is List) data = Data(data: value);
    if (value is Data) data = value;
    if (value is String) {
      var isXml = value.trim().startsWith('<');
      data = isXml ? Data.fromXml(value) : Data.fromJson(value);
    }

    // default
    data ??= Data(data: data);

    // root should be supplied
    root ??= data.findRoot(root);

    // select sub-list
    if (root != null) {
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

  static Data? fromJson(String json) => Data(data: Json.decode(json) ?? []);

  static String toJson(Data? data) => Json.encode(data);

  static Data? fromXml(String xml) => Data.fromJson(Json.fromXml(xml) ?? "{}");

  static String toXml(Data? data,
          {String? defaultRootName, String? defaultNodeName}) =>
      Json.toXml(data,
          defaultRootName: defaultRootName ?? data?.root?.split(".").first,
          defaultNodeName: defaultNodeName ?? data?.root?.split(".").last);

  static Data? fromDotNotation(Data data, DotNotation dotnotation) {
    try {
      if (data.isEmpty) return null;

      dynamic myData = data;
      if (dotnotation.isEmpty) return myData;

      // parse list
      for (NotationSegment? property in dotnotation) {
        if (property != null) {
          if (myData is Map) {
            if (!myData.containsKey(property.name)) {
              myData = null;
              break;
            }
            myData = myData[property.name];
          } else if (myData is List) {
            if (myData.length < property.offset) {
              myData = null;
              break;
            }
            myData = myData[property.offset];
            if ((myData is Map) && (myData.containsKey(property.name))) {
              myData = myData[property.name];
            }
          } else {
            myData = null;
            break;
          }
        }
      }

      return Data(data: myData);
    } catch (e) {
      return null;
    }
  }

  // legacy support pre version 0.9.0
  String? findRoot(String? name) {
    String? root;
    if (_list.isNotEmpty) {
      // find first repeat instance in the tree
      if (name == null) {
        bool done = false;
        dynamic node = _list.first;
        while (!done) {
          if (node is Map) {
            if (node.entries.isEmpty) done = true;
            if (node.entries.length > 1) done = true;
            if (node.entries.length == 1) {
              var name = node.keys.first;
              root = (root == null) ? name : "$root.$name";
              node = node.values.first;
              if ((node is Map) &&
                  (node.entries.isNotEmpty) &&
                  (node.values.first is String)) done = true;
            }
          } else {
            done = true;
          }
        }
        return root;
      }

      // find named map entry
      else {
        bool done = false;
        dynamic node = _list.first;
        while (!done) {
          if (node is Map) {
            var nodename = node.keys.first;
            root = (root == null) ? nodename : "$root.$nodename";
            if (node.containsKey(name)) done = true;
            node = node.values.first;
          } else {
            done = true;
          }
        }
        return root;
      }
    }
    return null;
  }

  static Future<String> toCsv(Data data) async {
    final buffer = StringBuffer();
    String string = "";

    int i = 0;
    try {
      // Build Header
      List<String> header = [];
      List<String> columns = [];
      if (data.isNotEmpty) {
        if (data.first is Map) {
          (data.first as Map).forEach((key, value) {
            columns.add(key);
            String h = key.toString();
            h.replaceAll('"', '""');
            h = h.contains(',') ? '"$h"' : h;
            header.add(h);
          });
        }
      }

      // Output Header
      buffer.write('${header.join(", ")}\n');

      // Output Data
      if (columns.isNotEmpty) {
        for (var map in data) {
          i++;
          List<String> row = [];
          for (var column in columns) {
            String value =
                map.containsKey(column) ? map[column].toString() : '';
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
    } catch (e) {
      Log().debug('Error - Creating CSV column[$i]');
      Log().exception(e);
    }
    return string;
  }

  // reads a value from the data list
  static void write(dynamic data, String? tag, dynamic value) =>
      Json.write(data, tag, value);

  // reads a value from the data list
  static dynamic read(dynamic data, String? tag) => Json.read(data, tag);

  // reads values from the bindings with source=data
  static Map<String?, dynamic> readBindings(List<Binding>? bindings, dynamic data) {

    var values = <String?, dynamic>{};
    if (bindings == null) return values;

    // we are only concerned with data bindings
    var db = bindings.where((binding) => binding.source == 'data');
    if (db.isEmpty) return values;

    // holds a list of previously read values
    List<String?> read = [];

    // read bound data values (dot notation)
    for (var binding in db) {

      // build the signature
      var property  = binding.dotnotation?.signature != null ? ".${binding.dotnotation!.signature}" : "";
      var signature = binding.property + property;

      // not already read?
      if (!read.contains(binding.signature)) {

        // read the value
        values[binding.signature] = Data.read(data, signature) ?? "";

        // mark read
        read.add(binding.signature);
      }
    }

    return values;
  }
}
