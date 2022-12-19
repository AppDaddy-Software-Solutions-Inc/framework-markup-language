// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart' as FILEPICKER;
import 'package:fml/datasources/detectors/detectable/detectable.dart';
import 'package:fml/log/manager.dart';
import 'package:path/path.dart';
import 'filepicker_view.dart' as ABSTRACT;
import 'package:fml/datasources/file/file.dart' as FILE;
import 'package:fml/datasources/detectors/iDetector.dart' ;
import 'package:fml/datasources/transforms/model.dart' as TRANSFORM;
import 'package:image/image.dart' as IMAGE;
import 'package:fml/helper/helper_barrel.dart';

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

  Future<FILE.File?> launchPicker(List<IDetector>? detectors, List<TRANSFORM.IImageTransform> transforms) async
  {
    try
    {
      FILEPICKER.FilePickerResult? result = await FILEPICKER.FilePicker.platform.pickFiles(withReadStream: true, type: (accept == null) || (accept!.isEmpty) ? FILEPICKER.FileType.any : FILEPICKER.FileType.custom, allowedExtensions: accept);
      if (result != null)
      {
        // set file
        XFile  file = XFile(result.files.single.path!);
        String url  = "file:${file.path}";
        String type = S.mimetype(file.path).toLowerCase();
        String name = basename(file.path);
        int    size = await file.length();

        // detect in image
        if ((detectors != null) && (type.startsWith("image")))
        {
          // create detectable image
          DetectableImage? detectable = DetectableImage.fromFilePath(result.files.single.path!);

          // detect
          if (detectable != null) detectors.forEach((detector) => detector.detect(detectable));
        }

        // apply image transforms
        if ((transforms.length > 0))
        {
          IMAGE.Image? image;

          IMAGE.Decoder? decoder;
          if (type.endsWith("jpg"))  decoder = IMAGE.JpegDecoder();
          if (type.endsWith("jpeg")) decoder = IMAGE.JpegDecoder();
          if (type.endsWith("png"))  decoder = IMAGE.PngDecoder();
          if (type.endsWith("gif"))  decoder = IMAGE.GifDecoder();
          if (decoder != null)
          {
            try
            {
              image = decoder.decodeImage(await file.readAsBytes());
            }
            catch(e)
            {
              Log().debug("Error detecting image in bytes. Error is $e");
              image = null;
            }

            for (var transform in transforms)
            {
              if ((image != null) && (transform.enabled == true)) image = transform.apply(image);
            }

            List<int>? bytes;
            if (image != null)
            {
              if (decoder is IMAGE.PngDecoder)   bytes = IMAGE.encodePng(image);
              if (decoder is IMAGE.JpegDecoder)  bytes = IMAGE.encodeJpg(image);
              if (decoder is IMAGE.GifDecoder)   bytes = IMAGE.encodeGif(image);
            }

            if (bytes != null)
            {
              var uri  = UriData.fromBytes(bytes, mimeType: S.mimetype(name));
              var url  = uri.toString();
              var size = bytes.length;
              return FILE.File(uri, url, name,type, size);
            }
          }
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