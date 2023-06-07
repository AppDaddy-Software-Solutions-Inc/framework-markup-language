// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/transforms/transform_interface.dart';
import 'package:fml/datasources/transforms/transform_model.dart';
import 'package:fml/eval/eval.dart' as fml_eval;
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/helper/common_helpers.dart';

class Calc extends TransformModel implements ITransform
{
  static const String sum       = "sum";
  static const String min       = "min";
  static const String max       = "max";
  static const String avg       = "avg";
  static const String avglong   = "average";
  static const String count     = "cnt";
  static const String countlong = "count";
  static const String total     = "total";
  static const String evaluate  = "eval";

  @override
  final String? source;
  final String? target;
  final String? precision;
  late final String? operation;
  late final List<String>? groups;

  Calc(WidgetModel? parent, {String? id, String? operation, this.source, this.target, this.precision, String? group}) : super(parent, id)
  {
    this.operation = operation?.toLowerCase();
    groups    = group?.split(",");
  }

  static Calc? fromXml(WidgetModel? parent, XmlElement xml)
  {
    Calc model = Calc
        (
        parent,
        id        : Xml.get(node: xml, tag: 'id'),
        operation : Xml.get(node: xml, tag: "operation"),
        source    : Xml.get(node: xml, tag: "source"),
        target    : Xml.get(node: xml, tag: "target"),
        precision : Xml.get(node: xml, tag: "precision"),
        group     : Xml.get(node: xml, tag: "group"),
      );
    model.deserialize(xml);
    return model;
  }

  @override
  void deserialize(XmlElement xml)
  {
    // Deserialize
    super.deserialize(xml);
  }

  String? _getGroup(dynamic data)
  {
    if (groups == null) return '*';

    String? group;
    for (var f in groups!) {
      var value = Data.readValue(data, f);
      if (value != null) group = "${group ?? ""}[$value]";
    }
    return group;
  }

  bool _inGroup(dynamic data, String? group)
  {
    if (group == null) return false;
    if (_getGroup(data) == group) return true;
    return false;
  }

  HashMap<String,double?>? _calcMin(Data list)
  {
    if (source == null) return null;
    var results = HashMap<String,double>();
    for (var row in list) {
      var group = _getGroup(row);
      var value = S.toDouble(Data.readValue(row, source));
      if (group != null && value != null)
      {
        if (!results.containsKey(group)) results[group] = value;
        if (value < results[group]!) results[group] = value;
      }
    }
    return results;
  }

  HashMap<String,double?>? _calcMax(Data list)
  {
    if (source == null) return null;
    var results = HashMap<String,double>();
    for (var row in list) {
      var group = _getGroup(row);
      var value = S.toDouble(Data.readValue(row, source));
      if (group != null && value != null)
      {
        if (!results.containsKey(group)) results[group] = value;
        if (value > results[group]!) results[group] = value;
      }
    }
    return results;
  }

  HashMap<String,double>? _calcCnt(Data list)
  {
    if (source == null) return null;
    HashMap<String,double> results = HashMap<String,double>();
    for (var row in list) {
      var group = _getGroup(row);
      var value = Data.readValue(row, source);
      if (group != null && value != null)
      {
        if (!results.containsKey(group)) results[group] = 0;
        results[group] = results[group]! + 1;
      }
    }
    return results;
  }


  Map? _calcTotal(Data list)
  {
    if (source == null) return null;
    Map duplicates = {};

    for (var element in list) {
      var value = Data.readValue(element, source);
      if(!duplicates.containsKey(value)) {
        duplicates[value] = 1;
      } else {
        duplicates[value] += 1;
      }
    }
    return duplicates;
  }


  HashMap<String,double>? _calcSum(Data list)
  {
    if (source == null) return null;
    HashMap<String,double> results = HashMap<String,double>();
    for (var row in list) {
      var group = _getGroup(row);
      var value = S.toDouble(Data.readValue(row, source));
      if (group != null && value != null)
      {
        if (!results.containsKey(group)) results[group] = 0;
        results[group] = results[group]! + value;
      }
    }
    return results;
  }

