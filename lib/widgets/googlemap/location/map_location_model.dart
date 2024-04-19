// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:typed_data';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/double.dart';
import 'package:fml/observable/observables/string.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class MapLocationModel extends ViewableWidgetModel {
  dynamic onTap;
  String? description;
  String? label;
  Uint8List? icon;

  /// title
  StringObservable? _title;
  set title(dynamic v) {
    if (_title != null) {
      _title!.set(v);
    } else if (v != null) {
      _title = StringObservable(Binding.toKey(id, 'title'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get title => _title?.get();

  /// marker
  StringObservable? _marker;
  set marker(dynamic v) {
    if (_marker != null) {
      _marker!.set(v);
    } else if (v != null) {
      _marker = StringObservable(Binding.toKey(id, 'marker'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get marker => _marker?.get();

  /// latitude
  DoubleObservable? _latitude;
  set latitude(dynamic v) {
    if (_latitude != null) {
      _latitude!.set(v);
    } else if (v != null) {
      _latitude =
          DoubleObservable(Binding.toKey(id, 'latitude'), v, scope: scope);
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
    }
  }

  double? get longitude => _longitude?.get();

  MapLocationModel(Model super.parent, super.id,
      {dynamic data,
      dynamic latitude,
      dynamic longitude,
      String? info,
      String? infoSnippet,
      this.label,
      String? marker,
      dynamic visible})
      : super(scope: Scope(parent: parent.scope)) {
    this.data = data;
    this.latitude = latitude;
    this.longitude = longitude;

    title = info;
    description = infoSnippet;
    this.marker = marker;
    this.visible = visible;
  }

  static MapLocationModel? fromXml(Model parent, XmlElement? xml,
      {dynamic data}) {
    MapLocationModel? model;
    try {
      // build model
      model =
          MapLocationModel(parent, Xml.get(node: xml, tag: 'id'), data: data);
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
    title = Xml.get(node: xml, tag: 'info');
    description = Xml.get(node: xml, tag: 'infosnippet');
    label = Xml.get(node: xml, tag: 'label');
    marker = Xml.get(node: xml, tag: 'marker');

    // remove datasource listener. The parent chart will take care of this.
    if ((datasource != null) &&
        (scope != null) &&
        (scope!.datasources.containsKey(datasource))) {
      scope!.datasources[datasource!]!.remove(this);
    }
  }
}
