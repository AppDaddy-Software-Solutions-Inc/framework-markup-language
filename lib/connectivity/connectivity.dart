import 'package:connectivity_plus/connectivity_plus.dart' as ConnectivityPlus;
import 'package:fml/log/manager.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/phrase.dart';
import 'package:fml/system.dart';

import 'package:fml/connectivity/connectivity.mobile.dart'
if (dart.library.io)   'package:fml/connectivity/connectivity.mobile.dart'
if (dart.library.html) 'package:fml/connectivity/connectivity.web.dart';

class Connectivity
{
  late final ConnectivityPlus.Connectivity connection;
  late final BooleanObservable connected;

  static final Connectivity _singleton = Connectivity._internal();
  Connectivity._internal() {}

  factory Connectivity(BooleanObservable connected)
  {
    _singleton.connected = connected;
    return _singleton;
  }

  Future initialize() async
  {
    try
    {
      // create connectivity
      connection = ConnectivityPlus.Connectivity();

      // check connectivity
      ConnectivityPlus.ConnectivityResult connectionType = await connection.checkConnectivity();

      // check internet access
      if (connectionType != ConnectivityPlus.ConnectivityResult.none)
      {
        var isConnected = await Internet.isConnected();
        connected.set(isConnected);
      }
      else
      {
        System.toast(Phrases().checkConnection, duration: 3);
      }

      // Add connection listener to determine connection
      connection.onConnectivityChanged.listen((connectionType) async
      {
        if (connectionType != ConnectivityPlus.ConnectivityResult.none)
        {
          var isConnected = await Internet.isConnected();
          connected.set(isConnected);
        }
        else
        {
          connected.set(false);
        }

        Log().info("Connection status changed. Connection type: $connectionType. Internet is ${(connected.get() == true) ? 'connected' : 'disconnected'}");
      });

      Log().debug('initConnectivity status: $connected');
    }
    catch (e)
    {
      connected.set(false);
      Log().debug('Error initializing connectivity');
    }
  }
}