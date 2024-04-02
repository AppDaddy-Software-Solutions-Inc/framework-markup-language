// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart' as ML;
// import 'biometrics.dart' as BIOMETRICS;
//
// BiometricsDetector getDetector() => BiometricsDetector();
//
// class BiometricsDetector implements BIOMETRICS.BiometricsDetector
// {
//   static final BiometricsDetector _singleton = BiometricsDetector._initialize();
//
//   static var _detector;
//
//   BiometricsDetector._initialize();
//
//   factory BiometricsDetector()
//   {
//     return _singleton;
//   }
//
//   Future<BIOMETRICS.Payload> detect(dynamic detectable) async
//   {
//     try
//     {
//       BIOMETRICS.Payload result;
//
//       if (detectable?.image is ML.InputImage)
//       {
//         var image = detectable.image;
//
//         // process the image
//         List<ML.Face> faces = await _detector.processImage(image);
//
//         // return result
//         result = Payload(faces);
//       }
//
//       return result;
//     }
//     catch(e)
//     {
//       print (e);
//       return null;
//     }
//   }
//
//   BIOMETRICS.Payload Payload(List<ML.Face> faces)
//   {
//     if ((faces == null) || (faces.isEmpty)) return null;
//
//     BIOMETRICS.Payload payload = BIOMETRICS.Payload();
//     faces.forEach((face)
//     {
//       BIOMETRICS.Biometric face = BIOMETRICS.Biometric();
//       payload.biometrics.add(face);
//     });
//
//     return payload;
//   }
// }
