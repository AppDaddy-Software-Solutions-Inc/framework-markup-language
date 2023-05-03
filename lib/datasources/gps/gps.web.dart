// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
@JS('navigator.geolocation') // navigator.geolocation namespace
library jslocation; // library name can be whatever you want

import 'dart:async';
import 'package:fml/log/manager.dart';
import 'package:js/js.dart';
import 'package:fml/system.dart';
import 'iGpsListener.dart';
import 'package:geolocator/geolocator.dart';
import 'payload.dart';
import 'gps.dart';

Gps getReceiver() => Receiver();

class Receiver implements Gps
{
  static final Receiver _singleton = Receiver._initialize();
  List<IGpsListener>? _listeners;
  Position? _location;
  StreamSubscription<Position>? _subscription;
  Payload? last;

  factory Receiver()
  {
    return _singleton;
  }

  Receiver._initialize();

  Future _start() async
  {
    _location = await _determinePosition();
    if (_location != null)
    {
      // Already Subscribed?
      if (_subscription == null)
      {
        // Listen for GPS Changes
        final LocationSettings locationSettings = LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        );
        _subscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
                (Position? position) async {
              try {
                last = Payload(accuracy: position?.accuracy,
                    latitude: position?.latitude,
                    longitude: position?.longitude,
                    altitude: position?.altitude,
                    speed: position?.speed,
                    speedaccuracy: position?.speedAccuracy,
                    heading: position?.heading,
                    epoch: DateTime
                        .now()
                        .millisecondsSinceEpoch,
                    user: System.app?.user.claim('key'),
                    username: System.app?.user.claim('name'));
                await notifyListeners(last!);
              }
              catch(e) {
                Log().debug('GPD Data Point');
                Log().exception(e);
              }
            });
      }
    }
  }

  Future _stop() async
  {
    if (_subscription != null) _subscription?.cancel();
  }

  @override
  registerListener(IGpsListener listener)
  {
    _listeners ??= [];
    if (!_listeners!.contains(listener))
    {
      _listeners!.add(listener);
      _start();
    }
    listener.onGpsData(payload: last);
  }

  @override
  removeListener(IGpsListener listener)
  {
    if ((_listeners != null) && (_listeners!.contains(listener)))
    {
      _listeners!.remove(listener);
      if (_listeners!.isEmpty)
        {
          _listeners = null;
          _stop();
        }
    }
  }

  notifyListeners(Payload data)
  {
    if (_listeners != null) {
      _listeners!.forEach((listener)
      {
        listener.onGpsData(payload: data);
      });
    }
  }
}

Payload? payload;

success(pos)
{
  try
  {
    Log().debug(pos.coords.latitude);
    Log().debug(pos.coords.longitude);
  }
  catch(ex)
  {
    Log().debug("Exception thrown : $ex");
  }
}

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}