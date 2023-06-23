// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class DetectableImage
{
  final dynamic image;

  DetectableImage(this.image);

  factory DetectableImage.fromCamera(CameraImage image, CameraDescription camera)
  {
    final WriteBuffer allBytes = WriteBuffer();

    for (final Plane plane in image.planes)
    {
      allBytes.putUint8List(plane.bytes);
    }

    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.rotation0deg;

    final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

    // final planeData = image.planes.map((Plane plane)
    // {
    //     return InputImagePlaneMetadata(bytesPerRow: plane.bytesPerRow, height: plane.height, width: plane.width,);
    // }).toList();
    // final inputImageData = InputImageData(size: imageSize, imageRotation: imageRotation, inputImageFormat: inputImageFormat, planeData: planeData,);

    final inputImageData = InputImageMetadata(size: imageSize, rotation: imageRotation, format: inputImageFormat, bytesPerRow: image.planes[0].bytesPerRow,);

    return DetectableImage(InputImage.fromBytes(bytes: bytes, metadata: inputImageData));
  }

  factory DetectableImage.fromFilePath(String path)
  {
     return DetectableImage(InputImage.fromFilePath(path));
  }

  factory DetectableImage.fromRgba(List<int> bytes, int width, int height)
  {
    // not implemented
    return DetectableImage(null);
  }
}