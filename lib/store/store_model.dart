// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fml/application/application_model.dart';
import 'package:fml/navigation/navigation_manager.dart';
import 'package:fml/navigation/page.dart';
import 'package:fml/system.dart';
import 'package:fml/theme/themenotifier.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:provider/provider.dart';

class Store extends WidgetModel implements IModelListener
{
  final List<ApplicationModel> _apps = [];

  List<ApplicationModel> getApps() => _apps.toList();

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

    var apps = await ApplicationModel.loadAll();

    _apps.clear();
    for (ApplicationModel app in apps)
    {
      app.registerListener(this);
      _apps.add(app);
    }

    // sort by position
    //_apps.sort();

    busy = false;

    return true;
  }

  Future add(ApplicationModel app) async
  {
    busy = true;

    // insert into the hive
    bool ok = await app.insert();

    // add to the list
    if (ok) _apps.add(app);

    busy = false;
  }

  ApplicationModel? find({String? url})
  {
    // query hive
    ApplicationModel? app = _apps.firstWhereOrNull((app) => app.url == url);

    return app;
  }

  delete(ApplicationModel? app) async
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
    await ApplicationModel.deleteAll();
    busy = false;
  }

  launch(ApplicationModel app, BuildContext context) async
  {
    // get the home page
    var page = app.homePage;

    // set the system app
    System().launch(app);

    // refresh the app
    app.refresh();

    // launch the page
    NavigationManager().setNewRoutePath(PageConfiguration(url: page, title: "Store"), source: "store");

    // change theme
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    String brightness   = Application?.settings('BRIGHTNESS') ?? 'light';
    String color        = Application?.settings('COLOR_SCHEME') ?? 'lightblue';
    themeNotifier.setTheme(brightness, color);
    themeNotifier.mapSystemThemeBindables();
  }

  @override
  onModelChange(WidgetModel model, {String? property, value})
  {
    notifyListeners(property, value);
  }
}