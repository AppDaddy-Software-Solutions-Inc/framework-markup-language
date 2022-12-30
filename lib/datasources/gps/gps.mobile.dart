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
  LocationData? _location;
  StreamSubscription<LocationData>? _subscription;
  bool busy = false;

  Payload? last;

  factory Receiver()
  {
    return _singleton;
  }

  Receiver._initialize();

  Future _start() async
  {
    if (_location != null)
    {
      // Already Subscribed?
      if (_subscription == null)
      {
        // Listen for GPS Changes
        _subscription = onLocationChanged(inBackground: false)
            .listen((LocationData currentLocation) async {
          // android notification
          // await updateBackgroundNotification(
          //   subtitle:
          //   'Location: ${currentLocation.latitude}, ${currentLocation.longitude}',
          //   onTapBringToFront: true,
          // );
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

  Future<bool> notifyListeners(Payload? data) async
  {
    _listeners?.forEach((listener)
    {
      listener.onGpsData(payload: data);
    });
    return true;
  }
}