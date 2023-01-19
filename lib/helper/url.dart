// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:io' as io;
import 'package:fml/datasources/http/http.dart';
import 'package:fml/helper/helper_barrel.dart';
import 'package:fml/helper/uri.dart';

/// URL Helpers
///
/// Helper functions that can be used by importing *url.dart*
/// Example ```dart
/// String myUrl = "https://appdaddy.co"
/// Uri myUri = Url.parse(myUrl); // Convert a URL String to a Uri
/// ```
class Url
{
  /// Url-safe encoding of a parameter values
  ///
  /// For example if your String contains a `/` it will encode this to `%2F`
  static String? encode(String url)
  {
    Uri? uri = URI.parse(url);
    if (uri == null) return null;
    if (uri.hasQuery)  uri.queryParameters.forEach((key, value) => Uri.encodeComponent(value));
    return uri.toString();
  }

  static Future<UriData?> toUriData(String url) async
  {
    try
    {
      // parse the url
      Uri? uri = URI.parse(url);

      // failed parse
      if (uri == null) return null;

      // already a data uri
      if (uri.data != null) return uri.data;

      // file reference
      if (uri.scheme == "file")
      {
        var filepath = uri.asFilePath();
        if (filepath == null) return null;
        var file  = io.File(filepath);
        var bytes = await file.readAsBytes();
        var mime  = await S.mimetype(url);
        return UriData.fromBytes(bytes,mimeType: mime);
      }

      // remote image file
      var response = await Http.get(url);
      if (response.statusCode == io.HttpStatus.ok)
      {
        var bytes = response.bytes;
        var mime  = await S.mimetype(url);
        return UriData.fromBytes(bytes, mimeType: mime);
      }
    }
    catch(e)
    {
      print("Error in toUriData. Error is $e");
    }
    return null;
  }
}
