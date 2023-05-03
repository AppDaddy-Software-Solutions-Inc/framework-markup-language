// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/log/manager.dart';
import 'package:zxing_lib/oned.dart'   deferred as code39;
import 'package:zxing_lib/pdf417.dart' deferred as pdf417;
import 'package:zxing_lib/qrcode.dart' deferred as qrcode;
import 'package:zxing_lib/zxing.dart'  deferred as zxing;
import 'barcode_detector.dart';
import 'package:fml/helper/common_helpers.dart';

import 'package:fml/datasources/detectors/image/detectable_image.stub.dart'
if (dart.library.io)   'package:fml/datasources/detectors/image/detectable_image.mobile.dart'
if (dart.library.html) 'package:fml/datasources/detectors/image/detectable_image.web.dart';

BarcodeDetector getDetector() => BarcodeDetector();

class BarcodeDetector implements IBarcodeDetector
{
  static final BarcodeDetector _singleton = BarcodeDetector._initialize();

  BarcodeDetector._initialize();

  factory BarcodeDetector() => _singleton;

  @override
  Future<Payload?> detect(DetectableImage detectable, List<BarcodeFormats>? formats, bool? tryharder, bool? invert) async
  {
    try
    {
      Payload? result;

      await zxing.loadLibrary();

      if (detectable.image != null)
      {
        //set barcode format
        formats ??= [];
        if (formats.length == 1)
        {
          if (formats.contains(BarcodeFormats.CODE39)) result = await _code39(detectable.image, tryharder, invert);
          if (formats.contains(BarcodeFormats.PDF417)) result = await _pdf417(detectable.image, tryharder, invert);
          if (formats.contains(BarcodeFormats.ONDL))   result = await _ondl(detectable.image, tryharder, invert);
          if (formats.contains(BarcodeFormats.QRCODE)) result = await _qrcode(detectable.image, tryharder, invert);
        }
        //default barcode format
        else {
          result = await _multi(detectable.image, formats, tryharder, invert);
        }
      }
      return result;
    }
    catch(e)
    {
      Log().info("No barcode found");
      return null;
    }
  }

  // any format
  static dynamic _multiFormatReader;
  static Future<Payload> _multi(dynamic bitmap, List<BarcodeFormats>? formats, bool? tryharder, bool? invert) async
  {
    _multiFormatReader ??= zxing.MultiFormatReader();

    var reader = _multiFormatReader!;

    Map<dynamic, Object> hints   = <dynamic, Object>{};
    hints[zxing.DecodeHintType.TRY_HARDER]    = (tryharder == true);
    hints[zxing.DecodeHintType.ALSO_INVERTED] = (invert == true);
    //hints[DecodeHintType.POSSIBLE_FORMATS] = BarcodeFormats.;

    Log().debug('Multi Decode Start');
    var result = reader.decode(bitmap, hints);
    Log().debug('Multi Decode End');

    return _buildPayload(result);
  }

  // pdf417 format
  static dynamic _pDF417Reader;
  static Future<Payload> _pdf417(dynamic bitmap, bool? tryharder, bool? invert) async
  {
    await pdf417.loadLibrary();

    _pDF417Reader ??= pdf417.PDF417Reader();
    var reader = _pDF417Reader!;

    Map<dynamic, Object> hints   = <dynamic, Object>{};
    hints[zxing.DecodeHintType.TRY_HARDER]    = (tryharder == true);
    hints[zxing.DecodeHintType.ALSO_INVERTED] = (invert == true);

    Log().debug('PDF417 Decode Start');
    var result = reader.decode(bitmap, hints);

    return _buildPayload(result);
  }

