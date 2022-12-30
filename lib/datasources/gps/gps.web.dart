// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
@JS('navigator.geolocation') // navigator.geolocation namespace
library jslocation; // library name can be whatever you want

import 'dart:async';
import 'package:fml/log/manager.dart';
import 'package:js/js.dart';
import 'package:fml/system.dart';
import 'iGpsListener.dart';
import 'package:location/location.dart';
import 'payload.dart';
import 'gps.dart';

Gps getReceiver() => Receiver();

class Receiver implements Gps
{
  static final Receiver _singleton = Receiver._initialize();
  List<IGpsListener>? _listeners;
  LocationData? _location;
  StreamSubscription<LocationData>? _subscription;
  Payload? last;

  factory Receiver()
  {
    return _singleton;
  }

  Receiver._initialize();

  Future _start() async
  {
    _location = await getCurrentLocation();
    if (_location != null)
    {
      if (_subscription == null)
      {
        _subscription = onLocationChanged(inBackground: false)
            .listen((LocationData currentLocation) async {
              try {
                last = Payload(accuracy: currentLocation.accuracy,
                    latitude: currentLocation.latitude,
                    longitude: currentLocation.longitude,
                    altitude: currentLocation.altitude,
                    speed: currentLocation.speed,
                    speedaccuracy: currentLocation.speedAccuracy,
                    heading: currentLocation.bearing,
                    epoch: DateTime
                        .now()
                        .millisecondsSinceEpoch,
                    user: System().setUserProperty('key'),
                    username: System().setUserProperty('name'));
                await notifyListeners(last!);
              }
              catch (e) {
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

  registerListener(IGpsListener listener)
  {
    if (_listeners == null) _listeners = [];
    if (!_listeners!.contains(listener))
    {
      _listeners!.add(listener);
      _start();
    }
    listener.onGpsData(payload: last);
  }

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
    if (_listeners != null)
      _listeners!.forEach((listener)
      {
        listener.onGpsData(payload: data);
      });
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
    Log().debug("Exception thrown : " + ex.toString());
  }
}

Future<LocationData?>? getCurrentLocation() async {
  try {
    final location = await getLocation();
    return location;
  }
  catch(e) {
    return null;
  }
}