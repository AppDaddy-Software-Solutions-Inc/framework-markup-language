// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:fml/config/config_model.dart';
import 'package:fml/fml.dart';
import 'package:fml/hive/database.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/hive/stash.dart';
import 'package:fml/mirror/mirror.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/observable/scope_manager.dart';
import 'package:fml/system.dart';
import 'package:fml/template/template_manager.dart';
import 'package:fml/token/token.dart';
import 'package:fml/user/user_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:provider/provider.dart';
import 'package:fml/theme/theme.dart';

class ApplicationModel extends WidgetModel {
  static const String myId = "APPLICATION";

  static String tableName = "APP";

  // key of this application record in
  // the HIVE database.
  late String _dbKey;

  /// initialization info
  final _initialized  = Completer<bool>();
  final _initializing = Completer<bool>();
  Future<bool> get initialized => _initialized.future;

  bool started = false;

  // Active user
  late UserModel _user;
  UserModel get user => _user;

  // Jwt
  Jwt? get jwt => _user.jwt;

  // used for social media
  FirebaseApp? firebase;

  ScopeManager scopeManager = ScopeManager();

  // application url
  late String url;

  // application title
  String? title;

  // mirrors
  Mirror? mirror;
  String? get mirrorApi => setting("MIRROR") ?? setting("MIRROR_API");
  bool get cacheContent => (mirror != null);

  // forces pages to repaint every visit
  bool get refresh => toBool(setting("REFRESH")) ?? false;

  // single page application?
  // single page applications restrict navigation to sub pages
  bool get singlePage => toBool(setting('SINGLE_PAGE_APPLICATION')) ?? false;

  // company name
  String? get company =>  toStr(setting("COMPANY"));

  // application name
  String? get name =>  toStr(setting("NAME") ?? setting("APPLICATION_NAME"));

  // application icons
  String? get icon => toStr(setting("ICON"));
  String? get iconLight => toStr(setting("ICON_LIGHT"));
  String? get iconDark => toStr(setting("ICON_DARK"));

  // splash
  String? get splash => toStr(setting("SPLASH"));

  // splash background color
  String? get splashBackground =>  toStr(setting("SPLASH_BACKGROUND"));

  // splash max width & height percent
  String? get splashWidth => toStr(setting("SPLASH_WIDTH"));

  // splash display duration
  // defaults to 2 seconds if splash image is defined, otherwise 0
  int get splashDuration =>  max(0,toInt(setting("SPLASH_DURATION")) ?? (splash == null ? 0 : 2));

  // hash key - used by encryption event
  String? get hashKey => toStr(setting("HASHKEY"));

  // theme - brightness
  Brightness get brightness =>
      toEnum(setting('BRIGHTNESS')?.toLowerCase().trim(), Brightness.values) ??
      FmlEngine.defaultBrightness;

  // theme - color
  Color get color => toColor(setting('COLOR')) ?? FmlEngine.defaultColor;

  // theme - font
  String get font => toStr(setting('FONT'))?.trim() ?? FmlEngine.defaultFont;

  // firebase settings
  String? get firebaseApiKey => toStr(setting("FIREBASE_API_KEY"));
  String? get firebaseAuthDomain => toStr(setting("FIREBASE_AUTH_DOMAIN"));

  // default page transition
  PageTransitions? get transition => toEnum(setting("TRANSITION"), PageTransitions.values);

  // application icons position
  // on the store display (future use for multi-page and ordering)
  int? page;
  int? order;

  // fml version support
  int? get fmlVersion => toVersionNumber(setting("FML_VERSION"));

  String get homePage => setting("HOME_PAGE") ?? "main.xml";
  String? get loginPage => setting("LOGIN_PAGE");
  String? get errorPage => setting("ERROR_PAGE");

  // config
  ConfigModel? _config;
  String? setting(String key) => (_config?.settings.containsKey(key) ?? false) ? _config?.settings[key] : null;
  bool get configured => _config != null;

  // application stash
  Stash? _stash;

  // secure?
  bool get secure => scheme == "https" || scheme == "wss";

  String? _scheme;
  String? get scheme => _scheme;

  String? _host;
  String? get host => _host;

  String? _domain;
  String? get domain => _domain;

  String? _startPage;
  String? get startPage => _startPage;

  Map<String, String>? _queryParameters;
  Map<String, String>? get queryParameters => _queryParameters;

  Map<String, String?>? get configParameters => _config?.parameters;