  // ontario drivers license
  static Future<Payload> _ondl(dynamic bitmap, bool? tryharder, bool? invert) async
  {
    Payload? payload;
    payload = await _pdf417(bitmap, tryharder, invert);

    for (var barcode in payload.barcodes) {
      if (barcode.barcode!.contains('ANSI 636012'))
      {
        barcode.parameters = <String, String?>{};
        var lines = barcode.barcode!.split(RegExp(r'\r\n|\n\r|\n|\r|DL'));
        for (var line in lines) {
          line = line.trim();
          String code = line.substring(0, 3);
          String value = line.substring(3).trim();

          switch (code) {
            case "DCA":
              barcode.parameters!["classification"] = value;
              break;
            case "DCB":
              barcode.parameters!["restrictions"] = value;
              break;
            case "DCD":
              barcode.parameters!["endorsements"] = value;
              break;
            case "DBA":
              barcode.parameters!["expiration"] =
                  S.toStr(S.toDate(value, format: "yyyyMMdd"));
              break;
            case "DCS":
              barcode.parameters!["last_name"] = S.toTitleCase(value);
              break;
            case "DAC":
              barcode.parameters!["first_name"] = S.toTitleCase(value);
              break;
            case "DCT":
              barcode.parameters!["first_name"] = S.toTitleCase(value);
              break;
            case "DAD":
              barcode.parameters!["middle_name"] = S.toTitleCase(value);
              break;
            case "DBD":
              barcode.parameters!["issue_date"] =
                  S.toStr(S.toDate(value, format: "yyyyMMdd"));
              break;
            case "DBB":
              barcode.parameters!["date_of_birth"] =
                  S.toStr(S.toDate(value, format: "yyyyMMdd"));
              break;
            case "DBC":
              barcode.parameters!["sex"] = (value == "1")
                  ? "M"
                  : (value == "2")
                      ? "F"
                      : "O";
              break;
            case "DAY":
              barcode.parameters!["eye_color"] = value;
              break;
            case "DAU":
              barcode.parameters!["height"] = value;
              break;
            case "DAG":
              barcode.parameters!["address"] = S.toTitleCase(value);
              break;
            case "DAI":
              barcode.parameters!["city"] = S.toTitleCase(value);
              break;
            case "DAJ":
              barcode.parameters!["province"] = "Ontario";
              break;
            case "DAK":
              barcode.parameters!["postal_code"] = value;
              break;
            case "DAQ":
              barcode.parameters!["barcode_number"] = value;
              break;
            case "DCF":
              barcode.parameters!["discrimination"] = value;
              break;
            case "DCG":
              barcode.parameters!["country"] = S.toTitleCase(value);
              break;
            case "DCK":
              barcode.parameters!["inventory_control"] = value;
              break;
            case "ZOZ":
              barcode.parameters!["number"] = value;
              break;
            default:
              break;
          }
        }
      }
    }

    return payload;
  }

  // code 39
  static dynamic _code39Reader;
  static Future<Payload> _code39(dynamic bitmap, bool? tryharder, bool? invert) async
  {
    await code39.loadLibrary();

    _code39Reader ??= code39.Code39Reader(false, true);
    var reader = _code39Reader!;

    Map<dynamic, Object> hints   = <dynamic, Object>{};
    hints[zxing.DecodeHintType.TRY_HARDER]    = (tryharder == true);
    hints[zxing.DecodeHintType.ALSO_INVERTED] = (invert == true);

    Log().debug('Code39 Decode Start');
    var result = reader.decode(bitmap, hints);

    return _buildPayload(result);
  }

  // qr code
  static dynamic _qRCodeReader;
  static Future<Payload> _qrcode(dynamic bitmap, bool? tryharder, bool? invert) async
  {
    // load deferred library
    await qrcode.loadLibrary();

    _qRCodeReader ??= qrcode.QRCodeReader();
    var reader = _qRCodeReader!;

    Map<dynamic, Object> hints   = <dynamic, Object>{};
    hints[zxing.DecodeHintType.TRY_HARDER]    = (tryharder == true);
    hints[zxing.DecodeHintType.ALSO_INVERTED] = (invert == true);

    Log().debug('QR Decode Start');
    var result = reader.decode(bitmap, hints);

    return _buildPayload(result);
  }

  static Payload _buildPayload(dynamic result)
  {
    Barcode barcode = Barcode();
    barcode.barcode = result.text;
    barcode.format = S.fromEnum(result.barcodeFormat);

    Payload payload = Payload();
    payload.barcodes.add(barcode);

    String msg = 'format: ${barcode.format!} barcode: ${barcode.barcode!}';
    Log().debug(msg);
    return payload;
  }
}
