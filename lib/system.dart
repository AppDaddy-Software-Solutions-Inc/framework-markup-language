// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
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
import 'package:fml/datasources/http/http.dart';
import 'package:fml/hive/database.dart';
import 'package:fml/datasources/gps/gps.dart' as GPS;
import 'package:fml/datasources/gps/payload.dart' as GPS;
import 'package:fml/config/model.dart' as CONFIG;
import 'package:fml/mirror/mirror.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';

// platform
 import 'package:fml/system.mobile.dart';
// import 'package:fml/system.web.dart';
//import 'package:fml/system.desktop.dart';

// application build version
final String version = '1.0.0';

// SingleApp - App initializes from a single domain endpoint (defined in defaultDomain)
// MultiApp  - (Desktop & Mobile Only) Launches the Store at startup
enum ApplicationTypes{ SingleApp, MultiApp }
final ApplicationTypes appType  = ApplicationTypes.MultiApp;

// This url is used to locate config.xml on startup
// Used in SingleApp only and on Web when developing on localhost
// Set this to file://config.xml to use the local assets

final String defaultDomain = 'https://fml.dev';

// denotes FML support Level
int? fmlVersion = currentVersion;
final int? currentVersion = S.toVersionNumber(version);

typedef CommitCallback = Future<bool> Function();

enum Keys { F1, F2, F3, F4, F5, F6, F7, F8, F9, shift, alt, control, enter }

// This variable is used throughout the code to determine if debug messages
// and their corresponding actions should be performed.
// Putting this inside the System() class is problematic at startup
// when log messages being written while System() is still be initialized.
final bool kDebugMode = !kReleaseMode;

// platform
bool get isWeb     => SystemPlatform.platform == "web";
bool get isMobile  => SystemPlatform.platform == "mobile";
bool get isDesktop => SystemPlatform.platform == "desktop";

class System extends SystemPlatform implements IEventManager
{
  /// Event Manager Host
  final EventManager manager = EventManager();
  registerEventListener(EventTypes type, OnEventCallback callback, {int? priority}) => manager.register(type, callback, priority: priority);
  removeEventListener(EventTypes type, OnEventCallback callback) => manager.remove(type, callback);
  broadcastEvent(WidgetModel source, Event event) => manager.broadcast(this, event);
  executeEvent(WidgetModel source, String event) => manager.execute(this, event);

  // if set to true in config file, forces server template refresh
  static bool refresh = false;

  // used for social media
  FirebaseApp? firebase;

  // authentication scheme
  bool singlePageApplication = true;

  /// home page
  String? homePage;

  /// requested page
  String? requestedPage;

  // authorization login page
  String? loginPage;

  // debug page
  String? debugPage;

  // unauthorized page
  String? unauthorizedPage;

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

  factory System() => _singleton;

  System.initialize()
  {
    initialized = _init();
  }

  Future<bool> _init() async
  {
    Log().info('Initializing FML Engine V$version ...');

    // set the URI
    if (isWeb)
    {
      // get initial domain and route
      String initialDomain = Uri.base.toString();

      // LocalHost? - use the default domain and route
      if (Url.host(initialDomain)?.toLowerCase().startsWith("localhost") == true)
      {
        var segments = defaultDomain.split("#");
        String host  = segments[0].trim();
        String route = PlatformDispatcher.instance.defaultRouteName.trim();
        if (route == "/") route = (segments.length > 1) ? segments[1].trim() : "/";

        // set the domain
        initialDomain = host + (host.endsWith("/") ? "" : "/") + "#" + (route.startsWith("/") ? "" : "/") + route;
      }

      // set the domain
      domain = initialDomain;
    }

    // initialize platform
    await super.init();

    // initialize Hive
    String? hiveFolder = await createFolder("hive");
    await Database().initialize(hiveFolder);

    // initialize System Globals
    await _initializeGlobals();

    // start the Post Master
    if (!isWeb) await postmaster.start();

    // start the Janitor
    await janitor.start();

    return true;
  }

