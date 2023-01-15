// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/config/config_model.dart';
import 'package:fml/crypto/crypto.dart';
import 'package:fml/hive/database.dart';
import 'package:fml/helper/helper_barrel.dart';

class App
{
  static String tableName = "APP";

  late Future<bool> initialized;

  // secure?
  bool get secure => _uri?.scheme == "https" || _uri?.scheme == "wss";

  // forces pages to repaint every visit
  bool get autoRefresh => S.toBool(settings("REFRESH")) ?? false;
  bool get singlePage  => S.toBool(settings('SINGLE_PAGE_APPLICATION')) ?? false;

  late final String key;
  late final String url;
  
  String? title;
  String? icon;
  int?    order;
  String? config;

  late final Uri? _uri;
  String? get domain => _uri?.domain;
  Map<String, String>? get queryParameters => _uri?.queryParameters;
  
  String  get homePage => settings("HOME_PAGE") ?? "main.xml";
  String? get loginPage => settings("LOGIN_PAGE");
  String? get debugPage => settings("DEBUG_PAGE");
  String? get unauthorizedPage => settings("UNAUTHORIZED_PAGE");
  String? get requestedPage => _uri?.page?.toLowerCase().trim().endsWith(".xml") ?? false ? _uri!.page : null;

  Map<String,String?>? get configParameters => _config?.parameters;

  ConfigModel? _config;

  App({required this.url, required this.title, this.icon, this.order})
  {
    // key is url (lowercase) hashed
    key = Cryptography.hash(text: url.toLowerCase());

    // parse to url into its parts
    _uri = Url.parse(url);

    // load the config
    initialized = initialize();
  }

  // initializes the app
  Future<bool> initialize() async
  {
    var model = await _getConfig(true);
    if (model != null) _config = model;
    return true;
  }


  Future<bool> insert() async => (await Database().insert(tableName, key, _toMap()) == null);
  Future<bool> update() async => (await Database().update(tableName, key, _toMap()) == null);
  Future<bool> delete() async => (await Database().delete(tableName, key) == null);
  static Future<bool> deleteAll() async => (await Database().deleteAll(tableName) == null);

  String? settings(String key)
  {
    if (_config == null) return null;
    if (_config!.settings.containsKey(key)) return _config!.settings[key];
    return null;
  }

  // refreshes the config file settings
  Future<bool> refresh() async
  {
    var model = await _getConfig(true);
    if (model != null) _config = model;
    return true;
  }

  // loads the config
  Future<ConfigModel?> _getConfig(bool refresh) async
  {
    ConfigModel? model;

    /// parse the config
    if (config != null)
    {
      var e = Xml.tryParse(config);
      if (e != null) model = await ConfigModel.fromXml(null, e.rootElement);
    }

    // get config from url
    if ((refresh || model == null) && _uri?.domain != null) model = await ConfigModel.fromUrl(null, _uri!.domain!);

    // model created?
    if (model != null)
    {
      // get the icon
      var icon = model.settings["APP_ICON"];
      if (icon != null)
      {
        var url = Url.toAbsolute(icon, domain: _uri?.domain);
        var uri = await Url.toUriData(url);
        if (uri != null) this.icon = uri.toString();
      }

      // set the config
      _config = model;

      // save to hive
      await update();
    }
    return model;
  }


  static App? _fromMap(dynamic map)
  {
    App? app;
    if (map is Map<String, dynamic>) app = App(url: S.mapVal(map, "url"), title: S.mapVal(map, "title"), icon: S.mapVal(map, "icon"), order: S.mapInt(map, "order"));
    return app;
  }

  Map<String, dynamic> _toMap()
  {
    Map<String, dynamic> map = {};
    map["key"]    = key;
    map["url"]    = url;
    map["title"]  = title;
    map["icon"]   = icon;
    map["order"]  = order;
    map["config"] = _config?.xml;
    return map;
  }

  static Future<List<App>> loadAll() async
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