// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/hive/database.dart';

class Stash
{
  static String tableName = "STASH";

  final String key;
  final Map<String, dynamic> map;

  Stash(this.key, this.map);

  // inserts a new app into the local hive
  Future<bool> insert() async
  {
    var exception = await Database().insert(tableName, key, map);
    return (exception == null);
  }

  // updates the app in the local hive
  Future<bool> upsert() async
  {
    var exception = await Database().upsert(tableName, key, map);
    return (exception == null);
  }

  // delete an app from the local hive
  Future<bool> delete() async
  {
    var exception = await Database().delete(tableName, key);
    return (exception == null);
  }

  static Future<Stash> get(String key) async
  {
    Map<String, dynamic>? entry = await Database().find(tableName, key);
    return Stash(key, entry ?? Map<String, dynamic>());
  }
}