// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:typed_data';

import 'file.mobile.dart'
    if (dart.library.io) 'file.mobile.dart'
    if (dart.library.html) 'file.web.dart';

abstract class File {
  String? get url;
  String? get uri;
  String? get name;
  int? get size;
  String? get mimeType;
  Uint8List? get bytes;

  factory File(
          dynamic file, String url, String name, String mimeType, int size) =>
      create(file, url, name, mimeType, size);
  Future<Uint8List?> read({int? start, int? end});
}
