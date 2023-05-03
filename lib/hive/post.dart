// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/hive/database.dart';
import 'package:fml/helper/common_helpers.dart';

enum Fields {key, form_key, status, title, format, method, headers, url, body, date, attempts, info}

class Post
{
  static String tableName = "POST";

  Map<String, dynamic> _map = <String, dynamic>{};
  
  static int statusINCOMPLETE = 1;
  static int statusCOMPLETE   = 2;
  static int statusERROR      = 3;

  String  get key      => _map["key"];
  String? get formKey  => _map["formKey"];

  int? get status => _map["status"];
  set status(int? value) => _map["status"] = value;

  String? get title    => _map["title"];
  String? get format   => _map["format"];
  String? get method   => _map["method"];
  String? get url      => _map["url"];
  String? get body     => _map["body"];
  int?    get date     => _map["date"];

  int? get attempts => _map["attempts"];
  set attempts (int? value) => _map["attempts"] = value;

  String? get info => _map["info"];
  set info (String? value) => _map["info"] = value;

  Map<String, String>? get headers  => _map["headers"];

  Post({
    String? key,
    String? formKey,
    int?    status,
    String? title,
    int?    date,
    int?    attempts,
    String? method,
    Map<String, String>? headers,
    String? format,
    String? url,
    String? body,
    String? info})
  {
    _map["key"]      = key ?? S.newId();
    _map["formKey"]  = formKey;
    _map["status"]   = status;
    _map["title"]    = title;
    _map["date"]     = date;
    _map["attempts"] = attempts;
    _map["method"]   = method;
    _map["format"]   = format;
    _map["url"]      = url;
    _map["body"]     = body;
    _map["info"]     = info;
    _map["headers"]  = headers;
  }

  Future<bool> insert() async => (await Database().insert(tableName, key, _map) == null);
  Future<bool> update() async => (await Database().update(tableName, key, _map) == null);
  Future<bool> delete() async => (await Database().delete(tableName, key) == null);
  static Future<bool> deleteAll() async => (await Database().deleteAll(tableName) == null);

  static Post? _fromMap(dynamic map)
  {
    Post? post;
    if (map is Map<String, dynamic>) {
      post = Post(
          key:      S.mapVal(map, S.fromEnum(Fields.key)),
          formKey:  S.mapVal(map, S.fromEnum(Fields.form_key)),
          status:   S.mapInt(map, S.fromEnum(Fields.status)),
          title:    S.mapVal(map, S.fromEnum(Fields.title)),
          date:     S.mapInt(map, S.fromEnum(Fields.date)),
          attempts: S.mapInt(map, S.fromEnum(Fields.attempts)),
          format:   S.mapVal(map, S.fromEnum(Fields.format)),
          method:   S.mapVal(map, S.fromEnum(Fields.method)),
          headers:  S.mapVal(map, S.fromEnum(Fields.headers)),
          url:      S.mapVal(map, S.fromEnum(Fields.url)),
          body:     S.mapVal(map, S.fromEnum(Fields.body)),
          info:     S.mapVal(map, S.fromEnum(Fields.info))
      );
    }
    return post;
  }

  Map<String?, dynamic> toMap()
  {
    var map = <String?, dynamic>{};
    map[S.fromEnum(Fields.key)]       = key;
    map[S.fromEnum(Fields.form_key)]  = formKey;
    map[S.fromEnum(Fields.status)]    = status;
    map[S.fromEnum(Fields.title)]     = title;
    map[S.fromEnum(Fields.date)]      = date;
    map[S.fromEnum(Fields.attempts)]  = attempts;
    map[S.fromEnum(Fields.format)]    = format;
    map[S.fromEnum(Fields.method)]    = method;
    map[S.fromEnum(Fields.headers)]   = headers;
    map[S.fromEnum(Fields.url)]       = url;
    map[S.fromEnum(Fields.body)]      = body;
    map[S.fromEnum(Fields.info)]      = info;
    return map;
  }

  static Future<Post?> find(String key) async
  {
    Map<String, dynamic>? entry = await Database().find(tableName, key);
    Post? post = _fromMap(entry);
    return post;
  }

  static Future<List<Post>> query({String? where, String? orderby}) async
  {
    List<Post> posts = [];
    List<Map<String, dynamic>> entries = await Database().query(tableName, where: where, orderby: orderby);
    entries.forEach((entry)
    {
      Post? post = _fromMap(entry);
      if (post != null) posts.add(post);
    });
    return posts;
  }
}