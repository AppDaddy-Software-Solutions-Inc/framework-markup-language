// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:io';
import 'package:fml/system.dart';
import 'package:fml/token/token.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as HTTP;
import 'package:fml/helper/helper_barrel.dart';

int defaultTimeout = 60;

class HttpResponse {
  final String url;
  final dynamic body;
  final dynamic bytes;
  final int? statusCode;
  final String? contentType;
  final String? statusMessage;

  bool get ok
  {
    if (statusCode == null) return true;
    if (statusCode == HttpStatus.ok) return true;
    return false;
  }

  HttpResponse(this.url, {this.body, this.bytes, this.contentType, this.statusCode, this.statusMessage});

  factory HttpResponse.factory(String url, HTTP.Response response)
  {
    // content type
    String? contentType;
    if (response.headers.containsKey(HttpHeaders.contentTypeHeader)) contentType = response.headers[HttpHeaders.contentTypeHeader];

    // This was commented out on December 16, 2022 and response.body used in its place. If the response body screws up this is the likely culprit
    // body
    //dynamic body;
    //try {body = utf8.decode(response.bodyBytes);} catch (e) {body = null;}

    return HttpResponse(url, body: response.body, bytes: response.bodyBytes, contentType: contentType, statusCode: response.statusCode, statusMessage: response.reasonPhrase);
  }
}

class Http
{
  static Future<HttpResponse> get(String url, {Map<String, String>? headers, int? timeout = 60, bool refresh = false}) async
  {
    try
    {
      // convert url
      Uri? uri = encodeUri(url, refresh: refresh);
      if (uri != null)
      {
        // execute request
        Response response = await HTTP.get(uri, headers: encodeHeaders(headers)).timeout(Duration(seconds: (((timeout != null) && (timeout > 0)) ? timeout : defaultTimeout)));

        // decode headers
        decodeHeaders(response);

        // return response
        return HttpResponse.factory(url, response);
      }
      else return HttpResponse(url, statusCode: HttpStatus.internalServerError, statusMessage: "Url $url is invalid");
    }
    catch (e)
    {
      var msg = e.toString();

      // endpoint not found or unreachable
      if ((msg.toLowerCase().startsWith('xmlhttp'))) return HttpResponse(url, statusCode: HttpStatus.notFound, statusMessage: "Not Found: " + msg);

      return HttpResponse(url, statusCode: HttpStatus.internalServerError, statusMessage: msg);
    }
  }

  static Future<HttpResponse> post(String url, String body, {Map<String, String>? headers, int? timeout = 60}) async
  {
    try
    {
      // convert url
      Uri? uri = encodeUri(url, refresh: false);
      if (uri != null)
      {
        // execute request
        Response response = await HTTP.post(uri, headers: encodeHeaders(headers), body: body).timeout(Duration(seconds: (((timeout != null) && (timeout > 0)) ? timeout : defaultTimeout)));

        // decode headers
        decodeHeaders(response);

        // return response
        return HttpResponse.factory(url, response);
      }
      else return HttpResponse(url, statusCode: HttpStatus.internalServerError, statusMessage: "Url $url is invalid");
    }
    catch (e)
    {
      return HttpResponse(url, statusCode: HttpStatus.internalServerError, statusMessage: e.toString());
    }
  }

  static Future<HttpResponse> put(String url, String body, {Map<String, String>? headers, int? timeout = 60}) async
  {
    try
    {
      // convert url
      Uri? uri = encodeUri(url, refresh: false);
      if (uri != null)
      {
        // execute request
        Response response = await HTTP.put(uri, headers: encodeHeaders(headers), body: body).timeout(Duration(seconds: (((timeout != null) && (timeout > 0)) ? timeout : defaultTimeout)));

        // decode headers
        decodeHeaders(response);

        // return response
        return HttpResponse.factory(url, response);
      }
      else return HttpResponse(url, statusCode: HttpStatus.internalServerError, statusMessage: "Url $url is invalid");
    }
    catch (e)
    {
      return HttpResponse(url, statusCode: HttpStatus.internalServerError, statusMessage: e.toString());
    }
  }

