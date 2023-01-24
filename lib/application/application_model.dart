// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fml/config/config_model.dart';
import 'package:fml/hive/database.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/mirror/mirror.dart';
import 'package:fml/observable/scope_manager.dart';
import 'package:fml/system.dart';
import 'package:fml/template/template.dart';
import 'package:fml/token/token.dart';
import 'package:fml/widgets/theme/theme_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:xml/xml.dart';

class ApplicationModel extends WidgetModel
{
  static final String myId = "APPLICATION";

  static String tableName = "APP";

  late final String key;

  late Future<bool> initialized;

  // used for social media
  FirebaseApp? firebase;

  ScopeManager scopeManager = ScopeManager();

  // mirrors
  Mirror? mirror;
  bool get cacheContent => (mirror != null);

  // secure?
  bool get secure => _uri?.scheme == "https" || _uri?.scheme == "wss";

  // forces pages to repaint every visit
  bool get autoRefresh => S.toBool(settings("REFRESH")) ?? false;
  bool get singlePage  => S.toBool(settings('SINGLE_PAGE_APPLICATION')) ?? false;

  late final String url;

  // application title
  String? title;

  // application icon
  String? icon;

  // application icons position
  // on the store display (future use for multi-page and ordering)
  String? page;
  int? order;

  // config
  String? config;
  ConfigModel? _config;
  bool get hasConfig => _config != null;

  // application stash
  Map<String, String> _stash = {};

  // jwt - json web token
  Jwt? jwt;

  late final Uri? _uri;
  String? get domain => _uri?.domain;
  String? get scheme => _uri?.scheme;
  String? get host   => _uri?.host;

  // fml version support
  int? fmlVersion;

  Map<String, String>? get queryParameters => _uri?.queryParameters;
  
  String  get homePage         => settings("HOME_PAGE") ?? "main.xml";
  String? get loginPage        => settings("LOGIN_PAGE");
  String? get debugPage        => settings("DEBUG_PAGE");
  String? get unauthorizedPage => settings("UNAUTHORIZED_PAGE");

  Map<String,String?>? get configParameters => _config?.parameters;

  ApplicationModel({String? key, required this.url, this.title, this.icon, this.page, this.order, String? jwt, dynamic stash}) : super(System(), myId)
  {
    // sett application key
    this.key = key ?? id;

    // parse to url into its parts
    _uri = URI.parse(url);

    // set token
    if (jwt != null)
    {
      var token = Jwt(jwt);
      if (token.valid) this.jwt = token;
    }

    // build stash
    if (stash is Map) stash.forEach((key, value) => _stash[key.toString()] = value.toString());

    // load the config
    initialized = initialize();
  }

  static Future<ApplicationModel?> _fromMap(dynamic map) async
  {
    ApplicationModel? app;
    if (map is Map<String, dynamic>)
    {
      app = ApplicationModel(key: S.mapVal(map, "key"), url: S.mapVal(map, "url"), title: S.mapVal(map, "title"), icon: S.mapVal(map, "icon"), page: S.mapVal(map, "page"), order: S.mapInt(map, "order"), jwt: S.mapVal(map, "jwt"), stash: S.mapVal(map, "stash"));
      await app.initialized;
    }
    return app;
  }

  // initializes the app
  Future<bool> initialize() async
  {
    // wait for the system to initialize
    await System.initialized;

    // add system scope
    this.scopeManager.add(System().scope!);

    // add GLOBAL alias to this scope
    this.scopeManager.add(scope!, alias: "GLOBAL");

    var config = await _getConfig(true);
    if (config != null) _config = config;

    // get global template
    await _buildGlobals();

    return true;
  }

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
    if ((refresh || model == null) && _uri?.domain != null) model = await ConfigModel.fromUrl(null, _uri!.domain);

