// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:io';
import 'package:fml/datasources/http/http.dart';
import 'package:fml/helper/helper_barrel.dart';
import 'package:path/path.dart';
import 'package:fml/system.dart';

/// URL Helpers
///
/// Helper functions that can be used by importing *url.dart*
/// Example ```dart
/// String myUrl = "https://appdaddy.co"
/// Uri myUri = Url.parse(myUrl); // Convert a URL String to a Uri
/// ```
class Url
{
  // active domain
  static String? activeDomain;

  // TODO
  static bool isAbsolute(String url)
  {
    Uri? uri = parse(url);
    return uri?.hasAuthority ?? false;
  }

  /// Takes a Url String and if it is a relative path, prepends it with the domain
  static String? toAbsolute(String url, String domain)
  {
    Uri? uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (!uri.isAbsolute)
    {
      url = domain + (url.startsWith('/') ? '' : '/') + url;
      uri = Uri.tryParse(url);
      if (uri == null) return null;
    }
    if (!uri.isAbsolute) return null;

    return uri.toString();
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
      if (uri.scheme == "file" && uri.filepath != null)
      {
        var name = uri.filepath!;
        var file  = File(name);
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
    catch(e)
    {
      print("Error in toUriData. Error is $e");
    }
    return null;
  }

  static Uri? parse(String? url, {bool qualifyName = true})
  {
    // null or missing url
    if (url == null) return null;

    // invalid url?
    Uri? uri = Uri.tryParse(url);
    if (uri == null) return null;

    // url is a data uri?
    if (uri.data != null) return uri;

    // absolute?
    if (!uri.isAbsolute && qualifyName)
    {
      uri = Uri.tryParse("$activeDomain/${uri.url}");
      if (uri == null) return null;
    }

    // because flutter is a SWA we need to ignore the /#/ for uri query param detection
    if (url.contains("/#")) uri = Uri.tryParse(url.replaceFirst("/#", "/"));
    if (uri == null) return null;

    // remove empty segments
    List<String> pathSegments = uri.pathSegments.toList();
    pathSegments.removeWhere((segment) => Uri.decodeComponent(segment).trim() == "");

    // build query parameters
    Map<String, dynamic>? queryParameters;
    if (uri.queryParameters.isNotEmpty)
    {
      queryParameters = {};
      queryParameters.addAll(uri.queryParameters);
    }

    // build a new uri
    return Uri(scheme: uri.hasScheme ? uri.scheme : null,
               host: uri.host,
               port: uri.hasPort ? uri.port : null,
               fragment: uri.hasFragment ? uri.fragment : null,
               pathSegments: pathSegments.isNotEmpty ? pathSegments : null,
               queryParameters: queryParameters);
  }
}

extension UriExtensions on Uri
{
  String get url => this.toString();

  String? get domain
  {
    if (!this.isAbsolute) return null;
    if (page != null) return url.replaceAll("/$page","");
    return url;
  }

  String? get page => (pathSegments.isNotEmpty && pathSegments.last.contains(".")) ? pathSegments.last : null;
  String? get pageExtension => page?.contains(".") ?? false ? extension(page!).toLowerCase().replaceFirst(".", "").trim() : null;

  String? get filepath
  {
    // file path
    if (isWeb) return null;
    if (scheme == "asset") return S.toAbsoluteFilePath(System.rootPath,"assets/$host/$path");
    if (scheme == "file")  return S.toAbsoluteFilePath(System.rootPath,"$host/$path");
    return null;
  }
}

