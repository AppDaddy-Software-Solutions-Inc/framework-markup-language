import 'package:flutter/material.dart';
import 'package:fml/application/application_manager.dart';
import 'package:fml/navigation/navigation_manager.dart';
import 'package:fml/navigation/parser.dart';
import 'package:fml/system.dart';
import 'package:fml/theme/themenotifier.dart';
import 'package:provider/provider.dart';

class Application extends StatelessWidget
{
  Application({super.key});

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
