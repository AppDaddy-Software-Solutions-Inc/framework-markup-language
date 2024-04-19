// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:core';
import 'package:changeicon/changeicon.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:fml/connection/connection.dart';
import 'package:fml/datasources/log/log_model.dart';
import 'package:fml/dialog/manager.dart';
import 'package:fml/event/event.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/navigation/navigation_manager.dart';
import 'package:fml/phrase.dart';
import 'package:fml/postmaster/postmaster.dart';
import 'package:fml/janitor/janitor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fml/widgets/shortcut/shortcut_model.dart';
import 'package:fml/widgets/theme/theme_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:fml/hive/database.dart';
import 'package:fml/datasources/gps/gps.dart';
import 'package:fml/datasources/gps/payload.dart';
import 'package:fml/application/application_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';
import 'fml.dart';
import 'widgets/framework/framework_model.dart';
import 'dart:io' as io show Platform;

// platform
import 'package:fml/platform/platform.vm.dart'
    if (dart.library.io) 'package:fml/platform/platform.vm.dart'
    if (dart.library.html) 'package:fml/platform/platform.web.dart';

class System extends Model implements IEventManager {
  static const String myId = "SYSTEM";

  static final initialized  = Completer<bool>();
  static final _initializing = Completer<bool>();

  static final System _singleton = System._initialize();
  factory System() => _singleton;
  System._initialize() : super(null, myId, scope: Scope(id: myId));

  // companies are used for defaultApp's in multiApp mode
  // on launch, if the user configures a single app in the store and
  // specified it as the "default" app, the icon on the mobile desktop
  // if changed to that same icon defined in the res images (android) or plist (ios)
  // this requires the client to add those images and recompile
  static final List<String> companies = ['appdaddy', 'goodyear', 'rocketfunds'];

  // application list
  static List<ApplicationModel> _apps = [];

  // sorted list of applications
  static List<ApplicationModel> get apps => _apps..sort((a, b) => Comparable.compare(a.order ?? 99999, b.order ?? 99999))..toList();

  // current app
  static ApplicationModel? _app;
  static ApplicationModel? get currentApp => _brandedApp ?? _app;
  static set currentApp (ApplicationModel? app) => _app = app;

  // returns the default app
  static ApplicationModel? get _brandedApp => (FmlEngine.type == ApplicationType.branded && _apps.isNotEmpty) ? _apps.first : null;

  // current theme
  static late ThemeModel _theme;
  static ThemeModel get theme => _theme;

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
  static StringObservable? _domain;
  static String? get domain => _domain?.get();

  static StringObservable? _scheme;
  static String? get scheme => _scheme?.get();

  // current host
  static StringObservable? _host;
  static String? get host => _host?.get();

  /// Global System Observable
  StringObservable? _userplatform;
  String? get userplatform => _userplatform?.get() ?? FmlEngine.platform;

  StringObservable? _useragent;
  String? get useragent => _useragent?.get() ?? Platform.useragent;

  StringObservable? _version;
  String get release => _version?.get() ?? "?";

  late IntegerObservable _screenheight;
  int get screenheight => _screenheight.get() ?? 0;
  set screenheight(dynamic v) => _screenheight.set(v);

  late IntegerObservable _screenwidth;
  int get screenwidth => _screenwidth.get() ?? 0;
  set screenwidth(dynamic v) => _screenwidth.set(v);

  // current domain
  late BooleanObservable? _mouse;
  bool get mouse => _mouse?.get() ?? false;

  // UUID
  StringObservable? _uuid;

  // Dates
  Timer? clock;

  IntegerObservable? _epoch;
  int epoch() => (_epoch != null) ? DateTime.now().millisecondsSinceEpoch : 0;

  IntegerObservable? _year;
  int year() => (_year != null) ? DateTime.now().year : 0;

  IntegerObservable? _month;
  int month() => (_month != null) ? DateTime.now().month : 0;

  IntegerObservable? _day;
  int day() => (_day != null) ? DateTime.now().day : 0;

