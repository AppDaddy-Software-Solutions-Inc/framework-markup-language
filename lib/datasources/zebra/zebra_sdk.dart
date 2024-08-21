// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:convert';
import 'package:fml/datasources/zebra/zebra_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:zebra_rfid_sdk_plugin/zebra_event_handler.dart';
import 'package:zebra_rfid_sdk_plugin/zebra_rfid_sdk_plugin.dart';

import '../detectors/rfid/rfid_detector.dart';

class Reader {
  static final Reader _singleton = Reader._initialize();

  List<IZebraListener>? _listeners;

  Completer<bool> initialized = Completer();
  Completer<bool> connected = Completer();

  int status = 0;
  String statusMessage = "";

  String? platform;

  factory Reader() {
    return _singleton;
  }

  Reader._initialize() {
    _init();
  }

  Future _init() async {

    if (initialized.isCompleted) return;
    connected = Completer();

    try {

      // get the platform version
      platform = await ZebraRfidSdkPlugin.platformVersion;

      // build event handler
      var handler = ZebraEngineEventHandler(
          readRfidCallback: _onEvent,
          errorCallback: _onError,
          connectionStatusCallback: _onConnectionStatusChange);

      // set the handler
      ZebraRfidSdkPlugin.setEventHandler(handler);

      // connect to the reader
      ZebraRfidSdkPlugin.connect();

      status = 200;
      statusMessage = "Connected to Zebra RFID Reader";

    } catch (e) {

      status = -1;
      statusMessage = "Error initializing the Zebra RFID Reader. $e";
      Log().error('Zebra Error on Initialize');
      Log().exception(e);
    }

    // set initialized
    initialized.complete(true);
  }

  void _onEvent(List<RfidData> data) async {
    Payload? payload = _fromRfidData(data);
    notifyListeners(payload);
  }

  void _onError(Object error) {

    connected.complete(false);
    status = -1;
    statusMessage = "Error connecting to the Zebra RFID Reader. $error";

    Log().error('Zebra Channel Error on Initialize');
  }

  void _onConnectionStatusChange(Object error) {
    Log().error('Zebra Channel Error on Initialize');
  }

  registerListener(IZebraListener listener) {
    _listeners ??= [];
    if (!_listeners!.contains(listener)) _listeners!.add(listener);
  }

  removeListener(IZebraListener listener) {
    if ((_listeners != null) && (_listeners!.contains(listener))) {
      _listeners!.remove(listener);
      if (_listeners!.isEmpty) _listeners = null;
    }
  }

  notifyListeners(Payload? data) {
    if (_listeners != null && data != null) {
      var listeners = _listeners!.where((element) => true);
      for (var listener in listeners) {
        listener.onZebraData(payload: data);
      }
    }
    if (data == null) Log().debug('Zebra Wedge Payload is null');
  }

  // creates an rfid Payload from RfidData
  Payload? _fromRfidData(List<RfidData> data) {

    if (data.isEmpty) return null;

    // build the payload
    Payload payload = Payload();
    for (var rfid in data) {
      Tag tag = Tag();
      tag.id = rfid.tagID;
      tag.antenna = rfid.antennaID;
      tag.rssi = rfid.peakRSSI;
      tag.distance = rfid.relativeDistance;
      tag.count = (rfid.count ?? 0) + 1;
      tag.size = rfid.allocatedSize;
      tag.data = rfid.memoryBankData;
      tag.lock = rfid.lockData;
      tag.parameters = null;
    }

    return payload;
  }
}
