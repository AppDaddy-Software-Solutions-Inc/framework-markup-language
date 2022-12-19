// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/detectors/detectable/detectable.dart';
import 'biometrics.dart' as BIOMETRICS;

BiometricsDetector getDetector() => BiometricsDetector();

class BiometricsDetector implements BIOMETRICS.BiometricsDetector
{
  static final BiometricsDetector _singleton = BiometricsDetector._initialize();

  BiometricsDetector._initialize();

  factory BiometricsDetector()
  {
    return _singleton;
  }

  Future<BIOMETRICS.Payload?> detect(DetectableImage image) async
  {
    // not implemented
    return null;
  }
}