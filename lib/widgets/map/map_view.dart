// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:math';
import 'package:flutter_map/flutter_map.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/map/map_model.dart';
import 'package:fml/widgets/widget/viewable_widget_view.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/widgets/map/marker/map_marker_model.dart';
import 'package:fml/widgets/widget/viewable_widget_state.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatefulWidget implements ViewableWidgetView {
  @override
  final MapModel model;
  MapView(this.model) : super(key: ObjectKey(model));

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends ViewableWidgetState<MapView> {
  Widget? busy;
  Future<MapModel>? future;
  bool startup = true;

  final mapController = MapController();
  List<Marker> markers = [];

  // default center
  // new york city
  final centerDefault = const LatLng(40.712776, -74.005974);

  /// Callback function for when the model changes, used to force a rebuild with setState()
  @override
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    var b = Binding.fromString(property);
    if (b?.property == 'busy') return;

    super.onModelChange(model);
  }

  FlutterMap? _buildMap() {
    try {
      // add map layers
      List<Widget> layers = [];
      for (var url in widget.model.layers) {
        layers
            .add(TileLayer(urlTemplate: url, userAgentPackageName: 'fml.dev'));
      }

      // default layer is openstreets
      if (widget.model.layers.isEmpty) {
        layers.add(TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'fml.dev'));
      }

      // add markers
      layers.add(MarkerLayer(markers: markers));

      // zoom level
      double zoom = widget.model.zoom > 0 ? min(16.0, widget.model.zoom) : 16.0;

      // center point
      if (widget.model.latitude != null && widget.model.longitude != null) {
        centerPoint = LatLng(widget.model.latitude!, widget.model.longitude!);
      }

      // bounds
      CameraFit? bounds;
      if (markerBounds != null) {
        bounds = CameraFit.bounds(
            bounds: markerBounds!, padding: const EdgeInsets.all(50));
        //var cz = bounds.fit(mapController);
        //centerPoint = cz.center;
        //zoom = cz.zoom;
      }

      // map options
      MapOptions options = MapOptions(
          keepAlive: true,
          initialZoom: zoom,
          initialCenter: centerPoint ?? centerDefault,
          initialCameraFit: bounds);

      // map
      var map = FlutterMap(
          key: ObjectKey(widget.model),
          mapController: mapController,
          options: options,
          children: layers);

      // center the map
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.model.autozoom) {
          // this move is a hack to force the map to
          // refresh its tiles on startup.
          mapController.move(centerDefault, zoom);

          // move back to intended spot
          mapController.move(centerPoint ?? centerDefault, zoom);
        }
      });

      return map;
    } catch (e) {
      Log().exception("There was a problem building the map. Error is $e",
          caller: 'widget.map.View');
    }
    return null;
  }

  LatLngBounds? markerBounds;
  LatLng? centerPoint;

  void _buildMarkers() async {
    try {
      //Clear Markers
      markers.clear();

      // build markers
      List<LatLng> points = [];
      for (MapMarkerModel model in widget.model.markers) {
        if (model.latitude != null && model.longitude != null) {
          var width = model.width ?? 20;
          if (width < 5 || width > 200) width = 20;

          var height = model.height ?? 20;
          if (height < 5 || height > 200) height = 20;

          // build marker
          var point = LatLng(model.latitude!, model.longitude!);
          points.add(point);
          var marker = Marker(
              point: point,
              width: width,
              height: height,
              child: _markerBuilder(model));
          markers.add(marker);
        }
      }

      // set center point
      centerPoint = null;
      if (points.length == 1) {
        centerPoint = points.first;
      }

      // set bounds
      markerBounds = null;
      if (points.length > 1) {
        markerBounds = LatLngBounds.fromPoints(points);
      }
    } catch (e) {
      Log().debug('$e');
    }
  }

  Widget _markerBuilder(MapMarkerModel model) {
    // build the child views
    List<Widget> children = model.inflate();

    Widget child = const Icon(Icons.location_on_outlined, color: Colors.red);
    if (children.length == 1) child = children.first;
    if (children.length > 1) child = Column(children: children);
    return child;
  }

  @override
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // get the children
    List<Widget> children = widget.model.inflate();

    // build the markers
    _buildMarkers();

    // build the map
    var map = _buildMap();
    if (map != null) children.insert(0, map);

    // Busy / Loading Indicator
    busy ??= BusyModel(widget.model,
            visible: widget.model.busy, observable: widget.model.busyObservable)
        .getView();

    // add busy
    children.add(Center(child: busy));

    // view
    Widget view = Stack(children: children);

    // create as Box
    view = BoxView(widget.model, children: [view]);

    return view;
  }
}
