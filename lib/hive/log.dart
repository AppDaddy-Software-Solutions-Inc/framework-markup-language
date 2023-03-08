// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/data/data.dart';
import 'package:intl/intl.dart';
import 'package:fml/hive/database.dart';
import 'package:fml/helper/common_helpers.dart';

class Log
{
  static String tableName = "LOG";

  static final int daysToSave = 1;

  Map<String, dynamic> _map = Map<String, dynamic>();

  String  get key     => _map["key"];
  String  get type    => _map["type"];
  int     get epoch   => _map["epoch"];
  String  get date    => _map["date"];
  String  get message => _map["message"];
  String? get caller  => _map["caller"];

  bool get initialized => Database().initialized;

  Log({String? key, String? type, int? epoch, String? message, String? caller})
  {
    _map["key"]     = key ?? S.newId();
    _map["type"]    = type    ?? "error";
    _map["epoch"]   = epoch   ?? DateTime.now().millisecondsSinceEpoch;
    _map["date"]    = DateFormat("yyyy-MM-dd hh:mm:ss.sss").format(DateTime.fromMillisecondsSinceEpoch(this.epoch));
    _map["message"] = message ?? "";
    _map["caller"]  = caller;
  }

  Future<bool> insert() async => (await Database().insert(tableName, key, _map) == null);
  Future<bool> update() async => (await Database().update(tableName, key, _map) == null);
  Future<bool> delete() async => (await Database().delete(tableName, key) == null);

  static Future<bool> deleteAll() async => (await Database().deleteAll(tableName) == null);

  static Log? _fromMap(dynamic map)
  {
    Log? log;
    if (map is Map) log = Log(key: S.mapVal(map, "key"), type: S.mapVal(map, "type"), epoch: S.mapInt(map, "epoch"), message: S.mapVal(map, "message"), caller: S.mapVal(map, "caller"));
    return log;
  }

  static Data toData(Iterable<Log> logs)
  {
    Data data = new Data();
    logs.forEach((log) => data.add(log._map));
    return data;
  }

  static Future<Log?> find(String key) async
  {
    Map<String, dynamic>? entry = await Database().find(tableName, key);
    Log? log = _fromMap(entry);
    return log;
  }

  static Future<List<Log>> findAll() async
  {
    List<Log> list = [];
    List<Map<String, dynamic>> entries = await Database().findAll(tableName);
    entries.forEach((entry)
    {
      Log? log = _fromMap(entry);
      if (log != null) list.add(log);
    });
    return list;
  }

  static Future<List<Log>> query({String? where, String? orderby}) async
  {
    List<Log> list = [];
    List<Map<String, dynamic>> entries = await Database().query(tableName, where: where, orderby: orderby);
    entries.forEach((entry)
    {
      Log? log = _fromMap(entry);
      if (log != null) list.add(log);
    });
    return list;
  }
}