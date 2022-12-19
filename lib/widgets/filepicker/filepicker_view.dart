// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/detectors/iDetector.dart' ;
import 'package:fml/datasources/transforms/model.dart' as TRANSFORM;

import 'filepicker_mobile_view.dart'
if (dart.library.io)   'filepicker_mobile_view.dart'
if (dart.library.html) 'filepicker_web_view.dart';

import 'package:fml/datasources/file/file.dart' as FILE;

abstract class FilePicker
{
  factory FilePicker(String? accept) => create(accept: accept);
  Future<FILE.File?> launchPicker(List<IDetector>? detectors, List<TRANSFORM.IImageTransform> transforms);
}