  IntegerObservable? _hour;
  int hour() => (_hour != null) ? DateTime.now().hour : 0;

  IntegerObservable? _minute;
  int minute() => (_minute != null) ? DateTime.now().minute : 0;

  IntegerObservable? _second;
  int second() => (_second != null) ? DateTime.now().second : 0;

  // GPS
  Gps gps = Gps();
  Payload? currentLocation;

  static late String baseUrl;

  @override
  Future<void> initialize() async {

    // initialize should only run once
    if (initialized.isCompleted || _initializing.isCompleted) return;

    // signal initializing in progress
    _initializing.complete(true);

    // base URL changes (fragment is dropped) if
    // used past this point
    baseUrl = Uri.base.toString();

    // initialize platform
    await Platform.initialize();

    // initialize System Globals
    await _initBindables();

    // initialize connection monitor
    // this needs to be done ahead of initializing apps
    // since they use the template manager
    await Connection.initialize(_connected);

    // initialize the database (Hive)
    await _initDatabase();

    // load apps
    await _loadApps();

    // start the Post Master
    postmaster.start();

    // start the Janitor
    janitor.start();

    // add keyboard listener
    ServicesBinding.instance.keyboard.addHandler(onShortcutHandler);

    // the mouse isn't always detected at startup
    // not until the moves it or clicks
    // this routine traps that
    RendererBinding.instance.mouseTracker.addListener(onMouseDetected);

    // set fml2js
    Platform.fml2js(version: FmlEngine.version);

    // launch the application
    await launchApplication(currentApp, navigate: false);

    // signal complete
    initialized.complete(true);
  }

  onMouseDetected() {
    _mouse?.set(true);
    RendererBinding.instance.mouseTracker.removeListener(onMouseDetected);
  }

  Future<bool> _initBindables() async {
    _rootpath =
        StringObservable(Binding.toKey('rootpath'), URI.rootPath, scope: scope);

    // connected
    _connected =
        BooleanObservable(Binding.toKey('connected'), null, scope: scope);

    // active application settings
    _domain = StringObservable(Binding.toKey('domain'), null, scope: scope);
    _scheme = StringObservable(Binding.toKey('scheme'), null, scope: scope);
    _host = StringObservable(Binding.toKey('host'), null, scope: scope);

    // create the theme
    _theme = ThemeModel(this, "THEME");

    // device settings
    _mouse = BooleanObservable(Binding.toKey('mouse'),
        RendererBinding.instance.mouseTracker.mouseIsConnected,
        scope: scope);
    _screenheight = IntegerObservable(Binding.toKey('screenheight'),
        PlatformDispatcher.instance.views.first.physicalSize.height,
        scope: scope);
    _screenwidth = IntegerObservable(Binding.toKey('screenwidth'),
        PlatformDispatcher.instance.views.first.physicalSize.width,
        scope: scope);
    _userplatform = StringObservable(
        Binding.toKey('platform'), FmlEngine.platform,
        scope: scope);
    _useragent = StringObservable(
        Binding.toKey('useragent'), Platform.useragent,
        scope: scope);
    _version = StringObservable(Binding.toKey('version'), FmlEngine.version,
        scope: scope);
    _uuid = StringObservable(Binding.toKey('uuid'), newId(),
        scope: scope, getter: newId);

    // this satisfies/eliminates the compiler warning
    if (kDebugMode) {
      print(_uuid);
    }

    // system dates
    _epoch = IntegerObservable(Binding.toKey('epoch'), epoch(),
        scope: scope, getter: epoch);
    _year = IntegerObservable(Binding.toKey('year'), year(),
        scope: scope, getter: year);
    _month = IntegerObservable(Binding.toKey('month'), month(),
        scope: scope, getter: month);
    _day = IntegerObservable(Binding.toKey('day'), day(),
        scope: scope, getter: day);
    _hour = IntegerObservable(Binding.toKey('hour'), hour(),
        scope: scope, getter: hour);
    _minute = IntegerObservable(Binding.toKey('minute'), minute(),
        scope: scope, getter: minute);
    _second = IntegerObservable(Binding.toKey('second'), second(),
        scope: scope, getter: second);

    // add system level log model datasource
    datasources ??= [];
    datasources!.add(LogModel(this, "LOG"));

    return true;
  }

