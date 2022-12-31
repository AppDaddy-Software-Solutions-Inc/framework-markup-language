// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:camera/camera.dart';
import 'package:zxing_lib/common.dart';
import 'package:zxing_lib/zxing.dart';
import 'package:fml/helper/helper_barrel.dart';

class DetectableImage
{
  final dynamic image;

  DetectableImage(this.image);

  factory DetectableImage.fromCamera(CameraImage image, CameraDescription camera)
  {
    // not implemented
    return DetectableImage(null);
  }

  factory DetectableImage.fromFilePath(String path)
  {
    // not implemented
    return DetectableImage(null);
  }

  factory DetectableImage.fromRgba(List<int> bytes, int width, int height)
  {
    print ('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');

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