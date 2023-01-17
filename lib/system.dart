// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'package:firebase_core/firebase_core.dart' show FirebaseApp;
import 'package:flutter/foundation.dart';
import 'package:fml/datasources/log/log_model.dart';
import 'package:fml/event/event.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/hive/stash.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/navigation/manager.dart';
import 'package:fml/phrase.dart';
import 'package:fml/postmaster/postmaster.dart';
import 'package:fml/janitor/janitor.dart';
import 'package:fml/token/token.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fml/widgets/theme/theme_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:xml/xml.dart';
import 'package:fml/hive/database.dart';
import 'package:fml/datasources/gps/gps.dart' as GPS;
import 'package:fml/datasources/gps/payload.dart' as GPS;
import 'package:fml/application/application_model.dart';
import 'package:fml/mirror/mirror.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';
import 'dart:io' as io;

// platform
import 'package:fml/platform/platform.web.dart'
if (dart.library.io)   'package:fml/platform/platform.vm.dart'
if (dart.library.html) 'package:fml/platform/platform.web.dart';

// platform
String get platform => isWeb ? "web" : isMobile ? "mobile" : "desktop";
bool get isWeb      => kIsWeb;
bool get isMobile   => !isWeb && (io.Platform.isAndroid || io.Platform.isIOS);
bool get isDesktop  => !isWeb && !isMobile;

// application build version
final String version = '1.0.0+10';

// SingleApp - App initializes from a single domain endpoint (defined in defaultDomain)
// MultiApp  - (Desktop & Mobile Only) Launches the Store at startup
enum ApplicationTypes{ SingleApp, MultiApp }
final ApplicationTypes appType  = ApplicationTypes.SingleApp;

// This url is used to locate config.xml on startup
// Used in SingleApp only and on Web when developing on localhost
// Set this to file://applications/<app>/config.xml to use the asset applications
final String defaultDomain = 'https://fml.dev';
late final ApplicationModel? defaultApplication;

typedef CommitCallback = Future<bool> Function();

enum Keys { F1, F2, F3, F4, F5, F6, F7, F8, F9, shift, alt, control, enter }

// This variable is used throughout the code to determine if debug messages
// and their corresponding actions should be performed.
// Putting this inside the System() class is problematic at startup
// when log messages being written while System() is still be initialized.
final bool kDebugMode = !kReleaseMode;

class System extends WidgetModel implements IEventManager
{
  static final System _singleton = System.initialize();
  factory System() => _singleton;
  System.initialize() : super(null, "SYSTEM", scope: Scope("SYSTEM")) {initialized = _init();}

  // system scope
  Scope? scope = Scope("SYSTEM");

  // set to true once done
  Future<bool>? initialized;

  // current application
  ApplicationModel? _app;
  set app(ApplicationModel? app)
  {
    // activate new application
    if (app != null)
    {
      Log().info("Activating Application (${app.title}) @ ${app.domain}");

      // set the default domain on the Url utilities
      Url.activeDomain = app.domain;

      // set the current application
      _app = app;

      // apply theme settings
      app.setTheme(theme);

      // check connectivity
      Platform.checkInternetConnection(app.domain);

      // set credentials
      logoff();
      if (app.jwt != null) logon(jwt);

      // set fml version support level
      //if (config?.get("FML_VERSION") != null) fmlVersion = S.toVersionNumber(config!.get("FML_VERSION")!) ?? currentVersion;

      // build the STASH
      // List<StashEntry> entries = await Stash.findAll(System().host);
      // entries.forEach((entry) => scope?.setObservable("STASH.${entry.key}", entry.value));

      // update application level bindables
      _domain.set(app.domain);
      _scheme.set(app.scheme);
      _host.set(app.host);
    }

    // closing application
    else
    {
      Log().info("Closing Application");

      // set the default domain on the Url utilities
      Url.activeDomain = null;

      // logoff
      logoff();

      // set fml version support level
      //if (config?.get("FML_VERSION") != null) fmlVersion = S.toVersionNumber(config!.get("FML_VERSION")!) ?? currentVersion;

      // build the STASH
      // List<StashEntry> entries = await Stash.findAll(System().host);
      // entries.forEach((entry) => scope?.setObservable("STASH.${entry.key}", entry.value));

      // update application level bindables
      _domain.set(null);
      _scheme.set(null);
      _host.set(null);
    }
  }
  ApplicationModel? get app => _app;

