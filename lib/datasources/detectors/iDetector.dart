// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'detectable/detectable.dart';
import 'detector_model.dart';
abstract class IDetector
{
  DetectorSources? get source;
  bool? get enabled;
  bool get busy;
  void detect(DetectableImage image);
}

