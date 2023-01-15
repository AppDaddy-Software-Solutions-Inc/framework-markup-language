// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'dart:core';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart' show FirebaseApp;
import 'package:flutter/foundation.dart';
import 'package:fml/datasources/log/log_model.dart';
import 'package:fml/event/event.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/hive/settings.dart';
import 'package:fml/hive/stash.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/navigation/manager.dart';
import 'package:fml/phrase.dart';
import 'package:fml/postmaster/postmaster.dart';
import 'package:fml/janitor/janitor.dart';
import 'package:fml/token/token.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:xml/xml.dart';
import 'package:fml/hive/database.dart';
import 'package:fml/datasources/gps/gps.dart' as GPS;
import 'package:fml/datasources/gps/payload.dart' as GPS;
import 'package:fml/hive/app.dart';
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
final ApplicationTypes appType  = ApplicationTypes.MultiApp;

// This url is used to locate config.xml on startup
// Used in SingleApp only and on Web when developing on localhost
// Set this to file://config.xml to use the local assets
final String defaultDomain = 'https://fml.appdaddy.co';

typedef CommitCallback = Future<bool> Function();

enum Keys { F1, F2, F3, F4, F5, F6, F7, F8, F9, shift, alt, control, enter }

// This variable is used throughout the code to determine if debug messages
// and their corresponding actions should be performed.
// Putting this inside the System() class is problematic at startup
// when log messages being written while System() is still be initialized.
final bool kDebugMode = !kReleaseMode;


class System extends WidgetModel implements IEventManager
{
  factory System() => _singleton;

  // current application
  App? _app;
  set app(App? app)
  {
    _app = app;

    // update bindables
    domain  = app?.domain;
  }
  App? get app => _app;

  /// Event Manager Host
  final EventManager manager = EventManager();
  registerEventListener(EventTypes type, OnEventCallback callback, {int? priority}) => manager.register(type, callback, priority: priority);
  removeEventListener(EventTypes type, OnEventCallback callback) => manager.remove(type, callback);
  broadcastEvent(WidgetModel source, Event event) => manager.broadcast(this, event);
  executeEvent(WidgetModel source, String event) => manager.execute(this, event);

  // used for social media
  FirebaseApp? firebase;

  /// holds user observables bound to claims
  Map<String, StringObservable> _user = Map<String, StringObservable>();

  /// json web token used to authenticate
  StringObservable? _jwtObservable;
  Jwt? _jwt;
  set jwt(Jwt? value)
  {
    _jwt = value;
    if (_jwtObservable != null) _jwtObservable!.set(_jwt?.token);
  }
  Jwt? get jwt => _jwt;

  /// Global callback to close any stray overlays avoiding overlay overlap
  dynamic closeOpenOverlay; // always call this if != null before setting
  
  System.initialize() : super(null, "SYSTEM", scope: Scope("SYSTEM"))
  {
    initialized = _init();
  }

  Future<bool> _init() async
  {
    Log().info('Initializing FML Engine V$version ...');

    // initialize platform
    await Platform.init();

    // initialize Hive
    String? hiveFolder = await Platform.createFolder("hive");
    await Database().initialize(hiveFolder);

    // initialize System Globals
    await _initializeGlobals();

    // start the Post Master
    if (!isWeb) await postmaster.start();

    // start the Janitor
    await janitor.start();

    return true;
  }

  // fully qualified domain name
  StringObservable? _domain;
  set domain(String? url)
  {
    if (url != null)
    {
      Log().info("Setting domain to $url");
      Uri? uri = Url.parse(url);
      if (uri != null)
      {
        // set scheme
        scheme = uri.scheme;

        // set host
        if (_host == null)
              _host = StringObservable(Binding.toKey(id, 'host'), uri.path, scope: scope, listener: onPropertyChange);
        else  _host!.set(uri.path);

        // set domain
        if (_domain == null)
             _domain = StringObservable(Binding.toKey(id, 'domain'), uri.domain, scope: scope, listener: onPropertyChange);
        else _domain!.set(uri.domain);

        // set start page
        //requestedPage = uri.page;
      }
    }
  }

  String? get domain
  {
    if (isWeb) return _domain?.get();
    if (appType == ApplicationTypes.SingleApp) return defaultDomain.split("/#").first.toString();
    return _domain?.get();
  }

  // query parameters from startup url
  Map<String, String> queryParameters = Map<String, String>();
  
  // end point urls used to prefetch templates
  static final Map<String, Mirror> mirrors = Map<String, Mirror>();