  // current theme
  late final ThemeModel _theme;
  ThemeModel get theme => _theme;

  // post master service
  final PostMaster postmaster = PostMaster();

  // janitorial service
  final Janitor janitor = Janitor();

  // mirrors
  static final Map<String, Mirror> mirrors = Map<String, Mirror>();

  /// holds user observables bound to claims
  Map<String, StringObservable> _user = Map<String, StringObservable>();

  // current domain
  late StringObservable _domain;
  String? get domain => _domain.get();

  // current scheme
  late StringObservable _scheme;
  String? get scheme => _scheme.get();

  // current host
  late StringObservable _host;
  String? get host => _host.get();

  /// Global System Observable
  StringObservable? _platform;
  String? get platform => _platform?.get();

  StringObservable? _useragent;
  String? get useragent => _useragent?.get() ?? Platform.useragent;

  StringObservable? _version;
  String get release => _version?.get() ?? "?";

  IntegerObservable? _screenheight;
  int get screenheight => _screenheight?.get() ?? 0;

  IntegerObservable? _screenwidth;
  int get screenwidth => _screenwidth?.get() ?? 0;

  // UUID
  StringObservable? _uuid;
  String uuid() => Uuid().v1();

  // Dates
  Timer? clock;

  IntegerObservable? _epoch;
  int epoch() => (_epoch != null) ? DateTime.now().millisecondsSinceEpoch : 0;

  IntegerObservable? _year;
  int year() => (_year != null) ? DateTime.now().year : 0;

  IntegerObservable? _month;
  int month() => (_month != null) ? DateTime.now().month: 0;

  IntegerObservable? _day;
  int day() => (_day != null) ? DateTime.now().day : 0;

  IntegerObservable? _hour;
  int hour() => (_hour != null) ? DateTime.now().hour : 0;

  IntegerObservable? _minute;
  int minute() => (_minute != null) ? DateTime.now().minute : 0;

  IntegerObservable? _second;
  int second() => (_second != null) ? DateTime.now().second : 0;

  // GPS
  GPS.Gps gps = GPS.Gps();
  GPS.Payload? currentLocation;

  // holds in-memory deserialized templates
  // primarily used for performance reasons
  HashMap<String?, XmlDocument?> templates = HashMap<String?, XmlDocument?>();

  /// current json web token used to authenticate
  StringObservable? _jwtObservable;
  Jwt? _jwt;
  set jwt(Jwt? value)
  {
    _jwt = value;
    if (_jwtObservable != null) _jwtObservable!.set(_jwt?.token);
  }
  Jwt? get jwt => _jwt;

  // firebase
  FirebaseApp? get firebase => app?.firebase;
  set firebase(FirebaseApp? v) => app?.firebase = v;

  Future<bool> _init() async
  {
    Log().info('Initializing FML Engine V$version ...');

    // initialize platform
    await Platform.init();

    // initialize Hive
    await _initDatabase();

    // set navigation
    await _initDefaultApp();

    // initialize System Globals
    await _initBindables();

    // create empty applications folder
    await _initFolders();

    // start the Post Master
    await postmaster.start();

    // start the Janitor
    await janitor.start();

    return true;
  }

