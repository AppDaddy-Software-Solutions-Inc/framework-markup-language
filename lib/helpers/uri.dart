import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fml/datasources/http/http.dart';
import 'package:fml/helpers/mime.dart';
import 'package:path/path.dart';

extension URI on Uri
{
  // active domain
  static String rootHost = "";
  static String rootPath = "";

  String  get url    => toString();
  String  get domain => replace(userInfo: null).removeFragment().removePage().removeQuery().url;
  String? get page   => (pathSegments.isNotEmpty && pathSegments.last.contains(".")) ? pathSegments.last : null;
  String? get pageExtension => page?.contains(".") ?? false ? extension(page!).toLowerCase().replaceFirst(".", "").trim() : null;

  String? asFilePath({String? domain})
  {
    if (page == null) return null;
    var folder = asFolderPath(domain: domain);
    var path   = normalize("$folder/$page");
    return path;
  }

  String asFolderPath({String? domain})
  {
    var root  = domain ?? rootPath;
    var uri  = removePage();
    var path = "${uri.host}/${uri.path}";
    if (uri.host != "applications") path = "applications/$path";
    path = normalize("$root/$path");
    return path;
  }

  Uri toAbsolute({String? domain})
  {
    var root = domain ?? rootHost;
    if (!this.isAbsolute)
    {
      var url = "$root/$host/$path";
      if (hasFragment)
      {
        url = "$url#$fragment";
      }
      if (hasQuery)    url = "$url?$query";
      var uri = Uri.parse(url).removeEmptySegments();
      return uri;
    }
    else {
      return this;
    }
  }

  Uri removeEmptySegments()
  {
    // url is a data uri?
    if (data != null) return this;

    // remove empty segments
    List<String> pathSegments = this.pathSegments.toList();
    pathSegments.removeWhere((segment) => Uri.decodeComponent(segment).trim() == "");

    // build a new uri
    return replace(pathSegments: pathSegments);
  }

  Uri removeQuery()
  {
    if (hasQuery) {
      return Uri.parse(url.split("?")[0]);
    } else {
      return this;
    }
  }

  Uri setPage(String page)
  {
    // url is a data uri?
    if (data != null) return this;

    List<String> pathSegments = this.pathSegments.toList();

    // remove last segment
    if (this.page != null) pathSegments.removeLast();
    pathSegments.add(page);

    // build a new uri
    return replace(pathSegments: pathSegments);
  }

  Uri removePage()
  {
    // url is a data uri?
    if (data != null) return this;

    // remove empty segments
    List<String> pathSegments = this.pathSegments.toList();
    if (page != null)
    {
      pathSegments.removeLast();

      // build a new uri
      return replace(pathSegments: pathSegments);
    }
    return this;
  }

  Uri addParameter(String key, String value)
  {
    // url is a data uri?
    if (data != null) return this;

    /* Get the Query Parameters */
    Map<String, List<String>> queryParameters = <String, List<String>>{};
    queryParameters.addAll(queryParametersAll);

    if (!queryParameters.containsKey(key)) queryParameters[key] = [];
    queryParameters[key]!.add(Uri.encodeComponent(value));

    /* Replace the Query String */
    return replace(queryParameters: queryParameters);
  }

  static Uri? parse(String? url, {String? domain})
  {
    // null or missing url
    if (url == null || url.trim() == "") return null;

    // fix for fragment # in query parameter
    // encode # to %23
    if (url.contains("#"))
    {
      var parts = url.split("?");
      if (parts.length > 1)
      {
        url = "${parts[0]}?${parts[1].replaceAll("#", "%23")}";
      }
    }

    // invalid url?
    Uri? uri = Uri.tryParse(url);
    if (uri == null) return null;

    // url is a data uri?
    if (uri.data != null) return uri;

    // because flutter is a SWA we need to ignore the /#/ for uri query param detection
    if (url.contains("/#")) uri = Uri.tryParse(url.replaceFirst("/#", "/"));
    if (uri == null) return null;

    // remove empty segments
    uri = uri.removeEmptySegments();

    // resolve uri
    uri = uri.toAbsolute(domain: domain);

    // build query parameters
    return uri;
  }

  static Future<UriData?> toUriData(String url) async
  {
    try
    {
      // parse the url
      Uri? uri = parse(url);

      // failed parse
      if (uri == null) return null;

      // already a data uri
      if (uri.data != null) return uri.data;

      // file reference
      if (uri.scheme == "file")
      {
        var filepath = uri.asFilePath();
        if (filepath == null) return null;
        var file  = File(filepath);
        var bytes = await file.readAsBytes();
        var mime  = await Mime.type(url);
        return UriData.fromBytes(bytes,mimeType: mime);
      }

      // file reference
      if (uri.scheme == "assets")
      {
        var assetpath = "${uri.scheme}/${uri.host}${uri.path}";
        ByteData bytes = await rootBundle.load(assetpath);
        var mime  = await Mime.type(url);
        return UriData.fromBytes(bytes.buffer.asUint8List(),mimeType: mime);
      }

      // remote image file
      var response = await Http.get(url);
      if (response.statusCode == HttpStatus.ok)
      {
        var bytes = response.bytes;
        var mime  = await Mime.type(url);
        return UriData.fromBytes(bytes, mimeType: mime);
      }
    }
    catch(e)
    {
      print("Error in toUriData using $url. Error is $e");
    }
    return null;
  }
}