  ApplicationModel(WidgetModel parent,
      {String? key,
        required String url,
        this.title,
        this.page,
        this.order,
        Map<String,dynamic>? settings})
      : super(parent, myId, scope: Scope(id: myId)) {

    // parse to url into its parts
    Uri? uri = Uri.tryParse(url);
    if (uri == null) return;

    // no scheme provided
    if (!uri.hasScheme) uri = Uri.tryParse("https://${uri.url}");
    if (uri == null) return;

    // set the url
    this.url = uri.url;

    // set database key
    _dbKey = key ?? this.url;

    _scheme = uri.scheme;
    _host = uri.host;

    // set the start page
    String? fragment = uri.hasFragment ? uri.fragment : null;
    if (fragment != null && fragment.toLowerCase().contains(".xml")) {
      var myUri = Uri.tryParse(fragment);
      if (myUri != null) {
        _queryParameters = myUri.hasQuery ? myUri.queryParameters : null;
        _startPage = myUri.removeQuery().url;
      }
    } else {
      _queryParameters = uri.queryParameters;
    }

    // base domain
    _domain = uri
        .removeFragment()
        .removeQuery()
        .replace(userInfo: null)
        .removeEmptySegments()
        .url;

    // initialize the config
    if (settings != null) _config = ConfigModel.fromMap(settings);

    // set active user
    var jwt = setting("jwt");
    _user = UserModel(this, jwt: jwt);

    // load the config
    initialize();
  }

  // initializes the app
  @override
  Future<void> initialize() async {

    // initialize should only run once
    if (_initialized.isCompleted || _initializing.isCompleted) return;

    // signal initializing in progress
    _initializing.complete(true);

    // build stash
    if (domain != null) {

      // initialize stash scope
      var scope = Scope(id: 'STASH');

      // initialize the stash
      _stash = await Stash.get(domain!, scope: scope);

      // set stash observables
      for (var entry in _stash!.map.entries) {
        _stash!.scope!.setObservable(entry.key, entry.value);
      }

      // add STASH scope
      scopeManager.add(scope);
    }

    // add SYSTEM scope
    scopeManager.add(System().scope!);

    // add THEME scope
    scopeManager.add(System.theme.scope!);

    // add USER scope
    scopeManager.add(_user.scope!);

    // add GLOBAL alias to this scope
    scopeManager.add(scope!, alias: "GLOBAL");

    // load config file from remote
    await _loadConfig();

    // get global template
    // get global.xml
    if (domain != null) {
      var uri = Uri.tryParse(domain!)?.setPage("global.xml");
      if (uri != null) {
        var template =
            await TemplateManager().fetch(url: uri.url, refresh: true);

        // deserialize the returned template
        if (template.document != null && !template.isAutoGeneratedErrorPage) {
          deserialize(template.document!.rootElement);
        }
      }
    }

    // mark initialized
    _initialized.complete(true);
  }

