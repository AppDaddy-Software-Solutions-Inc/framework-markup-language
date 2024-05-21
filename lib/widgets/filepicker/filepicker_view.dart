// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/detectors/detector_interface.dart';

import 'filepicker_view.vm.dart'
    if (dart.library.io) 'filepicker_view.vm.dart'
    if (dart.library.html) 'filepicker_view.web.dart';

import 'package:fml/datasources/file/file.dart';

abstract class FilePicker {
  factory FilePicker(String? accept) => create(accept: accept);
  Future<File?> launchPicker(List<IDetectable>? detectors);
}
