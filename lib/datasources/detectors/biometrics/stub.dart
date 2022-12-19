// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/detectors/biometrics/biometrics.dart';

BiometricsDetector getDetector() => BiometricsDetector();

class Stub
{
  bool? enabled;
  Future<dynamic>? detectInRgba(List<int> rgba, int width, int height, {int? rotation}) => null;
  Future<dynamic>? detectInDataUri(UriData uri) => null;
  Future<dynamic>? detectInImage(dynamic image, {int orientation = 0}) => null;
}