// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/data/data.dart';
import 'package:fml/hive/database.dart';
import 'package:fml/observable/scope.dart';

class Stash {
  static String tableName = "STASH";

  final String key;
  final Map<String, dynamic> map;
  final Scope? scope;

  Stash(this.key, this.map, {this.scope});

  // inserts a new stash entry
  Future<bool> insert() async {
    var exception = await Database.insert(tableName, key, map);
    return (exception == null);
  }

  // updates the stash entry
  Future<bool> upsert() async {
    var exception = await Database.upsert(tableName, key, map);
    return (exception == null);
  }

  // deletes a stash entry
  Future<bool> delete() async {
    var exception = await Database.delete(tableName, key);
    return (exception == null);
  }

  // get all stash entries
  static Future<Stash> get(String key, {Scope? scope}) async {
    Map<String, dynamic>? entry = await Database.find(tableName, key);
    return Stash(key, entry ?? <String, dynamic>{}, scope: scope);
  }

  // get specific stash
  static Future<Stash> getStash(String domain) async {
    Map<String, dynamic> entries = await Database.find(tableName, domain) ?? {};
    return Stash(domain, entries);
  }

  static Future<Data> getStashData(String domain) async {
    Stash stash = await getStash(domain);
    Data data = Data();
    stash.map.forEach((k, v) {
      data.add({'key': k, 'value': v});
    });
    return data;
  }
}
