// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:collection';
import 'package:fml/log/manager.dart';
import 'package:fml/phrase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/googlemap/map_model.dart';
import 'package:fml/widgets/googlemap/location/map_location_model.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/busy/busy_view.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fml/helper/common_helpers.dart';

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

  HashMap<String?, BitmapDescriptor> icons  = HashMap<String?, BitmapDescriptor>();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  double? latitudeUpperBound;
  double? longitudeUpperBound;
  double? latitudeLowerBound;
  double? longitudeLowerBound;
  GoogleMap?  map;

  @override
  void initState()
  {
    super.initState();

    /////////////////////
    /* Position Camera */
    /////////////////////
    Future.delayed(Duration(milliseconds: 500), _showAll);
    WidgetsBinding.instance.addPostFrameCallback((_) => Future.delayed(Duration(seconds: 1), () => busy = null));
  }

  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? controller;

  // static final CameraPosition _kGooglePlex = CameraPosition(
  //   target: LatLng(37.42796133580664, -122.085749655962),
  //   zoom: 14.4746,
  // );

  // static final CameraPosition _kLake = CameraPosition(
  //     bearing: 192.8334901395799,
  //     target: LatLng(44.4812792, -76.1424527),
  //     tilt: 59.440717697143555,
  //     zoom: 19.151926040649414);

  // Widget buildold(BuildContext context) {
  //   return new Scaffold(
  //     body: GoogleMap(
  //       mapType: MapType.hybrid,
  //       initialCameraPosition: _kGooglePlex,
  //       onMapCreated: (GoogleMapController controller) {
  //         _controller.complete(controller);
  //       },
  //     ),
  //     floatingActionButton: FloatingActionButton.extended(
  //       onPressed: _goToTheLake,
  //       label: Text('To the lake!'),
  //       icon: Icon(Icons.directions_boat),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    widget.model.busy = false;

    // save system constraints
    onLayout(constraints);

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    ///////////////////////
    /* Build the Markers */
    ///////////////////////
    _buildMarkers();

    ///////////////////
    /* Build the Map */
    ///////////////////
    map ??= _buildGoogleMap();

    /// Busy / Loading Indicator
    busy ??= BusyView(BusyModel(widget.model, visible: widget.model.busy, observable: widget.model.busyObservable));

    var width = widget.model.width   ?? widget.model.myMaxWidthOrDefault;
    var height = widget.model.height ?? widget.model.myMaxHeightOrDefault;

    //////////////////
    /* Reset Button */
    //////////////////
   var reset = FloatingActionButton.extended(onPressed: _showAll, label: Text(phrase.reset), icon: Icon(Icons.zoom_out_map_outlined));

    // add busy
    List<Widget> children = [map!, Positioned(top: 10, right: 10, child: reset)];
    if (widget.model.showbusy)
    {
      children.add(Center(child: busy));
    }

    // View
    dynamic view = Container(
        child: GestureDetector(behavior: HitTestBehavior.opaque, onDoubleTap: () => true, onVerticalDragCancel: () => true, onVerticalDragUpdate: (_) => true, onVerticalDragStart: (_) => true, onVerticalDragDown: (_) => true, onVerticalDragEnd: (_) => true, onHorizontalDragCancel: () => true, onHorizontalDragUpdate: (_) => true, onHorizontalDragStart: (_) => true, onHorizontalDragDown: (_) => true, onHorizontalDragEnd: (_) => true, // block scroll events while writing
            child: Listener(behavior: HitTestBehavior.opaque, onPointerSignal: (ps) => true,
                child: SizedBox(width: width, height: height,
                    child: Stack(fit: StackFit.expand,
                        children: children)))));

    // apply user defined constraints
    return applyConstraints(view, widget.model.constraints);
  }

  GoogleMap? _buildGoogleMap()
  {
      ////////////////
      /* Create Map */
      ////////////////
      try
      {
        //////////////
        /* Map Type */
        //////////////
        MapType type = MapType.hybrid;
        if (widget.model.mapType == MapTypes.roadmap)   type = MapType.hybrid;
        if (widget.model.mapType == MapTypes.terrain)   type = MapType.terrain;
        if (widget.model.mapType == MapTypes.satellite) type = MapType.satellite;

        /////////
        /* Map */
        /////////
        GoogleMap map = GoogleMap(
          onMapCreated: (GoogleMapController controller)
          {
            _controller.complete(controller);
          },
          initialCameraPosition: CameraPosition(target: LatLng(44.4749157,-76.1394201), bearing: 192.8334901395799, tilt: 59.440717697143555, zoom: widget.model.zoom),
          compassEnabled: false,
          mapToolbarEnabled: true,
          cameraTargetBounds: CameraTargetBounds.unbounded,
          mapType: type,
          rotateGesturesEnabled: false,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: false,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          indoorViewEnabled: false,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          trafficEnabled: false,
          markers: Set<Marker>.of(markers.values),
          // This fixes gestures but there is an issue with mousehweel onPointerSignals triggering on both the map and a scrollable parent
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())});

        return map;
      }
      catch(e)
      {
        Log().exception(e, caller: 'widget.map.View');
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

      ///////////////////
      /* Build Markers */
      ///////////////////
      int locationIndex = 0;
      for (MapLocationModel location in widget.model.locations)
      {
        if (location.latitude != null && location.longitude != null)
        {
          ///////////////
          /* Marker Id */
          ///////////////
          MarkerId id = MarkerId('$locationIndex,${location.latitude},${location.longitude}');

          /////////////////
          /* Info Window */
          /////////////////
          InfoWindow? info = ((!S.isNullOrEmpty(location.title)) || (!S.isNullOrEmpty(location.description)) || (location.onTap != null)) ? InfoWindow(title:location.title, snippet: location.description) : null;

          //////////
          /* Icon */
          //////////
          BitmapDescriptor icon = BitmapDescriptor.defaultMarker;
          if (!icons.containsKey(location.marker))
          {
            if (location.icon != null) icon = BitmapDescriptor.fromBytes(location.icon!);
            icons[location.marker] = icon;
          }

          ////////////
          /* Marker */
          ////////////
          markers[id] = Marker(markerId: id, position: LatLng(location.latitude!, location.longitude!), icon: icon, onTap: () {_show(location.latitude, location.longitude);}, infoWindow: info ?? InfoWindow.noText);

          ////////////////
          /* Set Bounds */
          ////////////////
          _setMarkerBounds(markers[id]);
        }
        locationIndex++;
      }
    }
    catch(e) {
      Log().debug('$e');
    }

  }

  void _showAll() async
  {
    if (map != null) {
      //////////
      /* Busy */
      //////////
      // widget.model.busy = true;

      final GoogleMapController controller = await _controller.future;

      /////////////////////
      /* Position Camera */
      /////////////////////
      ///////////////////////
      /* Show Single Point */
      ///////////////////////
      if (markers.length == 1)
      {
        _show(markers.values.first.position.latitude, markers.values.first.position.longitude);
        return;
      }

      /////////////////////
      /* Show All Points */
      /////////////////////
      if (markers.length > 1)
      {
        final LatLngBounds spot = LatLngBounds(southwest: LatLng(latitudeLowerBound!, longitudeLowerBound!), northeast: LatLng(latitudeUpperBound!, longitudeUpperBound!));
        controller.animateCamera(CameraUpdate.newLatLngBounds(spot, 10.0));
      }
    }

    //////////
    /* Busy */
    //////////
    widget.model.busy = false;
  }

  void _show(final double? latitude, final double? longitude) async
  {
    //////////
    /* Busy */
    //////////
    // widget.model.busy = true;

    final GoogleMapController controller = await _controller.future;


      final CameraPosition spot = CameraPosition(target: LatLng(latitude!, longitude!), bearing: 192.8334901395799, tilt: 59.440717697143555, zoom: widget.model.zoom);
      controller.animateCamera(CameraUpdate.newCameraPosition(spot));

    //////////
    /* Busy */
    //////////
    widget.model.busy = false;
  }

  void _setMarkerBounds(Marker? marker) 
  {
    if(widget.model.showAll == true) 
    {
      if (latitudeLowerBound == null || marker!.position.latitude < latitudeLowerBound!)    latitudeLowerBound = marker!.position.latitude;
      if (latitudeUpperBound == null || marker.position.latitude > latitudeUpperBound!)    latitudeUpperBound = marker.position.latitude;
      if (longitudeLowerBound == null || marker.position.longitude < longitudeLowerBound!) longitudeLowerBound = marker.position.longitude;
      if (longitudeUpperBound == null || marker.position.longitude > longitudeUpperBound!) longitudeUpperBound = marker.position.longitude;
    }
    else 
    {
      latitudeUpperBound  = marker!.position.latitude;
      latitudeLowerBound  = marker.position.latitude;
      longitudeUpperBound = marker.position.longitude;
      longitudeLowerBound = marker.position.longitude;
    }
  }
}