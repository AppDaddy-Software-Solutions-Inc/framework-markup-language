// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/datasources/detectors/barcode/barcode_detector.dart';
import 'package:fml/helper/common_helpers.dart';

abstract class IZebraListener
{
  onZebraData({Payload? payload});
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
      methodChannel ??= MethodChannel('co.appdaddy.fml/command');
      scanChannel ??= EventChannel('co.appdaddy.fml/scan');

      scanChannel!.receiveBroadcastStream().listen(_onEvent, onError: _onError);
      _send("com.symbol.datawedge.api.CREATEPROFILE", "co.appdaddy.fml");
    }
    catch(e)
    {
      Log().error('Zebra Channel Error on Initialize');
      Log().exception(e);
    }
  }

  void _onEvent(event)
  {
      Map? result = jsonDecode(event);
      Payload? payload = getPayload(result);
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
      Log().error('Zebra Wedge Error');
      Log().exception(e);
    }
  }

  registerListener(IZebraListener listener)
  {
    _listeners ??= [];
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

  notifyListeners(Payload? data)
  {
    if (_listeners != null && data != null)
    {
      var listeners = _listeners!.where((element) => true);
      listeners.forEach((listener) => listener.onZebraData(payload: data));
    }
    if (data == null) Log().debug('Zebra Wedge Payload is null');
  }

  Payload? getPayload(Map? barcode)
  {
    if ((barcode == null) || (barcode.isEmpty)) return null;

    Payload payload = Payload();
    Barcode bc = Barcode();

    String? display = barcode.containsKey("barcode") ? S.toStr(barcode["barcode"]) : "";

    String? format = barcode.containsKey("format") ? S.toStr(barcode["format"]) : null;
    if (S.isNullOrEmpty(format)) format = "UNKNOWN";
    format = format!.trim().toUpperCase().replaceAll("LABEL-TYPE-", "");

    BarcodeFormats fmt = S.toEnum(format, BarcodeFormats.values) ?? BarcodeFormats.UNKNOWN;

    bc.type    = 0;
    bc.format  = S.fromEnum(fmt);
    bc.display = display;
    bc.barcode = display;
    payload.barcodes.add(bc);
    return payload;
  }
}