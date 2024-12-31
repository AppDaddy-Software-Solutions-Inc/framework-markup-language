// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter_map/flutter_map.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/map/map_model.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/widgets/map/marker/map_marker_model.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatefulWidget implements ViewableWidgetView {
  @override
  final MapModel model;
  MapView(this.model) : super(key: ObjectKey(model));

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends ViewableWidgetState<MapView> {

  // flutter map controller
  MapController? controller;

  LatLng? center;
  double? zoom;
  LatLngBounds? bounds;
  double? rotation;

  void onMapEvent(MapEvent event) {
    if (!widget.model.fit) return;
    if (event.source == MapEventSource.doubleTapZoomAnimationController ||
        event.source == MapEventSource.doubleTap ||
        event.source == MapEventSource.doubleTapHold ||
        event.source == MapEventSource.dragStart ||
        event.source == MapEventSource.dragEnd ||
        event.source == MapEventSource.scrollWheel ||
        event.source == MapEventSource.multiFingerGestureStart) widget.model.fit = false;
  }

  /// Callback function for when the model changes, used to force a rebuild with setState()
  @override
  onModelChange(Model model, {String? property, dynamic value}) {
    var b = Binding.fromString(property);
    if (b?.property == 'busy') return;

    super.onModelChange(model);
  }

  void applyMapSettings() {
    if (widget.model.fit) {
      fitBounds();
    }
  }

  void fitBounds() {
    if (bounds != null) {
      CameraFit fit = CameraFit.bounds(bounds: bounds!, padding: const EdgeInsets.all(50));
      controller?.fitCamera(fit);
    }
  }

  Widget _markerBuilder(MapMarkerModel model) {
    // build the child views
    List<Widget> children = model.inflate();

    Widget child = const Icon(Icons.location_on_outlined, color: Colors.red);
    if (children.length == 1) child = children.first;
    if (children.length > 1)  child = Column(children: children);
    return child;
  }

  // builds/rebuilds markers array
  final List<Marker> markers = [];
  int markerHash = 0;
  void _buildMarkers() {
    try {

      // if the models marker list is the same, use the existing marker list
      if (widget.model.markers.hashCode == markerHash) return;
      markerHash = widget.model.markers.hashCode;

      // clear Markers
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
      if (points.length == 1) {
        center ??= points.first;
      }

      // set bounds
      bounds = null;
      if (points.length > 1) {
        bounds = LatLngBounds.fromPoints(points);
      }
    } catch (e) {
      Log().debug('$e');
    }
  }

  FlutterMap? _buildMap() {
    try {
      // add map layers
      List<Widget> layers = [];
      for (var url in widget.model.layers) {
        layers.add(TileLayer(urlTemplate: url, userAgentPackageName: 'fml.dev'));
      }

      // add default layer if none
      if (widget.model.layers.isEmpty) {
        layers.add(TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'fml.dev'));
      }

      // build the markers
      _buildMarkers();

      // add markers layer
      layers.add(MarkerLayer(markers: markers));

      // create a new controller
      controller ??= MapController();

      // zoom
      zoom = widget.model.zoom ?? 13;
      if (zoom! < 0) zoom = 0;

      // center (default NYC)
      center = const LatLng(40.712776, -74.005974);
      if (widget.model.latitude != null && widget.model.longitude != null) {
        center = LatLng(widget.model.latitude!, widget.model.longitude!);
      }

      // rotation
      rotation = 0.0;

      // fit
      CameraFit? fit;
      if (bounds != null) {
        fit = CameraFit.bounds(bounds: bounds!, padding: const EdgeInsets.all(50));
      }

      // map options
      MapOptions options = MapOptions(
          keepAlive: true,
          initialZoom: zoom!,
          initialCenter: center!,
          initialRotation: rotation!,
          onMapEvent: onMapEvent,
          initialCameraFit: fit);

      // map
      var map = FlutterMap(
          mapController: controller,
          options: options,
          children: layers);

      // set map bounds
      WidgetsBinding.instance.addPostFrameCallback((_) => applyMapSettings());

      return map;
    }
    catch (e) {
      Log().exception("There was a problem building the map. Error is $e",
          caller: 'widget.map.View');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => BoxView(widget.model, builder);

  List<Widget> builder(BuildContext context, BoxConstraints constraints) {

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const [Offstage()];

    // get the children
    List<Widget> children = widget.model.inflate();

    // build the map
    var map = _buildMap();
    if (map != null) children.insert(0, map);

    // view
    Widget view = children.length > 1 ? Stack(children: children) : children.first;

    return [view];
  }
}
