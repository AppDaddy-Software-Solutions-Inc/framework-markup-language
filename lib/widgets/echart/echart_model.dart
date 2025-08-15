// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide Axis;
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/echart/echart_view.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:xml/xml.dart';

import '../../data/data.dart' show Data;
import '../../log/manager.dart' show Log;

/// Chart [ChartModel]
///
/// Defines the properties used to build a Chart
class eChartModel extends BoxModel {

  @override
  bool get canExpandInfinitelyWide => !hasBoundedWidth;

  @override
  bool get canExpandInfinitelyHigh => !hasBoundedHeight;

  eChartModel(
    super.parent,
    super.id
   ) {
    busy = false;
  }

  // holds list of datasources
  List<IDataSource> _datasources = [];
  List<String> _datasource = [];

  @override
  set datasource(dynamic v) {
    if (v is String) {
      List<String> values = v.split(",");
      _datasource = [];
      for (var e in values) {
        if (!isNullOrEmpty(e)) _datasource.add(e.trim());
      }
    }
  }

  static eChartModel? fromXml(Model parent, XmlElement xml) {
    eChartModel? model;
    try {
      model = eChartModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      model = null;
    }
    return model;
  }

  // holds the option map decoded from option
  Map<String, dynamic> options = {};

  // echart option json string
  StringObservable? _option;
  set option(dynamic v) {
    if (_option != null) {
        _option!.set(v);
    } else if (v != null) {
        _option = StringObservable(Binding.toKey(id, 'option'), v, scope: scope, listener: _onOptionChange);
    }
  }
  String get option => _option?.get() ?? '{}';

  // build options map on option property change
  void _onOptionChange(Observable observable) {

    var json = observable.value;

    // decode options
    options = {};
    try {
      options = jsonDecode(json);
    }
    catch(e)
    {
      Log().error(e.toString());
    }

    // remove existing listeners
    for (var datasource in _datasources) {
      datasource.remove(this);
    }
    _datasources = [];

    // build new list of respective datasources and data
    List<Data> data = [];
    for (var id in _datasource) {

      // get datasource
      var datasource = scope?.getDataSource(id);

      Data? d;
      if (datasource != null) {

        // add to list
        _datasources.add(datasource);

        // register listener
        datasource.register(this);

        // add its data to dataset
        d = datasource.data;
      }

      // add data
      data.add(d ?? Data());
    }

    // build options dataset element
    var k = "dataset";
    for (var d in data) {

      // no dataset element?
      if (!options.containsKey(k)) options[k] = [];

      // single dataset element?
      if (options[k] is Map) {
        var temp = options[k];
        options[k] = [];
        options[k].add(temp);
      }

      // add source map
      var source = Map<String, dynamic>();
      source["source"] = d;
      (options[k] as List).add(source);
    }

    // trigger view update
    onPropertyChange(observable);
  }

  @override
  void dispose() {

    // remove listeners
    for (var datasource in _datasources) {
      datasource.remove(this);
    }
    _datasources = [];

    // dispose
    super.dispose();
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async {
    // rebuild options
    if (_option != null) {
      _onOptionChange(_option!);
    }
    return true;
  }
  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {

    super.deserialize(xml);

    // find cdata node - option
    var cdata = xml.children.firstWhereOrNull((child) => child is XmlCDATA);
    if (cdata?.value != null) option = cdata!.value?.trim();
  }

  @override
  Widget getView({Key? key}) {
    var view = eChartView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}
