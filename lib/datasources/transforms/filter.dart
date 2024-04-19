// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/datasources/transforms/transform_interface.dart';
import 'package:fml/datasources/transforms/transform_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class Filter extends TransformModel implements ITransform {
  /// enabled
  BooleanObservable? _enabled;
  @override
  set enabled(dynamic v) {
    if (_enabled != null) {
      _enabled!.set(v);
    } else if (v != null) {
      _enabled = BooleanObservable(Binding.toKey(id, 'enabled'), v,
          scope: scope, listener: onFilterChange);
    }
  }

  @override
  bool get enabled => _enabled?.get() ?? true;

  // filter
  BooleanObservable? _filter;
  StringObservable? _filterListener;
  set filter(dynamic v) {
    if (_filter != null) {
      _filter!.set(v);
    } else if (v != null) {
      // force as eval
      if (!Observable.isEvalSignature(v)) v = "=$v";

      // replace all references to data with this.row
      v = v.replaceAll("{data.", "{this.row.");

      // create boolean filter
      _filter = BooleanObservable(Binding.toKey(id, 'filter'), v, scope: scope);

      // filter listener needs to be a non-eval
      // hence using the signature
      _filterListener = StringObservable(null, _filter!.signature,
          scope: scope, listener: onFilterChange);
    }
  }

  bool get filter => _filter?.get() ?? false;

  Filter(Model? parent, {String? id, dynamic enabled, dynamic filter})
      : super(parent, id) {
    this.enabled = enabled;
    this.filter = filter;
  }

  static Filter? fromXml(Model? parent, XmlElement xml) {
    String? id = Xml.get(node: xml, tag: 'id');
    if (isNullOrEmpty(id)) id = newId();
    Filter model = Filter(parent,
        id: id,
        enabled: Xml.get(node: xml, tag: 'enabled'),
        filter: Xml.get(node: xml, tag: 'filter'));
    model.deserialize(xml);
    return model;
  }

  @override
  void deserialize(XmlElement xml) {
    // Deserialize
    super.deserialize(xml);
  }

  void _applyFilter(Data? data) {
    if (data == null || data.isEmpty || _filter == null) return;

    // disable the filter change listener
    // we don't want to trigger a refilter while
    // filter values are changing
    _filterListener?.removeListener(onFilterChange);
    _enabled?.removeListener(onFilterChange);

    // Filter the results out
    data.removeWhere((row) {
      // change the row data
      // this causes the filter to re-evaluate
      this.row = row;

      // exclude from the data set?
      return (filter == false);
    });

    // re-enabled the filter change listener
    _filterListener?.registerListener(onFilterChange);
    _enabled?.registerListener(onFilterChange);
  }

  void onFilterChange(Observable observable) {
    // force parent to rebuild
    // we may want to not notify if the parent
    // is re-querying
    if (data != null && parent is IDataSource) {
      (parent as IDataSource).onSuccess(data);
    }
  }

  @override
  apply(Data? data) async {
    // clone the data
    // need this for re-filtering
    this.data = data?.clone();

    // apply the filter
    if (enabled) _applyFilter(data);
  }
}
