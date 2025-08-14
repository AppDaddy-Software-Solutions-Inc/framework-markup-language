// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide Axis;
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/echart/echart_view.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:xml/xml.dart';

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

  List<String> dataset = [];
  @override
  set datasource(dynamic v) {
    if (v is String) {
      List<String> values = v.split(",");
      dataset = [];
      for (var e in values) {
        if (!isNullOrEmpty(e)) dataset.add(e.trim());
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

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {

    super.deserialize(xml);

    // find cdata node - option
    var cdata = xml.children.firstWhereOrNull((child) => child is XmlCDATA);
    if (cdata?.value != null) option = cdata!.value?.trim();
  }

  StringObservable? _option;
  set option(dynamic v) {
    if (_option != null) {
      _option!.set(v);
    } else if (v != null) {
      _option = StringObservable(Binding.toKey(id, 'option'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String get option => _option?.get() ?? '{}';

  @override
  Widget getView({Key? key}) {
    var view = eChartView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}
