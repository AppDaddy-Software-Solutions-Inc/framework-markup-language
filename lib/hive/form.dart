// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/hive/post.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/hive/database.dart';
import 'package:fml/helper/common_helpers.dart';

class Form implements Comparable
{
  static String tableName = "FORM";

  final Map<String, dynamic> _map = <String, dynamic>{};

  String  get key      => _map["key"];
  String? get parent   => _map["parent"];

  bool get complete => _map["complete"];
  set complete (bool? value) => _map["complete"] = value;

  int get created  => _map["created"];
  int get updated  => _map["updated"];
  set updated (int? value) => _map["updated"] = value;

  String? get template => _map["template"];
  set template(String? value) => _map["template"] = value;

  set data(Map<String,dynamic>? value) => _map["data"] = value;

  Form({String? key, String? parent, bool? complete, int? created, int? updated, String? template, Map<String,dynamic>? data})
  {
    _map["key"]      = key ?? S.newId();
    _map["parent"]   = parent;
    _map["complete"] = complete ?? false;
    _map["created"]  = created ?? DateTime.now().millisecondsSinceEpoch;
    _map["updated"]  = updated ?? DateTime.now().millisecondsSinceEpoch;
    _map["template"] = template;
    _map["data"]     = data;
  }

  Future<bool> insert() async => (await Database().insert(tableName, key, _map) == null);
  Future<bool> update() async => (await Database().update(tableName, key, _map) == null);
  static Future<bool> deleteAll() async => (await Database().deleteAll(tableName) == null);

  static Form? _fromMap(dynamic map)
  {
    Form? form;
    if (map is Map<String, dynamic>) {
      form = Form(
          key:      S.mapVal(map, "key"),
          parent:   S.mapVal(map, "parent"),
          complete: S.mapBoo(map, "complete"),
          created:  S.mapInt(map, "created"),
          updated:  S.mapInt(map, "updated"),
          template: S.mapVal(map, "template"),
          data:     map.containsKey("data") && map["data"] is Map<String,dynamic> ? map["data"] : null);
    }
    return form;
  }

  Future<Exception?> delete() async
  {
    Exception? exception;
    try
    {
      // delete posting documents
      List<Post> posts = await Post.query(where: "'{form_key}' == '$key'");
      for (var post in posts) {
        await post.delete();
      }

      // delete Sub-Forms 
      List<Form> forms = await query(where: "'{parent}' == '$key'");
      for (var form in forms) {
        await form.delete();
      }

      // delete form
      exception = await Database().delete(tableName, key);
    }
    on Exception catch(e)
    {
      Log().debug('Error deleting from table $tableName');
      Log().debug(e.toString());
      exception = e;
    }
    return exception;
  }

  static Future<Form?> find(dynamic key) async
  {
    Map<String, dynamic>? entry = await Database().find(tableName, key);
    Form? form = _fromMap(entry);
    return form;
  }

  static Future<List<Form>> query({String? where, String? orderby}) async
  {
    List<Form> forms = [];
    List<Map<String, dynamic>> entries = await Database().query(tableName, where: where, orderby: orderby);
    for (var entry in entries) {
      Form? form = _fromMap(entry);
      if (form != null) forms.add(form);
    }
    return forms;
  }

  ///**
   ///* Compares this object to another [Comparable]
   ///*
   ///* Returns a value like a [Comparator] when comparing `this` to [other].
   ///* That is, it returns a negative integer if `this` is ordered before [other],
   ///* a positive integer if `this` is ordered after [other],
   ///* and zero if `this` and [other] are ordered together.
  /// *
   ///* The [other] argument must be a value that is comparable to this object.

  @override
  int compareTo(other)
  {
    if (other == null) return -1;

    if (parent == null && other.parent != null) return 1;
    if (parent != null && other.parent == null) return -1;
    return (updated > other.updated) ? 1 : -1;
  }
}