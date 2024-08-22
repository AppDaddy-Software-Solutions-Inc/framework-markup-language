// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fml/datasources/zebra/zebra_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/datasources/detectors/barcode/barcode_detector.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/system.dart';

class Reader {
  static final Reader _singleton = Reader._initialize();

  MethodChannel? methodChannel;
  EventChannel? scanChannel;

  Completer<bool> initialized = Completer();
  int status = 0;
  String statusMessage = "";

  List<IZebraListener>? _listeners;

  factory Reader() {
    return _singleton;
  }

  Reader._initialize() {
    _init();
  }

  void _init() {

    if (initialized.isCompleted) return;

    try {

      // create method channel
      methodChannel ??= const MethodChannel('dev.fml.zebra/command');

      // create scan channel
      scanChannel ??= const EventChannel('dev.fml.zebra/scan');

      // listen for scan events
      scanChannel!.receiveBroadcastStream().listen(_onEvent, onError: _onError);

      // setup the profile
      _send("com.symbol.datawedge.api.CREATEPROFILE", "dev.fml.zebra");

      status = 200;
      statusMessage = "Connected to Zebra RFID Reader";

    } catch (e) {

      status = -1;
      statusMessage = "Error connecting to Zebra RFID Reader. $e";
      Log().error('Zebra Error on Initialize');
      Log().exception(e);
    }

    // set initialized
    initialized.complete(true);
  }


  void _onEvent(event) {
    Map? result = jsonDecode(event);
    Payload? payload = getPayload(result);
    notifyListeners(payload);
  }

  void _onError(Object error) {
    Log().error('Zebra Channel Error on Initialize, $error');
  }

  startScan() {
    _send("com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "START_SCANNING");
  }

  stopScan() {
    _send("com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "STOP_SCANNING");
  }

  Future<void> _send(String command, String parameter) async {
    try {
      String argumentAsJson =
          Json.encode({"command": command, "parameter": parameter});
      methodChannel?.invokeMethod('ZEBRA', argumentAsJson);
    } catch (e) {
      Log().error('Zebra Wedge Error');
      Log().exception(e);
    }
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

  Payload? getPayload(Map? result) {
    if ((result == null) || (result.isEmpty)) return null;

    Payload payload = Payload();

    // barcode
    String barcode =
        (result.containsKey("barcode") ? toStr(result["barcode"]) : null) ?? "";

    // barcode format
    String? format =
        (result.containsKey("format") ? toStr(result["format"]) : null)
            ?.trim()
            .toLowerCase()
            .replaceAll("label-type-", "");

    // source
    String? source =
        result.containsKey("source") ? toStr(result["source"]) : "";

    // get barcode(s) - RFID concatenates barcodes together and seperates by a newline
    var barcodes = LineSplitter.split(barcode);
    for (var barcode in barcodes) {
      barcode = barcode.trim();
      if (!isNullOrEmpty(barcode)) {
        Barcode bc = Barcode();
        bc.type = 0;
        bc.source = source;
        bc.format = fromEnum(
            toEnum(format, BarcodeFormats.values) ?? BarcodeFormats.unknown);
        bc.display = barcode;
        bc.barcode = barcode;
        payload.barcodes.add(bc);
      }
    }

    if (kDebugMode) {
      System.toast("Barcode(s): ${payload.barcodes.length}");
    }

    return payload;
  }
}
