// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'dart:convert';
import 'package:universal_html/html.dart' as universal_html;
import 'package:universal_html/js.dart' as universal_js;
import 'dart:ui' as dart_ui;
import 'package:fml/log/manager.dart';
import 'package:fml/helpers/helpers.dart';

typedef OnMessageCallback = void Function(Map<String, dynamic> data, [String? type]);

class Bridge
{
  final jsonEncoder = const JsonEncoder();
  final String script;

  universal_js.JsObject? _connector;

  final HashMap<String, List<OnMessageCallback>> _listeners = HashMap<String, List<OnMessageCallback>>();
  final id = newId();

  Bridge(this.script)
  {
    /////////////////////////////////////
    /* Contructor Callback from Script */
    /////////////////////////////////////
    universal_js.context["flutter"] = (content)
    {
      _connector = content;

      //////////////////
      /* Add Listener */
      //////////////////
      universal_html.window.removeEventListener('message', _receive);
      universal_html.window.addEventListener('message', _receive);

      return id;
    };

    //////////////////////////
    /* Register HTML iFrame */
    //////////////////////////
    // ignore: undefined_prefixed_name
    dart_ui.platformViewRegistry.registerViewFactory(id, (int viewId)
    {
      final universal_html.IFrameElement frame = universal_html.IFrameElement();
      frame.id     = id;
      frame.width  = '100%';
      frame.height = '100%';
      frame.src    = script;
      return frame;
    });

  }

  factory Bridge.from(String scriptUrl)
  {
    Bridge bridge = Bridge(scriptUrl);
    return bridge;
  }

  //////////////////////////////
  /* Call Javascript Function */
  //////////////////////////////
  void call(String functionName, [dynamic parameters])
  {
    try
    {
      Log().debug('Calling JS function ->($functionName)()');

      /////////////////////////////////////////////////
      /* Only Supports String and Numeric Parameters */
      /////////////////////////////////////////////////
      List<dynamic> parameters0 = [];
      if (parameters is String) parameters0.add(parameters);
      if (parameters is int)    parameters0.add(int);
      if (parameters is double) parameters0.add(double);
      if (parameters is num)    parameters0.add(num);
      if (parameters is List)   parameters0.addAll(parameters);

      if (_connector != null) _connector!.callMethod(functionName, parameters0);
    }
    catch(e)
    {
      Log().error('Error calling $functionName()');
      Log().exception(e);
    }
  }

  ////////////////////////////////
  /* Post Message to Javascript */
  ////////////////////////////////
  void message(String type, [Map<String, dynamic>? parameters])
  {
    try
    {
      ////////////////////////////
      /* Add Sender / Recipient */
      ////////////////////////////
      parameters ??= <String, dynamic>{};

      String from = 'DART-$id';
      String to   = 'JS-$id';

      parameters['message:id']   = DateTime.now().millisecondsSinceEpoch;
      parameters['message:type'] = type;
      parameters['message:from'] = from;
      parameters['message:to']   = to;

      ////////////////////
      /* Encode Message */
      ////////////////////
      final json = jsonEncoder.convert(parameters);

      Log().debug('Message Sent From: $from To: $to -> $json');

      //////////////////
      /* Send Message */
      //////////////////
      universal_html.window.postMessage(json, "*");
    }
    catch(e)
    {
      Log().exception(e);
    }
  }

  /////////////////////////////////////
  /* Receive Message from Javascript */
  /////////////////////////////////////
  Map? _receive(dynamic event)
  {
    try
    {
      // decode message
      var json = event.data;
      var data = Json.decode(json);

      Map<String, dynamic> map = <String, dynamic>{};
      if (data is Map) map.addAll(data as Map<String, dynamic>);

      String me        = 'DART-$id';
      // String id        =  ((map.containsKey('message:id'))   && (map['message:id']   is String)) ? (map['message:id']   as String) : null;
      String? type      =  ((map.containsKey('message:type')) && (map['message:type'] is String)) ? (map['message:type'] as String?) : null;
      String? from      =  ((map.containsKey('message:from')) && (map['message:from'] is String)) ? (map['message:from'] as String?) : null;
      String? to        =  ((map.containsKey('message:to'))   && (map['message:to']   is String)) ? (map['message:to']   as String?) : null;

      // message is for me?
      if ((to == me) && (!isNullOrEmpty(from)))
      {
        Log().debug('Message Received From: $from To: $to -> $json');
        map.remove('from');
        map.remove('to');
        notifyListeners(type, map);
      }
      else {
        Log().debug('Message Received From: $from To: $to -> Wrong Address');
      }

      // return map
      return Json.decode(json);
    }
    catch(e)
    {
      Log().exception(e);
    }
    return null;
  }

  void dispose()
  {
  }

  void registerListener(String type, OnMessageCallback callback)
  {
    if (!_listeners.containsKey(type)) _listeners[type] = [];
    if (!_listeners[type]!.contains(callback)) _listeners[type]!.add(callback);
  }

  void removeListener(String type, OnMessageCallback callback)
  {
    if ((!_listeners.containsKey(type)) || (!_listeners[type]!.contains(callback)) ) return;
    _listeners[type]!.remove(callback);
  }
  
  void notifyListeners(String? type, Map<String, dynamic> parameters)
  {
    //////////////////////
    /* Notify Listeners */
    //////////////////////
    List<OnMessageCallback>? callbacks;
    if (_listeners.containsKey(type)) callbacks = _listeners[type!];
    if (_listeners.containsKey('*'))
    {
      if (callbacks == null) {
        callbacks = _listeners['*'];
      } else {
        callbacks.addAll(_listeners['*']!);
      }
    }
    if (callbacks != null) {
      for (var callback in callbacks) {
        callback(parameters);
      }
    }
  }
}