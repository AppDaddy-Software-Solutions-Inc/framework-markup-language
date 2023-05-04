// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' as google_barcode;
import 'barcode_detector.dart';
import 'package:fml/helper/common_helpers.dart';

BarcodeDetector getDetector() => BarcodeDetector();

class BarcodeDetector implements IBarcodeDetector
{
  static final BarcodeDetector _singleton = BarcodeDetector._initialize();

  static google_barcode.BarcodeScanner? _detector;

  BarcodeDetector._initialize();
  factory BarcodeDetector() => _singleton;

  int count = 0;
  @override
  Future<Payload?> detect(dynamic detectable, List<BarcodeFormats>? formats, bool? tryharder, bool? invert) async
  {
    try
    {
      Payload? result;

      if (detectable?.image is google_barcode.InputImage)
      {
        // set barcode formats
        List<google_barcode.BarcodeFormat> myFormats = [];
        if (formats != null){
          for (BarcodeFormats format in formats)
          {
                 if ((format == BarcodeFormats.aztec)      && (!myFormats.contains(google_barcode.BarcodeFormat.aztec))) {
                   myFormats.add(google_barcode.BarcodeFormat.aztec);
                 } else if ((format == BarcodeFormats.code39)     && (!myFormats.contains(google_barcode.BarcodeFormat.code39))) {
              myFormats.add(google_barcode.BarcodeFormat.code39);
            } else if ((format == BarcodeFormats.code93)     && (!myFormats.contains(google_barcode.BarcodeFormat.code93))) {
              myFormats.add(google_barcode.BarcodeFormat.code93);
            } else if ((format == BarcodeFormats.codabar)    && (!myFormats.contains(google_barcode.BarcodeFormat.codabar))) {
              myFormats.add(google_barcode.BarcodeFormat.codabar);
            } else if ((format == BarcodeFormats.code128)    && (!myFormats.contains(google_barcode.BarcodeFormat.code128))) {
              myFormats.add(google_barcode.BarcodeFormat.code128);
            } else if ((format == BarcodeFormats.datamatrix) && (!myFormats.contains(google_barcode.BarcodeFormat.dataMatrix))) {
              myFormats.add(google_barcode.BarcodeFormat.dataMatrix);
            } else if ((format == BarcodeFormats.ean8)       && (!myFormats.contains(google_barcode.BarcodeFormat.ean8))) {
              myFormats.add(google_barcode.BarcodeFormat.ean8);
            } else if ((format == BarcodeFormats.ean13)      && (!myFormats.contains(google_barcode.BarcodeFormat.ean13))) {
              myFormats.add(google_barcode.BarcodeFormat.ean13);
            } else if ((format == BarcodeFormats.itf)        && (!myFormats.contains(google_barcode.BarcodeFormat.itf))) {
              myFormats.add(google_barcode.BarcodeFormat.itf);
            } else if ((format == BarcodeFormats.pdf417)     && (!myFormats.contains(google_barcode.BarcodeFormat.pdf417))) {
              myFormats.add(google_barcode.BarcodeFormat.pdf417);
            } else if ((format == BarcodeFormats.qrcode)     && (!myFormats.contains(google_barcode.BarcodeFormat.qrCode))) {
              myFormats.add(google_barcode.BarcodeFormat.qrCode);
            } else if ((format == BarcodeFormats.upca)       && (!myFormats.contains(google_barcode.BarcodeFormat.upca))) {
              myFormats.add(google_barcode.BarcodeFormat.upca);
            } else if ((format == BarcodeFormats.upce)       && (!myFormats.contains(google_barcode.BarcodeFormat.upce))) {
              myFormats.add(google_barcode.BarcodeFormat.upce);
            }
          }}

        // default format
        if (myFormats.isEmpty) myFormats.add(google_barcode.BarcodeFormat.all);

        // build detector
        _detector ??= google_barcode.BarcodeScanner(formats: myFormats);

        // process
        Log().debug("Processing image ${++count}");
        var barcodes = await _detector!.processImage(detectable.image);

        // detect
        result = _buildPayload(barcodes);

        // debug
        if (result != null){ for (var barcode in result.barcodes) {
   Log().debug("Found barcode $barcode");
 }}
      }

      return result;
    }
    catch(e)
    {
      Log().exception(e);
      return null;
    }
  }

  Payload? _buildPayload(List<google_barcode.Barcode> barcodes)
  {
    if (barcodes.isEmpty) return null;

    Payload payload = Payload();
    for (var barcode in barcodes) {
      Barcode bc = Barcode();
      bc.type    = barcode.type.index;
      bc.format  = S.fromEnum(barcode.format);
      bc.display = barcode.displayValue;
      bc.barcode = barcode.rawValue;
      payload.barcodes.add(bc);
    }
    return payload;
  }
}
