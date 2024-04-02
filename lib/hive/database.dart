// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';

import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:hive/hive.dart';
import 'package:fml/eval/eval.dart' as fml_eval;
import 'package:fml/helpers/helpers.dart';

class Database {

  static final _initialized = Completer<bool>();
  static bool get initialized => _initialized.isCompleted;

  static Future<bool> initialize(String? path, {List<int>? encryptionKey}) async {
    try
    {
      Log().info('Initializing Database at Path: $path');
      Hive.init(path);
      _initialized.complete(true);
    }
    catch (e) {
      Log().exception(e, caller: "database -> initialize(String? path) async");
    }
    return _initialized.isCompleted;
  }

  static Future<Exception?> insert(String table, String key, Map<String, dynamic> map,
      {bool logExceptions = true}) async {
    Exception? exception;
    try {
      if (!initialized) return null;
      var box = await Hive.openBox(table);
      await box.put(key, map);
    } on Exception catch (e) {
      // log calling insert causes an infinite loop on error
      // we pass logExceptions=false to prevent this
      if (logExceptions) {
        Log().error('Error Inserting Record Key [$key] into Table [$table]');
        Log().exception(e,
            caller:
                'Future<Exception?> insert(String table, dynamic key, dynamic record) async');
      }
      exception = e;
    }
    return exception;
  }

  static Future<Exception?> update(
      String table,
      String key,
      Map<String, dynamic> map) async {

    if (!initialized) return null;

    Exception? exception;
    try {
      var box = await Hive.openBox(table);
      if (box.containsKey(key)) {
        await box.put(key, map);
      }
    } on Exception catch (e) {
      Log().error('Error Updating Record Key [$key] in Table [$table]');
      Log().exception(e,
          caller: 'Future<Exception?> update($table, $key, $map) async');
      exception = e;
    }
    return exception;
  }

  static Future<Exception?> upsert(
      String table,
      String key,
      Map<String, dynamic> map) async {

    if (!initialized) return null;

    Exception? exception;
    try {
      var box = await Hive.openBox(table);
      await box.put(key, map);
    } on Exception catch (e) {
      Log().error(
          'Error Inserting/Updating Record Key [$key] in Table [$table]');
      Log().exception(e,
          caller: 'Future<Exception?> update($table, $key, $map) async');
      exception = e;
    }
    return exception;
  }

  static Future<Exception?> delete(String table, String key) async {

    if (!initialized) return null;

    Exception? exception;
    try {
      var box = await Hive.openBox(table);
      if (box.containsKey(key)) {
        await box.delete(key);
      }
    } on Exception catch (e) {
      Log().error('Error Deleting Record Key [$key] in Table [$table]');
      Log().exception(e,
          caller: 'Future<Exception?> delete($table, $key) async');
      exception = e;
    }
    return exception;
  }

  static Future<Exception?> deleteAll(String table) async {

    if (!initialized) return null;

    Exception? exception;
    try {
      var box = await Hive.openBox(table);
      await box.clear();
    } on Exception catch (e) {
      Log().error('Error Clearing Table [$table]');
      Log().exception(e,
          caller: 'Future<Exception?> deleteAll(String $table) async');
      exception = e;
    }
    return exception;
  }

  static Future<Map<String, dynamic>?> find(String table, String key) async {

    if (!initialized) return null;

    dynamic value;
    try {
      var box = await Hive.openBox(table);
      if (box.containsKey(key)) {
        value = await box.get(key);
      } else {
        Log().debug('Table [$table] does not contain a Key [$key]');
      }
    } catch (e) {
      Log().error('Error Querying Record Key [$key] in Table [$table]');
      Log().exception(e,
          caller: 'Future<dynamic> find(String $table, dynamic $key) async');
    }

    // convert to Map<String, dynamic>
    if (value is Map) return value.cast<String, dynamic>();

    // legacy value
    if (value != null) await delete(table, key);

    return null;
  }

  static Future<List<Map<String, dynamic>>> query(
      String table,
      {
        String? where,
        String? orderby
      }) async {

    List<Map<String, dynamic>> list = [];
    if (!initialized) return list;

    try {
      // open the table
      var box = await Hive.openBox(table);

      // where clause
      Iterable values = box.values.where((map) {
        bool? ok = true;
        if (!isNullOrEmpty(where)) {
          String? sql = Binding.applyMap(where, map, caseSensitive: false);
          ok = toBool(fml_eval.Eval.evaluate(sql));
        }
        return ok!;
      });

      // add values to list
      for (var value in values) {
        if (value is Map) {
          list.add(value.cast<String, dynamic>());
        }
      }

      // order by clause
      if (!isNullOrEmpty(orderby)) {
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
        list.sort((a, b) {
          if ((a.containsKey(orderby)) && (b.containsKey(orderby))) {
            return Comparable.compare(b[orderby], a[orderby]);
          } else {
            return 0;
          }
        });

        // sort descending?
        if (descending) list = list.reversed.toList();
      }
    } catch (e) {
      Log().error('Error Querying Table [$table]');
      Log().exception(e,
          caller:
              'database.dart => Future<List<dynamic>> query($table, where: $where, orderby: $orderby)');
    }
    return list;
  }

  static Future<List<Map<String, dynamic>>> findAll(String table) async {

    List<Map<String, dynamic>> list = [];

    if (!initialized) return list;

    try {
      var box = await Hive.openBox(table);
      var values = box.toMap();
      values.forEach((key, value) => list.add({key.toString(): value}));
    } catch (e) {
      Log().error('Error Querying All Record Keys in Table [$table]');
      Log().exception(e,
          caller:
              'database.dart => Future<dynamic> findAll(String tableName) async');
    }
    return list;
  }
}
