// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:camera/camera.dart';
import 'detectable.mobile.dart'
if (dart.library.io)   'detectable.mobile.dart'
if (dart.library.html) 'detectable.web.dart';

abstract class DetectableImage
{
  dynamic get image;
  static DetectableImage? fromCamera(CameraImage image, CameraDescription camera) => fromCamera(image, camera);
  static DetectableImage? fromFilePath(String path) => fromFilePath(path);
  static DetectableImage? fromRgba(List<int> bytes, int width, int height) => fromRgba(bytes, width, height);
}
