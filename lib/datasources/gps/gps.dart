// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'payload.dart';
import 'gps_listener_interface.dart';
import 'package:geolocator/geolocator.dart';

class Gps
{
  List<IGpsListener>? _listeners;
  Position? _location;
  StreamSubscription<Position>? _subscription;
  bool busy = false;
  Payload? last;

  static final Gps _singleton = Gps._initialize();
  factory Gps() => _singleton;

  Gps._initialize();

  Future _start() async
  {
    _location = await _determinePosition();
    if (_location != null)
    {
      // Already Subscribed?
      if (_subscription == null)
      {
        // Listen for GPS Changes
        final LocationSettings locationSettings = _getLocationSettings();

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
                    await notifyListeners(last);
                  }
                  catch(e) {
                    Log().debug('GPD Data Point');
                    Log().exception(e);
                  }
            });
      }
    }
  }

  LocationSettings _getLocationSettings()
  {
    late LocationSettings locationSettings;
    switch (defaultTargetPlatform)
    {
      // case TargetPlatform.android:
      //   locationSettings = AndroidSettings(
      //       accuracy: LocationAccuracy.high,
      //       distanceFilter: 100,
      //       forceLocationManager: true,
      //       intervalDuration: const Duration(seconds: 10),
      //       //(Optional) Set foreground notification config to keep the app alive
      //       //when going to the background
      //       foregroundNotificationConfig: const ForegroundNotificationConfig(
      //         notificationText:
      //         "Example app will continue to receive your location even when you aren't using it",
      //         notificationTitle: "Running in Background",
      //         enableWakeLock: true,
      //       ));
      //   break;
      //
      // case TargetPlatform.iOS:
      // case TargetPlatform.macOS:
      //   locationSettings = AppleSettings(
      //       accuracy: LocationAccuracy.high,
      //       activityType: ActivityType.fitness,
      //       distanceFilter: 100,
      //       pauseLocationUpdatesAutomatically: true,
      //       // Only set to true if our app will be started up in the background.
      //       showBackgroundLocationIndicator: false);
      //   break;

      default:
        locationSettings = const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 100);
    }
    return locationSettings;
  }

  Future _stop() async => _subscription?.cancel();

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
}