  static Future<HttpResponse> patch(String url, String? body, {Map<String, String>? headers, int? timeout = 60}) async
  {
    try
    {
      // convert url
      Uri? uri = encodeUri(url, refresh: false);
      if (uri != null)
      {
        // execute request
        Response response = await HTTP.patch(uri, headers: encodeHeaders(headers), body: body).timeout(Duration(seconds: (((timeout != null) && (timeout > 0)) ? timeout : defaultTimeout)));

        // decode headers
        decodeHeaders(response);

        // return response
        return HttpResponse.factory(url, response);
      }
      else return HttpResponse(url, statusCode: HttpStatus.internalServerError, statusMessage: "Url $url is invalid");
    }
    catch (e)
    {
      return HttpResponse(url, statusCode: HttpStatus.internalServerError, statusMessage: e.toString());
    }
  }

  static Future<HttpResponse> delete(String url, {Map<String, String>? headers, int? timeout = 60}) async
  {
    try
    {
      // convert url
      Uri? uri = encodeUri(url, refresh: false);
      if (uri != null)
      {
        // execute request
        Response response = await HTTP.delete(uri, headers: encodeHeaders(headers)).timeout(Duration(seconds: (((timeout != null) && (timeout > 0)) ? timeout : defaultTimeout)));

        // decode headers
        decodeHeaders(response);

        // return response
        return HttpResponse.factory(url, response);
      }
      else return HttpResponse(url, statusCode: HttpStatus.internalServerError, statusMessage: "Url $url is null or invalid");
    }
    catch (e)
    {
      return HttpResponse(url, statusCode: HttpStatus.internalServerError, statusMessage: e.toString());
    }
  }

  static Uri? encodeUri(String url, {bool refresh = false})
  {
    Uri? uri = Url.parse(url);
    if (uri == null) return null;

    Map<String, dynamic> parameters = {};
    parameters.addAll(uri.queryParameters);
    if (refresh == true) parameters["refresh"] = System().uuid();
    parameters.forEach((key, value) => Uri.encodeComponent(value));
    return uri.replace(queryParameters: parameters);
  }

  static Map<String, String> encodeHeaders(Map<String, String>? headers)
  {
    Map<String, String> _headers = {};
    if (headers == null)
    {
      _headers[HttpHeaders.ageHeader] = '0';
      _headers[HttpHeaders.contentEncodingHeader] = 'utf8';
      _headers[HttpHeaders.contentTypeHeader] = "application/xml";
      if (System().token != null) _headers[HttpHeaders.authorizationHeader] = "Bearer ${System().token!.token}";
    }
    else headers.forEach((key, value) => _headers[key] = value);
    return _headers;
  }

  static void decodeHeaders(Response response) {
    if ((!response.headers.containsKey(HttpHeaders.authorizationHeader)) ||
        (S.isNullOrEmpty(response.headers[HttpHeaders.authorizationHeader])))
      return;

    // authorization header
    String token = response.headers[HttpHeaders.authorizationHeader]!
        .replaceAll("Bearer", "")
        .trim();

    // decode token
    Jwt jwt = Jwt.decode(token);
    if (jwt.valid) System().logon(jwt);
  }
}

class MultipartRequest extends HTTP.MultipartRequest {
  MultipartRequest(String method, Uri url, {this.onProgress})
      : super(method, url);

  final void Function(int bytes, int totalBytes)? onProgress;

  HTTP.ByteStream finalize() {
    final byteStream = super.finalize();
    if (onProgress == null) return byteStream;

    final total = this.contentLength;
    int bytes = 0;

    final t = StreamTransformer.fromHandlers(
        handleData: (List<int> data, EventSink<List<int>> sink) {
      bytes += data.length;
      onProgress!(bytes, total);
      sink.add(data);
    });
    final stream = byteStream.transform(t);
    return HTTP.ByteStream(stream);
  }
}