  // converts versions of 0.0.0 to a number
  static int? toVersionNumber(String? version) {
    if (version == null) return null;
    try {
      version = version.replaceAll("+", "");
      List versionCells = version.split('.');
      versionCells = versionCells.map((i) => int.parse(i)).toList();
      return versionCells[0] * 100000 +
          versionCells[1] * 1000 +
          versionCells[2];
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadConfig() async {

    ConfigModel? model;

    // get the config file from the domain
    if (domain != null) {
      model = await ConfigModel.fromUrl(domain!);
    }

    // model created?
    if (model != null) {

      // set icons
      if (!kIsWeb)
      {
        model.settings["ICON"] = await _getIcon(model.settings["ICON"] ?? model.settings["APP_ICON"], domain);
        model.settings["ICON_LIGHT"] = await _getIcon(model.settings["ICON_LIGHT"], domain);
        model.settings["ICON_DARK"] = await _getIcon(model.settings["ICON_DARK"], domain);
      }

      // splash delay
      var delay = toInt(model.settings["SPLASH_DURATION"]) ?? 0;

      // get the splash image if delay is > 0
      if (delay > 0)
      {
        model.settings["SPLASH"] = await _getIcon(model.settings["SPLASH"], domain);
      }

      // set the config
      _config = model;

      // save the application to hive
      upsert();

      // notify listeners that the config has changed
      notifyListeners("config", _config);
    }
  }

  Future<String?> _getIcon(String? icon, String? domain) async {
    if (icon == null) return null;

    // already a data uri?
    var dataUri = await URI.toUriData(icon, domain: domain);
    if (dataUri != null) return dataUri.toString();

    // get
    var uri = URI.parse(icon, domain: domain);
    if (uri == null) return null;

    dataUri = await URI.toUriData(uri.url, domain: domain);
    return dataUri?.toString();
  }

  Future<bool> stashValue(String key, dynamic value) async {
    bool ok = true;
    if (_stash == null) return ok;

    try {
      // key must be supplied
      if (isNullOrEmpty(key)) return ok;

      if (value == null) {
        _stash!.map.remove(key);
        _stash!.upsert();
        Binding? binding = Binding.fromString('$key.value');
        if (binding != null) {
          _stash!.scope?.observables.remove(_stash!.scope?.getObservable(binding)?.key);
        }
        return ok;
      }

      // write application stash entry
      _stash!.map[key] = value;

      // save to the hive
      await _stash!.upsert();

      // set observable
      _stash!.scope?.setObservable(key, value);
    } catch (e) {
      // stash failure always returns true
      ok = true;
    }
    return ok;
  }

  Future<bool> clearStash() async {
    bool ok = true;
    if (_stash == null) return ok;

    try {
      // clear rthe stash map
      _stash!.map.clear();

      // save to the hive
      await _stash!.upsert();
    } catch (e) {
      // stash failure always returns true
      ok = true;
    }
    return ok;
  }

  Future<void> setActive() async
  {
    // wait for initialization to complete
    await initialized;

    // set current
    System.currentApp = this;

    // set active
    started = true;

    // reload the config?
    //_loadConfig();

    // start mirror
    if (mirrorApi != null && !FmlEngine.isWeb && scheme != "file") {
      Uri? uri = URI.parse(mirrorApi, domain: domain);
      if (uri != null) mirror = Mirror(uri.url)..execute();
    }

    // set credentials
    logon(jwt);

    // set stash values
    if (_stash != null)
    {
      for (var entry in _stash!.map.entries) {
        _stash!.scope?.setObservable(entry.key, entry.value);
      }
    }

    // start all datasources
    if (datasources != null) {
      for (var datasource in datasources!) {
        if (datasource.autoexecute != false) {
          datasource.start();
        }
        datasource.initialized = true;
      }
    }

    // set the theme
    if (context != null) {
      var notifier = Provider.of<ThemeNotifier>(context!, listen: false);
      notifier.setTheme(
          brightness: brightness,
          color: color,
          font: font);
    }
  }

  void close() {
    // start all datasources
    if (datasources != null) {
      for (var datasource in datasources!) {
        datasource.stop();
      }
    }
  }

  @override
  void dispose() {
    // close the app
    close();

    // remove stash scope
    _stash?.scope?.dispose();

    // dispose of all children
    super.dispose();
  }

  Map<String, dynamic> _toMap() {
    Map<String, dynamic> map = {};
    _config?.settings.forEach((key, value) => map[key] = value);
    map["key"] = _dbKey;
    map["url"] = url;
    map["title"] = title;
    map["page"] = page;
    map["order"] = order;
    return map;
  }

  static Future<ApplicationModel?> _fromMap(dynamic map) async {
    ApplicationModel? app;
    if (map is Map<String, dynamic>) {

      // create the application
      app = ApplicationModel(System(),
          key: fromMap(map, "key"),
          url: fromMap(map, "url"),
          title: fromMap(map, "title"),
          page: fromMapAsInt(map, "page"),
          order: fromMapAsInt(map, "order"),
          settings: map);
    }
    return app;
  }

  // inserts a new app into the local hive
  Future<bool> insert() async {
    var exception = await Database.insert(tableName, _dbKey, _toMap());
    return (exception == null);
  }

  // updates the app in the local hive
  Future<bool> update() async {
    var exception = await Database.update(tableName, _dbKey, _toMap());
    return (exception == null);
  }

  // updates the app in the local hive
  Future<bool> upsert() async {
    var exception = await Database.upsert(tableName, _dbKey, _toMap());
    return (exception == null);
  }

  // delete an app from the local hive
  Future<bool> delete() async {
    var exception = await Database.delete(tableName, _dbKey);
    return (exception == null);
  }

  static Future<List<ApplicationModel>> loadAll() async {
    List<ApplicationModel> apps = [];
    List<Map<String, dynamic>> entries = await Database.query(tableName);
    for (var entry in entries) {
      ApplicationModel? app = await _fromMap(entry);
      if (app != null) apps.add(app);
    }
    return apps;
  }

  Future<bool> logon(Jwt? jwt) async {
    if (jwt != null) _user.logon(jwt);
    return true;
  }

  Future<bool> logoff() async {
    _user.logoff();
    return true;
  }
}
