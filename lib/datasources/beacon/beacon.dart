// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:io';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';

abstract class IBeaconListener
{
  onBeaconData(List<Beacon> beacons);
}

class Reader
{
  final _regions = <Region>[];
  static final Reader _singleton = Reader._initialize();
  StreamSubscription? _detector;

  final List<IBeaconListener> _listeners = [];

  final Completer _initialized = Completer();

  factory Reader()
  {
    return _singleton;
  }

  Reader._initialize()
  {
    _initializeScanner();
  }

  _initializeScanner() async
  {
    bool ok = true;
    try
    {
      // initialize the scanner;
      await flutterBeacon.initializeScanning;

      if (Platform.isIOS)
      {
        _regions.add(Region(identifier: 'Apple Airlocate', proximityUUID: 'E2C56DB5-DFFB-48D2-B060-D0F5A71096E0'));
      }
      else
      {
        // android platform, it can ranging out of beacon that filter all of Proximity UUID
        _regions.add(Region(identifier: 'com.beacon'));
      }
    }
    catch(e)
    {
      ok = false;

      System.toast("Beacons detection is not supported on this platform");

      // library failed to initialize, check code and message
      Log().error("Error initializing beacon scanner. Error is $e");
    }

    // initialized
    _initialized.complete(ok);
  }

  void _onData(RangingResult result)
  {
    for (var listener in _listeners) {
      listener.onBeaconData(result.beacons);
    }
  }

  void _onDone()
  {
    Log().debug('BEACON Scanner -> Done');
  }

  void _onError(error)
  {
    Log().debug('BEACON Scanner -> Error is $error');
  }

  // Start Scanning
  void start() async
  {
    Log().debug('BEACON Scanner-> Starting');

    // to start ranging beacons
    bool ok = await _initialized.future;
    if (_detector == null && ok) _detector = flutterBeacon.ranging(_regions).listen(_onData, onError: _onError, onDone: _onDone);
  }

  void stop()
  {
    Log().debug('BEACON Scanner -> Stopping');
    if (_detector != null) _detector!.cancel();
    _detector = null;
  }

  registerListener(IBeaconListener listener) async
  {
    if (!_listeners.contains(listener)) _listeners.add(listener);
    start();
  }

  removeListener(IBeaconListener listener) async
  {
    if (_listeners.contains(listener)) _listeners.remove(listener);
    if (_listeners.isEmpty) stop();
  }
}