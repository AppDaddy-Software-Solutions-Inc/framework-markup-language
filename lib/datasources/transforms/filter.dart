// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/transforms/iTransform.dart';
import 'package:fml/datasources/transforms/transform_model.dart';
import 'package:fml/eval/eval.dart';
import 'package:fml/system.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class Filter extends TransformModel implements ITransform
{
  // enabled
  BooleanObservable? _enabled;

  Scope? externalScope;

  set enabled(dynamic v) {
    if (_enabled != null) {
      _enabled!.set(v);
    }
    else if (v != null)
    {
      _enabled = BooleanObservable(Binding.toKey(id, 'enabled'), v, scope: externalScope, listener: onPropertyChange);
      _enabled!.registerListener(onPropertyChange);
    }
  }
  bool get enabled => _enabled?.get() ?? true;

  // filter
  StringObservable? _filter;
  set filter (dynamic v)
  {
    ////////////
    /* Filter */
    ////////////
    if (_filter != null)
    {
      _filter!.set(v);
    }
    else if (v != null)
    {
      _filter = StringObservable(Binding.toKey(id, 'filter'), v, scope: externalScope, listener: onFilterChange);
      _filter!.registerListener(onFilterChange);
    }
  }
  String? get filter
  {
    String? v =_filter?.get();
    return v;
  }

  Filter(WidgetModel? parent, Scope? externalScope, {String? id, dynamic enabled, dynamic filter}) : super(parent, id)
  {
    this.externalScope = externalScope;
    this.enabled  = enabled;
    this.filter   = filter;
  }

  static Filter? fromXml(WidgetModel? parent, XmlElement xml, Scope? externalScope)
  {
    String? id = Xml.get(node: xml, tag: 'id');
    if (S.isNullOrEmpty(id)) id = S.newId();
    Filter model = Filter(
        parent,
        externalScope,
        id: id,
        enabled: Xml.get(node: xml, tag: 'enabled'),
        filter : Xml.get(node: xml, tag: 'filter')
    );
    model.deserialize(xml);
    return model;
  }

  @override
  void deserialize(XmlElement xml)
  {
    _enabled?.removeListener(onPropertyChange);
    _filter?.removeListener(onFilterChange);
    // Deserialize
    super.deserialize(xml);
  }

  _fromList(Data? data)
  {
    if (data == null || filter == null) return null;

    var bindings = Binding.getBindings(filter);

    // Out of Scope Variables, not local to the data row
    var oosVariables = Map<String?, dynamic>();
    bindings?.forEach((b) {
      if (b.source != 'data')
        oosVariables[b.signature] = externalScope?.getObservable(b, requestor: _filter)?.value;
    });

    List remove = [];
    data.forEach((row)
    {
      // Data Row Scoped Variables, local to the data row
      var rowVariables = Data.readValues(bindings, row);

      // Combine the local and out of scope variables so the row can utilize both within an eval
      rowVariables.addAll(oosVariables);

      // Evaluate the filter
      var result = Eval.evaluate(filter, variables: rowVariables);

      // Based on the eval create a remove list
      bool? ok = S.toBool(result);
      if (ok != true) remove.add(row);
    });

    // Filter the results out
    data.removeWhere((row) => remove.contains(row));
  }

  void onFilterChange(Observable observable)
  {
    print('################################################################');
    apply(data);
  }

  apply(Data? data) async
  {
    if (enabled == false) return;
    _fromList(data);
  }

}