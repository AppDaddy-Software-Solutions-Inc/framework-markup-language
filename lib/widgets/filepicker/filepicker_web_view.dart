// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:html' as HTML;
import 'dart:ui';
import 'package:fml/datasources/detectors/iDetectable.dart';
import 'package:fml/log/manager.dart';
import 'filepicker_view.dart' as ABSTRACT;
import 'package:fml/datasources/file/file.dart' as FILE;

import 'package:fml/datasources/detectors/image/detectable_image.stub.dart'
if (dart.library.io)   'package:fml/datasources/detectors/image/detectable_image.mobile.dart'
if (dart.library.html) 'package:fml/datasources/detectors/image/detectable_image.web.dart';

FilePickerView create({String? accept}) => FilePickerView(accept: accept);

class FilePickerView implements ABSTRACT.FilePicker {
  String? accept;

  FilePickerView({String? accept}) {
    this.accept = accept;
  }

  Future<FILE.File?> launchPicker(List<IDetectable>? detectors) async {
    final completer = Completer();
    bool hasSelectedFile = false;

    /// End the completer and return null on selector window close
    void cancelledButtonListener(HTML.Event e) {
      /// We want to delay this to give time for the completer to finish
      /// If it did not finish by selecting a file then we pass this check
      /// and we know the file selector was closed with selection
      Future.delayed(Duration(milliseconds: 500)).then((value) {
        if (hasSelectedFile == false) {
          HTML.window.removeEventListener('focus', cancelledButtonListener);
          completer.complete(null);
          return;
        }
      });
    }

    /// Listen to filepicker focus for cancel/close/x buttons
    HTML.window.addEventListener('focus', cancelledButtonListener);

    try {
      /////////////////
      /* File Picker */
      /////////////////
      HTML.InputElement picker =
          HTML.FileUploadInputElement() as HTML.InputElement;
      picker.multiple = false;
      picker.accept = accept;

      //////////////////////
      /* On Picker Change */
      //////////////////////
      picker.onChange.listen((e) async
      {
        if (picker.files!.isNotEmpty)
        {
          hasSelectedFile = true;

          // set file
          var blob = picker.files![0];
          String url = HTML.Url.createObjectUrlFromBlob(blob);
          String? type = blob.type.toLowerCase();
          String? name = blob.name;
          int? size = blob.size;
          var file = FILE.File(blob, url, name, type, size);

          // process detectors
          if ((detectors != null) && (type.startsWith("image")))
          {
            // read the file
            await file.read();

            // convert to raw rgba format
            if (file.bytes != null)
            {
              var codec = await instantiateImageCodec(file.bytes!);
              var frame = await codec.getNextFrame();
              var data  = await frame.image.toByteData(format: ImageByteFormat.rawRgba);
              if (data != null)
              {
                // create detectable image
                DetectableImage detectable = DetectableImage.fromRgba(data.buffer.asUint8List(), frame.image.width, frame.image.height);

                // detect in image
                detectors.forEach((detector) => detector.detect(detectable));
              }
            }
          }

          // return the file
          completer.complete(file);
        }
      });

      ///////////////////
      /* Launch Picker */
      ///////////////////
      picker.click();

      /////////////////////
      /* Wait for Result */
      /////////////////////
      return await completer.future;
    }
    catch (e)
    {
      Log().debug('Error Launching File Picker');
      return null;
    }
  }
}
