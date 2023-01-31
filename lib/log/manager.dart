// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'package:fml/data/data.dart';
import 'package:fml/hive/log.dart' as DATABASE;
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/system.dart';

// platform
import 'package:fml/platform/platform.stub.dart'
if (dart.library.io)   'package:fml/platform/platform.vm.dart'
if (dart.library.html) 'package:fml/platform/platform.web.dart';

class Log
{
  List<DATABASE.Log> queue = [];
  List<dynamic>? logs = [];

  int size = 5000;

  static Log _singleton = Log._init();
  factory Log()
  {
    return _singleton;
  }

  Log._init();

  // override
  Data get data => DATABASE.Log.toData(queue);

  void _addEntry(DATABASE.Log e) async
  {
    // add to the queue
    if (queue.length >= size) queue.removeLast();
    queue.insert(0, e);

    // archive the record
    e.insert();
  }

  Future<void> exception(dynamic exception, {String? caller}) async
  {
    try
    {
      // show dialog in debug mode only
      // if (kDebugMode) DialogService().show(type: DialogType.error, title: phrase.error, description: 'Exception: $exception Routine: $caller');

      // print in debug mode only
      if (kDebugMode) print('Exception: $exception' + (caller != null ? ' -> $caller' : ''));

      // add the entry
      DATABASE.Log e = DATABASE.Log(type: "exception", message: '$exception', caller: caller);
      _addEntry(e);
    }
    catch(ex)
    {
      DATABASE.Log e = DATABASE.Log(type: "exception", message: 'Logging Error: $ex', caller:  'Future<void> exception(dynamic exception, {String? callingRoutine}) async');
      _addEntry(e);
    }
  }

  Future<void> error(String message, {String? caller}) async
  {
    try
    {
      // print in debug mode only
      if (kDebugMode) print('Error: $message' + (caller != null ? ' -> $caller' : ''));

      // add the entry
      DATABASE.Log e = DATABASE.Log(type: "error", message: message, caller: caller);
      _addEntry(e);
    }
    catch(ex)
    {
      DATABASE.Log e = DATABASE.Log(type: "exception", message: 'Logging Error: $ex', caller: 'Future<void> error(String message, {String? callingRoutine}) async');
      _addEntry(e);
    }
  }

  Future<void> warning(String message, {String? caller}) async
  {
    try
    {
      // print in debug mode only
      if (kDebugMode) print('Warning: $message' + (caller != null ? ' -> $caller' : ''));

      // add the entry
      DATABASE.Log e = DATABASE.Log(type: "warning", message: message, caller: caller);
      _addEntry(e);
    }
    catch(ex)
    {
      DATABASE.Log e = DATABASE.Log(type: "exception", message: 'Logging Error: $ex', caller: 'Future<void> warning(String message, {String? callingRoutine}) async');
      _addEntry(e);
    }
  }

  Future<void> info(String message, {String? caller}) async
  {
    try
    {
      // print in debug mode only
      if (kDebugMode) print('Info: $message' + (caller != null ? ' -> $caller' : ''));

      // add the entry
      DATABASE.Log e = DATABASE.Log(type: "info", message: message, caller: caller);
      _addEntry(e);
    }
    catch(ex)
    {
      DATABASE.Log e = DATABASE.Log(type: "exception", message: 'Logging Error: $ex', caller: 'Future<void> info(String message, {String? callingRoutine}) async');
      _addEntry(e);
    }
  }

  Future<void> debug(String message, {String? caller}) async
  {
    try
    {
      if (kDebugMode)
      {
        print('Debug: $message' + (caller != null ? ' -> $caller' : ''));
        DATABASE.Log e = DATABASE.Log(type: "debug", message: message, caller: caller);
        _addEntry(e);
      }
    }
    catch(ex)
    {
      DATABASE.Log e = DATABASE.Log(type: "exception", message: 'Logging Error: $ex', caller: 'Future<void> debug(String message, {String? callingRoutine}) async');
      _addEntry(e);
    }
  }

