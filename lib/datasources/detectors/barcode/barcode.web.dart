// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/datasources/detectors/detectable/detectable.dart';
import 'package:fml/log/manager.dart';
import 'package:zxing_lib/oned.dart';
import 'package:zxing_lib/pdf417.dart';
import 'package:zxing_lib/qrcode.dart';
import 'package:zxing_lib/zxing.dart';
import 'barcode.dart' as BARCODE;
import 'package:fml/helper/helper_barrel.dart';

BarcodeDetector getDetector() => BarcodeDetector();

class BarcodeDetector implements BARCODE.BarcodeDetector {
  static final BarcodeDetector _singleton = BarcodeDetector._initialize();

  BarcodeDetector._initialize();

  factory BarcodeDetector() {
    return _singleton;
  }

  Future<BARCODE.Payload?> detect(
      DetectableImage detectable,
      List<BARCODE.BarcodeFormats>? formats,
      bool? tryharder,
      bool? invert) async {
    try {
      BARCODE.Payload? result;

      if (detectable.image is BinaryBitmap) {
        //set barcode format
        if (formats == null) formats = [];
        if (formats.length == 1) {
          if (formats.contains(BARCODE.BarcodeFormats.CODE39))
            result = await _code39(detectable.image, tryharder, invert);
          if (formats.contains(BARCODE.BarcodeFormats.PDF417))
            result = await _pdf417(detectable.image, tryharder, invert);
          if (formats.contains(BARCODE.BarcodeFormats.ONDL))
            result = await _ondl(detectable.image, tryharder, invert);
          if (formats.contains(BARCODE.BarcodeFormats.QRCODE))
            result = await _qrcode(detectable.image, tryharder, invert);
        }

        //default barcode format
        else
          result = await _multi(detectable.image, formats, tryharder, invert);
      }

      return result;
    } catch (e) {
      Log().exception(e);
      return null;
    }
  }

  static MultiFormatReader? _multiFormatReader;
  static Future<BARCODE.Payload> _multi(
      BinaryBitmap bitmap,
      List<BARCODE.BarcodeFormats>? formats,
      bool? tryharder,
      bool? invert) async {
    Result result;

    if (_multiFormatReader == null) _multiFormatReader = MultiFormatReader();
    MultiFormatReader reader = _multiFormatReader!;

    Map<DecodeHintType, dynamic> hints = Map<DecodeHintType, dynamic>();
    hints[DecodeHintType.TRY_HARDER] = (tryharder == true);
    hints[DecodeHintType.ALSO_INVERTED] = (invert == true);
    //hints[DecodeHintType.POSSIBLE_FORMATS] = BarcodeFormats.;

    Log().debug('Multi Decode Start');
    result = reader.decode(bitmap, hints as Map<DecodeHintType, Object>?);

    return getPayload(result);
  }

  static PDF417Reader? _pDF417Reader;
  static Future<BARCODE.Payload> _pdf417(
      BinaryBitmap bitmap, bool? tryharder, bool? invert) async {
    Result result;

    if (_pDF417Reader == null) _pDF417Reader = PDF417Reader();
    PDF417Reader reader = _pDF417Reader!;

    /**********/
    /* Decode */
    /**********/
    Map<DecodeHintType, dynamic> hints = Map<DecodeHintType, dynamic>();
    hints[DecodeHintType.TRY_HARDER] = (tryharder == true);
    hints[DecodeHintType.ALSO_INVERTED] = (invert == true);

    Log().debug('PDF417 Decode Start');
    result = reader.decode(bitmap, hints as Map<DecodeHintType, Object>?);

    return getPayload(result);
  }

  static Future<BARCODE.Payload> _ondl(
      BinaryBitmap bitmap, bool? tryharder, bool? invert) async {
    BARCODE.Payload? payload;

    payload = await _pdf417(bitmap, tryharder, invert);

    payload.barcodes.forEach((barcode) {
      if (barcode.barcode!.contains('ANSI 636012')) {
        barcode.parameters = new Map<String, String?>();
        var lines = barcode.barcode!.split(new RegExp(r'\r\n|\n\r|\n|\r|DL'));
        lines.forEach((line) {
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
        });
      }
    });

    return payload;
  }

  static Code39Reader? _code39Reader;
  static Future<BARCODE.Payload> _code39(
      BinaryBitmap bitmap, bool? tryharder, bool? invert) async {
    Result result;

    if (_code39Reader == null) _code39Reader = Code39Reader(false, true);
    var reader = _code39Reader!;

    ////////////
    /* Decode */
    ////////////
    Map<DecodeHintType, dynamic> hints = Map<DecodeHintType, dynamic>();
    hints[DecodeHintType.TRY_HARDER] = (tryharder == true);
    hints[DecodeHintType.ALSO_INVERTED] = (invert == true);

    Log().debug('Code39 Decode Start');
    result = reader.decode(bitmap, hints as Map<DecodeHintType, Object>?);

    return getPayload(result);
  }

  static QRCodeReader? _qRCodeReader;
  static Future<BARCODE.Payload> _qrcode(
      BinaryBitmap bitmap, bool? tryharder, bool? invert) async {
    Result result;

    if (_qRCodeReader == null) _qRCodeReader = QRCodeReader();
    var reader = _qRCodeReader!;

    ////////////
    /* Decode */
    ////////////
    Map<DecodeHintType, dynamic> hints = Map<DecodeHintType, dynamic>();
    hints[DecodeHintType.TRY_HARDER] = (tryharder == true);
    hints[DecodeHintType.ALSO_INVERTED] = (invert == true);

    Log().debug('QR Decode Start');
    result = reader.decode(bitmap, hints as Map<DecodeHintType, Object>?);

    return getPayload(result);
  }

  static BARCODE.Payload getPayload(Result result) {
    BARCODE.Barcode barcode = BARCODE.Barcode();
    barcode.barcode = result.text;
    barcode.format = S.fromEnum(result.barcodeFormat);

    BARCODE.Payload payload = BARCODE.Payload();
    payload.barcodes.add(barcode);

    String msg = 'format: ' + barcode.format! + ' barcode: ' + barcode.barcode!;
    // DialogService().show(title: 'Found Barcode', description:  msg);
    Log().debug(msg);

    return payload;
  }
}
