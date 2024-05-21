// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' as mlkit
  show InputImage, BarcodeScanner, BarcodeFormat, Barcode;
import 'barcode_detector.dart';
import 'package:fml/helpers/helpers.dart';

class BarcodeDetector implements IBarcodeDetector {

  static final BarcodeDetector _singleton = BarcodeDetector._initialize();
  factory BarcodeDetector() => _singleton;

  static mlkit.BarcodeScanner? _detector;

  BarcodeDetector._initialize();

  int count = 0;
  @override
  Future<Payload?> detect(dynamic detectable,
      List<BarcodeFormats>? formats,
      bool? tryharder, bool? invert) async {

    if (detectable == null) return null;
    if (detectable.image is! mlkit.InputImage) return null;

    try {
      // get barcode formats
      var fmts = _getBarcodeFormats(formats);

      // build detector
      _detector ??= mlkit.BarcodeScanner(formats: fmts);

      // process
      Log().debug("Processing image ${++count}");
      var barcodes = await _detector!.processImage(detectable.image);

      // detect
      return _buildPayload(barcodes);
    }

    catch (e) {
      Log().exception(e);
      return null;
    }
  }


  List<mlkit.BarcodeFormat> _getBarcodeFormats(List<BarcodeFormats>? formats) {

    // return all formats
    if (formats == null) return [mlkit.BarcodeFormat.all];

    List<mlkit.BarcodeFormat> list = [];
    for (BarcodeFormats format in formats) {
      switch(format) {
        case BarcodeFormats.aztec:
          if (!list.contains(mlkit.BarcodeFormat.aztec)) {
            list.add(mlkit.BarcodeFormat.aztec);
          }
          break;

        case BarcodeFormats.code39:
          if (!list.contains(mlkit.BarcodeFormat.code39)) {
            list.add(mlkit.BarcodeFormat.code39);
          }
          break;

        case BarcodeFormats.code93:
          if (!list.contains(mlkit.BarcodeFormat.code93)) {
            list.add(mlkit.BarcodeFormat.code93);
          }
          break;

        case BarcodeFormats.codabar:
          if (!list.contains(mlkit.BarcodeFormat.codabar)) {
            list.add(mlkit.BarcodeFormat.codabar);
          }
          break;

        case BarcodeFormats.code128:
          if (!list.contains(mlkit.BarcodeFormat.code128)) {
            list.add(mlkit.BarcodeFormat.code128);
          }
          break;

        case BarcodeFormats.datamatrix:
          if (!list.contains(mlkit.BarcodeFormat.dataMatrix)) {
            list.add(mlkit.BarcodeFormat.dataMatrix);
          }
          break;

        case BarcodeFormats.ean8:
          if (!list.contains(mlkit.BarcodeFormat.ean8)) {
            list.add(mlkit.BarcodeFormat.ean8);
          }
          break;

        case BarcodeFormats.ean13:
          if (!list.contains(mlkit.BarcodeFormat.ean13)) {
            list.add(mlkit.BarcodeFormat.ean13);
          }
          break;

        case BarcodeFormats.itf:
          if (!list.contains(mlkit.BarcodeFormat.itf)) {
            list.add(mlkit.BarcodeFormat.itf);
          }
          break;

        case BarcodeFormats.ondl:
          break;

        case BarcodeFormats.pdf417:
          if (!list.contains(mlkit.BarcodeFormat.pdf417)) {
            list.add(mlkit.BarcodeFormat.pdf417);
          }
          break;

        case BarcodeFormats.qrcode:
          if (!list.contains(mlkit.BarcodeFormat.qrCode)) {
            list.add(mlkit.BarcodeFormat.qrCode);
          }
          break;

        case BarcodeFormats.upca:
          if (!list.contains(mlkit.BarcodeFormat.upca)) {
            list.add(mlkit.BarcodeFormat.upca);
          }
          break;

        case BarcodeFormats.upce:
          if (!list.contains(mlkit.BarcodeFormat.upce)) {
            list.add(mlkit.BarcodeFormat.upce);
          }

        case BarcodeFormats.unknown:
          break;
      }
    }

    // default format
    if (list.isEmpty) list.add(mlkit.BarcodeFormat.all);

    return list;
  }

  Payload? _buildPayload(List<mlkit.Barcode> barcodes) {
    if (barcodes.isEmpty) return null;

    Payload payload = Payload();
    for (var barcode in barcodes) {
      Barcode bc = Barcode();
      bc.type = barcode.type.index;
      bc.format = fromEnum(barcode.format);
      bc.display = barcode.displayValue;
      bc.barcode = barcode.rawValue;
      payload.barcodes.add(bc);
    }
    return payload;
  }
}
