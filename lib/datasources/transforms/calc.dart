// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/transforms/transform_model.dart';
import 'package:fml/eval/eval.dart' as EVALUATE;
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/helper/helper_barrel.dart';

class Calc extends TransformModel implements IDataTransform
{
  static const String sum       = "sum";
  static const String min       = "min";
  static const String max       = "max";
  static const String avg       = "avg";
  static const String avglong   = "average";
  static const String count     = "cnt";
  static const String countlong = "count";
  static const String evaluate  = "eval";

  final String? source;
  final String? target;
  final String? precision;

  ///////////////
  /* operation */
  ///////////////
  String? _operation;
  set operation (String? v)
  {
    if (_operation != v)
    {
      if (v != null) v = v.toLowerCase();
      _operation = v;
    }
  }

  String? get operation
  {
    return _operation;
  }

  ///////////
  /* group */
  ///////////
  List<String>? _group;
  set group (String? v)
  {
    _group = null;
    if (v != null) _group = v.split(",");
  }

  Calc(WidgetModel? parent, {String? id, String? operation, this.source, this.target, this.precision, String? group}) : super(parent, id)
  {
    this.operation = operation;
    this.group = group;
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

  String? _getGroup(Map<dynamic,dynamic> point)
  {
    if (_group == null) return '*';

    String? group;
    _group!.forEach((f)
    {
      if (point.containsKey(f)) group = (group ?? "") + "[" + point[f].toString() + "]";
    });
    return group;
  }

  bool _inGroup(Map<dynamic,dynamic> point, String? group)
  {
    if (group == null) return false;
    if (_getGroup(point) == group) return true;
    return false;
  }

  HashMap<String,double?>? _calcMin(Data list)
  {
    if (source == null) return null;

    HashMap<String,double?> result = HashMap<String,double?>();
    list.forEach((point)
    {
      if ((point != null) && (point.containsKey(source)) && (point[source] != null) && (S.isNumber(point[source])))
      {
        double? value = S.toDouble(point[source]);
        String? group = _getGroup(point);
        if (group != null)
        {
          if (!result.containsKey(group)) result[group] = value;
          if (value! < result[group]!) result[group] = value;
        }
      }
    });
    return result;
  }

  HashMap<String,double?>? _calcMax(Data list)
  {
    if (source == null) return null;

    HashMap<String,double?> result = HashMap<String,double?>();

    list.forEach((point)
    {
      if ((point != null) && (point.containsKey(source)) && (point[source] != null) && (S.isNumber(point[source])))
      {
        double? value = S.toDouble(point[source]);
        String? group = _getGroup(point);
        if (group != null)
        {
          if (!result.containsKey(group)) result[group] = value;
          if (value! > result[group]!) result[group] = value;
        }
      }
    });
    return result;
  }

  HashMap<String,double>? _calcCnt(Data list)
  {
    if (source == null) return null;

    HashMap<String,double> result = HashMap<String,double>();

    list.forEach((point)
    {
      if ((point != null) && (point.containsKey(source)) && (point[source] != null))
      {
        String? group = _getGroup(point);
        if (group != null)
        {
          if (!result.containsKey(group)) result[group] = 0;
          result[group] = result[group]! + 1;
        }
      }
    });
    return result;
  }

  HashMap<String,double>? _calcSum(Data list)
  {
    if (source == null) return null;

    HashMap<String,double> result = HashMap<String,double>();

    list.forEach((point)
    {
      if ((point != null) && (point.containsKey(source)) && (point[source] != null) && (S.isNumber(point[source])))
      {
        double? value = S.toDouble(point[source]);
        String? group = _getGroup(point);
        if (group != null)
        {
          if (!result.containsKey(group)) result[group] = 0;
          result[group] = result[group]! + value!;
        }
      }
    });
    return result;
  }

  HashMap<String,double?>? _calcAvg(Data list)
  {
    if (source == null) return null;

    HashMap<String,double>? sum = _calcSum(list);
    HashMap<String,double>? cnt = _calcCnt(list);

    HashMap<String,double?> result = HashMap<String,double?>();
    if ((sum != null) && (cnt != null))
      list.forEach((point)
      {
        if ((point != null) && (point.containsKey(source)) && (point[source] != null) && (S.isNumber(point[source])))
        {
          String? group = _getGroup(point);
          if ((group != null) && (sum.containsKey(group)) && (cnt.containsKey(group)) && (cnt[group] != 0))
          {
            result[group] = sum[group]! / cnt[group]!;
            if (precision != null && S.toInt(precision) != null) result[group] = EVALUATE.Eval.evaluate("round(" + result[group].toString() + ", " + precision! + ")");
          }
        }
      });
    return result;
  }

  _avg(Data? list)
  {
    if ((list== null) || (source == null)) return null;
    HashMap<String,double?>? map = _calcAvg(list);

    if (map != null)
      list.forEach((point)
      {
        String? group = _getGroup(point);
        if ((_inGroup(point, group)) && (map.containsKey(group)))
        {
          try
          {
            point[target] = map[group!].toString();
          }
          catch(e) {
            Log().exception(e, caller: 'calc.dart => _avg(Data list)');
          }
        }
      });
  }

  _sum(Data? list)
  {
    if ((list== null) || (source == null)) return null;
    HashMap<String,double>? map = _calcSum(list);

    if (map != null)
      list.forEach((point)
      {
        String? group = _getGroup(point);
        if ((_inGroup(point, group)) && (map.containsKey(group)))
        {
          try
          {
            point[target] = map[group!].toString();
          }
          catch(e){}
        }
      });
  }

  _cnt(Data? list)
  {
    if ((list== null) || (source == null)) return null;
    HashMap<String,double>? map = _calcCnt(list);

    if (map != null)
      list.forEach((point)
      {
        String? group = _getGroup(point);
        if ((_inGroup(point, group)) && (map.containsKey(group)))
        {
          try
          {
            point[target] = S.toInt(map[group!]).toString();
          }
          catch(e){}
        }
      });
  }

  _min(Data? list)
  {
    if ((list== null) || (source == null)) return null;
    HashMap<String,double?>? map = _calcMin(list);

    if (map != null)
      list.forEach((point)
      {
        String? group = _getGroup(point);
        if ((_inGroup(point, group)) && (map.containsKey(group)))
        {
          try
          {
            point[target] = map[group!].toString();
          }
          catch(e){}
        }
      });
  }

  _eval(Data? list)
  {
    if ((list== null) || (source == null)) return null;

    List<Binding>? bindings  = Binding.getBindings(source);
    list.forEach((data)
    {
      try
      {
        // get variables
        Map<String?, dynamic> variables = Json.getVariables(bindings, data);

        // evaluate
        if (precision != null && S.toInt(precision) != null)
             data[target] = EVALUATE.Eval.evaluate("round(" + source! + ", " + precision! + ")", variables: variables);
        else data[target] = EVALUATE.Eval.evaluate(source, variables: variables);
      }
      catch(e) {}
    });
  }

  _max(Data? list)
  {
    if ((list== null) || (source == null)) return null;
    HashMap<String,double?>? map = _calcMax(list);

    if (map != null)
      list.forEach((point)
      {
        String? group = _getGroup(point);
        if ((_inGroup(point, group)) && (map.containsKey(group)))
        {
          try
          {
            point[target] = map[group!].toString();
          }
          catch(e){}
        }
      });
  }

  apply(List? list) async
  {
    if (enabled == false) return;

    switch (operation)
    {
      case sum:
        _sum(list as Data?);
        break;
      case min:
        _min(list as Data?);
        break;
      case max:
        _max(list as Data?);
        break;
      case avg:
        _avg(list as Data?);
        break;
      case count:
        _cnt(list as Data?);
        break;
      case countlong:
        _cnt(list as Data?);
        break;
      case evaluate:
        _eval(list as Data?);
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