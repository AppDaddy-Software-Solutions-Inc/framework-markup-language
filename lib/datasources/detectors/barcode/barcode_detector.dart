// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';

import 'barcode_detector.mobile.dart'
if (dart.library.io)   'barcode_detector.mobile.dart'
if (dart.library.html) 'barcode_detector.web.dart';

import 'package:fml/datasources/detectors/image/detectable_image.stub.dart'
if (dart.library.io)   'package:fml/datasources/detectors/image/detectable_image.mobile.dart'
if (dart.library.html) 'package:fml/datasources/detectors/image/detectable_image.web.dart';

enum BarcodeFormats { UNKNOWN, CODE128, CODE39, CODE93, CODABAR, DATAMATRIX, EAN13, EAN8, ITF, QRCODE, UPCA, UPCE, PDF417, AZTEC, ONDL}

Map<int, BarcodeFormats> barcodeMap = {
  0   : BarcodeFormats.UNKNOWN,
  1   : BarcodeFormats.CODE128,
  2   : BarcodeFormats.CODE39,
  4   : BarcodeFormats.CODE93,
  8   : BarcodeFormats.CODABAR,
  16  : BarcodeFormats.DATAMATRIX,
  32  : BarcodeFormats.EAN13,
  64  : BarcodeFormats.EAN8,
  128 : BarcodeFormats.ITF,
  256 : BarcodeFormats.QRCODE,
  512 : BarcodeFormats.UPCA,
  1024: BarcodeFormats.UPCE,
  2048: BarcodeFormats.PDF417,
  4096: BarcodeFormats.AZTEC,
};

class Barcode
{
  int?    type;
  String? barcode;
  String? display;
  String? format;
  Map<String, String?>? parameters;
}

class Payload
{
  final List<Barcode> barcodes = [];
  Payload({List<Barcode>? barcodes})
  {
    if (barcodes != null) this.barcodes.addAll(barcodes);
  }

  static Data toData(Payload payload)
  {
    Data data = Data();
    payload.barcodes.forEach((barcode)
    {
      Map<dynamic,dynamic> map = <dynamic,dynamic>{};
      map["barcode"] = barcode.barcode;
      map["display"] = barcode.display;
      map["format"]  = barcode.format;
      map["type"]    = barcode.type != null ? barcode.type.toString() : "";
      if (barcode.parameters != null) barcode.parameters!.forEach((key, value) => map[key] = value);
      data.add(map);
    });
    return data;
  }
}

abstract class IBarcodeDetector
{
  factory IBarcodeDetector() => getDetector();
  Future<Payload?> detect(DetectableImage image, List<BarcodeFormats>? formats, bool? tryharder, bool? invert);
}

