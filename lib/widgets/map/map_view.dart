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

   /// Callback function for when the model changes, used to force a rebuild with setState()
  @override
  onModelChange(WidgetModel model,{String? property, dynamic value})
  {
    if (mounted)
    {
      var b = Binding.fromString(property);
      if (b?.property == 'busy') return;
      setState(() {});
    }
  }

  FlutterMap? _buildMap()
  {
      try
      {
        // add map layers
        List<Widget> layers = [];
        for (var url in widget.model.layers)
        {
          layers.add(TileLayer(urlTemplate: url, userAgentPackageName: 'fml.dev'));
        }

        // default layer is openstreets
        if (widget.model.layers.isEmpty)
        {
          layers.add(TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", userAgentPackageName: 'fml.dev'));
        }

        // add markers
        layers.add(MarkerLayer(markers: markers));

        // zoom level
        double zoom = 16.0;
        if (widget.model.zoom > 0)
        {
          zoom = widget.model.zoom;
        }

        // center point
        LatLng? center;
        if (widget.model.latitude != null && widget.model.longitude != null) center = LatLng(widget.model.latitude!, widget.model.longitude!);
        if (center == null && centerPoint != null && markerBounds == null)
        {
          center = centerPoint;
        }

        //bounds
        LatLngBounds? bounds;
        if (center == null && markerBounds != null)
        {
          bounds = markerBounds;
        }

        // map options
        MapOptions options = MapOptions(
          keepAlive: true,
          zoom: zoom,
          minZoom: 1,
          maxZoom: 20,
          slideOnBoundaries: true,
          center: center,
          bounds: bounds,
          maxBounds: LatLngBounds(LatLng(-90, -180.0), LatLng(90.0, 180.0)));

        // map
        var map = FlutterMap(mapController: mapController, children: layers, options: options);

        // center the map
        if (center != null)
        {
          WidgetsBinding.instance.addPostFrameCallback((_)
          {
            mapController.move(center!,zoom);
          });
        }

        // center the map
        else if (bounds != null)
        {
          WidgetsBinding.instance.addPostFrameCallback((_)
          {
            mapController.centerZoomFitBounds(bounds!,options: FitBoundsOptions(padding: EdgeInsets.all(10)));
          });
        }

        return map;
      }
      catch(e)
      {
        Log().exception("There was a problem building the map. Error is $e", caller: 'widget.map.View');
      }
      return null;
  }

  LatLngBounds? markerBounds;
  LatLng? centerPoint;
  
  void _buildMarkers() async
  {
    try 
    {
      //Clear Markers
      markers.clear();

      markerBounds = null;
      centerPoint = null;

      //Reset Bounds
      double? minLogitude;
      double? minLatitude;
      double? maxLogitude;
      double? maxLatitude;

      // build markers
      for (MapMarkerModel marker in widget.model.markers)
      {
        if (marker.latitude != null && marker.longitude != null)
        {
          var width = marker.width ?? 20;
          if (width < 5 || width > 200) width = 20;

          var height = marker.height ?? 20;
          if (height < 5 || height > 200) height = 20;

          double latitude  = marker.latitude!;
          double longitude = marker.longitude!;

          // set center
          if (centerPoint == null)
          {
            centerPoint = LatLng(latitude, longitude);
          }

          // set min/max values
          if (minLogitude == null || minLogitude > longitude)
          {
            minLogitude = longitude;
          }
          if (minLatitude == null || minLatitude > latitude)
          {
            minLatitude = latitude;
          }
          if (maxLogitude == null || maxLogitude > longitude)
          {
            maxLogitude = longitude;
          }
          if (maxLatitude == null || maxLatitude > latitude)
          {
            maxLatitude = latitude;
          }

          // build marker
          var m = Marker(point: LatLng(marker.latitude!,  marker.longitude!), width: width, height: height, builder: (context) => _markerBuilder(marker));
          markers.add(m);
        }
      }

      // set marker bounds
      if (widget.model.markers.length > 1 && minLatitude != null && minLogitude != null && maxLatitude != null && maxLogitude != null)
      {
        // top left coordinate
        var tl = LatLng(minLatitude, minLogitude);

        // top right coordinate
        var br = LatLng(maxLatitude, minLogitude);

        // marker bounds
        if (tl.latitude != br.latitude || tl.longitude != br.longitude)
        {
          markerBounds = LatLngBounds(tl, br);
        }
      }
    }
    catch(e)
    {
      Log().debug('$e');
    }
  }

  Widget _markerBuilder(MapMarkerModel model)
  {
    // build the child views
    List<Widget> children = model.inflate();

    Widget child = Icon(Icons.location_on_outlined, color: Colors.red);
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

     // Busy / Loading Indicator
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