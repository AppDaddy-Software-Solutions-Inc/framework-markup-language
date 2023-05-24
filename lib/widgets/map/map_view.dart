// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/map/map_model.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/busy/busy_view.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/widgets/map/marker/map_marker_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatefulWidget implements IWidgetView
{
  @override
  final MapModel model;
  MapView(this.model) : super(key: ObjectKey(model));

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends WidgetState<MapView>
{
  BusyView? busy;
  Future<MapModel>? future;
  bool startup = true;

  final mapController = MapController();
  List<Marker> markers = [];

  double? latitudeUpperBound;
  double? longitudeUpperBound;
  double? latitudeLowerBound;
  double? longitudeLowerBound;

  /// Callback function for when the model changes, used to force a rebuild with setState()
  @override
  onModelChange(WidgetModel model,{String? property, dynamic value})
  {
    if (mounted)
    {
      var b = Binding.fromString(property);
      if (b?.property == 'busy') return;
      if (property == 'busy') return;

      if ((b?.property == 'latitude' || b?.property == 'longitude') && (widget.model.latitude != null && widget.model.longitude != null)) {
        mapController.move(LatLng(widget.model.latitude!, widget.model.longitude!), widget.model.zoom);
      }
      setState(() {});
    }
  }

  FlutterMap? _buildMap()
  {
      try
      {
        // add map layers
        List<Widget> layers = [];
        for (var url in widget.model.layers) {
          layers.add(TileLayer(urlTemplate: url, userAgentPackageName: 'fml.dev'));
        }

        // default layer is openstreets
        if (widget.model.layers.isEmpty) layers.add(TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", userAgentPackageName: 'fml.dev'));

        // add markers
        layers.add(MarkerLayer(markers: markers));

        // center point
        LatLng? center;
        if (widget.model.latitude != null && widget.model.longitude != null) center = LatLng(widget.model.latitude!, widget.model.longitude!);

        // zoom level
        double zoom = 16.0;
        if (widget.model.zoom > 0) zoom = widget.model.zoom;

        // map options
        MapOptions options = MapOptions(
          keepAlive: true,
          center: center,
          zoom: zoom,
          minZoom: 1,
          maxZoom: 20,
          //bounds: LatLngBounds(
          //  LatLng(51.74920, -0.56741),
          //  LatLng(51.25709, 0.34018),
          //),
          maxBounds: LatLngBounds(LatLng(-90, -180.0), LatLng(90.0, 180.0)));

        // map
        return FlutterMap(mapController: mapController, children: layers, options: options);
      }
      catch(e)
      {
        Log().exception("There was a problem building the map. Error is $e", caller: 'widget.map.View');
      }
      return null;
  }

  void _buildMarkers() async
  {
    try {
      ///////////////////
      /* Clear Markers */
      ///////////////////
      markers.clear();

      //////////////////
      /* Reset Bounds */
      //////////////////
      latitudeUpperBound  = null;
      latitudeLowerBound  = null;
      longitudeUpperBound = null;
      longitudeLowerBound = null;

      // build markers
      for (MapMarkerModel marker in widget.model.markers)
      {
        if (marker.latitude != null && marker.longitude != null)
        {
          var width = marker.width ?? 20;
          if (width < 5 || width > 200) width = 20;

          var height = marker.height ?? 20;
          if (height < 5 || height > 200) height = 20;

          markers.add(Marker(point: LatLng(marker.latitude!,  marker.longitude!), width: width, height: height, builder: (context) => _markerBuilder(marker.children)));
        }
      }
    }
    catch(e) {
      Log().debug('$e');
    }

  }

  Widget _markerBuilder(List<WidgetModel>? children)
  {
    // build the child views
    List<Widget> children = widget.model.inflate();

    Widget child = FlutterLogo();
    if (children.length == 1) child = children.first;
    if (children.length >  1) child = Column(children: children);
    return child;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // save system constraints
    onLayout(constraints);

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // get the children
    List<Widget> children = widget.model.inflate();

    // build the markers
    _buildMarkers();

    // build the map
    var map = _buildMap();
    if (map != null) children.insert(0, map);

    /// Busy / Loading Indicator
    busy ??= BusyView(BusyModel(widget.model, visible: widget.model.busy, observable: widget.model.busyObservable));

    // add busy
    children.add(Center(child: busy));

    // view
    Widget view = Stack(children: children);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.tightestOrDefault);

    return view;
  }
}