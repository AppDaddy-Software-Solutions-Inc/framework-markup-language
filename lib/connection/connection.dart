import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/phrase.dart';
import 'package:fml/system.dart';

import 'package:fml/connection/connection.mobile.dart'
    if (dart.library.io) 'package:fml/connection/connection.mobile.dart'
    if (dart.library.html) 'package:fml/connection/connection.web.dart';

class Connection {

  static late Connectivity _connection;
  static BooleanObservable? _connected;

  /// initialization info
  static final _initialized  = Completer<bool>();
  static final _initializing = Completer<bool>();
  static Future<bool> get initialized => _initialized.future;

  static Future initialize(BooleanObservable? connected) async {

    // initialize should only run once
    if (_initialized.isCompleted || _initializing.isCompleted) return;

    // signal initializing in progress
    _initializing.complete(true);

    try {
      // set connected observable
      _connected = connected;

      // create connectivity
      _connection = Connectivity();

      // check connectivity
      List<ConnectivityResult> connections = await _connection.checkConnectivity();

      // check internet access
      var isConnected = false;
      if (connections.isNotEmpty) isConnected = await Internet.isConnected();
      _connected?.set(isConnected);

      // notify user
      if (!isConnected) System.toast(Phrases().checkConnection, duration: 3);

      // add connection listener to determine connection
      _connection.onConnectivityChanged.listen(_connectionListener);

    } catch (e) {
      _connected?.set(true);
      Log().debug('Error initializing connectivity');
    }

    // set initialized
    _initialized.complete(true);
  }

  static void _connectionListener(List<ConnectivityResult> connections) async {

    // connections?
    if (connections.isNotEmpty && connections.first != ConnectivityResult.none)
    {
      var isConnected = await Internet.isConnected();
      _connected?.set(isConnected);
    }
    else
    {
      _connected?.set(false);
    }

    // write log message
    Log().info("Connection status changed. Internet is ${_connected?.get() == true ? 'connected' : 'disconnected'}");
  }
}
