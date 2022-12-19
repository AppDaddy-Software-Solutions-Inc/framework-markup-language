// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/detectors/detectable/detectable.dart';
import 'package:fml/data/data.dart';

//import 'biometrics.mobile.dart'
//if (dart.library.io)   'biometrics.mobile.dart'
//if (dart.library.html) 'biometrics.web.dart';
import 'stub.dart';

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

abstract class BiometricsDetector
{
  factory BiometricsDetector() => getDetector();
  Future<Payload?> detect(DetectableImage image);
}