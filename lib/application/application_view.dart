import 'package:flutter/material.dart';
import 'package:fml/application/application_manager.dart';
import 'package:fml/navigation/navigation_manager.dart';
import 'package:fml/navigation/parser.dart';
import 'package:fml/system.dart';
import 'package:fml/theme/theme.dart';
import 'package:provider/provider.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        title: System.title,
        debugShowCheckedModeBanner: false,
        routerDelegate: NavigationManager(key: GlobalKey<NavigatorState>()),
        routeInformationParser: const RouteParser(),
        backButtonDispatcher: RootBackButtonDispatcher(),
        theme: Provider.of<ThemeNotifier>(context).getTheme(),
        builder: (context, widget) => ApplicationManager(child: widget));
  }
}
