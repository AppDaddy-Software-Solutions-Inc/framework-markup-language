// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/googlemap/map_view.dart';
import 'package:fml/widgets/googlemap/location/map_location_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

enum MapTypes { satellite, hybrid, terrain, roadmap }

class MapModel extends ViewableModel {
  String? style;
  bool editmode = false;

  final prototypes = HashMap<String?, List<XmlElement>>();

  //////////////
  /* latitude */
  //////////////
  DoubleObservable? _latitude;
  set latitude(dynamic v) {
    if (_latitude != null) {
      _latitude!.set(v);
    } else if (v != null) {
      _latitude = DoubleObservable(Binding.toKey(id, 'latitude'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get latitude => _latitude?.get();

  //////////////
  /* longitude */
  //////////////
  DoubleObservable? _longitude;
  set longitude(dynamic v) {
    if (_longitude != null) {
      _longitude!.set(v);
    } else if (v != null) {
      _longitude = DoubleObservable(Binding.toKey(id, 'longitude'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get longitude => _longitude?.get();

  ///////////
  /* Zoom */
  ///////////
  DoubleObservable? _zoom;
  set zoom(dynamic v) {
    if (_zoom != null) {
      _zoom!.set(v);
    } else if (v != null) {
      _zoom = DoubleObservable(Binding.toKey(id, 'zoom'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double get zoom {
    double? scale = _zoom?.get() ?? 2;
    if (_zoom == null) return scale;

    scale = _zoom?.get();
    scale ??= 5.4;
    if ((scale < 0)) scale = 0;
    if ((scale > 25)) scale = 25;
    return scale;
  }

  MapTypes? mapType = MapTypes.roadmap;

  bool showAll = true;

  final List<MapLocationModel> locations = [];

  MapModel(
    Model super.parent,
    super.id, {
    this.style,
    dynamic zoom,
    this.mapType,
    dynamic visible,
    dynamic showAll,
  }) {
    // instantiate busy observable
    busy = false;
    this.zoom = zoom;
    this.visible = visible;
    this.showAll = (showAll ?? true);
  }

  static MapModel? fromXml(Model parent, XmlElement xml) {
    MapModel? model;
    try {
      model = MapModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'map.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);

    // properties
    style = Xml.get(node: xml, tag: 'style');
    zoom = Xml.get(node: xml, tag: 'zoom');
    latitude = Xml.get(node: xml, tag: 'latitude');
    longitude = Xml.get(node: xml, tag: 'longitude');
    mapType = toEnum(Xml.get(node: xml, tag: 'type'), MapTypes.values);
    showAll = toBool(Xml.get(node: xml, tag: 'showallpoints')) == false
        ? false
        : true;

    // build locations
    List<MapLocationModel> locations =
        findChildrenOfExactType(MapLocationModel).cast<MapLocationModel>();
    for (var model in locations) {
      // data driven prototype location
      if (!isNullOrEmpty(model.datasource)) {
        if (!prototypes.containsKey(model.datasource)) {
          prototypes[model.datasource] = [];
        }

        // build prototype
        var prototype = prototypeOf(model.element) ?? model.element;

        // add location model
        if (prototype != null) {
          prototypes[model.datasource]!.add(prototype);
        }

        // register listener to the models datasource
        IDataSource? source =
            (scope != null) ? scope!.getDataSource(model.datasource) : null;
        if (source != null) source.register(this);
      }

      // static location
      else {
        this.locations.add(model);
      }
    }
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async {
    busy = false;
    bool ok = await _build(list, source);
    notifyListeners('list', locations);
    return ok;
  }

  // HashMap<String, Uint8List> _icons = HashMap<String, Uint8List>();

  Future<bool> _build(Data? list, IDataSource source) async {
    try {
      List<XmlElement>? prototypes = this.prototypes.containsKey(source.id)
          ? this.prototypes[source.id]
          : null;
      if (prototypes == null) return true;

      // Remove Old Locations
      locations.removeWhere((model) => source.id == model.datasource);

      // build new locations
      if ((list != null) && (list.isNotEmpty)) {
        for (var prototype in prototypes) {
          for (var data in list) {
            var location =
                MapLocationModel.fromXml(parent!, prototype, data: data);
            if (location != null) locations.add(location);
          }
        }
      }
    } catch (e) {
      Log().error('Error building list. Error is $e', caller: 'MAP');
      return false;
    }

    return true;
  }

  @override
  Widget getView({Key? key}) => getReactiveView(MapView(this));
}
