// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/application/application_manager.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/navigation/navigation_manager.dart';
import 'package:fml/navigation/parser.dart';
import 'package:fml/splash/splash.dart';
import 'package:fml/system.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fml/theme/theme.dart' as fml_theme;
import 'package:fml/theme/themenotifier.dart';
import 'package:fml/phrase.dart';

final RegExp nonQuotedSemiColons = RegExp(r"''(?=([^'\\]*(\\.|'([^'\\]*\\.)*[^'\\]*'))*[^']*$)");

main()
{
  ErrorWidget.builder = (FlutterErrorDetails details) {
    Log().error(details.exception.toString(), caller: 'ErrorWidget() : main.dart');
    // In debug mode shows the normal redscreen  error
    if (kDebugMode) {
      return ErrorWidget("${details.exception}\n${details.stack.toString()}");
    }
    // In release builds, shows a more user friendly interface
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Text('⚠️\n${Phrases().somethingWentWrong}',
        style: const TextStyle(color: Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  };
  runApp(Container(color: Colors.black, child: Splash(key: UniqueKey(), onInitializationComplete: runMainApp)));
}

void runMainApp()
{
  // hides all render flex exceptions
  FlutterError.onError = (details)
  {
    bool show = false;
    if (details.exception.toString().startsWith("A Render")) show = false;
    if (show) FlutterError.presentError(details);
  };

  // run the application
  runApp(ChangeNotifierProvider<ThemeNotifier>(
      create: (_)
      {
        try
        {
          var font = System.theme.font;
          return ThemeNotifier(fml_theme.MyTheme().deriveTheme(System.theme.colorscheme, googleFont: font));
        }
        catch(e)
        {
          Log().debug('Init Theme Error: $e \n(Configured fonts from https://fonts.google.com/ are case sensitive)');
          return ThemeNotifier(fml_theme.MyTheme().deriveTheme(System.theme.colorscheme));
        }
      },
      child: Application(key: applicationKey)));
}

class Application extends StatelessWidget
{
  Application({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context)
  {
    // initializes the theme bindables and updates on theme change
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    themeNotifier.mapSystemThemeBindables();

    return MaterialApp.router(
        title: System.title,
        debugShowCheckedModeBanner: false,
        routerDelegate: NavigationManager(key: GlobalKey<NavigatorState>()),
        routeInformationParser: const RouteParser(),
        backButtonDispatcher: RootBackButtonDispatcher(),
        theme: themeNotifier.getTheme(),
        builder: (context, widget) => ApplicationManager(child: widget));
  }
}