// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:typed_data';
import 'package:cross_file/cross_file.dart';
import 'package:fml/log/manager.dart';
import 'file.base.dart';

File create(dynamic file, String url, String name, String? mimeType, int size) {
  return File(file, url, name, mimeType, size);
}

class File extends FileBase {
  File(super.file, super.url, super.name, super.mimeType, super.size);

  @override
  Future<Uint8List?> read({int? start, int? end}) async {
    try {
      // already read
      if (bytes != null) return bytes;

      if (file is XFile) {
        if ((start == null) && (end == null)) {
          bytes = await file.readAsBytes();
        } else {
          return await _read(start!, end);
        }
      }

      return bytes;
    } catch (e) {
      Log().exception(e);
      return null;
    }
  }

  Future<Uint8List?> _read(int start, int? end) async {
    List<int> parts = [];
    if (start.isNegative) start = 0;
    end ??= await file.length();

    Stream<List<int>> stream = file.openRead(start, end);
    await for (dynamic part in stream) {
      try {
        parts.addAll(Uint8List.fromList(part));
      } catch (e) {
        Log().exception(e);
      }
    }
    return (parts.isEmpty ? null : Uint8List.fromList(parts));
  }
}