  static Future<bool> _initDatabase() async {

    // create the hive folder
    var folder = normalize(join(URI.rootPath, "hive"));
    String? hiveFolder = await Platform.createFolder(folder);

    // initialize hive
    return await Database.initialize(hiveFolder);
  }

  static toast(String? msg, {int? duration}) {
    BuildContext? context = NavigationManager().navigatorKey.currentContext;
    if (context != null && context.mounted) {
      SnackBar snackBar = SnackBar(
          content: Text(msg ?? ''),
          duration: Duration(seconds: duration ?? 4),
          behavior: SnackBarBehavior.floating,
          elevation: 5,
          showCloseIcon: true);
      ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(snackBar);
    }
  }

  static var appsLoaded = Completer<bool>();
  static Future _loadApps() async {

    // load the apps from the database
    _apps = FmlEngine.isWeb ? [] : await ApplicationModel.loadAll();

    // remove redundant apps if branded (this normally wont be needed
    // only in development mode where user is switching between app types
    while (FmlEngine.type == ApplicationType.branded && _apps.length > 1) {
      var app = _apps.last;
      await app.initialized;
      await app.delete();
      _apps.removeLast();
    }

    // reorder apps by index
    var reorder = _apps.length > 1 && (_apps.firstWhereOrNull((app) => app.order == null) != null);
    if (reorder) await _resequenceApps();

    // set default app
    if (kIsWeb || FmlEngine.type == ApplicationType.single) {

      // set the domain
      var domain = FmlEngine.domain;

      // replace default for testing
      if (FmlEngine.isWeb) {

        // parse the site domain url
        var uri = Uri.tryParse(baseUrl);

        // if web, we use the browser url unless its localhost
        if (uri != null && !uri.host.toLowerCase().startsWith("localhost")) {
          domain = uri.url;
        }
      }

      var app = ApplicationModel(System(), url: domain, page: 0, order: 0);

      // add the app to the apps list
      _apps.insert(0, app);

      // set current
      System.currentApp = app;
    }

    // wait for current app to initialize
    await System.currentApp?.initialized;

    // signal complete - used in splash
    appsLoaded.complete(true);
  }

  static String get title => Platform.title;

  static void setApplicationTitle(String? title) async {
    title = title ?? currentApp?.name;
    if (!isNullOrEmpty(title)) {
      SystemChrome.setApplicationSwitcherDescription(
          ApplicationSwitcherDescription(
              label: title, primaryColor: Colors.blue.value));
    }
  }

  /// changes the desktop icon
  static const mainIcon = 'MainActivity';
  static Changeicon? _changeIconPlugin;
  static void _setBranding(String icon)
  {
    //if (kIsWeb) return;

    bool canSet = false;
    try
    {
      canSet = io.Platform.isIOS || io.Platform.isAndroid;
    }
    catch(e)
    {
      canSet = false;
    }
    if (!canSet) return;

    // no clients defined
    if (companies.isEmpty) return;

    // initialize the plugin
    if (_changeIconPlugin == null) {
      Changeicon.initialize(classNames: [mainIcon, ...companies]);
      _changeIconPlugin = Changeicon();
    }

    // trim icon
    icon = icon.toLowerCase().trim();

    // change the icon
    if (companies.contains(icon))
    {
      _changeIconPlugin?.switchIconTo(classNames: [icon]);
    }
    else
    {
      _changeIconPlugin?.switchIconTo(classNames: [mainIcon]);
    }
  }

  static Future<bool> _confirmClearBranding() async
  {
    var context = NavigationManager().navigatorKey.currentContext;
    if (context != null)
    {
      var no = Text(phrase.no,
          style:
          const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500));
      var yes = Text(phrase.yes,
          style:
          const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500));

