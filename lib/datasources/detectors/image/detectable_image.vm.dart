// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:fml/helpers/image.dart';
import 'package:fml/platform/platform.vm.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart' as mlkit
    show InputImageMetadata, InputImageFormatValue, InputImageRotationValue, InputImage, InputImageFormat, InputImageRotation;
import 'package:zxing_lib/common.dart' show HybridBinarizer;
import 'package:zxing_lib/zxing.dart' as zxing show RGBLuminanceSource;
import 'package:zxing_lib/zxing.dart' as zxing show BinaryBitmap;

class DetectableImage {

  final dynamic image;

  DetectableImage(this.image);

  static Future<DetectableImage> fromCamera(
      CameraImage image, CameraDescription camera) async {

    final WriteBuffer allBytes = WriteBuffer();

    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }

    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final imageRotation =
        mlkit.InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
            mlkit.InputImageRotation.rotation0deg;

    final inputImageFormat =
        mlkit.InputImageFormatValue.fromRawValue(image.format.raw) ??
            mlkit.InputImageFormat.nv21;

    final inputImageData = mlkit.InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return DetectableImage(
        mlkit.InputImage.fromBytes(bytes: bytes, metadata: inputImageData));
  }

  static Future<DetectableImage> fromFile(XFile file) async {

    // zxing
    if (isDesktop) {
      var bytes = await file.readAsBytes();
      var codec = await instantiateImageCodec(bytes);
      var frame = await codec.getNextFrame();
      var data  = await frame.image.toByteData(format: ImageByteFormat.rawRgba);
      if (data == null) return DetectableImage(null);
      return await fromRgba(data.buffer.asUint8List(), frame.image.width, frame.image.height);
    }

    // mlkit
    return DetectableImage(mlkit.InputImage.fromFilePath(file.path));
  }

  static Future<DetectableImage> fromRgba(List<int> bytes, int width, int height) async {

    // decode pixels
    List<int> pixels = ImageHelper.toPixelsFromRgba(bytes);

    // get luminance
    var source = zxing.RGBLuminanceSource(width, height, pixels);

    // get bitmap
    zxing.BinaryBitmap bitmap = zxing.BinaryBitmap(HybridBinarizer(source));

    return DetectableImage(bitmap);
  }
}
