// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/datasources/detectors/barcode/barcode_detector.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/system.dart';

abstract class IZebraListener
{
  onZebraData({Payload? payload});
}

class Reader
{
  static final Reader _singleton = Reader._initialize();

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
      methodChannel = MethodChannel('co.appdaddy.fml/command');
      scanChannel = EventChannel('co.appdaddy.fml/scan');

      scanChannel!.receiveBroadcastStream().listen(_onEvent, onError: _onError);
      _send("com.symbol.datawedge.api.CREATE_PROFILE", "co.appdaddy.fml");
      _send("com.symbol.datawedge.api.SET_CONFIG", "");
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
      _send("com.symbol.datawedge.api.SOFT_RFID_TRIGGER", "START_SCANNING");
  }

  Reader.stopScan()
  {
      _send("com.symbol.datawedge.api.SOFT_RFID_TRIGGER", "STOP_SCANNING");
  }

  Future<void> _send(String command, String parameter) async
  {
    try
    {
      String argumentAsJson = jsonEncode({"command": command, "parameter": parameter});
      await methodChannel?.invokeMethod('ZEBRARF', argumentAsJson);
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
      for (var listener in listeners) {
        listener.onZebraData(payload: data);
      }
    }
    if (data == null) Log().debug('Zebra Wedge Payload is null');
  }

  Payload? getPayload(Map? result)
  {
    if ((result == null) || (result.isEmpty)) return null;

    String? source  = result.containsKey("source") ? S.toStr(result["source"])?.toUpperCase()  : null;
    System.toast("Source is $source");

    return source == "RFID" ? rfidPayload(result) : barcodePayload(result);
  }

  Payload barcodePayload(Map result)
  {
    System.toast("inside barcode");

    String? barcode = result.containsKey("barcode") ? S.toStr(result["barcode"]) : "";

    String? fmt = result.containsKey("format")  ? S.toStr(result["format"])  : null;
    if (S.isNullOrEmpty(fmt)) fmt = "UNKNOWN";
    fmt = fmt?.trim().toUpperCase().replaceAll("LABEL-TYPE-", "");
    var format = S.fromEnum(S.toEnum(fmt, BarcodeFormats.values) ?? BarcodeFormats.unknown);

    // add barcode to payload
    Payload payload = Payload();
    payload.barcodes.add(Barcode(type: 0, format: format, display: barcode, barcode: barcode));
    return payload;
  }

  Payload? rfidPayload(Map result)
  {
    Payload payload = Payload();

    String? value = result.containsKey("barcode") ? S.toStr(result["barcode"]) : "";
    if (S.isNullOrEmpty(value)) return payload;

    // split barcode into multiple
    var barcodes = value!.split("\n");
    for (var barcode in barcodes)
    {
      barcode = barcode.trim();
      if (!S.isNullOrEmpty(barcode))
      {
        payload.barcodes.add(Barcode(type: 0, format: null, display: barcode, barcode: barcode));
      }
    }
    return payload;
  }
}