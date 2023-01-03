// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';

import 'package:fml/datasources/detectors/image/detectable_image.stub.dart'
if (dart.library.io)   'package:fml/datasources/detectors/image/detectable_image.mobile.dart'
if (dart.library.html) 'package:fml/datasources/detectors/image/detectable_image.web.dart';

import 'biometrics_detector.stub.dart';
//if (dart.library.io)   'biometrics_detector.mobile.dart'
//if (dart.library.html) 'biometrics_detector.web.dart';

class Biometric
{
  int? smile;
}

class Payload
{
  final List<Biometric> biometrics = [];
  Payload({List<Biometric>? biometrics})
  {
    if (biometrics != null) this.biometrics.addAll(biometrics);
  }

  static Data toData(Payload payload)
  {
    Data data = Data();
    payload.biometrics.forEach((biometric)
    {
      Map<dynamic,dynamic> map = Map<dynamic,dynamic>();
      map["smile"] = (biometric.smile != null ? biometric.smile.toString() : '0');
      data.add(map);
    });
    return data;
  }
}

abstract class iBiometricsDetector
{
  factory iBiometricsDetector() => getDetector();
  Future<Payload?> detect(DetectableImage image);
}