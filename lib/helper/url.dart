// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fml/datasources/http/http.dart';
import 'package:fml/system.dart';
import 'package:fml/helper/helper_barrel.dart';
import 'package:path/path.dart';

/// URL Helpers
///
/// Helper functions that can be used by importing *url.dart*
/// Example ```dart
/// String myUrl = "https://appdaddy.co"
/// Uri myUri = Url.parse(myUrl); // Convert a URL String to a Uri
/// ```
class Url
{
  // TODO
  static bool isAbsolute(String url)
  {
    Uri? uri = parse(url);
    return uri?.hasAuthority ?? false;
  }

  /// Takes a Url String and if it is a relative path, prepends it with the domain
  static String toAbsolute(String url, {String? domain})
  {
    Uri? uri = parse(url);
    if (uri != null && !uri.hasAuthority)
    {
      if (domain == null) domain = System().domain;
      url = domain! + (url.startsWith('/') ? '' : '/') + url;
    }
    return url;
  }

  /// Url-safe encoding of a parameter values
  ///
  /// For example if your String contains a `/` it will encode this to `%2F`
  static String? encode(String url)
  {
    Uri? uri = parse(url);
    if (uri == null) return null;
    if (uri.hasQuery)  uri.queryParameters.forEach((key, value) => Uri.encodeComponent(value));
    return uri.toString();
  }

  /// Takes a valid Url String and appends a key-value pair as a parameter
  static String addParameter(String url, String key, String? value)
  {
    if ((S.isNullOrEmpty(url)) || (S.isNullOrEmpty(key))) return url;

    Uri? uri = parse(url);
    if (uri == null) return url;

    //////////////////////////////
    /* Get the Query Parameters */
    //////////////////////////////
    Map<String, List<String>> parameters = Map<String, List<String>>();
    parameters.addAll(uri.queryParametersAll);

    if (!parameters.containsKey(key)) parameters[key] = [];
    parameters[key]!.add(Uri.encodeComponent(value ?? ""));

    //////////////////////////////
    /* Replace the Query String */
    //////////////////////////////
    uri = uri.replace(queryParameters: parameters);

    ///////////////////////
    /* Convert to String */
    ///////////////////////
    url = uri.toString();

    return url;
  }

  /// Returns the path component of a valid String Url
  static String? path(String url)
  {
    Uri? uri = parse(url);
    if (uri == null) return null;

    // default the scheme
    if (!uri.hasScheme) uri = parse('http://' + url);

    return uri?.domain;
  }
  
  static Future<UriData?> toUriData(String url) async
  {
    try
    {
      // parse the url
      Uri? uri = Url.parse(url);

      // failed parse
      if (uri == null) return null;

      // already a data uri
      if (uri.data != null) return uri.data;

      // file reference
      if (uri.scheme == "file")
      {
        var file  = File(url);
        var bytes = await file.readAsBytes();
        var mime  = await S.mimetype(url);
        return UriData.fromBytes(bytes,mimeType: mime);
      }

      // remote image file
      var response = await Http.get(url);
      if (response.statusCode == HttpStatus.ok)
      {
        var bytes = response.bytes;
        var mime  = await S.mimetype(url);
        return UriData.fromBytes(bytes, mimeType: mime);
      }
    }
    catch(e) {}
    return null;
  }

  static Uri? parse(String? url)
  {
    // null or missing url
    if (url == null) return null;

    // invalid url?
    Uri? uri = Uri.tryParse(url);
    if (uri == null) return null;

    // url is a data uri?
    if (uri.data != null) return uri;

    // because flutter is a SWA we need to ignore the /#/ for uri query param detection
    if (uri.hasFragment) uri = Uri.tryParse(url.replaceFirst("/#", "/"));
    if (uri == null) return null;

    // remove empty segments
    List<String> segments = uri.pathSegments.toList();
    segments.removeWhere((segment) => Uri.decodeComponent(segment).trim() == "");

    // get start page && remove from segments
    String? page;
    if (segments.isNotEmpty && segments.last.contains("."))
    {
      page = uri.pathSegments.last.trim();
      segments.removeLast();
    }

    // build a new uri
    return Uri(scheme: uri.scheme, host: uri.host,  port: uri.port, pathSegments: segments, fragment: page, queryParameters: uri.queryParameters.cast());
  }
}

extension UriExtensions on Uri
{
  String? get domain => "$scheme://$authority$path";
  String? get page   => fragment == "" ? null : this.fragment;
  String? get pageExtension
  {
    var _page = page;
    if (_page != null && _page.contains(".")) return extension(_page).toLowerCase().replaceFirst(".", "").trim();
    return null;
  }

  String? get filePath
  {
    String? _path;
    
    // file path
    if (!kIsWeb) 
    switch (scheme)
    {
      case "asset":
      case "file":
        _path = dirname(Platform.resolvedExecutable) + Platform.pathSeparator + "assets" + Platform.pathSeparator + path;
        _path = _path.replaceAll("\\", Platform.pathSeparator).replaceAll("/", Platform.pathSeparator);
        break;
    }
    
    return _path;
  }
}

