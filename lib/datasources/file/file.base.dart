// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:typed_data';

import 'file.dart';

class FileBase implements File {
  final dynamic file;
  @override
  final String url;
  @override
  final String name;
  @override
  final String? mimeType;
  @override
  final int size;

  UriData? _uri;
  @override
  Uint8List? get bytes {
    if (file is UriData) return (file as UriData).contentAsBytes();
    if (_uri == null) return null;
    return _uri!.contentAsBytes();
  }

  set bytes(Uint8List? value) {
    if (value != null) {
      _uri = UriData.fromBytes(value,
          mimeType: mimeType!,
          parameters: {'name': name, 'bytes': size.toString()});
    }
  }

  @override
  String? get uri {
    if (file is UriData) return (file as UriData).toString();
    if (_uri == null) return null;
    return _uri.toString();
  }

  FileBase(this.file, this.url, this.name, this.mimeType, this.size);

  @override
  Future<Uint8List?> read({int? start, int? end}) async => null;
}
