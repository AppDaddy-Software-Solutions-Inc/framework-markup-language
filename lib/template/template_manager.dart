// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:collection';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'package:xml/xml.dart';
import 'package:fml/datasources/http/http.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fml/hive/form.dart';
import 'package:fml/helper/common_helpers.dart';

class TemplateManager
{
  // holds in-memory deserialized templates
  // primarily used for performance reasons
  HashMap<String, XmlDocument> templates = HashMap<String, XmlDocument>();

  static final TemplateManager _singleton = TemplateManager._init();
  factory TemplateManager()
  {
    return _singleton;
  }
  TemplateManager._init();

  XmlDocument? fromJs(String? xml)
  {
    XmlDocument? template;
    try {
      template = Xml.tryParse(xml);
      if (template == null) { // invalid xml from the js2fml data
        Log().warning('Template Parsing Error, likely invalid syntax', caller: 'template_manager.dart: fromJs()');
        template = Xml.tryParse('<FML><CENTER><TEXT style="h6" value="Template Parsing Error" /></CENTER></FML>');
      }
    } catch(e) {
      Log().exception(e, caller: 'template_manager.dart: fromJs()');
      template = null;
    }
    return template;
  }

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
      Form? form = await Form.find(key);
      if (form != null) template = form.template;
    }
    catch(e)
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
    catch(e)
    {
      template = null;
    }
    return template;
  }

  Future<String?> fromDisk(String url) async
  {
    String? template;
    try
    {
      // not supported on web
      if (isWeb)    throw('Local Files not supported in Browser');
      if (isMobile) throw('Local Files not supported in Mobile');

      // get template from file
      Uri? uri = URI.parse(url);
      String? filepath = uri?.asFilePath();
      template = await Platform.readFile(filepath);
    }
    catch(e)
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
    catch(e)
    {
      Log().error("Can't find valid template $url on server. Error is $e");
    }
    return template;
  }

  Future<bool> toDisk(String url, String xml) async
  {
    var uri = URI.parse(url);
    if (uri != null)
    {
      var filepath = uri.asFilePath();
      Log().debug ("Writing $url to $filepath");
      return await Platform.writeFile(filepath, xml);
    }
    return false;
  }
}