// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:collection';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'package:xml/xml.dart';
import 'package:fml/datasources/http/http.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fml/hive/form.dart' as DATABASE;
import 'package:fml/helper/common_helpers.dart';

// platform
import 'package:fml/platform/platform.stub.dart'
if (dart.library.io)   'package:fml/platform/platform.vm.dart'
if (dart.library.html) 'package:fml/platform/platform.web.dart';

class TemplateManager
{
  // holds in-memory deserialized templates
  // primarily used for performance reasons
  HashMap<String, XmlDocument> templates = HashMap<String, XmlDocument>();

  static TemplateManager _singleton = TemplateManager._init();
  factory TemplateManager()
  {
    return _singleton;
  }
  TemplateManager._init();

  XmlDocument? fromMemory(String url)
  {
    var uri = URI.parse(url);
    if (uri != null && templates.containsKey(uri.url)) return templates[uri.url];
    return null;
  }

  toMemory(String url, XmlDocument? document)
  {
    var uri = URI.parse(url);
    if (uri != null && document != null) templates[uri.url] = document;
  }

  Future<String?> fromDatabase(String key) async
  {
    String? template;
    try
    {
      // lookup from local hive
      DATABASE.Form? form = await DATABASE.Form.find(key);
      if (form != null) template = form.template;
    }
    catch (e)
    {
      Log().exception(e);
      template = null;
    }
    return template;
  }

  Future<String?> fromAssetsBundle(String url) async
  {
    String? template;
    try
    {
      // not supported on web
      if (isWeb) throw('Local Files not supported in Browser');

      // get template from asset bundle
      template = await rootBundle.loadString(url.replaceFirst("file://", "assets/"), cache: false);
    }
    catch (e)
    {
      template = null;
    }
    return template;
  }

  Future<String?> fromFile(String url) async
  {
    String? template;
    try
    {
      // not supported on web
      if (isWeb)    throw('Local Files not supported in Browser');
      if (isMobile) throw('Local Files not supported in Mobile');

      // get template from file
      Uri? uri = URI.parse(url);
      if (uri != null)
      {
        var filepath = uri.asFilePath();
        var file = Platform.getFile(filepath);
        if (file != null) template = await Platform.readFile(url);
      }
    }
    catch (e)
    {
      template = null;
    }
    return template;
  }

  Future<String?> fromServer(String url) async
  {
    String? template;
    try
    {
      // get template from remote server
      if (System().connected)
      {
        // get the template from the cloud
        HttpResponse response = await Http.get(url, refresh: true);
        if (!response.ok) throw '[${response.statusCode}] ${response.statusMessage}';
        template = response.body;
      }
      else
      {
        Log().debug("Unable to fetch template from server. No internet connection");
      }
    }
    catch (e)
    {
      Log().error("Can't find valid template $url on server. Error is $e");
    }
    return template;
  }

  Future<String?> fromDisk(String url) async
  {
    String? template;
    try
    {
      var uri = URI.parse(url);
      if (uri != null)
      {
        bool exists = Platform.fileExists(uri.url);
        if (exists) template = await Platform.readFile(uri.url);
      }
    }
    catch (e)
    {
      Log().exception(e);
      template = null;
    }
    return template;
  }

  Future<bool> toDisk(String url, String xml) async
  {
    var uri = URI.parse(url);
    if (uri != null)
    {
      var filepath = uri.asFilePath();
      Log().debug('Writing $url to $filepath", object: "TEMPLATE"');
      return await Platform.writeFile(filepath, xml);
    }
    return false;
  }
}