library fml;
export 'fml.dart' show FmlEngine;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fml/application/application_view.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/phrase.dart';
import 'package:fml/splash/splash.dart';
import 'package:fml/system.dart';
import 'package:provider/provider.dart';
import 'package:fml/theme/theme.dart';
import 'dart:io' as io;

enum _ApplicationTypes { singleApp, multiApp }

enum PageTransitions {
  platform,
  none,
  fade,
  slide,
  slideright,
  slideleft,
  zoom,
  rotate
}

/// The FML Engine
class FmlEngine {
  static const String package = "fml";

  // used in context lookup
  static var key = GlobalKey();

  // if the engine has been initialized
  static final initialized = Completer<bool>();

  // platform
  static String get platform => isWeb
      ? "web"
      : isMobile
          ? "mobile"
          : "desktop";
  static bool get isWeb => kIsWeb;
  static bool get isMobile =>
      !isWeb && (io.Platform.isAndroid || io.Platform.isIOS);
  static bool get isDesktop => !isWeb && !isMobile;

  /// This url is used to locate config.xml on startup
  /// Used in Single Application mode only and on Web when developing on localhost
  /// Set this to file://app
  static late String _domain;
  static String get domain => _domain;

  // application version
  static late String _version;
  static String get version => _version;

  /// application title
  /// only used in Android when viewing open applications
  static late String _title;
  static String get title => _title;

  // MultiApp  - (Desktop & Mobile Only) Launches the Store at startup
  static late _ApplicationTypes _type;
  static bool get isMultiApp =>  _type == _ApplicationTypes.multiApp;
  static bool get isSingleApp => _type == _ApplicationTypes.singleApp;
  static set singleApp(bool value) => _type = value ? _ApplicationTypes.singleApp : _ApplicationTypes.multiApp;

  static late String _font;
  static String get defaultFont => _font;

  static late PageTransitions _transition;
  static PageTransitions get defaultTransition => _transition;

  static late Brightness _brightness;
  static Brightness get defaultBrightness => _brightness;

  static late Color _color;
  static Color get defaultColor => _color;

  static final FmlEngine _singleton = FmlEngine._init();

  /// This is the main entry point for the FML
  /// language parser.
  factory FmlEngine({
    /// this domain (url) is used to locate config.xml on startup
    /// Used in Single Application mode only and on Web when developing on localhost
    /// Set this to file://app
    String domain = "https://test.appdaddy.co",

    /// application version
    String version = "1.0.0",

    /// application title
    String title = "My Application Title",

    /// multi app - ignored on web. on desktop and mobile
    /// launches the front page store app on start for multiApp.
    bool multiApp = true,

    /// default theme color on startup
    Color color = Colors.lightBlue,

    /// default theme brightness on startup
    Brightness brightness = Brightness.light,

    /// default theme brightness on startup
    String font = 'Roboto',

    /// default page transition
    PageTransitions transition = PageTransitions.platform,
  }) {

    // already initialized?
    if (FmlEngine.initialized.isCompleted) return _singleton;

    // initialize the engine
    FmlEngine._domain = domain;
    FmlEngine._title = title;
    FmlEngine._version = version;
    FmlEngine._type = (multiApp && !isWeb)
        ? _ApplicationTypes.multiApp
        : _ApplicationTypes.singleApp;
    FmlEngine._font = font;
    FmlEngine._transition = transition;
    FmlEngine._color = color;
    FmlEngine._brightness = brightness;

    // mark initialized
    FmlEngine.initialized.complete(true);

    return _singleton;
  }

  FmlEngine._init() {
    // error builder
    ErrorWidget.builder = _errorBuilder;

    // hides all render flex exceptions
    FlutterError.onError = _showError;

    // initialize the system
    System().initialize();
  }

  Widget launch() {
    // fml engine
    var engine = ChangeNotifierProvider<ThemeNotifier>(
        child: Application(key: FmlEngine.key),
        create: (_) => onThemeNotifierCreated());

    // splash screen
    var splash = Splash(
        key: UniqueKey(), onInitializationComplete: () => runApp(engine));

    // launch the splash screen
    runApp(splash);

    return splash;
  }

  onThemeNotifierCreated() {
    try {
      var theme = ThemeNotifier.from(System.theme.colorScheme,
          googleFont: System.theme.font);
      return ThemeNotifier(theme);
    } catch (e) {
      Log().debug(
          'Init Theme Error: $e \n(Configured fonts from https://fonts.google.com/ are case sensitive)');
      return ThemeNotifier(ThemeNotifier.from(System.theme.colorScheme));
    }
  }

  Widget _errorBuilder(FlutterErrorDetails details) {
    // log the error
    Log().error(details.exception.toString(),
        caller: 'ErrorWidget() : main.dart');

    // in debug mode shows the normal red screen  error
    if (kDebugMode) {
      return ErrorWidget("${details.exception}\n${details.stack.toString()}");
    }

    var style = const TextStyle(color: Colors.black);
    var text = Text('⚠️\n${Phrases().somethingWentWrong}',
        style: style, textAlign: TextAlign.center);

    // in release builds, shows a more user friendly interface
    return Container(
        color: Colors.white, alignment: Alignment.center, child: text);
  }

  void _showError(FlutterErrorDetails details) {
    bool show = false;
    if (details.exception.toString().startsWith("A Render")) show = false;
    if (show) FlutterError.presentError(details);
  }
}
