// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/hive/database.dart';
import 'package:fml/helpers/helpers.dart';

enum Fields { key, username, password, rights, language }

class User {
  static String tableName = "USER";

  final Map<String, dynamic> _map = <String, dynamic>{};

  String get key => _map["key"];
  String? get username => _map["username"];
  String? get password => _map["password"];
  String? get language => _map["language"];
  int? get rights => _map["rights"];

  User(
      {String? key,
      String? username,
      String? password,
      int? rights,
      String? language,
      Map<String, dynamic>? map}) {
    _map["key"] = key ?? newId();
    _map["username"] = username;
    _map["password"] = password;
    _map["language"] = language;
    _map["rights"] = rights;

    // user defined values
    map?.forEach((key, value) {
      if (key != "key" &&
          key != "username" &&
          key != "password" &&
          key != "langauge" &&
          key != "rights") _map[key] = value;
    });
  }

  Future<bool> insert() async =>
      (await Database().insert(tableName, key, _map) == null);
  Future<bool> update() async =>
      (await Database().update(tableName, key, _map) == null);
  Future<bool> delete() async =>
      (await Database().delete(tableName, key) == null);

  static Future<bool> deleteAll() async =>
      (await Database().deleteAll(tableName) == null);

  static User? _fromMap(dynamic map) {
    User? user;
    if (map is Map<String, dynamic>) {
      user = User(
          key: fromMap(map, "key"),
          username: fromMap(map, "username"),
          password: fromMap(map, "password"),
          language: fromMap(map, "language"),
          rights: fromMapAsInt(map, "rights"),
          map: map);
    }
    return user;
  }

  static Future<User?> find(String key) async {
    Map<String, dynamic>? entry = await Database().find(tableName, key);
    User? user = _fromMap(entry);
    return user;
  }

  static Future<List<User>> query({String? where, String? orderby}) async {
    List<User> users = [];
    List<Map<String, dynamic>> entries =
        await Database().query(tableName, where: where, orderby: orderby);
    for (var entry in entries) {
      User? user = _fromMap(entry);
      if (user != null) users.add(user);
    }
    return users;
  }
}
