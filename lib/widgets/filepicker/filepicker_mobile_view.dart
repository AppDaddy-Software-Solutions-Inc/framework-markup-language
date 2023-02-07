// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart' as FILEPICKER;
import 'package:fml/datasources/detectors/iDetectable.dart';
import 'package:fml/log/manager.dart';
import 'package:path/path.dart';
import 'filepicker_view.dart' as ABSTRACT;
import 'package:fml/datasources/file/file.dart' as FILE;
import 'package:fml/helper/common_helpers.dart';

import 'package:fml/datasources/detectors/image/detectable_image.stub.dart'
if (dart.library.io)   'package:fml/datasources/detectors/image/detectable_image.mobile.dart'
if (dart.library.html) 'package:fml/datasources/detectors/image/detectable_image.web.dart';

FilePickerView create({String? accept}) => FilePickerView(accept: accept);

class FilePickerView implements ABSTRACT.FilePicker
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

  Future<FILE.File?> launchPicker(List<IDetectable>? detectors) async
  {
    try
    {
      FILEPICKER.FilePickerResult? result = await FILEPICKER.FilePicker.platform.pickFiles(withReadStream: true, type: (accept == null) || (accept!.isEmpty) ? FILEPICKER.FileType.any : FILEPICKER.FileType.custom, allowedExtensions: accept);
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
        return FILE.File(file, url, name, type, size);
      }
    }
    catch(e)
    {
      Log().debug('Error Launching File Picker');
    }
    return null;
  }
}