  /// Initialize Domain Connection
  Future<void> initializeDomainConnection(String? domain) async
  {
    Log().info('Initializing Connection to Domain: $domain');

    // set system domain
    this.domain = domain;

    // clear firebase sign on
    firebase = null;

    // domain is defined?
    if (!S.isNullOrEmpty(this.domain))
    {
      // check connection
      Platform.checkInternetConnection(domain);

      // set credentials
      System().logon(await (Settings().get("jwt:$domain")));

      // get configuration file from server
      //config = await getConfigModel(domain!, refresh: true);


      // set fml version support level
      //if (config?.get("FML_VERSION") != null) fmlVersion = S.toVersionNumber(config!.get("FML_VERSION")!) ?? currentVersion;

      // build the STASH
      List<StashEntry> entries = await Stash.findAll(System().host);
      entries.forEach((entry) => scope?.setObservable("STASH.${entry.key}", entry.value));

      // mirror assets from server
      //if (!mirrors.containsKey(domain))
     // {
     //   String? url = S.toStr(config?.get('MIRROR_API'));
     //   if ((!S.isNullOrEmpty(url)) && (!isWeb))
     //   {
     //     Mirror mirror = Mirror(domain, url);
     //     mirrors[domain] = mirror;
     //     mirror.execute();
     //   }
     // }
    }
  }

  static final System _singleton = System.initialize();
  static final PostMaster postmaster = PostMaster();
  static final Janitor janitor = Janitor();
  static const int timeout = 60;

  Future<bool>? initialized;

  Future<bool>? initializationPostUrl;
  Scope? scope = Scope("SYSTEM");

  static const Color colorDefault = Color(0xffb2dd4c);

  // authentication scheme
  StringObservable? _scheme;
  set scheme(dynamic v)
  {
    if (_scheme != null)
    {
      _scheme!.set(v);
    }
    else if (v != null)
    {
      _scheme = StringObservable(Binding.toKey(id, 'scheme'), v, scope: scope);
    }
  }
  String? get scheme => _scheme?.get();

  // current host
  StringObservable? _host;
  String? get host => _host?.get();

