// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:fml/hive/settings.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/datasources/http/http.dart';
import 'package:fml/helper/helper_barrel.dart';
import 'package:http/http.dart' as http;

class StoreModel extends WidgetModel
{
  StoreModel() : super(null, "STORE", scope: Scope("STORE"))
  {
    // instantiate busy observable
    busy = false;
  }

  Future<String?> link(String url) async
  {
    bool found = false;
    String domain = url;

    ///////////////////
    /* Verify Domain */
    ///////////////////
    Uri? uri = Uri.tryParse(domain);
    HttpResponse response;

    //////////////
    /* Try Http */
    //////////////
    if ((!found) && (uri!.hasScheme))
    {
      domain = url;
      response = await Http.get(domain + '/' + 'config.xml', timeout: 5, refresh: true);
      if (response.ok) found = true;
    }

    //////////////
    /* Try Http */
    //////////////
    if ((!found) && (!uri.hasScheme))
    {
      domain = 'http://' + url;
      response = await Http.get(domain + '/' + 'config.xml', timeout: 5, refresh: true);
      if (response.ok) found = true;
    }

    ///////////////
    /* Try Https */
    ///////////////
    if ((!found) && (!uri.hasScheme))
    {
      domain = 'https://' + url;
      response = await Http.get(domain + '/' + 'config.xml', timeout: 5, refresh: true);
      if (response.ok) found = true;
    }

    if (found)
    {
      await System().initializeDomainConnection(domain);
    }

    return found == true ? domain : null;
  }

  Future<Map<String, String?>> store() async
  {
    LinkedHashMap? apps = await Settings().get('appstore');
    Map<String, String?> appstore = {};
    if (apps != null && apps != {})
    {
      appstore = apps.map((key, value) => MapEntry(key, value));
      Log().info('appstore: $appstore');
    }
    return appstore;
  }

  addApp(String link, {String? friendlyName}) async {
    busy = true;
    LinkedHashMap? apps = await Settings().get('appstore');
    Map<String, String> appstore = {};
    if (apps != null && apps != {}) {
      appstore = apps.map((key, value) => MapEntry(key, value));
    }
    if (!appstore.containsValue(link)) appstore.addAll({link: friendlyName ?? link});
    await Settings().set('appstore', appstore);
    busy = false;
  }

  deleteApps() async {
    Settings().set('appstore', {});
  }

  removeApp(String keyValue) async {
    busy = true;
    LinkedHashMap? apps = await Settings().get('appstore');
    Map<String, String> appstore = {};
    if (apps != null && apps != {}) {
      appstore = apps.map((key, value) => MapEntry(key, value));
    }
    // if (appstore.containsValue(keyValue))
      appstore.remove(keyValue);
    await Settings().set('appstore', appstore);
    busy = false;
  }

  Future<String?> getBase64IconImage(String url) async {
    String? base64;
    try {
      base64 = await Settings().get('ASSETS:$url', defaultValue: null);
    }
    catch(e)
    {
      Log().debug('Unable to getBase64IconImage from cache APP_ICON');
    }
    return base64;
  }

  setBase64IconImage(String url) async
  {
    String? base64;
    try
    {
      if (!S.isNullOrEmpty(url)) base64 = await networkImageToBase64(url);
      if (!S.isNullOrEmpty(base64)) await Settings().set('ASSETS:$url', base64);
    }
    catch(e)
    {
      Log().error('Unable to setBase64IconImage to cache APP_ICON');
      Log().exception(e);
    }
  }

  Future<String?> networkImageToBase64(String imageUrl) async {
    Uri? uri = S.toURI(imageUrl);
    if (uri == null) return null;
    try {
      http.Response response = await http.get(uri);
      final bytes = response.bodyBytes;
      return base64Encode(bytes);
    } catch(e) {
      return null;
    }
  }

}