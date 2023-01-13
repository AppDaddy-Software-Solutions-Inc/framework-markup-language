// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:fml/hive/database.dart';
import 'package:fml/helper/helper_barrel.dart';

enum Fields {key, url, title, icon, order}

class App
{
  static String tableName = "APP";

  Map<String, dynamic> _map = Map<String, dynamic>();

  String  get key   => _map["key"];
  String  get url   => _map["url"];
  String? get title => _map["title"];
  String? get icon  => _map["icon"];
  int?    get order => _map["order"];

  App({String? key, String? url, String? title, String? icon, int? order})
  {
    _map["key"]   = key ?? Uuid().v4();
    _map["url"]   = url;
    _map["title"] = title;
    _map["icon"]  = icon;
    _map["order"] = order;
  }

  Future<bool> insert() async => (await Database().insert(tableName, key, _map) == null);
  Future<bool> update() async => (await Database().update(tableName, key, _map) == null);
  Future<bool> delete() async => (await Database().delete(tableName, key) == null);

  static Future<bool> deleteAll() async => (await Database().deleteAll(tableName) == null);

  static App? _fromMap(dynamic map)
  {
    App? app;
    if (map is Map<String, dynamic>) app = App(key: S.mapVal(map, "key"), url: S.mapVal(map, "url"), title: S.mapVal(map, "title"), icon: S.mapVal(map, "icon"), order: S.mapInt(map, "order"));
    return app;
  }

  static Future<List<App>> load() async
  {
    List<App> apps = [];
    List<Map<String, dynamic>> entries = await Database().query(tableName);
    entries.forEach((entry)
    {
      App? app = _fromMap(entry);
      if (app != null) apps.add(app);
    });
    return apps;
  }
}