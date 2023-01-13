// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:fml/hive/app.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;

class Store extends WidgetModel
{
  final List<App> apps = [];
  bool initialized = false;

  static Store _singleton = Store._initialize();
  factory Store() => _singleton;
  Store._initialize() : super(null, "STORE")
  {
   init();
  }

  init() async
  {
    initialized = await load();
  }

  Future<bool> load() async
  {
    busy = true;

    var apps = await App.load();

    this.apps.clear();
    for (App app in apps) this.apps.add(app);
    this.apps.sort();

    busy = false;

    return true;
  }

  Future add(App app) async
  {
    busy = true;
    bool ok = await app.insert();
    if (ok)
    busy = false;
  }

  App? find({String? url})
  {
    App? app = apps.firstWhereOrNull((app) => app.url == url);
    return app;
  }

  delete(App? app) async
  {
    if (app != null)
    {
      busy = true;
      await app.delete();
      busy = false;
    }
  }

  deleteAll() async
  {
    busy = true;
    await App.deleteAll();
    busy = false;
  }
}