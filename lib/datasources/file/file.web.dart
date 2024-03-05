// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:typed_data';
import 'package:universal_html/html.dart' as universal_html;
import 'package:camera/camera.dart' show XFile;
import 'package:fml/log/manager.dart';
import 'file.base.dart';

File create(dynamic file, String url, String name, String mimeType, int size)
{
  return File(file, url, name, mimeType, size);
}

class File extends FileBase
{
  File(super.file, super.url, super.name, String super.mimeType, super.size);

  @override
  Future<Uint8List?> read({int? start, int? end}) async
  {
    try
    {
      // already read
      if (bytes != null) return bytes;

      // filepicker format read from file
      if (file is universal_html.File)
      {
        if ((start == null) && (end == null))
        {
          bytes = await _read();
        }
        else {
          return await _readPart(start, end);
        }
      }

      // camera format. read from blob
      if (file is XFile)
      {
        bytes = await file.readAsBytes();
      }

      return bytes;
    }
    catch(e)
    {
      Log().exception(e);
      return null;
    }
  }

  Future<Uint8List?> _read() async
  {
      Uint8List? bytes;

      final completer = Completer();

      /////////////////
      /* File Reader */
      /////////////////
      universal_html.FileReader reader = universal_html.FileReader();

      ///////////////////
      /* Read Complete */
      ///////////////////
      reader.onLoadEnd.listen((e) async
      {
        bytes = reader.result as Uint8List?;
        completer.complete();
      });

      ///////////////////
      /* Read the File */
      ///////////////////
      reader.readAsArrayBuffer(file);

      /////////////////////
      /* Wait for Result */
      /////////////////////
      await completer.future;

      return bytes;
  }

  Future<Uint8List?> _readPart(int? start, int? end) async
  {
    Uint8List? bytes;

    final completer = Completer();

    if ((start == null) || (start < 0)) start = 0;
    if ((end == null)   || (end   > file.size)) end = file.size;

    /////////////////
    /* File Reader */
    /////////////////
    universal_html.FileReader reader = universal_html.FileReader();

    ///////////////////
    /* Read Complete */
    ///////////////////
    reader.onLoadEnd.listen((e) async
    {
      bytes = reader.result as Uint8List?;
      completer.complete();
    });

    ///////////////////
    /* Read the File */
    ///////////////////
    reader.readAsArrayBuffer(file.slice(start,end));

    /////////////////////
    /* Wait for Result */
    /////////////////////
    await completer.future;

    return bytes;
  }
}