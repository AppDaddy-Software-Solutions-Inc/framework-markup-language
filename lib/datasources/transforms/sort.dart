// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/transforms/transform_interface.dart';
import 'package:fml/datasources/transforms/transform_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/helpers/helpers.dart';

enum SortTypes { none, ascending, descending }

class Sort extends TransformModel implements IDataTransform {

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

  // field type
  Type? _type;
  set type(dynamic v) {
    Type sortType = String;
    if (!isNullOrEmpty(v)) {
      v = v.toLowerCase().trim();
      if (v == 'string') sortType = String;
      if (v == 'numeric') sortType = num;
      if (v == 'integer') sortType = num;
      if (v == 'real') sortType = num;
      if (v == 'date' || v == 'datetime' || v == 'time') sortType = DateTime;
    }
    _type = sortType;
  }
  Type get type => _type ?? String;

  // asscending
  BooleanObservable? _ascending;
  set ascending(dynamic v) {
    if (_ascending != null) {
      _ascending!.set(v);
    } else if (v != null) {
      _ascending = BooleanObservable(Binding.toKey(id, 'ascending'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get ascending => _ascending?.get() ?? true;

  // sase sensitive
  bool? _casesensitive;
  set casesensitive(dynamic v) {
    _casesensitive = toBool(v);
  }
  bool get casesensitive => _casesensitive ?? false;

  Sort(Model? parent,
      {String? id,
      dynamic field,
      dynamic type,
      dynamic ascending,
      dynamic casesensitive})
      : super(parent, id) {
    this.field = field;
    this.type = type;
    this.ascending = ascending;
    this.casesensitive = casesensitive;
  }

  static Sort? fromXml(Model? parent, XmlElement xml) {
    Sort model = Sort(
      parent,
      id: Xml.get(node: xml, tag: 'id'),
      field: Xml.get(node: xml, tag: 'field'),
      type: Xml.get(node: xml, tag: 'type'),
      ascending: Xml.get(node: xml, tag: 'ascending'),
      casesensitive: Xml.get(node: xml, tag: 'casesensitive'),
    );
    model.deserialize(xml);
    return model;
  }

  @override
  void deserialize(XmlElement xml) {
    // Deserialize
    super.deserialize(xml);
  }

  _sort(List? list) {
    if (list == null) return;
    if (list.isEmpty) return;

    list.sort((a, b) {
      dynamic v1 = Data.read(a, field);
      dynamic v2 = Data.read(b, field);

      int? result = 0;
      if (type == String) {
        v1 = (v1 != null)
            ? (casesensitive ? v1.toString() : v1.toString().toLowerCase())
            : null;
        v2 = (v2 != null)
            ? (casesensitive ? v2.toString() : v2.toString().toLowerCase())
            : null;
      } else if (type == int) {
        v1 = (isNumeric(v1) == true) ? toInt(v1) : null;
        v2 = (isNumeric(v2) == true) ? toInt(v2) : null;
      } else if (type == double) {
        v1 = (isNumeric(v1) == true) ? toDouble(v1) : null;
        v2 = (isNumeric(v2) == true) ? toDouble(v2) : null;
      } else if (type == num) {
        v1 = (isNumeric(v1) == true) ? toNum(v1) : null;
        v2 = (isNumeric(v2) == true) ? toNum(v2) : null;
      } else if (type == DateTime) {
        v1 = toDate(v1);
        v2 = toDate(v2);
      }

      try {
        // We want to add special handling for numbers when comparing a null
        // so that they are always shown last regardless of ascending or not
        if (type == num || type == int || type == double) {
          if ((v1 == null) && (v2 == null)) {
            result = 0;
          } else if ((v1 != null) && (v2 == null)) {
            result = -1;
          } else if ((v1 == null) && (v2 != null)) {
            result = 1;
          } else if ((v1 != null) && (v2 != null)) {
            result = (ascending == true) ? v1.compareTo(v2) : v2.compareTo(v1);
          }
        } else {
          if ((v1 == null) && (v2 == null)) {
            result = 0;
          } else if ((v1 != null) && (v2 == null)) {
            result = (ascending == true) ? -1 : 1;
          } else if ((v1 == null) && (v2 != null)) {
            result = (ascending == true) ? 1 : -1;
          } else if ((v1 != null) && (v2 != null)) {
            result = (ascending == true) ? v1.compareTo(v2) : v2.compareTo(v1);
          }
        }
      } catch (e) {
        result = 0;
      }
      return result!;
    });
  }

  @override
  Future<void> apply(Data? data) async {
    if (enabled == false) return;
    _sort(data);
  }
}
