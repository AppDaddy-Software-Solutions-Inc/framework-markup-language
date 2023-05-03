// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/detectors/iDetectable.dart';

import 'filepicker_mobile_view.dart'
if (dart.library.io)   'filepicker_mobile_view.dart'
if (dart.library.html) 'filepicker_web_view.dart';

import 'package:fml/datasources/file/file.dart';

abstract class FilePicker
{
  factory FilePicker(String? accept) => create(accept: accept);
  Future<File?> launchPicker(List<IDetectable>? detectors);
}