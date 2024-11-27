// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/transforms/transform_interface.dart';
import 'package:fml/datasources/transforms/transform_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class Distinct extends TransformModel implements IDataTransform {

  /* field */
  StringObservable? _field;
  set field(dynamic v) {
    if (_field != null) {
      _field!.set(v);
    } else if (v != null) {
      _field = StringObservable(Binding.toKey(id, 'field'), v, scope: scope);
    }
  }
  String? get field => _field?.get();

  Distinct(Model? parent, {String? id, dynamic enabled, dynamic field})
      : super(parent, id) {
    this.enabled = enabled;
    this.field = field;
  }

  static Distinct? fromXml(Model? parent, XmlElement xml) {
    String? id = Xml.get(node: xml, tag: 'id');
    if (isNullOrEmpty(id)) id = newId();

    Distinct model = Distinct(parent,
        id: id,
        enabled: Xml.get(node: xml, tag: 'enabled'),
        field: Xml.get(node: xml, tag: 'field'));

    model.deserialize(xml);

    return model;
  }

  _fromList(Data? data) {

    if (data == null) return;

    if (isNullOrEmpty(field)) return;

    Map<String, dynamic> distinct = {};

    for (var row in data) {
      var value = toStr(Data.read(row, field)) ?? "";
      if (!distinct.containsKey(value)) {
        distinct[value] = row;
      }
    }

    data.clear();
    data.addAll(distinct.values);
  }

  @override
  apply(Data? data) async {
    if (enabled == false) return;
    _fromList(data);
  }
}
