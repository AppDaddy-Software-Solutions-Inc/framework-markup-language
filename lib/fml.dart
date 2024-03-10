library fml;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fml/application/application_view.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/phrase.dart';
import 'package:fml/splash/splash.dart';
import 'package:fml/system.dart';
import 'package:fml/theme/themenotifier.dart';
import 'package:provider/provider.dart';
import 'package:fml/theme/theme.dart';
import 'dart:io' as io;

enum ApplicationTypes { singleApp, multiApp }

/// The FML Engine
class FmlEngine
{
  static final String package = "fml";

  // used in context lookup
  static var key = GlobalKey();

  // platform
  static String get platform => isWeb ? "web" : isMobile ? "mobile" : "desktop";
  static bool get isWeb => kIsWeb;
  static bool get isMobile => !isWeb && (io.Platform.isAndroid || io.Platform.isIOS);
  static bool get isDesktop => !isWeb && !isMobile;

  // This variable is used throughout the code to determine if debug messages
  // and their corresponding actions should be performed.
  // Putting this inside the System() class is problematic at startup
  // when log messages being written while System() is still be initialized.
  static final bool kDebugMode = !kReleaseMode;

  /// This url is used to locate config.xml on startup
  /// Used in Single Application mode only and on Web when developing on localhost
  /// Set this to file://app
  static late String _domain;
  static String get domain => _domain;

  // application version
  static late String _version;
  static String get version => _version;

  // application title
  // only used in Android when viewing open applications
  static late String _title;
  static String get title => _title;

  // MultiApp  - (Desktop & Mobile Only) Launches the Store at startup
  static late ApplicationTypes _type;
  static ApplicationTypes get type => _type;

  // splash screen background color
  static late Color _splashScreenColor;
  static Color get splashScreenColor => _splashScreenColor;

  // if the engine has been initialized
  static bool _initialized = false;

  static final FmlEngine _singleton =  FmlEngine._init();
  factory FmlEngine({

    // this domain (url) is used to locate config.xml on startup
    // Used in Single Application mode only and on Web when developing on localhost
    // Set this to file://app
    String domain = "https://test.appdaddy.co",

    // application version
    String version = "1.0.0",

    // application title
    String title = "My Application Title",

    // application type = multiApp types launch the store on startup for desktop and mobile
    ApplicationTypes type = ApplicationTypes.multiApp,

    // splash screen color
    Color splashScreenColor = Colors.black})
  {
    if (FmlEngine._initialized) return _singleton;

    // initialize the engine
    FmlEngine._domain = domain;
    FmlEngine._title = title;
    FmlEngine._version = version;
    FmlEngine._type = type;
    FmlEngine._splashScreenColor = splashScreenColor;

    // mark initialized
    FmlEngine._initialized = true;

    return _singleton;
  }

  FmlEngine._init()
  {
    _initErrorBuilder();
  }

  _initErrorBuilder()
  {
    // error builder
    ErrorWidget.builder = (FlutterErrorDetails details)
    {
      Log().error(details.exception.toString(), caller: 'ErrorWidget() : main.dart');

      // in debug mode shows the normal red screen  error
      if (kDebugMode) return ErrorWidget("${details.exception}\n${details.stack.toString()}");

      // in release builds, shows a more user friendly interface
      return Container(color: Colors.white,
          alignment: Alignment.center,
          child: Text('⚠️\n${Phrases().somethingWentWrong}',
              style: const TextStyle(color: Colors.black), textAlign: TextAlign.center));
    };

    // hides all render flex exceptions
    FlutterError.onError = (details)
    {
      bool show = false;
      if (details.exception.toString().startsWith("A Render")) show = false;
      if (show) FlutterError.presentError(details);
    };
  }

  launch() => runApp(Container(color: splashScreenColor, child: Splash(key: UniqueKey(), onInitializationComplete: _runApp)));
}

void _runApp()
{
  // run the application
  runApp(ChangeNotifierProvider<ThemeNotifier>(
      create: (_)
      {
        try
        {
          var font = System.theme.font;
          return ThemeNotifier(MyTheme().deriveTheme(System.theme.colorScheme, googleFont: font));
        }
        catch(e)
        {
          Log().debug('Init Theme Error: $e \n(Configured fonts from https://fonts.google.com/ are case sensitive)');
          return ThemeNotifier(MyTheme().deriveTheme(System.theme.colorScheme));
        }
      },
      child: Application(key: FmlEngine.key)));
}