  Future _initDefaultApp() async
  {
    Uri? uri;

    // web
    if (isWeb)
    {
      String url = Uri.base.toString();

      // parse the requested url
      uri = Url.parse(url);

      // if localhost - use the default domain and route
      // port 9000 is used by node.js by our installer
      if (uri != null)
      {
        bool localhost = uri.host.startsWith(RegExp("localhost", caseSensitive: false));
        if (localhost && uri.port != 9000) uri = Url.parse(defaultDomain);
      }
    }

    // single page application
    else if (appType == ApplicationTypes.SingleApp) uri = Url.parse(defaultDomain);

    // set start Uri
    if (uri != null)
    {
      var url = uri.url;

      var app = ApplicationModel(url: uri.url, title: uri.url);

      // wait for it to initialize
      await app.initialized;

      // assign default app to current
      defaultApplication = app;
    }
  }

  Future<bool> _initBindables() async
  {
    // create the theme
    _theme = ThemeModel(this, "THEME");

    // active application settings
    _domain        = StringObservable(Binding.toKey(id, 'domain'), null, scope: scope, listener: onPropertyChange);
    _scheme        = StringObservable(Binding.toKey(id, 'scheme'), null, scope: scope, listener: onPropertyChange);
    _host          = StringObservable(Binding.toKey(id, 'host'),   null, scope: scope, listener: onPropertyChange);

    // json web token
    _jwtObservable = StringObservable(Binding.toKey(id, 'jwt'), null, scope: scope);

    // device settings
    _screenheight = IntegerObservable(Binding.toKey(id, 'screenheight'), WidgetsBinding.instance.window.physicalSize.height, scope: scope);
    _screenwidth  = IntegerObservable(Binding.toKey(id, 'screenwidth'),  WidgetsBinding.instance.window.physicalSize.width, scope: scope);
    _platform     = StringObservable(Binding.toKey(id, 'platform'), platform, scope: scope);
    _useragent    = StringObservable(Binding.toKey(id, 'useragent'), Platform.useragent, scope: scope);
    _version      = StringObservable(Binding.toKey(id, 'version'), version, scope: scope);
    _uuid         = _uuid == null ? StringObservable(Binding.toKey(id, 'uuid'), uuid(), scope: scope, getter: uuid) : null;

    // system dates
    _epoch  = IntegerObservable(Binding.toKey(id, 'epoch'), epoch(), scope: scope, getter: epoch);
    _year   = IntegerObservable(Binding.toKey(id, 'year'), year(), scope: scope, getter: year);
    _month  = IntegerObservable(Binding.toKey(id, 'month'), month(), scope: scope, getter: month);
    _day    = IntegerObservable(Binding.toKey(id, 'day'), day(), scope: scope, getter: day);
    _hour   = IntegerObservable(Binding.toKey(id, 'hour'), hour(), scope: scope, getter: hour);
    _minute = IntegerObservable(Binding.toKey(id, 'minute'), minute(), scope: scope, getter: minute);
    _second = IntegerObservable(Binding.toKey(id, 'second'), second(), scope: scope, getter: second);

    // add system level log model datasource
    if (datasources == null) datasources = [];
    datasources!.add(LogModel(this, "LOG"));

    return true;
  }

  Future<bool> _initDatabase() async
  {
    // create the hive folder
    String? hiveFolder = await Platform.createFolder("hive");

    // initialize hive
    await Database().initialize(hiveFolder);

    return true;
  }

  Future<bool> _initFolders() async
  {
    bool ok = true;

    if (isWeb) return ok;
    try
    {
      // create folder
      Platform.createFolder("applications");

      // read asset manifest
      Map<String, dynamic> manifest = json.decode(await rootBundle.loadString('AssetManifest.json'));

      // copy assets
      for (String key in manifest.keys)
      if (key.startsWith("assets/applications"))
      {
        var folder = key.replaceFirst("assets/", "");
        await Platform.writeFile(folder, await rootBundle.load(key));
      }
    }
    catch(e)
    {
      print("Error building application assets. Error is $e");
      ok = false;
    }
    return ok;
  }

  // hack to fix focus/unfocus commits
  CommitCallback? commit;
  Future<bool> onCommit() async
  {
    if (commit != null) return await commit!();
    return true;
  }

