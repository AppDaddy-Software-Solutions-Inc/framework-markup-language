// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/transforms/transform_model.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';

class Distinct extends TransformModel implements IDataTransform
{
  ///////////
  /* field */
  ///////////
  StringObservable? _field;
  set field (dynamic v)
  {
    if (_field != null)
    {
      _field!.set(v);
    }
    else if (v != null)
    {
      _field = StringObservable(Binding.toKey(id, 'field'), v, scope: scope);
    }
  }
  String? get field => _field?.get();

  Distinct(WidgetModel? parent, {String? id, dynamic enabled, dynamic field}) : super(parent, id)
  {
    this.enabled  = enabled ?? true;
    this.field   = field;
  }

  static Distinct? fromXml(WidgetModel? parent, XmlElement xml)
  {
    String? id = Xml.get(node: xml, tag: 'id');
    if (S.isNullOrEmpty(id)) id = Uuid().v4().toString();

    Distinct model = Distinct
      (
        parent,
        id      : id,
        enabled : Xml.get(node: xml, tag: 'enabled'),
        field   : Xml.get(node: xml, tag: 'field')
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

  List<Map<dynamic, dynamic>> distinctList = [];
  List<String?> uniqueFields = [];

  _fromList(List? list)
  {
    if (list == null) return null;

    if (field == null) // removes duplicates
      list.toSet().toList();
    else {
      for (dynamic l in list) {
        if (!uniqueFields.contains(l[field])) {
          uniqueFields.add(l[field]);
          distinctList.add(l);
        }
      }
      list.clear();
      list.addAll(distinctList);
      // list = distinctList;
      distinctList = [];
      uniqueFields = [];
    }
  }

  apply(List? list) async
  {
    if (enabled == false) return;
    _fromList(list);
  }

  String encode(String v)
  {
    List<String?>? bindings = Binding.getBindingStrings(v);
    if (bindings != null)
      bindings.forEach((binding)
      {
        if (!binding!.contains(".")) v = v.replaceAll(binding, binding.replaceAll("{", "[[[[").replaceAll("}", "]]]]"));
      });
    return v;
  }

  String decode(String v)
  {
    v = v.replaceAll("[[[[", "{");
    v = v.replaceAll("]]]]", "}");
    return v;
  }
}