// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:fml/datasources/detectors/rfid/rfid_detector.dart';
import 'package:fml/datasources/zebra/zebra_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'package:zebra_rfid_sdk_plugin/zebra_event_handler.dart';
import 'package:zebra_rfid_sdk_plugin/zebra_rfid_sdk_plugin.dart';

class Reader {
  static final Reader _singleton = Reader._initialize();

  List<IZebraListener>? _listeners;

  Completer<bool> initialized = Completer();

  ReaderConnectionStatus connectionStatus = ReaderConnectionStatus.UnConnection;
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

    try {

      // build event handler
      var handler = ZebraEngineEventHandler(
          readRfidCallback: _onData,
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

  void _onData(List<RfidData> data) async {
    Payload? payload = _fromRfidData(data);
    notifyListeners(payload);
  }

  void _onEvent(String event, Map<String, dynamic> map) async {
    System.toast(event);
  }

  void _onError(ErrorResult error) {

    status = -1;
    statusMessage = "Error connecting to the Zebra RFID Reader. $error";

    Log().error('Zebra Channel Error on Initialize');
  }

  void _onConnectionStatusChange(ReaderConnectionStatus status) {
    connectionStatus = status;
    notifyListenersOfConnectionChange(status == ReaderConnectionStatus.ConnectionRealy);
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

  notifyListenersOfConnectionChange(bool connected) {
    if (_listeners != null) {
      var listeners = _listeners!.where((element) => true);
      for (var listener in listeners) {
        listener.onZebraConnectionStatus(connected);
      }
    }
  }


  Map<String, Tag> _tags = {};

  // creates an rfid Payload from RfidData
  Payload? _fromRfidData(List<RfidData> data) {

    if (data.isEmpty) return null;

    // build the payload
    List<Tag> tags = [];
    for (var rfid in data) {
      Tag tag = Tag();
      tag.id = rfid.tagID;
      tag.antenna = rfid.antennaID;
      tag.rssi = rfid.peakRSSI;
      tag.distance = rfid.relativeDistance;
      tag.count = rfid.count;
      tag.size = rfid.allocatedSize;
      tag.data = rfid.memoryBankData;
      tag.lock = rfid.lockData;
      tag.parameters = null;
      tags.add(tag);
    }

    // set the tags
    for (var tag in tags) {
      _tags[tag.id!] = tag;
    }

    // sort by RSSI - closest the furthest
    var list = _tags.values.toList();
    list.sort((a, b) => (b.rssi ?? 0).compareTo(a.rssi ?? 0));

    // return the payload
    Payload payload = Payload();
    payload.tags.addAll(list);
    return payload;
  }
}