    // model created?
    if (model != null)
    {
      // set fml version support level
      fmlVersion = S.toVersionNumber(model.settings["FML_VERSION"]);

      // get the icon
      var icon = model.settings["APP_ICON"];
      if (icon != null && _uri?.domain != null)
      {
        Uri? uri = URI.parse(icon, domain: _uri!.domain);
        if (uri != null)
        {
          var data = await URI.toUriData(uri.url);
          if (data != null)
               this.icon = data.toString();
          else this.icon = null;
        }
      }

      // mirror?
      var mirrorApi = model.settings["MIRROR_API"];
      if (mirrorApi != null && !isWeb && _uri?.scheme != "file")
      {
        Uri? uri = URI.parse(mirrorApi, domain: _uri?.domain);
        if (uri != null)
        {
          mirror = Mirror(uri.url);
          mirror!.execute();
        }
      }

      // set the config
      _config = model;

      // save to hive
      await update();

      notifyListeners("config", null);
    }
    return model;
  }

  // loads the globals
  Future _buildGlobals() async
  {
    Uri? uri = URI.parse(url);
    if (uri != null)
    {
      // get global.xml
      uri = uri.setPage("global.xml");
      XmlDocument? template = await Template.fetchTemplate(url: uri.url, refresh: true);

      // deserialize the returned template
      if (template != null) this.deserialize(template.rootElement);
    }
  }

  void setTheme(ThemeModel theme)
  {
    /// Initial Theme Setting
    String def = 'light';
    String cBrightness = settings('BRIGHTNESS')?.toLowerCase() ?? def;
    if (cBrightness == 'system' || cBrightness == 'platform')
    try
    {
      cBrightness = MediaQueryData.fromWindow(WidgetsBinding.instance.window).platformBrightness.toString().toLowerCase().split('.')[1];
    }
    catch (e)
    {
      cBrightness = def;
    }

    // theme values from the app
    theme.brightness  = cBrightness;
    theme.colorscheme = settings('PRIMARY_COLOR')?.toLowerCase() ?? 'lightblue'; // backwards compatibility
    theme.colorscheme = settings('COLOR_SCHEME')?.toLowerCase()  ?? theme.colorscheme;
    theme.font        = settings('FONT');
  }

  Future<bool> stash(String key, dynamic value) async
  {
    bool ok = true;
    try
    {
      // key must be supplied
      if (S.isNullOrEmpty(key)) return ok;

      // write application stash entry
      _stash[key] = value.toString();

      // save to the hive
      await update();

      // set observable
      scope?.setObservable("STASH.$key", value);
    }
    catch (e)
    {
      // stash failure always returns true
      ok = true;
    }
    return ok;
  }

  void launch({ThemeModel? theme})
  {
    // set stash values
    for (var entry in _stash.entries) scope?.setObservable("STASH.${entry.key}", entry.value);

    // start all datasources
    if (datasources != null)
    for (var datasource in datasources!)
    {
      if (datasource.autoexecute != false) datasource.start();
      datasource.initialized = true;
    }

    // set the theme if supplied
    if (theme != null) setTheme(theme);
  }

  void close()
  {
    // clear stash values
    for (var entry in _stash.entries) scope?.setObservable("STASH.${entry.key}", null);

    // start all datasources
    if (datasources != null)
      for (var datasource in datasources!) datasource.stop();
  }


  void dispose()
  {
    // close the app
    close();

    // dispose of all children
    super.dispose();
  }

  Map<String, dynamic> _toMap()
  {
    Map<String, dynamic> map = {};
    map["key"]    = key;
    map["url"]    = url;
    map["title"]  = title;
    map["icon"]   = icon;
    map["page"]   = page;
    map["order"]  = order;
    map["config"] = _config?.xml;
    map["stash"]  = _stash;
    map["jwt"]    = jwt;
    return map;
  }

  // inserts a new app into the local hive
  Future<bool> insert() async
  {
    var exception = await Database().insert(tableName, key, _toMap());
    return (exception == null);
  }

  // updates the app in the local hive
  Future<bool> update() async
  {
    var exception = await Database().update(tableName, key, _toMap());
    return (exception == null);
  }

  // delete an app from the local hive
  Future<bool> delete() async
  {
    var exception = await Database().delete(tableName, key);
    return (exception == null);
  }

  static Future<List<ApplicationModel>> loadAll(WidgetModel parent) async
  {
    List<ApplicationModel> apps = [];
    List<Map<String, dynamic>> entries = await Database().query(tableName);
    for (var entry in entries)
    {
      ApplicationModel? app = await _fromMap(entry);
      if (app != null) apps.add(app);
    }
    return apps;
  }
}