// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fml/hive/app.dart';
import 'package:fml/navigation/manager.dart';
import 'package:fml/navigation/page.dart';
import 'package:fml/system.dart';
import 'package:fml/theme/themenotifier.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:provider/provider.dart';

class Store extends WidgetModel
{
  final List<App> _apps = [];
  List<App> getApps() => _apps.toList();

  bool initialized = false;

  static Store _singleton = Store._initialize();
  factory Store() => _singleton;
  Store._initialize() : super(null, "STORE")
  {
   init();
  }

  init() async
  {
    initialized = await _load();
  }

  Future<bool> _load() async
  {
    busy = true;

    var apps = await App.load();

    _apps.clear();
    for (App app in apps) _apps.add(app);

    // sort by position
    //_apps.sort();

    busy = false;

    return true;
  }

  Future add(App app) async
  {
    busy = true;

    // insert into the hive
    bool ok = await app.insert();

    // add to the list
    if (ok) _apps.add(app);

    busy = false;
  }

  App? find({String? url})
  {
    // query hive
    App? app = _apps.firstWhereOrNull((app) => app.url == url);

    return app;
  }

  delete(App? app) async
  {
    if (app != null)
    {
      busy = true;

      // delete from the hive
      bool ok = await app.delete();

      // remove from the list
      if (ok && _apps.contains(app)) _apps.remove(app);

      busy = false;
    }
  }

  deleteAll() async
  {
    busy = true;
    await App.deleteAll();
    busy = false;
  }

  launch(App app, BuildContext context) async
  {
    // get the home page
    var page = app.homePage;

    // set the system app
    System().app = app;

    // launch the page
    NavigationManager().setNewRoutePath(PageConfiguration(url: page, title: "Store"), source: "store");

    // change theme
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    String brightness   = System().app?.settings('BRIGHTNESS') ?? 'light';
    String color        = System().app?.settings('COLOR_SCHEME') ?? 'lightblue';
    themeNotifier.setTheme(brightness, color);
    themeNotifier.mapSystemThemeBindables();
  }
}