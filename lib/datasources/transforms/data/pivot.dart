// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/transforms/transform_interface.dart';
import 'package:fml/datasources/transforms/transform_model.dart';
import 'package:fml/log/manager.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class Pivot extends TransformModel implements ITransform {

  // column
  StringObservable? _column;
  set column(dynamic v) {
    if (_column != null) {
      _column!.set(v);
    } else if (v != null) {
      _column = StringObservable(Binding.toKey(id, 'column'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get column => _column?.get();

  // row
  StringObservable? _row;
  set row(dynamic v) {
    if (_row != null) {
      _row!.set(v);
    } else if (v != null) {
      _row = StringObservable(Binding.toKey(id, 'row'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get row => _row?.get();

  // field
  StringObservable? _field;
  set field(dynamic v) {
    if (_field != null) {
      _field!.set(v);
    } else if (v != null) {
      _field = StringObservable(Binding.toKey(id, 'field'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get field => _field?.get();

  // add summary rows (total, avg)
  BooleanObservable? _addSummaryRows;
  set addSummaryRows(dynamic v) {
    if (_addSummaryRows != null) {
      _addSummaryRows!.set(v);
    } else if (v != null) {
      _addSummaryRows = BooleanObservable(Binding.toKey(id, 'addsummaryrows'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get addSummaryRows => _addSummaryRows?.get() ?? false;


  // add summary rows (total, avg)
  BooleanObservable? _addSummaryColumns;
  set addSummaryColumns(dynamic v) {
    if (_addSummaryColumns != null) {
      _addSummaryColumns!.set(v);
    } else if (v != null) {
      _addSummaryColumns = BooleanObservable(Binding.toKey(id, 'addsummarycolumns'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get addSummaryColumns => _addSummaryColumns?.get() ?? false;

  Pivot(Model? parent,
      {String? id, String? row, String? column, String? field, dynamic addSummaryRows, dynamic addSummaryColumns})
      : super(parent, id) {
    this.row = row;
    this.column = column;
    this.field = field;
    this.addSummaryRows = addSummaryRows;
    this.addSummaryColumns = addSummaryColumns;
  }

  static Pivot? fromXml(Model? parent, XmlElement xml) {
    Pivot model = Pivot(parent,
        id: Xml.get(node: xml, tag: 'id'),
        row: Xml.get(node: xml, tag: "row"),
        column: Xml.get(node: xml, tag: "column"),
        field: Xml.get(node: xml, tag: "field"),
        addSummaryRows: Xml.get(node: xml, tag: "addsummaryrows"),
        addSummaryColumns: Xml.get(node: xml, tag: "addsummarycolumns"));
    model.deserialize(xml);
    return model;
  }

  @override
  void deserialize(XmlElement xml) {
    // Deserialize
    super.deserialize(xml);
  }

  Data? _pivot(Data data) {
    bool columnFound = false;
    bool rowFound = false;
    bool fieldFound = false;

    // build list of distinct columns
    List<String> columns = [];
    for (var row in data) {
      var name = Data.read(row, column);
      if (name != null && !columns.contains(name.toString())) {
        columns.add(name.toString());
      }
    }

    // sort the list
    columns.sort();

    Map<String, Map<String?, Map<String, double?>>> statistics =
        <String, Map<String?, Map<String, double?>>>{};
    for (var row in data) {
      String? myColumn;
      String? myRow;
      String? mField;

      // lookup column
      var value = Data.read(row, column);
      if (value != null) {
        myColumn = value.toString();
        columnFound = true;
      }

      // lookup row
      value = Data.read(row, this.row);
      if (value != null) {
        myRow = value.toString();
        rowFound = true;
      }

      // lookup field
      value = Data.read(row, field);
      if (value != null) {
        mField = value.toString();
        fieldFound = true;
      }

      if (myRow != null) {
        // create new row?
        if (!statistics.containsKey(myRow)) {
          statistics[myRow] = <String?, Map<String, double?>>{};
          for (var column in columns) {
            statistics[myRow]![column] = <String, double?>{};
            statistics[myRow]![column]!["min"] = null;
            statistics[myRow]![column]!["max"] = null;
            statistics[myRow]![column]!["cnt"] = null;
            statistics[myRow]![column]!["avg"] = null;
            statistics[myRow]![column]!["sum"] = null;
          }
        }

        // set the values
        double? v = (mField is String) ? toDouble(mField) : null;
        var p = statistics[myRow]![myColumn]!;
        if (v != null) {
          p["cnt"] = p["cnt"] == null ? 1 : p["cnt"]! + 1;
          p["sum"] = p["sum"] == null ? v : p["sum"]! + v;
          p["min"] = p["min"] == null || p["min"]! > v ? v : p["min"];
          p["max"] = p["max"] == null || p["max"]! < v ? v : p["max"];
          p["avg"] = p["sum"]! / p["cnt"]!;
        }
      }
    }

    if (!columnFound) {
      Log().exception(Exception("Column ${column!} not found in data set"));
    }
    if (!rowFound) {
      Log().exception(Exception("Row ${row!} not found in data set"));
    }
    if (!fieldFound) {
      Log().exception(Exception("Field ${field!} not found in data set"));
    }
    if ((!columnFound) || (!rowFound) || (!fieldFound)) return null;

    Data result = Data();
    statistics.forEach((key, value) {
      Map<String?, dynamic> myrow = <String?, dynamic>{};
      myrow[row] = key;
      // Sum
      double sum = 0;
      double count = 0;
      value.forEach((key, value) {
        var v = value["sum"];
        myrow[key] = null;
        if (v != null) myrow[key] = v.toString();
        sum = sum + (v ?? 0);
        count++;
      });
      if (_addSummaryColumns?.get() == true)
        {
          myrow["AVG"] = (count > 0) ? (sum / count).toStringAsFixed(2) : "";
          myrow["TOTAL"] = sum.toString();
        }
      result.add(myrow);
    });

    // Column Totals
    Map<String, dynamic> totals = <String, dynamic>{};
    Map<String, dynamic> counts = <String, dynamic>{};
    Map<String, dynamic> averages = <String, dynamic>{};
    for (var row in result) {
      row.forEach((key, value) {
        if (!totals.containsKey(key)) totals[key] = null;
        if (!counts.containsKey(key)) counts[key] = null;
        double? sum = toDouble(value);
        if (sum != null) {
          totals[key] = (totals[key] ?? 0) + sum;
          counts[key] = (counts[key] ?? 0) + 1;
        }
      });
    }

    totals.forEach((key, value) {
      averages[key] = null;
      if (totals[key] != null && counts[key] != null && counts[key]! > 0) {
        averages[key] =
            ((totals[key] / counts[key]) as double).toStringAsFixed(2);
      }
    });

    totals.forEach((key, value) {
      if (totals[key] != null) totals[key] = totals[key].toString();
    });

    /* Totals */
    totals[row!] = "TOTAL";
    averages[row!] = "AVG";

    // add summary rows
    if (addSummaryRows) {
      totals["AVG"] = "";
      averages["TOTAL"] = "";
      result.add(averages);
      result.add(totals);
    }

    return result;
  }

  @override
  apply(Data? data) async {
    if (enabled == false) return;
    Data? result;
    try {
      if (data != null) result = _pivot(data);
    } catch (e) {
      Log().exception(e);
    }

    if (result != null) {
      data!.clear();
      data.addAll(result);
    }
  }
}
