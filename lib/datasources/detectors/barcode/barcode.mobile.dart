// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' as ML;
import 'barcode.dart' as BARCODE;
import 'package:fml/helper/helper_barrel.dart';

BarcodeDetector getDetector() => BarcodeDetector();

class BarcodeDetector implements BARCODE.BarcodeDetector
{
  static final BarcodeDetector _singleton = BarcodeDetector._initialize();

  static ML.BarcodeScanner? _detector;

  BarcodeDetector._initialize();

  factory BarcodeDetector()
  {
    return _singleton;
  }

  int count = 0;
  Future<BARCODE.Payload?> detect(dynamic detectable, List<BARCODE.BarcodeFormats>? formats, bool? tryharder, bool? invert) async
  {
    try
    {
      BARCODE.Payload? result;

      if (detectable?.image is ML.InputImage)
      {
        // set formats
        List<ML.BarcodeFormat> _formats = [];
        if (formats != null)
          for (BARCODE.BarcodeFormats format in formats)
          {
                 if ((format == BARCODE.BarcodeFormats.AZTEC)      && (!_formats.contains(ML.BarcodeFormat.aztec)))      _formats.add(ML.BarcodeFormat.aztec);
            else if ((format == BARCODE.BarcodeFormats.CODE39)     && (!_formats.contains(ML.BarcodeFormat.code39)))     _formats.add(ML.BarcodeFormat.code39);
            else if ((format == BARCODE.BarcodeFormats.CODE93)     && (!_formats.contains(ML.BarcodeFormat.code93)))     _formats.add(ML.BarcodeFormat.code93);
            else if ((format == BARCODE.BarcodeFormats.CODABAR)    && (!_formats.contains(ML.BarcodeFormat.codabar)))    _formats.add(ML.BarcodeFormat.codabar);
            else if ((format == BARCODE.BarcodeFormats.CODE128)    && (!_formats.contains(ML.BarcodeFormat.code128)))    _formats.add(ML.BarcodeFormat.code128);
            else if ((format == BARCODE.BarcodeFormats.DATAMATRIX) && (!_formats.contains(ML.BarcodeFormat.dataMatrix))) _formats.add(ML.BarcodeFormat.dataMatrix);
            else if ((format == BARCODE.BarcodeFormats.EAN8)       && (!_formats.contains(ML.BarcodeFormat.ean8)))       _formats.add(ML.BarcodeFormat.ean8);
            else if ((format == BARCODE.BarcodeFormats.EAN13)      && (!_formats.contains(ML.BarcodeFormat.ean13)))      _formats.add(ML.BarcodeFormat.ean13);
            else if ((format == BARCODE.BarcodeFormats.ITF)        && (!_formats.contains(ML.BarcodeFormat.itf)))        _formats.add(ML.BarcodeFormat.itf);
            else if ((format == BARCODE.BarcodeFormats.PDF417)     && (!_formats.contains(ML.BarcodeFormat.pdf417)))     _formats.add(ML.BarcodeFormat.pdf417);
            else if ((format == BARCODE.BarcodeFormats.QRCODE)     && (!_formats.contains(ML.BarcodeFormat.qrCode)))     _formats.add(ML.BarcodeFormat.qrCode);
            else if ((format == BARCODE.BarcodeFormats.UPCA)       && (!_formats.contains(ML.BarcodeFormat.upca)))       _formats.add(ML.BarcodeFormat.upca);
            else if ((format == BARCODE.BarcodeFormats.UPCE)       && (!_formats.contains(ML.BarcodeFormat.upce)))       _formats.add(ML.BarcodeFormat.upce);
          }

        // default format
        if (_formats.length == 0) _formats.add(ML.BarcodeFormat.all);

        // build detector
        if (_detector == null) _detector = ML.BarcodeScanner(formats: _formats);

        // process
        Log().debug("Processing image ${++count}");
        var barcodes = await _detector!.processImage(detectable.image);

        // detect
        result = payload(barcodes);

        // debug
        if (result != null) result.barcodes.forEach((barcode) => Log().debug("Found barcode ${barcode.barcode}"));
      }

      return result;
    }
    catch(e)
    {
      Log().exception(e);
      return null;
    }
  }

  BARCODE.Payload? payload(List<ML.Barcode> barcodes)
  {
    if (barcodes.isEmpty) return null;

    BARCODE.Payload payload = BARCODE.Payload();
    barcodes.forEach((barcode)
    {
      BARCODE.Barcode bc = BARCODE.Barcode();
      bc.type    = barcode.type.index;
      bc.format  = S.fromEnum(barcode.format);
      bc.display = barcode.displayValue;
      bc.barcode = barcode.rawValue;
      payload.barcodes.add(bc);
    });
    return payload;
  }
}
