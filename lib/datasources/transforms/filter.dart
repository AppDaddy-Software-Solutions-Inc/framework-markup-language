// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/transforms/iTransform.dart';
import 'package:fml/datasources/transforms/transform_model.dart';
import 'package:fml/eval/eval.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class Filter extends TransformModel implements ITransform
{
  ////////////
  /* filter */
  ////////////
  StringObservable? _filter;
  set filter (dynamic v)
  {
    ////////////
    /* Filter */
    ////////////
    if (v is String) v = encode(v);
    if (_filter != null)
    {
      _filter!.set(v);
    }
    else if (v != null)
    {
      _filter = StringObservable(Binding.toKey(id, 'filter'), v, scope: scope);
    }
  }
  String? get filter
  {
    String? v =_filter?.get();
    if (v != null) v = decode(v);
    return v;
  }

  Filter(WidgetModel? parent, {String? id, dynamic enabled, dynamic filter}) : super(parent, id)
  {
    this.enabled  = enabled ?? true;
    this.filter   = filter;
  }

  static Filter? fromXml(WidgetModel? parent, XmlElement xml)
  {
    String? id = Xml.get(node: xml, tag: 'id');
    if (S.isNullOrEmpty(id)) id = Uuid().v4().toString();

    Filter model = Filter
      (
        parent,
        id      : id,
        enabled : Xml.get(node: xml, tag: 'enabled'),
        filter  : Xml.get(node: xml, tag: 'filter')
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

  _fromList(Data? data)
  {
    if (data == null) return null;

    var bindings = Binding.getBindings(filter);

    List remove = [];
    data.forEach((row)
    {
      var variables = Data.readValues(bindings, row);
      var result = Eval.evaluate(filter, variables: variables);

      bool? ok = S.toBool(result);
      if (ok != true) remove.add(row);
    });
    data.removeWhere((row) => remove.contains(row));
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

  apply(Data? data) async
  {
    if (enabled == false) return;
    _fromList(data);
  }
}