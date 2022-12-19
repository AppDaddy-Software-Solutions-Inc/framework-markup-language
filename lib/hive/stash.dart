// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/hive/database.dart';

class StashEntry
{
    final String  key;
    final dynamic value;
    StashEntry(this.key, this.value);
}

class Stash
{
  static final Stash _singleton = Stash._initialize();
  Stash._initialize();

  factory Stash() => _singleton;

  static String tableName(String? domain) => "STASH.$domain".toLowerCase();

  static StashEntry? _fromMap(dynamic map)
  {
    StashEntry? entry;
    if (map is Map<String, dynamic>)
    {
      String  k = map.keys.first;
      dynamic v = map[k];
      if (v is Map && v.containsKey("value")) entry = StashEntry(k,v["value"]);
    }
    return entry;
  }

  Future<dynamic> get(String? domain, String key, {dynamic defaultValue}) async
  {
    if (domain == null) return null;

    Map<String, dynamic>? entry = await Database().find(tableName(domain), key);
    if (entry != null && entry.containsKey("value"))
         return entry["value"];
    else return defaultValue;
  }

  Future<bool> set(String? domain, String key, dynamic value) async
  {
    if (domain == null) return false;

    Map<String, dynamic> map = Map<String, dynamic>();
    map["value"] = value;
    return (await Database().insert(tableName(domain), key, map) == null);
  }

  Future<bool> delete(String? domain, String key) async
  {
    if (domain == null) return false;

    return (await Database().delete(tableName(domain), key) == null);
  }

  static Future<List<StashEntry>> findAll(String? domain) async
  {
    List<StashEntry> list = [];
    if (domain == null) return list;

    List<Map<String, dynamic>> entries = await Database().findAll(tableName(domain));
    entries.forEach((entry)
    {
      StashEntry? stash = _fromMap(entry);
      if (stash != null) list.add(stash);
    });
    return list;
  }
}