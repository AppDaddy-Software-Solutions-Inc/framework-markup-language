// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/detectors/detectable/detectable.dart';
import 'text.dart' as TEXT;

TextDetector getDetector() => TextDetector();

class TextDetector implements TEXT.TextDetector
{
  static final TextDetector _singleton = new TextDetector._initialize();

  factory TextDetector()
  {
    return _singleton;
  }

  TextDetector._initialize();

  Future<TEXT.Payload?> detect(DetectableImage image) async
  {
    // not implemented
    return null;
  }
}