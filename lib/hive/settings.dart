// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/hive/database.dart';

class Settings {
  static const String tableName = "SETTINGS";

  static final Settings _singleton = Settings._initialize();
  Settings._initialize();

  factory Settings() => _singleton;

  Future<bool> set(String key, dynamic value) async {
    Map<String, dynamic> map = <String, dynamic>{};
    map["value"] = value;
    return (await Database.insert(tableName, key, map) == null);
  }

  Future<dynamic> get(String key, {dynamic defaultValue}) async {
    Map<String, dynamic>? setting = await Database.find(tableName, key);
    if (setting != null && setting.containsKey("value")) {
      return setting["value"];
    } else {
      return defaultValue;
    }
  }

  Future<bool> delete(String key) async =>
      (await Database.delete(tableName, key) == null);
}
