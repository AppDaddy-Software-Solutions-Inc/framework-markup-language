// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/datasources/detectors/barcode/barcode.dart' as BARCODE;
import 'package:fml/helper/helper_barrel.dart';

abstract class IZebraListener
{
  onZebraData({BARCODE.Payload? payload});
}

class Reader
{
  static final Reader _singleton = new Reader._initialize();

  MethodChannel? methodChannel;
  EventChannel?  scanChannel;

  List<IZebraListener>? _listeners;

  factory Reader()
  {
    return _singleton;
  }

  Reader._initialize()
  {
    try
    {
      if (methodChannel == null) methodChannel = MethodChannel('co.appdaddy.fml/command');
      if (scanChannel   == null) scanChannel   = EventChannel('co.appdaddy.fml/scan');

      scanChannel!.receiveBroadcastStream().listen(_onEvent, onError: _onError);
      _send("com.symbol.datawedge.api.CREATEPROFILE", "co.appdaddy.fml");
    }
    catch(e)
    {
      Log().exception('Zebra Channel Error on Initialize $e');
    }
  }

  void _onEvent(event)
  {
      Map? result = jsonDecode(event);
      BARCODE.Payload? payload = getPayload(result);
      notifyListeners(payload);
  }

  void _onError(Object error)
  {
  }

  Reader.startScan()
  {
      _send("com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "START_SCANNING");
  }

  Reader.stopScan()
  {
      _send("com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "STOP_SCANNING");
  }

  Future<void> _send(String command, String parameter) async
  {
    try
    {
      String argumentAsJson = jsonEncode({"command": command, "parameter": parameter});
      await methodChannel!.invokeMethod('ZEBRA', argumentAsJson);
    }
    catch(e)
    {
      Log().exception('Zebra Wedge Error: $e');
    }
  }

  registerListener(IZebraListener listener)
  {
    if (_listeners == null) _listeners = [];
    if (!_listeners!.contains(listener)) _listeners!.add(listener);
  }

  removeListener(IZebraListener listener)
  {
    if ((_listeners != null) && (_listeners!.contains(listener)))
    {
      _listeners!.remove(listener);
      if (_listeners!.isEmpty) _listeners = null;
    }
  }

  notifyListeners(BARCODE.Payload? data)
  {
    if (_listeners != null && data != null)
    {
      var listeners = _listeners!.where((element) => true);
      listeners.forEach((listener) => listener.onZebraData(payload: data));
    }
    if (data == null) Log().debug('Zebra Wedge Payload is null');
  }

  BARCODE.Payload? getPayload(Map? barcode)
  {
    if ((barcode == null) || (barcode.isEmpty)) return null;

    BARCODE.Payload payload = BARCODE.Payload();
    BARCODE.Barcode bc = BARCODE.Barcode();

    String? display = barcode.containsKey("barcode") ? S.toStr(barcode["barcode"]) : "";

    String? format = barcode.containsKey("format") ? S.toStr(barcode["format"]) : null;
    if (S.isNullOrEmpty(format)) format = "UNKNOWN";
    format = format!.trim().toUpperCase().replaceAll("LABEL-TYPE-", "");

    var fmt = S.toEnum(format, BARCODE.BarcodeFormats.values);
    if (fmt == null) fmt = BARCODE.BarcodeFormats.UNKNOWN;

    bc.type    = 0;
    bc.format  = S.fromEnum(fmt);
    bc.display = display;
    bc.barcode = display;
    payload.barcodes.add(bc);
    return payload;
  }
}