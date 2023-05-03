// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' as ML;
import 'barcode_detector.dart';
import 'package:fml/helper/common_helpers.dart';

BarcodeDetector getDetector() => BarcodeDetector();

class BarcodeDetector implements IBarcodeDetector
{
  static final BarcodeDetector _singleton = BarcodeDetector._initialize();

  static ML.BarcodeScanner? _detector;

  BarcodeDetector._initialize();
  factory BarcodeDetector() => _singleton;

  int count = 0;
  Future<Payload?> detect(dynamic detectable, List<BarcodeFormats>? formats, bool? tryharder, bool? invert) async
  {
    try
    {
      Payload? result;

      if (detectable?.image is ML.InputImage)
      {
        // set barcode formats
        List<ML.BarcodeFormat> _formats = [];
        if (formats != null)
          for (BarcodeFormats format in formats)
          {
                 if ((format == BarcodeFormats.AZTEC)      && (!_formats.contains(ML.BarcodeFormat.aztec)))      _formats.add(ML.BarcodeFormat.aztec);
            else if ((format == BarcodeFormats.CODE39)     && (!_formats.contains(ML.BarcodeFormat.code39)))     _formats.add(ML.BarcodeFormat.code39);
            else if ((format == BarcodeFormats.CODE93)     && (!_formats.contains(ML.BarcodeFormat.code93)))     _formats.add(ML.BarcodeFormat.code93);
            else if ((format == BarcodeFormats.CODABAR)    && (!_formats.contains(ML.BarcodeFormat.codabar)))    _formats.add(ML.BarcodeFormat.codabar);
            else if ((format == BarcodeFormats.CODE128)    && (!_formats.contains(ML.BarcodeFormat.code128)))    _formats.add(ML.BarcodeFormat.code128);
            else if ((format == BarcodeFormats.DATAMATRIX) && (!_formats.contains(ML.BarcodeFormat.dataMatrix))) _formats.add(ML.BarcodeFormat.dataMatrix);
            else if ((format == BarcodeFormats.EAN8)       && (!_formats.contains(ML.BarcodeFormat.ean8)))       _formats.add(ML.BarcodeFormat.ean8);
            else if ((format == BarcodeFormats.EAN13)      && (!_formats.contains(ML.BarcodeFormat.ean13)))      _formats.add(ML.BarcodeFormat.ean13);
            else if ((format == BarcodeFormats.ITF)        && (!_formats.contains(ML.BarcodeFormat.itf)))        _formats.add(ML.BarcodeFormat.itf);
            else if ((format == BarcodeFormats.PDF417)     && (!_formats.contains(ML.BarcodeFormat.pdf417)))     _formats.add(ML.BarcodeFormat.pdf417);
            else if ((format == BarcodeFormats.QRCODE)     && (!_formats.contains(ML.BarcodeFormat.qrCode)))     _formats.add(ML.BarcodeFormat.qrCode);
            else if ((format == BarcodeFormats.UPCA)       && (!_formats.contains(ML.BarcodeFormat.upca)))       _formats.add(ML.BarcodeFormat.upca);
            else if ((format == BarcodeFormats.UPCE)       && (!_formats.contains(ML.BarcodeFormat.upce)))       _formats.add(ML.BarcodeFormat.upce);
          }

        // default format
        if (_formats.isEmpty) _formats.add(ML.BarcodeFormat.all);

        // build detector
        if (_detector == null) _detector = ML.BarcodeScanner(formats: _formats);

        // process
        Log().debug("Processing image ${++count}");
        var barcodes = await _detector!.processImage(detectable.image);

        // detect
        result = _buildPayload(barcodes);

        // debug
        if (result != null) result.barcodes.forEach((barcode) => Log().debug("Found barcode $barcode"));
      }

      return result;
    }
    catch(e)
    {
      Log().exception(e);
      return null;
    }
  }

  Payload? _buildPayload(List<ML.Barcode> barcodes)
  {
    if (barcodes.isEmpty) return null;

    Payload payload = Payload();
    barcodes.forEach((barcode)
    {
      Barcode bc = Barcode();
      bc.type    = barcode.type.index;
      bc.format  = S.fromEnum(barcode.format);
      bc.display = barcode.displayValue;
      bc.barcode = barcode.rawValue;
      payload.barcodes.add(bc);
    });
    return payload;
  }
}
