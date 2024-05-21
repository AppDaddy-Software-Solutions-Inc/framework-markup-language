import 'package:fml/datasources/detectors/barcode/barcode_detector.dart';
import 'package:fml/datasources/detectors/barcode/barcode_detector_mlkit.dart' as mlkit;
import 'package:fml/datasources/detectors/barcode/barcode_detector_zxing.dart' as zxing;
import 'package:fml/platform/platform.vm.dart';

class BarcodeDetector {
  Future<IBarcodeDetector> getDetector() async => isDesktop ? zxing.BarcodeDetector() : mlkit.BarcodeDetector();
}