  HashMap<String,double?>? _calcAvg(Data list)
  {
    if (source == null) return null;

    HashMap<String,double>? sum = _calcSum(list);
    HashMap<String,double>? cnt = _calcCnt(list);

    var results = HashMap<String,double?>();
    if ((sum != null) && (cnt != null)) {
      for (var point in list) {
      if ((point != null) && (point.containsKey(source)) && (point[source] != null) && (S.isNumber(point[source])))
      {
        String? group = _getGroup(point);
        if ((group != null) && (sum.containsKey(group)) && (cnt.containsKey(group)) && (cnt[group] != 0))
        {
          results[group] = sum[group]! / cnt[group]!;
          if (precision != null && S.toInt(precision) != null) results[group] = fml_eval.Eval.evaluate("round(${results[group]}, ${precision!})");
        }
      }
    }
    }
    return results;
  }

  _avg(Data? list)
  {
    if ((list== null) || (source == null)) return null;
    HashMap<String,double?>? map = _calcAvg(list);

    if (map != null) {
      for (var row in list) {
        String? group = _getGroup(row);
        if ((_inGroup(row, group)) && (map.containsKey(group))) Data.writeValue(row, target, map[group!]);
      }
    }
  }

  _sum(Data? list)
  {
    if ((list== null) || (source == null)) return null;
    HashMap<String,double>? map = _calcSum(list);

    if (map != null) {
      for (var row in list) {
        String? group = _getGroup(row);
        if ((_inGroup(row, group)) && (map.containsKey(group))) Data.writeValue(row, target, map[group!]);
      }
    }
  }

  _cnt(Data? list)
  {
    if ((list== null) || (source == null)) return null;
    HashMap<String,double>? map = _calcCnt(list);

    if (map != null) {
      for (var row in list) {
        String? group = _getGroup(row);
        if ((_inGroup(row, group)) && (map.containsKey(group))) Data.writeValue(row, target, S.toInt(map[group!]));
      }
    }
  }

  //Total calculates the total occurences in each field and prints to a source. Would be useful to add this feature to DISTINCT.
  _total(Data? list)
  {
    if ((list== null) || (source == null)) return null;
    Map? map = _calcTotal(list);

    if (map != null) {
      for (var row in list) {
        String? group = _getGroup(row);
        var value = Data.readValue(row, source);
        if ((_inGroup(row, group)) && map.containsKey(value)) {
          Data.writeValue(row, target, S.toInt(map[value]));
        }
      }
    }
  }

  _min(Data? list)
  {
    if ((list== null) || (source == null)) return null;
    HashMap<String,double?>? map = _calcMin(list);

    if (map != null) {
      for (var row in list) {
        String? group = _getGroup(row);
        if ((_inGroup(row, group)) && (map.containsKey(group))) Data.writeValue(row, target, map[group!]);
      }
    }
  }

  _eval(Data? list)
  {
    if ((list== null) || (source == null)) return null;

    List<Binding>? bindings  = Binding.getBindings(source);
    for (var row in list) {
      try
      {
        // get variables
        Map<String?, dynamic> variables = Data.readValues(bindings, row);

        // evaluate
        dynamic value;
        if (precision != null && S.toInt(precision) != null) {
          value = fml_eval.Eval.evaluate("round(${source!}, ${precision!})", variables: variables);
        } else {
          value = fml_eval.Eval.evaluate(source, variables: variables);
        }

        Data.writeValue(row, target, value);
      }
      catch(e) {
        Log().debug('$e');
      }
    }
  }

  _max(Data? list)
  {
    if ((list== null) || (source == null)) return null;
    HashMap<String,double?>? map = _calcMax(list);

    if (map != null) {
      for (var row in list) {
        String? group = _getGroup(row);
        if ((_inGroup(row, group)) && (map.containsKey(group))) Data.writeValue(row, target, map[group!]);
      }
    }
  }

  @override
  apply(Data? data) async
  {
    if (enabled == false) return;

    switch (operation)
    {
      case sum:
        _sum(data);
        break;
      case min:
        _min(data);
        break;
      case max:
        _max(data);
        break;
      case avg:
        _avg(data);
        break;
      case count:
        _cnt(data);
        break;
      case countlong:
        _cnt(data);
        break;
      case total:
        _total(data);
        break;
      case evaluate:
        _eval(data);
        break;
    }
  }
}

class Statistics {
  String? value;
  double? min;
  double? max;
  double? avg;
  double? sum;
  double cnt = 0;
}