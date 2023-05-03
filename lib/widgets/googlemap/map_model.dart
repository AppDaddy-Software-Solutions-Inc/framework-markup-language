// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/googlemap/map_view.dart';
import 'package:fml/widgets/googlemap/location/map_location_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

enum MapTypes { satellite, hybrid, terrain, roadmap }

class MapModel extends DecoratedWidgetModel 
{
  String? style;
  bool editmode = false;

  final HashMap<String?,List<String>> prototypes = HashMap<String?,List<String>>();

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
  double get zoom
  {
    double? scale = _zoom?.get() ?? 2;
    if (_zoom == null) return scale;

    scale = _zoom?.get();
    scale ??= 5.4;
    if ((scale < 0))   scale = 0;
    if ((scale > 25))  scale = 25;
    return scale;
  }

  MapTypes? mapType = MapTypes.roadmap;

  bool showAll = true;

  final List<MapLocationModel> locations = [];

  MapModel(
    WidgetModel parent,
    String? id, {
    dynamic style,
    dynamic zoom,
    dynamic mapType,
    dynamic visible,
    dynamic showAll,
  }) : super(parent, id)
  {
    // instantiate busy observable
    busy = false;

    this.style = style;
    this.zoom = zoom;
    this.visible = visible;
    this.mapType = mapType;
    this.showAll = (showAll ?? true);
  }

  static MapModel? fromXml(WidgetModel parent, XmlElement xml) {
    MapModel? model;
    try
    {
      model = MapModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'map.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize 
    super.deserialize(xml);

    // properties
    style = Xml.get(node: xml, tag: 'style');
    zoom = Xml.get(node: xml, tag: 'zoom');
    latitude = Xml.get(node: xml, tag: 'latitude');
    longitude = Xml.get(node: xml, tag: 'longitude');
    mapType = S.toEnum(Xml.get(node: xml, tag: 'type'), MapTypes.values);
    showAll = S.toBool(Xml.get(node: xml, tag: 'showallpoints')) == false ? false : true;

    // build locations
    List<MapLocationModel> locations = findChildrenOfExactType(MapLocationModel).cast<MapLocationModel>();
    for (var model in locations) {
      // data driven prototype location
      if (!S.isNullOrEmpty(model.datasource))
      {
        if (!prototypes.containsKey(model.datasource)) prototypes[model.datasource] = [];

        // build prototype
        String prototype = S.toPrototype(model.element.toString());

        // add location model
        prototypes[model.datasource]!.add(prototype);

        // register listener to the models datasource
        IDataSource? source = (scope != null) ? scope!.getDataSource(model.datasource) : null;
        if (source != null) source.register(this);
      }

      // static location
      else {
        this.locations.add(model);
      }
    }
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async
  {
    busy = false;
    bool ok = await _build(list, source);
    notifyListeners('list', locations);
    return ok;
  }

  // HashMap<String, Uint8List> _icons = HashMap<String, Uint8List>();

  Future<bool> _build(Data? list, IDataSource source) async {
    try
    {
      List<String>? prototypes = this.prototypes.containsKey(source.id) ? this.prototypes[source.id] : null;
      if (prototypes == null) return true;

      // Remove Old Locations
      locations.removeWhere((model) => source.id == model.datasource);

      // build new locations
      if ((list != null) && (list.isNotEmpty)){
        for (String prototype in prototypes)
        {
          int i = 0;
          for (var data in list) {
            XmlElement? node = S.fromPrototype(prototype, S.newId());
            i = i + 1;

            var location = MapLocationModel.fromXml(parent!, node, data: data);
            if (location != null) locations.add(location);
          }
        }}
    }
    catch(e)
    {
      Log().error('Error building list. Error is $e', caller: 'MAP');
      return false;
    }

    return true;
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  @override
  Widget getView({Key? key}) => getReactiveView(MapView(this));
}
