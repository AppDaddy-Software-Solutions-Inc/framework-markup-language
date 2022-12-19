// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/datasources/gps/gps.dart';
import 'package:fml/log/manager.dart';

import 'package:location/location.dart';
import 'package:fml/system.dart';
import 'payload.dart';
import 'iGpsListener.dart';

Gps getReceiver() => Receiver();

class Receiver implements Gps
{
  static final Receiver _singleton = Receiver._initialize();
  List<IGpsListener>? _listeners;
  Location? _location;
  StreamSubscription<LocationData>? _subscription;
  bool busy = false;

  Payload? last;

  factory Receiver()
  {
    return _singleton;
  }

  Receiver._initialize()
  {
    try
    {
      _location = Location();
    }
    catch(e)
    {
      Log().debug("GPS Failed");
    }
  }

  Future _start() async
  {
    if (_location != null)
    {
      /////////////////////////
      /* Already Subscribed? */
      /////////////////////////
      if (_subscription == null)
      {
        ////////////////////////////
        /* Listen for GPS Changes */
        ////////////////////////////
        await _location!.requestPermission();

        PermissionStatus permission = await _location!.hasPermission();
        if(permission == PermissionStatus.granted) {
          _location!.changeSettings(accuracy: LocationAccuracy.high,
              interval: 1000,
              distanceFilter: 0);
          _subscription = _location!.onLocationChanged.listen((
              LocationData currentLocation) async
          {
            //////////////////
            /* New Location */
            //////////////////
            try {
              last = Payload(accuracy: currentLocation.accuracy,
                  latitude: currentLocation.latitude,
                  longitude: currentLocation.longitude,
                  altitude: currentLocation.altitude,
                  speed: currentLocation.speed,
                  speedaccuracy: currentLocation.speedAccuracy,
                  heading: currentLocation.heading,
                  epoch: DateTime
                      .now()
                      .millisecondsSinceEpoch,
                  user: System().setUserProperty('key'),
                  username: System().setUserProperty('name'));
              await notifyListeners(last);
            }
            catch (e) {
              Log().debug('GPD Data Point');
              Log().exception(e);
            }
          });
        }
      }
    }
  }

  Future _stop() async
  {
    if (_subscription != null) _subscription?.cancel();
    PermissionStatus permission = await _location!.hasPermission();
    if(permission == PermissionStatus.granted) {
      _location!.changeSettings(accuracy: LocationAccuracy.powerSave,
          interval: 1000,
          distanceFilter: 0);
    }
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

  Future<bool> notifyListeners(Payload? data) async
  {
    _listeners?.forEach((listener)
    {
      listener.onGpsData(payload: data);
    });
    return true;
  }
}