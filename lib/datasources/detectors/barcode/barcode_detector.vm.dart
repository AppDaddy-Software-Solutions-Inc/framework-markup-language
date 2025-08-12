import 'package:fml/datasources/detectors/barcode/barcode_detector.dart';
import 'package:fml/datasources/detectors/barcode/barcode_detector_mlkit.dart' deferred as mlkit;
import 'package:fml/datasources/detectors/barcode/barcode_detector_zxing.dart' deferred as zxing;

// platform
import 'package:fml/platform/platform.vm.dart'
if (dart.library.io) 'package:fml/platform/platform.vm.dart'
if (dart.library.html) 'package:fml/platform/platform.web.dart';


class BarcodeDetector {
  Future<IBarcodeDetector> getDetector() async => isDesktop ? zxing.BarcodeDetector() : mlkit.BarcodeDetector();
}
