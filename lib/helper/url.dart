// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/system.dart';
import 'package:fml/helper/helper_barrel.dart';

/// URL Helpers
///
/// Helper functions that can be used by importing *url.dart*
/// Example ```dart
/// String myUrl = "https://appdaddy.co"
/// Uri myUri = Url.toUri(myUrl); // Convert a URL String to a Uri
/// ```
class Url
{
  /// Takes a valid Url String and parses it to a [Uri]
  static Uri? toUri(String? url)
  {
    if (url == null) return null;
    Uri? uri = Uri.tryParse(url);
    return uri;
  }

  // TODO
  static bool isRelative(String? url)
  {
    bool hasAuthority = false;
    Uri? uri = toUri(url);
    if (uri != null) hasAuthority = uri.hasAuthority;
    return (!hasAuthority);
  }

  // TODO
  static bool isAbsolute(String url)
  {
    return !isRelative(url);
  }

  /// Takes a Url String and if it is a relative path, prepends it with the domain
  static String toAbsolute(String url, {String? domain})
  {
    if (isRelative(url)) url = (domain ?? System().domain ?? "") + (url.startsWith('/') ? '' : '/') + url;
    return url;
  }

  /// Checks if a String is a valid Uri
  static bool isUrl(String url)
  {
    Uri? uri = toUri(url);

    //////////////////
    /* Web Address? */
    //////////////////
    return ((uri != null) && (uri.hasAuthority));
  }

  /// Url-safe encoding of a String
  ///
  /// For example if your String contains a `/` it will encode this to `%2F`
  static String? encode(String url)
  {
    Uri? uri = toUri(url);
    if (uri == null) return null;

    /////////////////////////////
    /* Encode Parameter Values */
    /////////////////////////////
    if (uri.hasQuery)  uri.queryParameters.forEach((key, value) => Uri.encodeComponent(value));

    ///////////////////////
    /* Convert to String */
    ///////////////////////
    return uri.toString();
  }

  /// Takes a valid Url String and appends a key-value pair as a parameter
  static String addParameter(String url, String key, String? value)
  {
    if ((S.isNullOrEmpty(url)) || (S.isNullOrEmpty(key))) return url;

    Uri? uri = toUri(url);
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

  /// Takes a valid String Url and removes a parameter if it matches by key and optionally by key-value
  static String removeParameter(String url, String key, {String? value})
  {
    if ((S.isNullOrEmpty(url)) || (S.isNullOrEmpty(key))) return url;

    Uri? uri = toUri(url);
    if (uri == null) return url;

    //////////////////////////////
    /* Get the Query Parameters */
    //////////////////////////////
    Map<String, List<String>> parameters = Map<String, List<String>>();
    parameters.addAll(uri.queryParametersAll);

    //////////////////////
    /* Remove Parameter */
    //////////////////////
    if ((value != null) && (parameters.containsKey(key)) && parameters[key]!.contains(value)) parameters[key]!.remove(value);
    if ((value == null) && (parameters.containsKey(key))) parameters.remove(key);

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

  /// Takes a valid String Url and returns the specified parameter
  static String? getParameter(String url, String key)
  {
    // valid url?
    if (S.isNullOrEmpty(url) || S.isNullOrEmpty(key)) return null;

    // get uri
    Uri? uri = toUri(url);
    if (uri == null) return null;

    // query has specified key?
    if (uri.hasQuery && uri.queryParameters.containsKey(key)) return uri.queryParameters[key];

    // key not found
    return null;
  }

  /// Returns the scheme component of a valid String Url
  static String? scheme(String url)
  {
    Uri? uri = toUri(url);
    if (uri == null) return null;
    if (!uri.hasAuthority) uri = toUri('http://' + url);
    return uri!.hasScheme ? uri.scheme : null;
  }
  /// Returns the authority component of a valid String Url
  static String? authority(String url)
  {
    Uri? uri = toUri(url);
    if (uri == null) return null;
    if (!uri.hasAuthority) uri = toUri('http://' + url);
    return uri!.hasAuthority ? uri.authority : null;
  }

  /// Returns the host component of a valid String Url
  static String? host(String url)
  {
    Uri? uri = toUri(url);
    if (uri == null) return null;
    if (!uri.hasAuthority) uri = toUri('http://' + url);
    return  uri!.host;
  }

  /// Returns the path component of a valid String Url
  static String? path(String url)
  {
    Uri? uri = toUri(url);
    if (uri == null) return null;
    if (!uri.hasAuthority) uri = toUri('http://' + url);
    String path = uri!.host;
    uri.pathSegments.forEach((segment) => path = path + "/" + segment);
    return path;
  }

  /// Returns the parameter components of a valid String Url as a Map<String, String>
  static Map<String, String>? parameters(String url)
  {
    Map<String, String> parameters = Map<String, String>();

    Uri? uri = toUri(url);
    if (uri == null) return null;
    if (!uri.hasAuthority) uri = toUri('http://' + url);
    if (uri!.hasQuery) uri.queryParameters.forEach((key, value) => parameters[key] = value);

    return parameters;
  }

}

