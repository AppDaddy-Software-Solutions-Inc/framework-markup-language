// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'dart:core';
import 'package:cross_connectivity/cross_connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:fml/datasources/log/log_model.dart';
import 'package:fml/event/event.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/navigation/navigation_manager.dart';
import 'package:fml/phrase.dart';
import 'package:fml/postmaster/postmaster.dart';
import 'package:fml/janitor/janitor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fml/widgets/theme/theme_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:fml/hive/database.dart';
import 'package:fml/datasources/gps/gps.dart' as GPS;
import 'package:fml/datasources/gps/payload.dart' as GPS;
import 'package:fml/application/application_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';
import 'dart:io' as io;

// application build version
final String version = '1.2.2';

// application title
// only used in Android when viewing open applications
final String applicationTitle = "Flutter Markup Language " + version;

// This url is used to locate config.xml on startup
// Used in SingleApp only and on Web when developing on localhost
// Set this to file://applications/<app> to use the asset applications
String get defaultDomain => 'https://test.appdaddy.co';

// SingleApp - App initializes from a single domain endpoint (defined in defaultDomain)
// MultiApp  - (Desktop & Mobile Only) Launches the Store at startup
final ApplicationTypes appType = ApplicationTypes.MultiApp;

enum ApplicationTypes{ SingleApp, MultiApp }

// platform
String get platform => isWeb ? "web" : isMobile ? "mobile" : "desktop";
bool get isWeb      => kIsWeb;
bool get isMobile   => !isWeb && (io.Platform.isAndroid || io.Platform.isIOS);
bool get isDesktop  => !isWeb && !isMobile;

// This variable is used throughout the code to determine if debug messages
// and their corresponding actions should be performed.
// Putting this inside the System() class is problematic at startup
// when log messages being written while System() is still be initialized.
final bool kDebugMode = !kReleaseMode;

typedef CommitCallback = Future<bool> Function();

// used in context lookup
var applicationKey = GlobalKey();

class System extends WidgetModel implements IEventManager
{
  static final String myId = "SYSTEM";

  // set to true once done
  static var _completer = Completer();
  static get initialized => _completer.future;

  // this get called once by Splash
  Future get installed => _completer.future;

  static final System _singleton = System._initialize();
  factory System() => _singleton;
  System._initialize() : super(null, myId, scope: Scope(id: myId)) {_initialize();}

  // current application
  static ApplicationModel? _app;
  static ApplicationModel? get app => _app;

  // current theme
  static late ThemeModel _theme;
  static ThemeModel get theme => _theme;

  late Connectivity connection;

  // post master service
  final PostMaster postmaster = PostMaster();

  // janitorial service
  final Janitor janitor = Janitor();

  // current domain
  BooleanObservable? _connected;
  bool get connected => _connected?.get() ?? false;

  // root folder path
  StringObservable? _rootpath;
  String? get rootpath => _rootpath?.get();

  // current domain
  StringObservable? _domain;
  String? get domain => _domain?.get();

  StringObservable? _scheme;
  String? get scheme => _scheme?.get();

  // current host
  StringObservable? _host;
  String? get host => _host?.get();

  /// Global System Observable
  StringObservable? _userplatform;
  String? get userplatform => _userplatform?.get();

  StringObservable? _useragent;
  String? get useragent => _useragent?.get() ?? Platform.useragent;

  StringObservable? _version;
  String get release => _version?.get() ?? "?";

  late IntegerObservable _screenheight;
  int get screenheight => _screenheight.get() ?? 0;
  set screenheight (dynamic v) => _screenheight.set(v);

  late IntegerObservable _screenwidth;
  int get screenwidth => _screenwidth.get() ?? 0;
  set screenwidth (dynamic v) => _screenwidth.set(v);

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

  late String baseUrl;

  _initialize() async
  {
    print('Initializing FML Engine V$version on ${Uri.base}...');

    // base URL changes (fragment is dropped) if
    // used past this point
    baseUrl = Uri.base.toString();

    // initialize platform
    await Platform.init();

    // initialize System Globals
    await _initBindables();

    // initialize Hive
    await _initDatabase();

    // initialize connectivity
    await _initConnectivity();

    // create empty applications folder
    if (!isWeb) await _initFolders();

    // set initial route
    await _initRoute();

    // start the Post Master
    await postmaster.start();

    // start the Janitor
    await janitor.start();

    // signal complete
    _completer.complete(true);
  }

  Future _initConnectivity() async
  {
    try
    {
      connection = Connectivity();

      ConnectivityStatus initialConnection = await connection.checkConnectivity();
      if (initialConnection == ConnectivityStatus.none) System.toast(Phrases().checkConnection, duration: 3);

      // Add connection listener
      connection.isConnected.listen((isconnected)
      {
        Log().info("Connection status changed to $isconnected");
        _connected?.set(isconnected);
      });

      // For the initial connectivity test we want to give checkConnection some time
      // but it still needs to run synchronous so we give it a second
      await Future.delayed(Duration(seconds: 1));
      Log().debug('initConnectivity status: $connected');
    }
    catch(e)
    {
      _connected?.set(false);
      Log().debug('Error initializing connectivity');
    }
  }

