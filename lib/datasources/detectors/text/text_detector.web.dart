// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'text_detector.dart';
import 'package:fml/datasources/detectors/image/detectable_image.stub.dart'
if (dart.library.io)   'package:fml/datasources/detectors/image/detectable_image.mobile.dart'
if (dart.library.html) 'package:fml/datasources/detectors/image/detectable_image.web.dart';

TextDetector getDetector() => TextDetector();

class TextDetector implements ITextDetector
{
  static final TextDetector _singleton = new TextDetector._initialize();

  factory TextDetector()
  {
    return _singleton;
  }

  TextDetector._initialize();

  Future<Payload?> detect(DetectableImage image) async
  {
    // not implemented
    return null;
  }
}