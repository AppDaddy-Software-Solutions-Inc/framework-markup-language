// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:ui';

import 'package:camera/camera.dart' show CameraImage;
import 'package:camera/camera.dart' show CameraDescription;
import 'package:cross_file/cross_file.dart';
import 'package:zxing_lib/common.dart' show HybridBinarizer;
import 'package:zxing_lib/zxing.dart' show RGBLuminanceSource;
import 'package:zxing_lib/zxing.dart' show BinaryBitmap;
import 'package:fml/helpers/helpers.dart';

class DetectableImage {
  final dynamic image;

  DetectableImage(this.image);

  static Future<DetectableImage> fromCamera(
      CameraImage image, CameraDescription camera) async {
    return DetectableImage(null);
  }

  static Future<DetectableImage> fromFile(XFile file) async {
    var bytes = await file.readAsBytes();
    var codec = await instantiateImageCodec(bytes);
    var frame = await codec.getNextFrame();
    var data  = await frame.image.toByteData(format: ImageByteFormat.rawRgba);
    if (data == null) return DetectableImage(null);
    return await fromRgba(data.buffer.asUint8List(), frame.image.width, frame.image.height);
  }

  static Future<DetectableImage> fromRgba(List<int> bytes, int width, int height) async {

    // decode pixels
    List<int> pixels = ImageHelper.toPixelsFromRgba(bytes);

    // get luminance
    var source = RGBLuminanceSource(width, height, pixels);

    // get bitmap
    BinaryBitmap bitmap = BinaryBitmap(HybridBinarizer(source));

    return DetectableImage(bitmap);
  }
}