      var response = await DialogManager.show(context,
          type: DialogType.warning,
          title: phrase.removeDefaultApp,
          buttons: [no, yes]);

      return response == 1;
    }
    return false;
  }

  static void clearBranding() async
  {
    // do nothing if in web or no default application
    if (FmlEngine.isWeb || _brandedApp == null) return;

    // show dialog to confirm
    bool ok = await _confirmClearBranding();
    if (!ok) return;

    // reset default icon
    _setBranding(mainIcon);

    // delete all apps
    for (var app in _apps) {
      await app.initialized;
      await app.delete();
    }
    _apps.clear();

    // notify the user
    ok ? toast(phrase.defaultAppRemoved) : toast(phrase.defaultAppRemovedProblem);
  }

  static _closeCurrentApp()
  {
    if (currentApp == null) return;

    // closing app
    Log().info("Closing Application ${currentApp?.url}");

    // set the default domain on the Url utilities
    URI.rootHost = "";

    // logoff
    currentApp?.logoff();

    // update application level bindables
    _domain?.set(null);
    _scheme?.set(null);
    _host?.set(null);

    // close application
    currentApp?.close();
  }

  // launches the application
  static Future<void> launchApplication(ApplicationModel? app, {bool navigate = true}) async {

    if (app == null) return;

    // close the current application
    if (app != currentApp) _closeCurrentApp();

    // set the default domain for url conversion
    URI.rootHost = app.domain ?? "";

    // open new application
    Log().info("Launching Application (${app.title}) @ ${app.domain}");

    // wait for app to initialize
    await app.initialized;

    // set branding
    if (_brandedApp != null) _setBranding(_brandedApp!.company ?? mainIcon);

    // update application level bindables
    _domain?.set(app.domain);
    _scheme?.set(app.scheme);
    _host?.set(app.host);

    //  activate the app
    await app.setActive();

    // navigate to page?
    if (navigate) {
      NavigationManager().navigateTo(app.homePage);
    }
  }

  static Future<bool> addApplication(ApplicationModel app) async {

    bool ok = true;

    // set page
    app.page ??= 0;

    // set ordering
    app.order ??= _apps.length;

    // insert into the hive
    ok = await app.insert();

    // add to the list
    if (!_apps.contains(app)) _apps.add(app);

    return ok;
  }

  static Future<bool> deleteApplication(ApplicationModel app) async {

    bool ok = true;

    // delete app from the database
    ok = await app.delete();

    // add to the list
    if (_apps.contains(app)) _apps.remove(app);

    // re-sequence the apps
    await _resequenceApps();

    // dispose of the app
    app.dispose();

    return ok;
  }

  static Future<bool> _resequenceApps() async {

    bool ok = true;

    // sort the list by app ordering
    _apps.sort((a, b) => Comparable.compare(a.order ?? 99999, b.order ?? 99999));

    int i = 0;
    for (var app in _apps) {
      // set the application ordering
      app.order = i++;

      // insert into the hive
      ok = await app.update();
    }

    return ok;
  }

  // sets the active framework
  FrameworkModel? _activeFramework;
  void setActiveFramework(FrameworkModel model) => _activeFramework = model;

  // handle key press
  bool onShortcutHandler(KeyEvent event) =>
      ShortcutHandler.handleKeyPress(event, _activeFramework);

  /// Event Manager Host
  final EventManager manager = EventManager();
  @override
  registerEventListener(EventTypes type, OnEventCallback callback,
          {int? priority}) =>
      manager.register(type, callback, priority: priority);

  @override
  removeEventListener(EventTypes type, OnEventCallback callback) =>
      manager.remove(type, callback);

  @override
  broadcastEvent(Model source, Event event) =>
      manager.broadcast(this, event);

  @override
  executeEvent(Model source, String event) =>
      manager.execute(this, event);
}