  static const String wildcard = "%";
  bool _filter(String? filter, String? value)
  {
    if (S.isNullOrEmpty(filter)) return true;
    if (S.isNullOrEmpty(value))  return false;

    filter = filter!.toLowerCase();
    value  = value!.toLowerCase();

    if (filter.contains(wildcard))
    {
      String comparator = value.replaceAll(wildcard,'');
      if ((filter.startsWith(wildcard)) && (filter.endsWith(wildcard))) return (value.contains(comparator));
      if (filter.startsWith(wildcard)) return (value.endsWith(comparator));
      if (filter.endsWith(wildcard))   return (value.startsWith(comparator));
      return (value.contains(comparator));
    }
    else return (value == filter);
  }

  Future<List> query(Map<String, String> parameters) async
  {
    String? clear;
    String? where;
    String? order;
    if (parameters.containsKey("clear")) clear = parameters["clear"];
    if (parameters.containsKey("where")) where = parameters["where"];
    if (parameters.containsKey("orderby")) order = parameters["orderby"];

    if (clear == "true") this.clear();
    logs = await DATABASE.Log.query(where: where, orderby: order);

    final List<Map<dynamic,dynamic>> list = [];
    logs!.forEach((entry)
    {
      Map<String,String?> map = Map<String,String?>();
      map['type']      = entry['type'];
      map['time']      = DateTime.fromMillisecondsSinceEpoch(entry['epoch']).toIso8601String().replaceAll("T", " ");
      map['routine']   = entry['routine'];
      map['message']   = entry['message'].replaceAll('\n', ' ');

      bool ok = true;

      if (ok) ok = _filter(parameters['type'],     map['type']);
      if (ok) ok = _filter(parameters['key'],      map['key']);
      if (ok) ok = _filter(parameters['message'],  map['message']);
      if (ok) ok = _filter(parameters['function'], map['function']);

      if (ok) list.add(map);
    });
    list.sort((a, b) => b['time'].compareTo(a['time']));
    return list;
  }

  clear() async
  {
    await DATABASE.Log.deleteAll();
    queue.clear();
    logs!.clear();
    info("Logs cleared");
  }

  export({String format = "html", bool withHistory = false}) async
  {
    var logs = (withHistory) ? await DATABASE.Log.query(orderby: "epoch") : queue;
    var filename = "log-${S.toChar(DateTime.now(),format: 'yyyy-MM-dd HHmmss')}";

    // export to html
    if (format.trim().toLowerCase() != "excel")
    {
      String str = toHtml(logs);
      List<int> bytes = utf8.encode(str);
      Platform.fileSaveAs(bytes, "$filename.html");
    }

    // export to csv
    else
    {
      Data data  = DATABASE.Log.toData(logs);
      String csv = await Data.toCsv(data);
      List<int> bytes = utf8.encode(csv);
      Platform.fileSaveAs(bytes, "$filename.csv");
    }

    return true;
  }

  String toHtml(List<DATABASE.Log> logs)
  {
    final buffer = StringBuffer();
    try
    {

      buffer.write('<html>');
      buffer.write("<head>");
      buffer.write("<style> table, th, td { padding: 15px; border: 1px solid black; border-collapse: collapse;} </style>");
      buffer.write("</head>");
      buffer.write('<table border="1">');

      // Build Header
      buffer.write("<tr>");
      buffer.write("<td>Date</td>");
      buffer.write("<td>Type</td>");
      buffer.write("<td>Message</td>");
      buffer.write("<td>Caller</td>");
      buffer.write("</tr>");

      logs.forEach((log)
      {
        var color = 'black';
        if (log.type == "error" || log.type == "exception") color = '#FF0000';
        if (log.type == "warning") color = '#DAA520';
        if (log.type == "debug") color = '#006400';

        String message = log.message.replaceAll("<", " &lt;").replaceAll(">", " &gt;");
        String caller  = log.caller != null ? log.caller!.replaceAll("<", " &lt;").replaceAll(">", " &gt;") : "";

        buffer.write('<tr style="color:$color">');
        buffer.write('<td>${log.date}</td>');
        buffer.write('<td>${log.type}type</td>');
        buffer.write('<td>$message</td>');
        buffer.write('<td>$caller</td>');
        buffer.write("</tr>");
      });

      buffer.write("<//table>");
      buffer.write("<//html>");
    }
    catch(e)
    {
      Log().exception(e);
    }
    return buffer.toString();
  }
}