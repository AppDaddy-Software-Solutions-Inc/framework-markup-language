// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';

import 'barcode_detector.mobile.dart'
if (dart.library.io)   'barcode_detector.mobile.dart'
if (dart.library.html) 'barcode_detector.web.dart';

import 'package:fml/datasources/detectors/image/detectable_image.stub.dart'
if (dart.library.io)   'package:fml/datasources/detectors/image/detectable_image.mobile.dart'
if (dart.library.html) 'package:fml/datasources/detectors/image/detectable_image.web.dart';

enum BarcodeFormats { unknown, code128, code39, code93, codabar, datamatrix, ean13, ean8, itf, qrcode, upca, upce, pdf417, aztec, ondl}

Map<int, BarcodeFormats> barcodeMap = {
  0   : BarcodeFormats.unknown,
  1   : BarcodeFormats.code128,
  2   : BarcodeFormats.code39,
  4   : BarcodeFormats.code93,
  8   : BarcodeFormats.codabar,
  16  : BarcodeFormats.datamatrix,
  32  : BarcodeFormats.ean13,
  64  : BarcodeFormats.ean8,
  128 : BarcodeFormats.itf,
  256 : BarcodeFormats.qrcode,
  512 : BarcodeFormats.upca,
  1024: BarcodeFormats.upce,
  2048: BarcodeFormats.pdf417,
  4096: BarcodeFormats.aztec,
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
    for (var barcode in payload.barcodes) {
      Map<dynamic,dynamic> map = <dynamic,dynamic>{};
      map["barcode"] = barcode.barcode;
      map["display"] = barcode.display;
      map["format"]  = barcode.format;
      map["type"]    = barcode.type != null ? barcode.type.toString() : "";
      if (barcode.parameters != null) barcode.parameters!.forEach((key, value) => map[key] = value);
      data.add(map);
    }
    return data;
  }
}

abstract class IBarcodeDetector
{
  factory IBarcodeDetector() => getDetector();
  Future<Payload?> detect(DetectableImage image, List<BarcodeFormats>? formats, bool? tryharder, bool? invert);
}