  static toast(String? msg, {int? duration})
  {
    BuildContext? context = NavigationManager().navigatorKey.currentContext;
    if (context != null)
    {
      var snackbar = SnackBar(
          content: Text(msg ?? ""),
          duration: Duration(seconds: duration ?? 1),
          behavior: SnackBarBehavior.floating,
          elevation: 5);
      var messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(snackbar);
    }
  }

  Future<bool> stashValue(String key, dynamic value) async {
    bool ok = true;
    try
    {
      if (S.isNullOrEmpty(key)) return ok;

      // write to the hive
      await Stash().set(System().host, key, value);

      // set observable
      scope!.setObservable("STASH.$key", value);
    }
    catch (e)
    {
      // stash failure always returns true
      ok = true;
    }
    return ok;
  }

  Future<bool> logon(Jwt? token) async
  {
    // valid token?
    if ((token != null) && (token.valid))
    {
      // set user claims
      token.claims.forEach((key, value)
      {
        if (_user.containsKey(key))
             _user[key]!.set(value);
        else _user[key] = StringObservable(Binding.toKey("USER", key), value, scope: scope);
      });

      // clear missing claims
      _user.forEach((key, observable)
      {
        bool clear = !token.claims.containsKey(key);
        if (clear) observable.set(null);
      });

      // set rights
      if (!_user.containsKey('rights')) _user['rights'] = StringObservable(Binding.toKey("USER", 'rights'), 0, scope: scope);

      // set connected = true
      if (!_user.containsKey('connected'))
           _user['connected'] = StringObservable(Binding.toKey("USER", 'connected'), true, scope: scope);
      else _user['connected']!.set(true);

      // set token
      this.jwt = token;
      return true;
    }

    // clear all claims
    else
    {
      // clear user values
      _user.forEach((key, observable) => observable.set(null));

      // set phrase language
      phrase.language = _user.containsKey('language') ? _user['language'] as String? : Phrases.english;

      // clear rights
      if (!_user.containsKey('rights')) _user['rights'] = StringObservable(Binding.toKey("USER", 'rights'), 0, scope: scope);

      // set connected = false
      if (!_user.containsKey('connected'))
           _user['connected'] = StringObservable(Binding.toKey("USER", 'connected'), false, scope: scope);
      else _user['connected']!.set(false);

      // clear token
      this.jwt = null;
      return false;
    }
  }

  Future<bool> logoff() async
  {
    // set rights
    if (!_user.containsKey('rights'))
         _user['rights'] = StringObservable(Binding.toKey("USER", 'rights'), 0, scope: scope);
    else _user['rights']!.set(0);

    // set connected
    if (!_user.containsKey('connected'))
         _user['connected'] = StringObservable(Binding.toKey("USER", 'connected'), false, scope: scope);
    else _user['connected']!.set(false);

    // remember token
    this.jwt = null;
    return true;
  }

  // return specific user claim
  String? userProperty(String property)
  {
    if ((_user.containsKey(property)) && (_user[property] is Observable)) return _user[property]?.get();
    return null;
  }

  void setApplicationTitle(String? title) async
  {
    title = title ?? System().app?.settings("APPLICATION_NAME");
    if (!S.isNullOrEmpty(title))
    {
      // print('setting title to $title');
      SystemChrome.setApplicationSwitcherDescription(ApplicationSwitcherDescription(label: title, primaryColor: Colors.blue.value));
    }
  }

  /// Event Manager Host
  final EventManager manager = EventManager();
  registerEventListener(EventTypes type, OnEventCallback callback, {int? priority}) => manager.register(type, callback, priority: priority);
  removeEventListener(EventTypes type, OnEventCallback callback) => manager.remove(type, callback);
  broadcastEvent(WidgetModel source, Event event) => manager.broadcast(this, event);
  executeEvent(WidgetModel source, String event) => manager.execute(this, event);
}
