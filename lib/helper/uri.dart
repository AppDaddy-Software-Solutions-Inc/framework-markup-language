import 'package:path/path.dart';

// platform
import 'package:fml/platform/platform.stub.dart'
if (dart.library.io)   'package:fml/platform/platform.vm.dart'
if (dart.library.html) 'package:fml/platform/platform.web.dart';

extension URI on Uri
{
  // active domain
  static String rootHost = "";
  static String rootPath = "";

  String  get url    => this.toString();
  String  get domain => replace(queryParameters: null).replace(fragment: null).removePage().url;
  String? get page   => (pathSegments.isNotEmpty && pathSegments.last.contains(".")) ? pathSegments.last : null;
  String? get pageExtension => page?.contains(".") ?? false ? extension(page!).toLowerCase().replaceFirst(".", "").trim() : null;

  String? asFilePath({String? domain})
  {
    var root = domain ?? rootPath;
    if (page == null) return null;
    var uri = this;
    var url = "${uri.host}/${uri.path}";
    if (uri.scheme == "file"  && uri.host != "applications") url = "applications/$url";
    if (uri.scheme == "asset" && uri.host != "assets")       url = "assets/$url";
    url = normalize("$root/$url");
    return url;
  }

  String asFolderPath({String? domain})
  {
    var root = domain ?? rootPath;
    var uri = this.removePage();
    var url = "${uri.host}/${uri.path}";
    if (uri.scheme == "file"  && uri.host != "applications") url = "applications/$url";
    if (uri.scheme == "asset" && uri.host != "assets")       url = "assets/$url";
    url = normalize("$root/$url");
    return url;
  }

  Uri toAbsolute({String? domain})
  {
    var root = domain ?? rootHost;
    if (!this.isAbsolute)
    {
      var url = "$root/${this.host}/${this.path}";
      if (hasFragment) url = "$url#$fragment";
      if (hasQuery)    url = "$url?$query";
      var uri = Uri.parse(url).removeEmptySegments();
      return uri;
    }
    else return this;
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

  Uri removePage()
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

  static Uri? parse(String? url, {String? domain})
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
    uri = uri.toAbsolute(domain: domain);

    // build query parameters
    return uri;
  }

  Uri resolve(String domain)
  {
    if (!this.isAbsolute)
    {
      var url = "$domain/${this.host}/${this.path}";
      if (hasFragment) url = "$url#$fragment";
      if (hasQuery)    url = "$url?$query";
      var uri = Uri.parse(url).removeEmptySegments();
      return uri;
    }
    else return this;
  }
}
