// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:hive/hive.dart';
import 'package:fml/eval/eval.dart' as EVALUATE;
import 'package:fml/helper/common_helpers.dart';

class Database
{
  static final Database _singleton = Database._initialize();
  Database._initialize();

  String? path;
  List<int>? encryptionKey;

  bool _initialized = false;
  bool get initialized => _initialized;

  factory Database() => _singleton;

  initialize(String? path) async
  {
    bool ok = false;
    try
    {
      Log().info('Initializing Database at Path: $path');
      this.path = path;
      this.encryptionKey = encryptionKey;
      if (path != null) Hive.init(path);
      ok = true;
    }
    catch(e)
    {
      ok = false;
      Log().exception(e, caller: "database -> initialize(String? path) async");
    }

    _initialized = true;

    return ok;
  }

  Future<Exception?> insert(String table, String key, Map<String, dynamic> map, {bool logExceptions = true}) async
  {
    Exception? exception;
    try
    {
      if (!_initialized) return null;
      var box = await Hive.openBox(table);
      await box.put(key, map);
    }
    on Exception catch(e)
    {
      // log calling insert causes an infinite loop on error
      // we pass logExceptions=false to prevent this
      if (logExceptions)
      {
        Log().error('Error Inserting Record Key [$key] into Table [$table]');
        Log().exception(e, caller: 'Future<Exception?> insert(String table, dynamic key, dynamic record) async');
      }
      exception = e;
    }
    return exception;
  }

  Future<Exception?> update(String table, String key, Map<String, dynamic> map) async
  {
    Exception? exception;
    try
    {
      if (!_initialized) return null;
      var box = await Hive.openBox(table);
      if (box.containsKey(key))
      {
        await box.put(key, map);
      }
    }
    on Exception catch(e)
    {
      Log().error('Error Updating Record Key [$key] in Table [$table]');
      Log().exception(e, caller: 'Future<Exception?> update($table, $key, $map) async');
      exception = e;
    }
    return exception;
  }

  Future<Exception?> upsert(String table, String key, Map<String, dynamic> map) async
  {
    Exception? exception;
    try
    {
      if (!_initialized) return null;
      var box = await Hive.openBox(table);
      await box.put(key, map);
    }
    on Exception catch(e)
    {
      Log().error('Error Inserting/Updating Record Key [$key] in Table [$table]');
      Log().exception(e, caller: 'Future<Exception?> update($table, $key, $map) async');
      exception = e;
    }
    return exception;
  }

  Future<Exception?> delete(String table, String key) async
  {
    Exception? exception;
    try
    {
      if (!_initialized) return null;
      var box = await Hive.openBox(table);
      if (box.containsKey(key))
      {
        await box.delete(key);
      }
    }
    on Exception catch(e)
    {
      Log().error('Error Deleting Record Key [$key] in Table [$table]');
      Log().exception(e, caller: 'Future<Exception?> delete($table, $key) async');
      exception = e;
    }
    return exception;
  }

  Future<Exception?> deleteAll(String table) async
  {
    Exception? exception;
    try
    {
      if (!_initialized) return null;
      var box = await Hive.openBox(table);
      await box.clear();
    }
    on Exception catch(e)
    {
      Log().error('Error Clearing Table [$table]');
      Log().exception(e, caller: 'Future<Exception?> deleteAll(String $table) async');
      exception = e;
    }
    return exception;
  }

  Future<Map<String, dynamic>?> find(String table, String key) async
  {
    dynamic value;
    try
    {
      var box = await Hive.openBox(table);
      if (box.containsKey(key)) {
        value = await box.get(key);
      } else {
        Log().debug('Table [$table] does not contain a Key [$key]');
      }
    }
    catch(e)
    {
      Log().error('Error Querying Record Key [$key] in Table [$table]');
      Log().exception(e, caller: 'Future<dynamic> find(String $table, dynamic $key) async');
    }

    // convert to Map<String, dynamic>
    if (value is Map) return value.cast<String, dynamic>();

    // legacy value
    if (value != null) await delete(table, key);

    return null;
  }

  Future<List<Map<String, dynamic>>> query(String table, {String? where, String? orderby}) async
  {
    List<Map<String, dynamic>> list = [];
    try
    {
      // open the table
      var box = await Hive.openBox(table);

      // where clause
      Iterable values = box.values.where((map)
      {
        bool? ok = true;
        if (!S.isNullOrEmpty(where))
        {
          String? sql = Binding.applyMap(where, map, caseSensitive: false);
          ok = S.toBool(EVALUATE.Eval.evaluate(sql));
        }
        return ok!;
      });

      // add values to list
      values.forEach((value) => value is Map ? list.add(value.cast<String, dynamic>()) : null);

      // order by clause
      if (!S.isNullOrEmpty(orderby))
      {
        // get ordre by field and descending clause
        orderby = orderby!.trim();
        while (orderby!.contains("  ")) {
          orderby = orderby.replaceAll("  ", " ").trim();
        }
        var s = orderby.trim().split(" ");
        orderby = s.first;
        bool descending = false;
        if ((s.isNotEmpty) && (s[1].toLowerCase() == "desc")) descending = true;

        // sort values
        list.sort((a, b)
        {
          if ((a.containsKey(orderby)) && (b.containsKey(orderby))) {
            return Comparable.compare(b[orderby], a[orderby]);
          } else {
            return 0;
          }
        });

        // sort descending?
        if (descending) list = list.reversed.toList();
      }
    }
    catch(e)
    {
      Log().error('Error Querying Table [$table]');
      Log().exception(e, caller: 'database.dart => Future<List<dynamic>> query($table, where: $where, orderby: $orderby)');
    }
    return list;
  }

  Future<List<Map<String, dynamic>>> findAll(String table) async
  {
    List<Map<String, dynamic>> list = [];
    try
    {
      var box = await Hive.openBox(table);
      var values = box.toMap();
      values.forEach((key, value) => list.add({key.toString() : value}));
    }
    catch(e)
    {
      Log().error('Error Querying All Record Keys in Table [$table]');
      Log().exception(e, caller: 'database.dart => Future<dynamic> findAll(String tableName) async');
    }
    return list;
  }
}