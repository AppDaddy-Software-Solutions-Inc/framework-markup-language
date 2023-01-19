import 'package:path/path.dart';

extension URI on Uri
{
  // active domain
  static String rootHost = "";
  static String rootPath = "";

  String  get url    => this.toString();
  String  get domain => replace(queryParameters: null).replace(fragment: null).replace(userInfo: null).replacePage().url;
  String? get page   => (pathSegments.isNotEmpty && pathSegments.last.contains(".")) ? pathSegments.last : null;
  String? get pageExtension => page?.contains(".") ?? false ? extension(page!).toLowerCase().replaceFirst(".", "").trim() : null;

  String? asFilePath()
  {
    var domain = replace(queryParameters: null).replace(fragment: null).replace(userInfo: null).url;
    if (!domain.startsWith(rootPath.toLowerCase()))
         return join(rootPath,domain);
    else return rootPath;
  }

  String asFolderPath(String rootPath)
  {
    var domain = replace(queryParameters: null).replace(fragment: null).replace(userInfo: null).replacePage().url;
    if (!domain.startsWith(rootPath.toLowerCase()))
         return join(rootPath,domain);
    else return rootPath;
  }

  Uri toAbsolute()
  {
    var before = this.toString();

    String host = URI.rootHost;

    // url is a data uri?
    if (data != null) return this;

    // file uri?
    if (scheme == "file")
    {
      host = rootPath;
      if (this.host == "applications") host = "$host/applications";
    }

    // asset uri?
    if (scheme == "asset")
    {
      host = rootPath;
      if (this.host == "assets") host = "$host/assets";
    }

    var uri = resolve(host).normalizePath();
    var after = uri.toString();
    return uri;
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

  Uri replacePage()
  {
    // url is a data uri?
    if (data != null) return this;

    // remove empty segments
    List<String> pathSegments = this.pathSegments.toList();
    if (this.page != null)
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
    Map<String, List<String>> queryParameters = Map<String, List<String>>();
    queryParameters.addAll(queryParametersAll);

    if (!queryParameters.containsKey(key)) queryParameters[key] = [];
    queryParameters[key]!.add(Uri.encodeComponent(value));

    /* Replace the Query String */
    return replace(queryParameters: queryParameters);
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
    if (url.contains("/#")) uri = Uri.tryParse(url.replaceFirst("/#", "/"));
    if (uri == null) return null;

    // remove empty segments
    uri = uri.removeEmptySegments();

    // resolve uri
    uri = uri.toAbsolute();

    // build query parameters
    return uri;
  }
}
