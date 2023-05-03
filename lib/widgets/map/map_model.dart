// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/map/map_view.dart';
import 'package:fml/widgets/map/marker/map_marker_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

enum MapTypes { satellite, hybrid, terrain, roadmap }

class MapModel extends DecoratedWidgetModel 
{
  final List<String> layers = [];

  @override
  bool get isVerticallyExpanding => !isFixedHeight;

  @override
  bool get isHorizontallyExpanding => !isFixedWidth;
  
  // marker prototypes
  final HashMap<String?,List<String>> prototypes = HashMap<String?,List<String>>();

  // latitude
  DoubleObservable? _latitude;
  set latitude(dynamic v)
  {
    if (_latitude != null)
    {
      _latitude!.set(v);
    } else if (v != null)
    {
      _latitude = DoubleObservable(Binding.toKey(id, 'latitude'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double? get latitude => _latitude?.get();

  // longitude
  DoubleObservable? _longitude;
  set longitude(dynamic v) {
    if (_longitude != null)
    {
      _longitude!.set(v);
    }
    else if (v != null)
    {
      _longitude = DoubleObservable(Binding.toKey(id, 'longitude'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double? get longitude => _longitude?.get();

  // zoom level
  DoubleObservable? _zoom;
  set zoom(dynamic v)
  {
    if (_zoom != null)
    {
      _zoom!.set(v);
    } else if (v != null)
    {
      _zoom = DoubleObservable(Binding.toKey(id, 'zoom'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double get zoom
  {
    double? scale = _zoom?.get() ?? 1;
    if (_zoom == null) return scale;

    scale = _zoom?.get();
    scale ??= 1;
    if ((scale < 1))   scale = 1;
    if ((scale > 20))  scale = 20;
    return scale;
  }

  bool showAll = true;

  final List<MapMarkerModel> markers = [];

  MapModel(
    WidgetModel parent,
    String? id, {
    dynamic zoom,
    dynamic visible,
    dynamic showAll,
  }) : super(parent, id)
  {
    // instantiate busy observable
    busy = false;

    this.zoom = zoom;
    this.visible = visible;
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
    zoom      = Xml.get(node: xml, tag: 'zoom');
    latitude  = Xml.get(node: xml, tag: 'latitude');
    longitude = Xml.get(node: xml, tag: 'longitude');
    showAll   = S.toBool(Xml.get(node: xml, tag: 'showallpoints')) == false ? false : true;

    // add layers
    var layers = Xml.getChildElements(node: xml, tag: "LAYER");
    if (layers != null){
      layers.forEach((layer)
      {
        String? url = Xml.get(node: layer, tag: 'url');
        if (url != null) this.layers.add(url);
      });}

    // build locations
    List<MapMarkerModel> markers = findChildrenOfExactType(MapMarkerModel).cast<MapMarkerModel>();
    markers.forEach((model)
    {
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
        this.markers.add(model);
      }
    });
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async
  {
    busy = false;
    bool ok = await _build(list, source);
    notifyListeners('list', markers);
    return ok;
  }

  // HashMap<String, Uint8List> _icons = HashMap<String, Uint8List>();

  Future<bool> _build(Data? list, IDataSource source) async {
    try
    {
      List<String>? prototypes = this.prototypes.containsKey(source.id) ? this.prototypes[source.id] : null;
      if (prototypes == null) return true;

      // Remove Old Locations
      markers.removeWhere((model) => source.id == model.datasource);

      // build new locations
      if ((list != null) && (list.isNotEmpty)){
        for (String prototype in prototypes)
        {
          int i = 0;
          list.forEach((data)
          {
            XmlElement? node = S.fromPrototype(prototype, "$id-${S.newId()}");
            i = i + 1;

            var location = MapMarkerModel.fromXml(parent!, node, data: data);
            if (location != null) markers.add(location);
          });
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