  // screen height
  IntegerObservable? _screenheight;
  set screenheight(dynamic v)
  {
    if (_screenheight != null)
    {
      _screenheight!.set(v);
    }
    else if (v != null)
    {
      _screenheight = IntegerObservable(Binding.toKey(id, 'screenheight'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int? get screenheight => _screenheight?.get();

  // screen width
  IntegerObservable? _screenwidth;
  set screenwidth(dynamic v)
  {
    if (_screenwidth != null)
    {
      _screenwidth!.set(v);
    }
    else if (v != null)
    {
      _screenwidth = IntegerObservable(Binding.toKey(id, 'screenwidth'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int? get screenwidth => _screenwidth?.get();

  /// THEME BINDABLES
  ///
  /// ie `{THEME.brightness}`
  ///
  StringObservable? _brightness;
  set brightness(dynamic v) {
    if (_brightness != null)
      _brightness!.set(v);
    else if (v != null)
      _brightness = StringObservable(Binding.toKey('THEME', 'brightness'), v, scope: scope, listener: onPropertyChange);
  }
  String? get brightness => _brightness?.get();

  StringObservable? _colorscheme;
  set colorscheme(dynamic v) {
    if (_colorscheme != null)
      _colorscheme!.set(v);
    else if (v != null)
      _colorscheme = StringObservable(Binding.toKey('THEME', 'colorscheme'), v, scope: scope, listener: onPropertyChange);
  }
  String? get colorscheme => _colorscheme?.get();

  StringObservable? _font;
  set font(dynamic v) {
    if (_font != null)
      _font!.set(v);
    else if (v != null)
      _font = StringObservable(Binding.toKey('THEME', 'font'), v, scope: scope, listener: onPropertyChange);
  }
  String get font => _font?.get() ?? 'Roboto';

  StringObservable? _background;
  set background(dynamic v) {
    if (_background != null)
      _background!.set(v);
    else if (v != null)
      _background = StringObservable(Binding.toKey('THEME', 'background'), v, scope: scope, listener: onPropertyChange);
  }
  String? get background => _background?.get();

  StringObservable? _onbackground;
  set onbackground(dynamic v) {
    if (_onbackground != null)
      _onbackground!.set(v);
    else if (v != null)
      _onbackground = StringObservable(Binding.toKey('THEME', 'onbackground'), v, scope: scope, listener: onPropertyChange);
  }
  String? get onbackground => _onbackground?.get();

  StringObservable? _shadow;
  set shadow(dynamic v) {
    if (_shadow != null)
      _shadow!.set(v);
    else if (v != null)
      _shadow = StringObservable(Binding.toKey('THEME', 'shadow'), v, scope: scope, listener: onPropertyChange);
  }
  String? get shadow => _shadow?.get();

  StringObservable? _outline;
  set outline(dynamic v) {
    if (_outline != null)
      _outline!.set(v);
    else if (v != null)
      _outline = StringObservable(Binding.toKey('THEME', 'outline'), v, scope: scope, listener: onPropertyChange);
  }
  String? get outline => _outline?.get();

  StringObservable? _surface;
  set surface(dynamic v) {
    if (_surface != null)
      _surface!.set(v);
    else if (v != null)
      _surface = StringObservable(Binding.toKey('THEME', 'surface'), v, scope: scope, listener: onPropertyChange);
  }
  String? get surface => _surface?.get();

  StringObservable? _onsurface;
  set onsurface(dynamic v) {
    if (_onsurface != null)
      _onsurface!.set(v);
    else if (v != null)
      _onsurface = StringObservable(Binding.toKey('THEME', 'onsurface'), v, scope: scope, listener: onPropertyChange);
  }
  String? get onsurface => _onsurface?.get();

  StringObservable? _surfacevariant;
  set surfacevariant(dynamic v) {
    if (_surfacevariant != null)
      _surfacevariant!.set(v);
    else if (v != null)
      _surfacevariant = StringObservable(Binding.toKey('THEME', 'surfacevariant'), v, scope: scope, listener: onPropertyChange);
  }
  String? get surfacevariant => _surfacevariant?.get();

  StringObservable? _onsurfacevariant;
  set onsurfacevariant(dynamic v) {
    if (_onsurfacevariant != null)
      _onsurfacevariant!.set(v);
    else if (v != null)
      _onsurfacevariant = StringObservable(Binding.toKey('THEME', 'onsurfacevariant'), v, scope: scope, listener: onPropertyChange);
  }
  String? get onsurfacevariant => _onsurfacevariant?.get();

  StringObservable? _inversesurface;
  set inversesurface(dynamic v) {
    if (_inversesurface != null)
      _inversesurface!.set(v);
    else if (v != null)
      _inversesurface = StringObservable(Binding.toKey('THEME', 'inversesurface'), v, scope: scope, listener: onPropertyChange);
  }
  String? get inversesurface => _inversesurface?.get();

  StringObservable? _oninversesurface;
  set oninversesurface(dynamic v) {
    if (_oninversesurface != null)
      _oninversesurface!.set(v);
    else if (v != null)
      _oninversesurface = StringObservable(Binding.toKey('THEME', 'oninversesurface'), v, scope: scope, listener: onPropertyChange);
  }
  String? get oninversesurface => _oninversesurface?.get();

  StringObservable? _primary;
  set primary(dynamic v) {
    if (_primary != null)
      _primary!.set(v);
    else if (v != null)
      _primary = StringObservable(Binding.toKey('THEME', 'primary'), v, scope: scope, listener: onPropertyChange);
  }
  String? get primary => _primary?.get();

  StringObservable? _onprimary;
  set onprimary(dynamic v) {
    if (_onprimary != null)
      _onprimary!.set(v);
    else if (v != null)
      _onprimary = StringObservable(Binding.toKey('THEME', 'onprimary'), v, scope: scope, listener: onPropertyChange);
  }
  String? get onprimary => _onprimary?.get();

  StringObservable? _primarycontainer;
  set primarycontainer(dynamic v) {
    if (_primarycontainer != null)
      _primarycontainer!.set(v);
    else if (v != null)
      _primarycontainer = StringObservable(Binding.toKey('THEME', 'primarycontainer'), v, scope: scope, listener: onPropertyChange);
  }
  String? get primarycontainer => _primarycontainer?.get();

  StringObservable? _onprimarycontainer;
  set onprimarycontainer(dynamic v) {
    if (_onprimarycontainer != null)
      _onprimarycontainer!.set(v);
    else if (v != null)
      _onprimarycontainer = StringObservable(Binding.toKey('THEME', 'onprimarycontainer'), v, scope: scope, listener: onPropertyChange);
  }
  String? get onprimarycontainer => _onprimarycontainer?.get();

  StringObservable? _inverseprimary;
  set inverseprimary(dynamic v) {
    if (_inverseprimary != null)
      _inverseprimary!.set(v);
    else if (v != null)
      _inverseprimary = StringObservable(Binding.toKey('THEME', 'inverseprimary'), v, scope: scope, listener: onPropertyChange);
  }
  String? get inverseprimary => _inverseprimary?.get();

  StringObservable? _secondary;
  set secondary(dynamic v) {
    if (_secondary != null)
      _secondary!.set(v);
    else if (v != null)
      _secondary = StringObservable(Binding.toKey('THEME', 'secondary'), v, scope: scope, listener: onPropertyChange);
  }
  String? get secondary => _secondary?.get();

  StringObservable? _onsecondary;
  set onsecondary(dynamic v) {
    if (_onsecondary != null)
      _onsecondary!.set(v);
    else if (v != null)
      _onsecondary = StringObservable(Binding.toKey('THEME', 'onsecondary'), v, scope: scope, listener: onPropertyChange);
  }
  String? get onsecondary => _onsecondary?.get();

  StringObservable? _secondarycontainer;
  set secondarycontainer(dynamic v) {
    if (_secondarycontainer != null)
      _secondarycontainer!.set(v);
    else if (v != null)
      _secondarycontainer = StringObservable(Binding.toKey('THEME', 'secondarycontainer'), v, scope: scope, listener: onPropertyChange);
  }
  String? get secondarycontainer => _secondarycontainer?.get();

  StringObservable? _onsecondarycontainer;
  set onsecondarycontainer(dynamic v) {
    if (_onsecondarycontainer != null)
      _onsecondarycontainer!.set(v);
    else if (v != null)
      _onsecondarycontainer = StringObservable(Binding.toKey('THEME', 'onsecondarycontainer'), v, scope: scope, listener: onPropertyChange);
  }
  String? get onsecondarycontainer => _onsecondarycontainer?.get();

  StringObservable? _tertiarycontainer;
  set tertiarycontainer(dynamic v) {
    if (_tertiarycontainer != null)
      _tertiarycontainer!.set(v);
    else if (v != null)
      _tertiarycontainer = StringObservable(Binding.toKey('THEME', 'tertiarycontainer'), v, scope: scope, listener: onPropertyChange);
  }
  String? get tertiarycontainer => _tertiarycontainer?.get();

  StringObservable? _ontertiarycontainer;
  set ontertiarycontainer(dynamic v) {
    if (_ontertiarycontainer != null)
      _ontertiarycontainer!.set(v);
    else if (v != null)
      _ontertiarycontainer = StringObservable(Binding.toKey('THEME', 'ontertiarycontainer'), v, scope: scope, listener: onPropertyChange);
  }
  String? get ontertiarycontainer => _ontertiarycontainer?.get();

  StringObservable? _error;
  set error(dynamic v) {
    if (_error != null)
      _error!.set(v);
    else if (v != null)
      _error = StringObservable(Binding.toKey('THEME', 'error'), v, scope: scope, listener: onPropertyChange);
  }
  String? get error => _error?.get();

  StringObservable? _onerror;
  set onerror(dynamic v) {
    if (_onerror != null)
      _onerror!.set(v);
    else if (v != null)
      _onerror = StringObservable(Binding.toKey('THEME', 'onerror'), v, scope: scope, listener: onPropertyChange);
  }
  String? get onerror => _onerror?.get();

  StringObservable? _errorcontainer;
  set errorcontainer(dynamic v) {
    if (_errorcontainer != null)
      _errorcontainer!.set(v);
    else if (v != null)
      _errorcontainer = StringObservable(Binding.toKey('THEME', 'errorcontainer'), v, scope: scope, listener: onPropertyChange);
  }
  String? get errorcontainer => _errorcontainer?.get();

  StringObservable? _onerrorcontainer;
  set onerrorcontainer(dynamic v) {
    if (_onerrorcontainer != null)
      _onerrorcontainer!.set(v);
    else if (v != null)
      _onerrorcontainer = StringObservable(Binding.toKey('THEME', 'onerrorcontainer'), v, scope: scope, listener: onPropertyChange);
  }
  String? get onerrorcontainer => _onerrorcontainer?.get();

  // UUID
  StringObservable? _uuid;
  String uuid() => Uuid().v1();

  /// Global System Observable
  StringObservable? _platform;
  String? get platform => _platform?.get();

  StringObservable? _useragent;
  String? get useragent => _useragent?.get() ?? Platform.useragent;

  StringObservable? _version;
  String get release => _version?.get() ?? "?";

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

  ///////////////
  /* Templates */
  ///////////////
  HashMap<String?, XmlDocument?> templates = HashMap<String?, XmlDocument?>();

  _initializeGlobals() async
  {
    // json web token
    _jwtObservable = StringObservable(Binding.toKey(id, 'jwt'), "", scope: scope);

    // device settings
    _screenheight = IntegerObservable(Binding.toKey(id, 'screenheight'), null, scope: scope);
    _screenwidth  = IntegerObservable(Binding.toKey(id, 'screenwidth'), null, scope: scope);
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
  }

  int getEpoch() => DateTime.now().millisecondsSinceEpoch;

  ///////////////////////////////////////
  /* Hack to Fix Focus/Unfocus Commits */
  ///////////////////////////////////////
  CommitCallback? commit;
  Future<bool> onCommit() async {
    if (commit != null) return await commit!();
    return true;
  }

  Future<bool> setDomain(String? domain) async
  {
    // start the process
    await initializeDomainConnection(domain);

    // single page application?
    //singlePageApplication = S.toBool(config?.get('SINGLE_PAGE_APPLICATION')) ?? false;

    // set home page
    //homePage = config?.get('HOME_PAGE');

    // set login page
    //loginPage = config?.get('LOGIN_PAGE');

    // set login page
    //debugPage = config?.get('DEBUG_PAGE');

    // set unauthorized page
    //unauthorizedPage = config?.get('UNAUTHORIZED_PAGE');

    // initialize the theme
    initTheme();

    return true;
  }

  initTheme() {
    /// Initial Theme Setting
    String def = 'light';
    String cBrightness = System().app?.settings('BRIGHTNESS')?.toLowerCase() ?? def;
    if (cBrightness == 'system' || cBrightness == 'platform')
      try {
        cBrightness = MediaQueryData.fromWindow(WidgetsBinding.instance.window)
            .platformBrightness
            .toString()
            .toLowerCase()
            .split('.')[1];
      } catch (e) {
        cBrightness = def;
      }
    System().brightness = cBrightness;
    System().colorscheme =
        System().app?.settings('PRIMARY_COLOR')?.toLowerCase() ??
            'lightblue'; // backwards compatibility
    System().colorscheme =
        System().app?.settings('COLOR_SCHEME')?.toLowerCase() ??
            System().colorscheme;
    System().font = System().app?.settings('FONT');
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

  Future<bool> logon(Jwt? token) async {
    // valid token?
    if ((token != null) && (token.valid)) {
      // set user claims
      token.claims.forEach((key, value) {
        if (_user.containsKey(key))
          _user[key]!.set(value);
        else
          _user[key] =
              StringObservable(Binding.toKey("USER", key), value, scope: scope);
      });

      // clear missing claims
      _user.forEach((key, observable) {
        bool clear = !token.claims.containsKey(key);
        if (clear) observable.set(null);
      });

      // set rights
      if (!_user.containsKey('rights'))
        _user['rights'] =
            StringObservable(Binding.toKey("USER", 'rights'), 0, scope: scope);

      // set connected = true
      if (!_user.containsKey('connected'))
        _user['connected'] = StringObservable(
            Binding.toKey("USER", 'connected'), true,
            scope: scope);
      else
        _user['connected']!.set(true);

      // set token
      this.jwt = token;
      return true;
    }

    // clear all claims
    else {
      // clear user values
      _user.forEach((key, observable) => observable.set(null));

      // set phrase language
      phrase.language = _user.containsKey('language')
          ? _user['language'] as String?
          : Phrases.english;

      // clear rights
      if (!_user.containsKey('rights'))
        _user['rights'] =
            StringObservable(Binding.toKey("USER", 'rights'), 0, scope: scope);

      // set connected = false
      if (!_user.containsKey('connected'))
        _user['connected'] = StringObservable(
            Binding.toKey("USER", 'connected'), false,
            scope: scope);
      else
        _user['connected']!.set(false);

      // clear token
      this.jwt = null;
      return false;
    }
  }

  Future<bool> logoff() async {
    // set rights
    if (!_user.containsKey('rights'))
      _user['rights'] =
          StringObservable(Binding.toKey("USER", 'rights'), 0, scope: scope);
    else
      _user['rights']!.set(0);

    // set connected
    if (!_user.containsKey('connected'))
      _user['connected'] = StringObservable(
          Binding.toKey("USER", 'connected'), false,
          scope: scope);
    else
      _user['connected']!.set(false);
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
}