  // domain
  StringObservable? _domain;
  set domain(String? url)
  {
    if (url != null)
    {
      Log().info("Setting domain to $url");

      Uri? uri = S.toURI(url);
      if (uri != null)
      {
        // set the scheme
        scheme = uri.hasScheme ? uri.scheme : 'http';

        // build host
        String host = (uri.hasAuthority ? uri.authority : '');
        uri.pathSegments.forEach((segment) => host += '/' + segment);

        // set host
        if (_host == null)
              _host = StringObservable(Binding.toKey(id, 'host'), host, scope: scope, listener: onPropertyChange);
        else  _host!.set(host);

        // set fqdn
        String fqdn = "$scheme://$host";
        if (_domain == null)
             _domain = StringObservable(Binding.toKey(id, 'domain'), fqdn, scope: scope, listener: onPropertyChange);
        else _domain!.set(fqdn);

        // set the startup parameters
        Uri? uri2 = S.toURI(url.replaceAll('/#', '')); // Because flutter is a SWA we need to ignore the /#/ for uri query param detection
        if ((uri2 is Uri) && (uri2.hasQuery)) uri2.queryParameters.forEach((key, value) => queryParameters[key] = value);

        // set the start page
        if (uri.hasFragment)
        {
          List<String> parts = uri.fragment.split("?");
          if (parts[0].trim().toLowerCase().endsWith(".xml"))
          {
            requestedPage = uri.fragment;
            if (requestedPage!.startsWith("/")) requestedPage = requestedPage!.replaceFirst("/", "");
          }
        }
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

  // config file
  CONFIG.ConfigModel? config;

  // end point urls used to prefetch templates
  static final Map<String, Mirror> mirrors = Map<String, Mirror>();

  /// Initialize Domain Connection
  Future<void> initializeDomainConnection(String? domain) async
  {
    Log().info('Initializing Connection to Domain: $domain');

    // set system domain
    this.domain = domain;

    // clear config
    config = null;

    // clear firebase sign on
    firebase = null;

    // domain is defined?
    if (!S.isNullOrEmpty(this.domain))
    {
      // check connection
      System().checkInternetConnection(domain);

      // set credentials
      System().logon(await (Settings().get("jwt:$domain")));

      // get configuration file from server
      config = await getConfigModel(domain, refresh: true);

      // set template refresh
      refresh = S.toBool(config?.get("REFRESH")) ?? false;

      // set fml version support level
      if (config?.get("FML_VERSION") != null) fmlVersion = S.toVersionNumber(config!.get("FML_VERSION")!) ?? currentVersion;

      // build the STASH
      List<StashEntry> entries = await Stash.findAll(System().host);
      entries.forEach((entry) => scope?.setObservable("STASH.${entry.key}", entry.value));

      // mirror assets from server
      if (!mirrors.containsKey(domain))
      {
        String? url = S.toStr(config?.get('MIRROR_API'));
        if ((!S.isNullOrEmpty(url)) && (!isWeb))
        {
          Mirror mirror = Mirror(domain, url);
          mirrors[domain!] = mirror;
          mirror.execute();
        }
      }
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
  bool get secure => scheme?.toLowerCase().startsWith("https") ?? false;

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
  String? get useragent => _useragent?.get();

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
    _platform     = StringObservable(Binding.toKey(id, 'platform'), SystemPlatform.platform, scope: scope);
    _useragent    = StringObservable(Binding.toKey(id, 'useragent'), System().useragent, scope: scope);
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

  Widget localErrorBuilder(
      BuildContext content, Object object, StackTrace stacktrace) {
    // int i = 0;
    //TODO: ADD IMAGE PATH TO CONFIG
    return Image.memory(Base64Codec().decode(
        "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"));
    // return Image.asset('assets/images/404.jpg', width: 0, height: 0,);
  }

  ///////////////////////////////////////
  /* Hack to Fix Focus/Unfocus Commits */
  ///////////////////////////////////////
  CommitCallback? commit;
  Future<bool> onCommit() async {
    if (commit != null) return await commit!();
    return true;
  }

  Future<bool> setDomain(String? domain) async {
    // empty domain
    //if (S.isNullOrEmpty(domain)) return false;

    // start the process
    await initializeDomainConnection(domain);

    // single page application?
    singlePageApplication = S.toBool(config?.get('SINGLE_PAGE_APPLICATION')) ?? false;

    // set home page
    homePage = config?.get('HOME_PAGE');

    // set login page
    loginPage = config?.get('LOGIN_PAGE');

    // set login page
    debugPage = config?.get('DEBUG_PAGE');

    // set unauthorized page
    unauthorizedPage = config?.get('UNAUTHORIZED_PAGE');

    // initialize the theme
    initTheme();

    return true;
  }

  initTheme() {
    /// Initial Theme Setting
    String def = 'light';
    String cBrightness =
        System().config?.get('BRIGHTNESS')?.toLowerCase() ?? def;
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
        System().config?.get('PRIMARY_COLOR')?.toLowerCase() ??
            'lightblue'; // backwards compatibility
    System().colorscheme =
        System().config?.get('COLOR_SCHEME')?.toLowerCase() ??
            System().colorscheme;
    System().font = System().config?.get('FONT');
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

  Future<CONFIG.ConfigModel?> getConfigModel(String? domain, {bool refresh = false}) async
  {
    CONFIG.ConfigModel? model;

    bool isLocalUrl = defaultDomain.toLowerCase().trim().startsWith("file://");
    if (appType == ApplicationTypes.SingleApp && isLocalUrl)
    {
      String cfg = await rootBundle.loadString('assets/config.xml', cache: false);
      if (!S.isNullOrEmpty(cfg)) model = await buildConfigModel(cfg);
      return model;
    }

    if (S.isNullOrEmpty(domain)) return model;
    domain = domain!.trim();

    try
    {
      // get config from settings
      var xml = await Settings().get('config' + ":" + domain);
      if (xml is String)
      {
        XmlDocument? document = Xml.tryParse(xml, silent: true);
        if (document != null) model = CONFIG.ConfigModel.fromXml(null, document.rootElement);
      }
      if (model == null) refresh = true;

      // refresh the config file?
      if ((refresh == true) && (System().connected == true))
      {
        // get the config file from web
        String url = domain + (domain.endsWith("/") ? "" : "/") + "config.xml";
        HttpResponse response = await Http.get(url, refresh: true);

        // found?
        if (response.statusCode == 200)
        {
          model = await buildConfigModel(response.body);
        }
        else if (response.statusCode == 404)
        {
          Log().info('[404] ' + url);
        }
      }
      Log().info('No network connection, unable to fetch config');
    }
    catch (e)
    {
      Log().debug("Failed host lookup: $domain");
    }

    return model;
  }

  Future<CONFIG.ConfigModel?> buildConfigModel(String? xml) async {
    CONFIG.ConfigModel? model;
    ////////////////////
    /* Parse Response */
    ////////////////////
    XmlDocument? document = Xml.tryParse(xml);
    if (document != null) {
      /////////////////
      /* Build Model */
      /////////////////
      Iterable<XmlElement> nodes =
          document.rootElement.findAllElements("CONFIG", namespace: "*");
      if ((nodes.isNotEmpty)) {
        XmlElement node = nodes.first;

        /////////////////
        /* Build Model */
        /////////////////
        model = CONFIG.ConfigModel.fromXml(null, node);

        //////////////////
        /* Save to Hive */
        //////////////////
        if (model != null)
        {
          bool configSaved = await Settings().set('config' + ":" + domain!, node.toXmlString());
          if (configSaved != true) Log().error('Unable to save configuration settings to Hive', caller: 'System.dart buildConfigModel()');
        }
      }
    }
    return model;
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
  String? setUserProperty(String property)
  {
    if ((_user.containsKey(property)) && (_user[property] is Observable)) return _user[property]?.get();
    return null;
  }

  void setApplicationTitle(String? title) async
  {
    title = title ?? System().config?.get("APPLICATION_NAME");
    if (!S.isNullOrEmpty(title))
    {
      // print('setting title to $title');
      SystemChrome.setApplicationSwitcherDescription(ApplicationSwitcherDescription(label: title, primaryColor: Colors.blue.value));
    }
  }
}
