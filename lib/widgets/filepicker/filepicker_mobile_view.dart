// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:fml/datasources/detectors/iDetectable.dart';
import 'package:fml/log/manager.dart';
import 'package:path/path.dart';
import 'filepicker_view.dart';
import 'package:fml/datasources/file/file.dart';
import 'package:fml/helper/common_helpers.dart';

import 'package:fml/datasources/detectors/image/detectable_image.stub.dart'
if (dart.library.io)   'package:fml/datasources/detectors/image/detectable_image.mobile.dart'
if (dart.library.html) 'package:fml/datasources/detectors/image/detectable_image.web.dart';

FilePickerView create({String? accept}) => FilePickerView(accept: accept);

class FilePickerView implements FilePicker
{
  // allowed file extensions
  List<String>? _accept;
  set accept(dynamic value)
  {
    if (value is String)
    {
      var values = value.split(",");
      _accept = [];
      values.forEach((v) => _accept!.add(v.replaceAll(".","").trim()));
    }
  }
  List<String>? get accept => _accept;


  FilePickerView({String? accept})
  {
    this.accept = accept;
  }

  @override
  Future<File?> launchPicker(List<IDetectable>? detectors) async
  {
    try
    {
      file_picker.FilePickerResult? result = await file_picker.FilePicker.platform.pickFiles(withReadStream: true, type: (accept == null) || (accept!.isEmpty) ? file_picker.FileType.any : file_picker.FileType.custom, allowedExtensions: accept);
      if (result != null)
      {
        // set file
        XFile  file = XFile(result.files.single.path!);
        String url  = "file:${file.path}";
        String type = (await S.mimetype(file.path)).toLowerCase();
        String name = basename(file.path);
        int    size = await file.length();

        // detect in image
        if ((detectors != null) && (type.startsWith("image")))
        {
          // create detectable image
          DetectableImage detectable = DetectableImage.fromFilePath(result.files.single.path!);

          // detect
          detectors.forEach((detector) => detector.detect(detectable, false));
        }

        // return the file
        return File(file, url, name, type, size);
      }
    }
    catch(e)
    {
      Log().debug('Error Launching File Picker');
    }
    return null;
  }
}