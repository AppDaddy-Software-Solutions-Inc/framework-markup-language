// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:html' as HTML;
import 'dart:ui';
import 'package:fml/datasources/detectors/detectable/detectable.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'filepicker_view.dart' as ABSTRACT;
import 'package:fml/datasources/file/file.dart' as FILE;
import 'package:fml/datasources/transforms/model.dart' as TRANSFORM;
import 'package:fml/datasources/detectors/iDetector.dart' ;
import 'package:image/image.dart' as IMAGE;

FilePickerView create({String? accept}) => FilePickerView(accept: accept);

class FilePickerView implements ABSTRACT.FilePicker {
  String? accept;

  FilePickerView({String? accept}) {
    this.accept = accept;
  }

  Future<FILE.File?> launchPicker(List<IDetector>? detectors,
      List<TRANSFORM.IImageTransform> transforms) async {
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
      picker.onChange.listen((e) async {
        if (picker.files!.isNotEmpty) {
          hasSelectedFile = true;

          // set file
          var blob = picker.files![0];
          String url = HTML.Url.createObjectUrlFromBlob(blob);
          String? type = blob.type.toLowerCase();
          String? name = blob.name;
          int? size = blob.size;
          var file = FILE.File(blob, url, name, type, size);

          // apply image transforms
          if (
              (transforms.length > 0)) {
            IMAGE.Image? image;

            IMAGE.Decoder? decoder;
            if (type.endsWith("jpg")) decoder = IMAGE.JpegDecoder();
            if (type.endsWith("jpeg")) decoder = IMAGE.JpegDecoder();
            if (type.endsWith("png")) decoder = IMAGE.PngDecoder();
            if (type.endsWith("gif")) decoder = IMAGE.GifDecoder();
            if (decoder != null) {
              try
              {
                var bytes = await file.read() as List<int>;
                image = decoder.decodeImage(bytes);
              }
              catch (e)
              {
                Log().debug("Error detecting image in bytes. Error is $e");
                System.toast("Error decoding image $e", duration: 10);
                image = null;
              }

              for (var transform in transforms) {
                if ((image != null) && (transform.enabled == true))
                  image = transform.apply(image);
              }

              List<int>? bytes;
              if (image != null) {
                if (decoder is IMAGE.PngDecoder) bytes = IMAGE.encodePng(image);
                if (decoder is IMAGE.JpegDecoder)
                  bytes = IMAGE.encodeJpg(image);
                if (decoder is IMAGE.GifDecoder) bytes = IMAGE.encodeGif(image);
              }

              if (bytes != null) {
                var uri = UriData.fromBytes(bytes, mimeType: type);
                var url = uri.toString();
                var size = bytes.length;
                file = FILE.File(uri, url, name, type, size);
              }
            }
          }

          // detect in image
          if ((detectors != null) && (type.startsWith("image"))) {
            // read the file
            await file.read();

            // convert to raw rgba format
            var codec;
            if (file.bytes != null)
              codec = await instantiateImageCodec(file.bytes!);
            var frame = await codec.getNextFrame();
            var data =
                await frame.image.toByteData(format: ImageByteFormat.rawRgba);
            var rgba = data.buffer.asUint8List();

            // create detectable image
            DetectableImage? detectable = DetectableImage.fromRgba(rgba, frame.image.dirtyObservable, frame.image.height);

            // detect
            if (detectable != null) detectors.forEach((detector) => detector.detect(detectable));
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
