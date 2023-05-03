// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/hive/database.dart';
import 'package:fml/crypto/crypto.dart';
import 'package:fml/helper/common_helpers.dart';
String _cacheHashKey = 'FUQK70bxp6e3dUeyXqqNjPbDLhDfYTA1';

class Data
{
  static String tableName = "DATA";

  Map<String, dynamic> _map = <String, dynamic>{};

  String  get key     => _map["key"];
  String? get value   => _map["value"];
  int?    get expires => _map["expires"];

  Data({String? key, String? value, int? expires})
  {
    key ??= S.newId();
    if (key.length > 256) key = Cryptography.hash(key: _cacheHashKey, text: key);
    _map["key"]     = key;
    _map["value"]   = value ?? "";
    _map["expires"] = expires ?? 0;
  }

  Future<bool> insert() async => (await Database().insert(tableName, key, _map) == null);
  Future<bool> update() async => (await Database().update(tableName, key, _map) == null);
  Future<bool> delete() async => (await Database().delete(tableName, key) == null);

  static Future<bool> deleteAll() async => (await Database().deleteAll(tableName) == null);

  static Data? _fromMap(dynamic map)
  {
    Data? data;
    if (map is Map<String, dynamic>) data = Data(key: S.mapVal(map, "key"), value: S.mapVal(map, "value"), expires: S.mapInt(map, "expires"));
    return data;
  }

  static Future<Data?> find(String key) async
  {
    Map<String, dynamic>? entry = await Database().find(tableName, key);
    Data? data = _fromMap(entry);
    return data;
  }
}