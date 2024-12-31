// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observable.dart';
import 'package:fml/observable/observables/double.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:fml/widgets/map/map_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class MapMarkerModel extends ViewableModel {
  /// latitude
  DoubleObservable? _latitude;
  set latitude(dynamic v) {
    if (_latitude != null) {
      _latitude!.set(v);
    } else if (v != null) {
      _latitude =
          DoubleObservable(Binding.toKey(id, 'latitude'), v, scope: scope);
      _latitude!.registerListener(onMarkerChange);
    }
  }

  double? get latitude => _latitude?.get();

  /// longitude
  DoubleObservable? _longitude;
  set longitude(dynamic v) {
    if (_longitude != null) {
      _longitude!.set(v);
    } else if (v != null) {
      _longitude =
          DoubleObservable(Binding.toKey(id, 'longitude'), v, scope: scope);
      _longitude!.registerListener(onMarkerChange);
    }
  }

  double? get longitude => _longitude?.get();

  MapMarkerModel(Model super.parent, super.id,
      {dynamic data,
      dynamic latitude,
      dynamic longitude,
      String? info,
      String? infoSnippet,
      String? marker,
      dynamic visible})
      : super(scope: Scope(parent: parent.scope)) {
    this.data = data;
    this.latitude = latitude;
    this.longitude = longitude;
  }

  static MapMarkerModel? fromXml(Model parent, XmlElement? xml,
      {dynamic data}) {
    MapMarkerModel? model;
    try {
      // build model
      model = MapMarkerModel(parent, Xml.get(node: xml, tag: 'id'), data: data);
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'map.location.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement? xml) {
    if (xml == null) return;

    // deserialize
    super.deserialize(xml);

    latitude = Xml.get(node: xml, tag: 'latitude');
    longitude = Xml.get(node: xml, tag: 'longitude');

    // remove datasource listener. The parent map will take care of this.
    if ((datasource != null) &&
        (scope != null) &&
        (scope!.datasources.containsKey(datasource))) {
      scope!.datasources[datasource!]!.remove(this);
    }
  }

  void onMarkerChange(Observable observable) {
    if (parent is MapModel) {
      (parent as MapModel).onMarkerChange(this, observable);
    }
  }

  @override
  Widget getView() => const Offstage();
}
