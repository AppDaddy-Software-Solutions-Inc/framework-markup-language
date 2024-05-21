import 'package:fml/datasources/detectors/barcode/barcode_detector.dart';
import 'package:fml/datasources/detectors/barcode/barcode_detector_zxing.dart' deferred as zxing;

class BarcodeDetector {
  Future<IBarcodeDetector> getDetector() async {

    // load library
    await zxing.loadLibrary();

    // return zebra crossing detector
    return zxing.BarcodeDetector();
  }
}