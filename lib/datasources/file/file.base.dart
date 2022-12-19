// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:typed_data';

import 'file.dart';

class FileBase implements File
{
  final dynamic file;
  final String  url;
  final String  name;
  final String?  mimeType;
  final int     size;

  UriData? _uri;
  Uint8List? get bytes
  {
    if (file is UriData) return (file as UriData).contentAsBytes();
    if (_uri == null) return null;
    return _uri!.contentAsBytes();
  }
  set bytes(Uint8List? value)
  {
    if (value != null) _uri = UriData.fromBytes(value, mimeType: mimeType!, parameters: {'name' : name, 'bytes' : size.toString()});
  }

  String? get uri
  {
    if (file is UriData) return (file as UriData).toString();
    if (_uri == null) return null;
    return _uri.toString();
  }

  FileBase(this.file, this.url, this.name, this.mimeType, this.size);

  Future<Uint8List?> read({int? start, int? end}) async => null;
}