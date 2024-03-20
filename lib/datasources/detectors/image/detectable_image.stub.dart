// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:camera/camera.dart' show CameraImage;
import 'package:camera/camera.dart' show CameraDescription;

class DetectableImage {
  final dynamic image;
  DetectableImage(this.image);
  factory DetectableImage.fromCamera(
          CameraImage image, CameraDescription camera) =>
      DetectableImage(null);
  factory DetectableImage.fromFilePath(String path) => DetectableImage(null);
  factory DetectableImage.fromRgba(List<int> bytes, int width, int height) =>
      DetectableImage(null);
}
