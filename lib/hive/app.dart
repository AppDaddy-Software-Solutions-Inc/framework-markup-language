// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/config/config_model.dart';
import 'package:fml/crypto/crypto.dart';
import 'package:fml/hive/database.dart';
import 'package:fml/helper/helper_barrel.dart';

enum Fields {key, url, title, icon, order}

class App
{
  static String tableName = "APP";

  // secure?
  bool get secure => scheme == "https" || scheme == "wss";

  // forces pages to repaint every visit
  bool get refresh => S.toBool(settings("REFRESH")) ?? false;
  bool get singlePage => S.toBool(settings('SINGLE_PAGE_APPLICATION')) ?? false;

  Map<String, dynamic> _map = Map<String, dynamic>();

  String  get key    => _map["key"];
  String  get url    => _map["url"];
  String? get title  => _map["title"];
  String? get icon   => _map["icon"];
  int?    get order  => _map["order"];
  String? get xml    => _map["xml"];

  late final String? scheme;
  late final String? host;
  late final String? fqdn;
  late final String? page;
  late final int? port;
  late final Map<String,String>? parameters;

  String  get homePage => settings("HOME_PAGE") ?? "main.xml";
  String? get loginPage => settings("LOGIN_PAGE");
  String? get debugPage => settings("DEBUG_PAGE");
  String? get unauthorizedPage => settings("UNAUTHORIZED_PAGE");
  String? get requestedPage => page;

  Map<String,String?>? get configParameters => _config?.parameters;

  ConfigModel? _config;

  App({required String url, required String title, String? icon, int? order, String? xml})
  {
    // key is url (lowercase) hashed
    _map["key"]   = Cryptography.hash(text: url.toLowerCase());
    _map["url"]   = url;
    _map["title"] = title;
    _map["icon"]  = icon;
    _map["order"] = order;
    _map["xml"]   = xml;

    var uri = Url.toUrlData(url);
    fqdn       = uri?.fqdn;
    scheme     = uri?.scheme;
    port       = uri?.port;
    host       = uri?.host;
    parameters = uri?.parameters;

    // load the config
    _getConfig(true);
  }

  String? settings(String key)
  {
    if (_config == null) return null;
    if (_config!.settings.containsKey(key)) return _config!.settings[key];
    return null;
  }

  // refreshes the config file settings
  Future<bool> refreshConfig() async
  {
    var model = await _getConfig(true);
    if (model != null) _config = model;
    return true;
  }

  // loads the config
  Future<ConfigModel?> _getConfig(bool refresh) async
  {
    ConfigModel? model;
    if (xml != null)
    {
      var e = Xml.tryParse(xml);
      if (e != null) model = await ConfigModel.fromXml(null, e.rootElement);
    }
    if (refresh || model == null)
    {
      if (fqdn != null) model = await ConfigModel.fromUrl(null, fqdn!);
    }
    if (model != null)
    {
      var icon = model.settings["APP_ICON"];
      if (icon != null)
      {
        Url.toUrlData(icon);
      }
      _config = model;
    }
    return model;
  }

  Future<bool> insert() async => (await Database().insert(tableName, key, _map) == null);
  Future<bool> update() async => (await Database().update(tableName, key, _map) == null);
  Future<bool> delete() async => (await Database().delete(tableName, key) == null);

  static Future<bool> deleteAll() async => (await Database().deleteAll(tableName) == null);

  static App? _fromMap(dynamic map)
  {
    App? app;
    if (map is Map<String, dynamic>) app = App(url: S.mapVal(map, "url"), title: S.mapVal(map, "title"), icon: S.mapVal(map, "icon"), order: S.mapInt(map, "order"));
    return app;
  }

  static Future<List<App>> load() async
  {
    List<App> apps = [];
    List<Map<String, dynamic>> entries = await Database().query(tableName);
    entries.forEach((entry)
    {
      App? app = _fromMap(entry);
      if (app != null) apps.add(app);
    });
    return apps;
  }
}