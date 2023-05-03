// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/transforms/iTransform.dart';
import 'package:fml/datasources/transforms/transform_model.dart';
import 'package:fml/log/manager.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class Pivot extends TransformModel implements ITransform
{
  // column
  StringObservable? _column;
  set column (dynamic v)
  {
    if (_column != null)
    {
      _column!.set(v);
    }

    else if (v != null)
    {
      _column = StringObservable(Binding.toKey(id, 'column'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get column => _column?.get();

  // row
  StringObservable? _row;
  set row (dynamic v)
  {
    if (_row != null)
    {
      _row!.set(v);
    }

    else if (v != null)
    {
      _row = StringObservable(Binding.toKey(id, 'row'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get row => _row?.get();

  // Field
  StringObservable? _field;
  set field (dynamic v)
  {
    if (_field != null)
    {
      _field!.set(v);
    }
    else if (v != null)
    {
      _field = StringObservable(Binding.toKey(id, 'field'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get field => _field?.get();

  Pivot(WidgetModel? parent, {String? id, String? row, String? column, String? field}) : super(parent, id)
  {
    this.row    = row;
    this.column = column;
    this.field  = field;
  }

  static Pivot? fromXml(WidgetModel? parent, XmlElement xml)
  {
    Pivot model = Pivot
        (
          parent,
          id       : Xml.get(node: xml, tag: 'id'),
          row      : Xml.get(node: xml, tag: "row"),
          column   : Xml.get(node: xml, tag: "column"),
          field    : Xml.get(node: xml, tag: "field")
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

  Data? _pivot(Data data)
  {
    bool columnFound = false;
    bool rowFound    = false;
    bool fieldFound  = false;

    Map<String, Map<String?, Map<String, double?>>> statistics = <String, Map<String?, Map<String, double?>>>{};
    data.forEach((row)
    {
      String? _column;
      String? _row;
      String? _field;

      // lookup column
      var value = Data.readValue(row,this.column);
      if (value != null)
      {
        _column = value.toString();
        columnFound = true;
      }

      // lookup row
      value = Data.readValue(row,this.row);
      if (value != null)
      {
        _row = value.toString();
        rowFound = true;
      }

      // lookup field
      value = Data.readValue(row,this.field);
      if (value != null)
      {
        _field = value.toString();
        fieldFound = true;
      }

      if (_row != null)
      {
        double? v = (_field is String) ? S.toDouble(_field) : null;
        if (!statistics.containsKey(_row)) statistics[_row] = <String?, Map<String, double?>>{};
        if (!statistics[_row]!.containsKey(_column))
        {
          statistics[_row]![_column] = <String, double?>{};
          statistics[_row]![_column]!["min"] = null;
          statistics[_row]![_column]!["max"] = null;
          statistics[_row]![_column]!["cnt"] = 0;
          statistics[_row]![_column]!["avg"] = null;
          statistics[_row]![_column]!["sum"] = null;
        }
        var p = statistics[_row]![_column]!;
        p["cnt"] = p["cnt"]! + 1;
        if (v != null)
        {
          p["sum"] = (p["sum"] != null) ? (p["sum"]! + v) : v;
          p["avg"] = p["sum"]! / p["cnt"]!;
          p["min"] = (p["min"] == null) || (p["min"]! > v) ? v : p["min"];
          p["max"] = (p["max"] == null) || (p["max"]! < v) ? v : p["max"];
        }
      }
    });

    if (!columnFound) Log().exception(Exception("Column ${this.column!} not found in data set"));
    if (!rowFound)    Log().exception(Exception("Row ${this.row!} not found in data set"));
    if (!fieldFound)  Log().exception(Exception("Field ${this.field!} not found in data set"));
    if ((!columnFound) || (!rowFound) || (!fieldFound)) return null;

    Data result = Data();
    statistics.forEach((key, value)
    {
      Map<String?, dynamic> row = <String?, dynamic>{};
      row["TIME"] = key;

      // Sum
      double sum = 0;
      double count = 0;
      value.forEach((key, value)
      {
        row[key] = value["sum"].toString();
        sum = sum + (value["sum"] ?? 0);
        count++;
      });

      row["AVG"]   = (count > 0) ? (sum /count).toStringAsFixed(2) : "";
      row["TOTAL"] = sum.toString();
      result.add(row);
    });

    // Column Totals
    Map<String, dynamic> totals   = <String, dynamic>{};
    Map<String, dynamic> averages = <String, dynamic>{};
    result.forEach((row)
    {
      row.forEach((key, value)
      {
        if (!totals.containsKey(key)) totals[key] = null;
        double? sum = S.toDouble(value);
        if (sum != null) totals[key] = (totals[key] ?? 0) + sum;
      });
    });

    totals.forEach((key, value)
    {
      if (totals[key] != null) averages[key] = (result.isNotEmpty) ? ((totals[key] / result.length) as double).toStringAsFixed(2) : "0";
    });

    totals.forEach((key, value)
    {
      if (totals[key] != null) totals[key] = totals[key].toString();
    });

    /* Totals */
    totals["TIME"]   = "TOTAL";
    averages["TIME"] = "AVG";

    totals["AVG"]     = "";
    averages["TOTAL"] = "";
    result.add(averages);
    result.add(totals);

    return result; //16 19 14 19 18 21
  }

  apply(Data? data) async
  {
    if (enabled == false) return;
    Data? result;
    try
    {
      if (data != null) result = _pivot(data);
    }
    catch(e)
    {
      Log().exception(e);
    }

    if (result != null)
    {
      data!.clear();
      data.addAll(result);
    }
  }
}