  Future<bool> _initBindables() async
  {
    // platform root path
    URI.rootPath  = await Platform.path ?? "";
    _rootpath = StringObservable(Binding.toKey('rootpath'), URI.rootPath, scope: scope);

    // connected
    _connected = BooleanObservable(Binding.toKey('connected'), null, scope: scope);

    // active application settings
    _domain = StringObservable(Binding.toKey('domain'), null, scope: scope);
    _scheme = StringObservable(Binding.toKey('scheme'), null, scope: scope);
    _host   = StringObservable(Binding.toKey('host'),   null, scope: scope);

    // create the theme
    _theme = ThemeModel(this, "THEME");

    // device settings
    _screenheight = IntegerObservable(Binding.toKey('screenheight'), WidgetsBinding.instance.window.physicalSize.height, scope: scope);
    _screenwidth  = IntegerObservable(Binding.toKey('screenwidth'),  WidgetsBinding.instance.window.physicalSize.width, scope: scope);
    _userplatform = StringObservable(Binding.toKey('platform'), platform, scope: scope);
    _useragent    = StringObservable(Binding.toKey('useragent'), Platform.useragent, scope: scope);
    _version      = StringObservable(Binding.toKey('version'), version, scope: scope);
    _uuid         = StringObservable(Binding.toKey('uuid'), uuid(), scope: scope, getter: uuid);

    // system dates
    _epoch  = IntegerObservable(Binding.toKey('epoch'), epoch(), scope: scope, getter: epoch);
    _year   = IntegerObservable(Binding.toKey('year'), year(), scope: scope, getter: year);
    _month  = IntegerObservable(Binding.toKey('month'), month(), scope: scope, getter: month);
    _day    = IntegerObservable(Binding.toKey('day'), day(), scope: scope, getter: day);
    _hour   = IntegerObservable(Binding.toKey('hour'), hour(), scope: scope, getter: hour);
    _minute = IntegerObservable(Binding.toKey('minute'), minute(), scope: scope, getter: minute);
    _second = IntegerObservable(Binding.toKey('second'), second(), scope: scope, getter: second);

    // add system level log model datasource
    if (datasources == null) datasources = [];
    datasources!.add(LogModel(this, "LOG"));

    return true;
  }

  Future<bool> _initDatabase() async
  {
    // create the hive folder
    var folder = normalize(join(URI.rootPath,"hive"));
    String? hiveFolder = await Platform.createFolder(folder);

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
      // create applications folder
      String? folderpath = normalize(join(URI.rootPath,"applications"));
      folderpath = await Platform.createFolder(folderpath);

      // read asset manifest
      Map<String, dynamic> manifest = json.decode(await rootBundle.loadString('AssetManifest.json'));

      // copy assets
      for (String key in manifest.keys)
      if (key.startsWith("assets/applications"))
      {
        var folder   = key.replaceFirst("assets/", "");
        var filepath = normalize(join(URI.rootPath,folder));
        await Platform.writeFile(filepath, await rootBundle.load(key));
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

  Future _initRoute() async
  {
    // set default app
    if (isWeb || appType == ApplicationTypes.SingleApp)
    {
      var domain = defaultDomain;

      // replace default for testing
      if (isWeb)
      {
        var uri = Uri.tryParse(baseUrl);
        if (uri != null && !uri.host.toLowerCase().startsWith("localhost")) domain = uri.url;
      }

      print('Startup Domain is $domain');

      // set default app
      ApplicationModel app = ApplicationModel(System(), url: domain);

      // wait for it to initialize
      await app.initialized;

      // start the app
      System().launchApplication(app, false);
    }
  }

  void setApplicationTitle(String? title) async
  {
    title = title ?? app?.settings("APPLICATION_NAME");
    if (!S.isNullOrEmpty(title))
    {
      // print('setting title to $title');
      SystemChrome.setApplicationSwitcherDescription(ApplicationSwitcherDescription(label: title, primaryColor: Colors.blue.value));
    }
  }

  // launches the application
  launchApplication(ApplicationModel app, bool notifyOnThemeChange)
  {
    // Close the old application if one
    // is running
    if (_app != null)
    {
      Log().info("Closing Application ${_app!.url}");

      // set the default domain on the Url utilities
      URI.rootHost = "";

      // logoff
      _app?.logoff();

      // update application level bindables
      _domain?.set(null);
      _scheme?.set(null);
      _host?.set(null);

      // close application
      _app!.close();
    }

    Log().info("Activating Application (${app.title}) @ ${app.domain}");

    // set the default domain on the Url utilities
    URI.rootHost = app.domain ?? "";

    // set the current application
    _app = app;

    // launch the application
    app.launch(theme, notifyOnThemeChange);

    // set credentials
    if (app.jwt != null) _app?.logon(app.jwt);

    // update application level bindables
    _domain?.set(app.domain);
    _scheme?.set(app.scheme);
    _host?.set(app.host);
  }

  /// Event Manager Host
  final EventManager manager = EventManager();
  registerEventListener(EventTypes type, OnEventCallback callback, {int? priority}) => manager.register(type, callback, priority: priority);
  removeEventListener(EventTypes type, OnEventCallback callback) => manager.remove(type, callback);
  broadcastEvent(WidgetModel source, Event event) => manager.broadcast(this, event);
  executeEvent(WidgetModel source, String event) => manager.execute(this, event);
}
