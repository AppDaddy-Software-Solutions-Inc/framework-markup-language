// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
@JS('navigator.geolocation') // navigator.geolocation namespace
library jslocation; // library name can be whatever you want

import 'package:fml/log/manager.dart';

import 'package:js/js.dart';
import 'package:fml/system.dart';
import 'iGpsListener.dart';
import 'package:location/location.dart';
import 'payload.dart';
import 'gps.dart';

@JS('getCurrentPosition') // Accessing method getCurrentPosition from       Geolocation API
external void getCurrentPosition(Function success(GeolocationPosition pos));

Gps getReceiver() => Receiver();

class Receiver implements Gps
{
  static final Receiver _singleton = Receiver._initialize();
  List<IGpsListener>? _listeners;
  Location? _location;

  factory Receiver()
  {
    return _singleton;
  }

  Receiver._initialize()
  {
    try
    {
      _location = null;
      if (_location == null) _location = Location();
    }
    catch(e)
    {
      Log().debug("GPS Failed");
    }
  }

  _start()
  {
      Payload? position = getCurrentLocation();
      Log().debug(position.toString());
      if(position != null)
      {
        Payload data = position;
        Log().debug(position.toString());
        notifyListeners(data);
      }
  }

  _stop() {}

  registerListener(IGpsListener listener)
  {
    if (_listeners == null) _listeners = [];
    if (!_listeners!.contains(listener))
    {
      _listeners!.add(listener);
      _start();
    }
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

@JS()
@anonymous
class GeolocationCoordinates {
  external double get latitude;
  external double get longitude;
  external double get altitude;
  external double get accuracy;
  external double get altitudeAccuracy;
  external double get heading;
  external double get speed;

  external factory GeolocationCoordinates(
      {double? latitude,
        double? longitude,
        double? altitude,
        double? accuracy,
        double? altitudeAccuracy,
        double? heading,
        double? speed});
}

@JS()
@anonymous
class GeolocationPosition
{
  external GeolocationCoordinates get coords;
  external factory GeolocationPosition({GeolocationCoordinates? coords});
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

Payload? getCurrentLocation()
{
  getCurrentPosition(allowInterop((pos) => success(pos)));
  GeolocationCoordinates coordinates = GeolocationCoordinates();
  payload = Payload(latitude: coordinates.latitude, longitude: coordinates.latitude, altitude: coordinates.altitude, epoch: DateTime.now().millisecondsSinceEpoch, user: System().setUserProperty('key'), username: System().setUserProperty('name'));
  return payload;
}