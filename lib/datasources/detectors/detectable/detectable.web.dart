// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:camera/camera.dart';
import 'package:zxing_lib/common.dart';
import 'package:zxing_lib/zxing.dart';
import 'detectable.dart' as DETECTABLE;
import 'package:fml/helper/helper_barrel.dart';

DetectableImage? fromCamera(CameraImage image, CameraDescription camera) => DetectableImage.fromCamera(image, camera);
DetectableImage? fromFilePath(String path) => DetectableImage.fromFilePath(path);
DetectableImage? fromRgba(List<int> bytes, int width, int height) => DetectableImage.fromRgba(bytes, width, height);

class DetectableImage implements DETECTABLE.DetectableImage
{
  final dynamic image;

  DetectableImage(this.image);

  static DetectableImage? fromCamera(CameraImage image, CameraDescription camera)
  {
    // not implemented
    return null;
  }

  static DetectableImage? fromFilePath(String path)
  {
    // not implemented
    return null;
  }

  factory DetectableImage.fromRgba(List<int> bytes, int width, int height)
  {
      // decode pixels
      List<int> pixels = ImageHelper.toPixelsFromRgba(bytes);

      // convert to greyscale
      //List<int> bw = List<int>.generate(rgba.length ~/ 4, (index) => _toBlackAndWhite(rgba[index * 4], rgba[(index * 4) + 1], rgba[(index * 4) + 2], 0.25));

      // get luminance
      LuminanceSource source = RGBLuminanceSource(width, height, pixels);

      // get bitmap
      BinaryBitmap bitmap = BinaryBitmap(HybridBinarizer(source));

      return DetectableImage(bitmap);
  }
}