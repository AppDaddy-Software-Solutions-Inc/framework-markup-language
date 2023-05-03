// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'dart:convert';
import 'package:universal_html/html.dart' as HTML;
import 'package:universal_html/js.dart' as JAVASCRIPT;
import 'dart:ui' as UI;
import 'package:fml/log/manager.dart';
import 'package:fml/helper/common_helpers.dart';

typedef OnMessageCallback = void Function(Map<String, dynamic> data, [String? type]);

class Bridge
{
  final jsonEncoder = JsonEncoder();
  final String script;

  JAVASCRIPT.JsObject? _connector;

  final HashMap<String, List<OnMessageCallback>> _listeners = HashMap<String, List<OnMessageCallback>>();
  final id = S.newId();

  Bridge(this.script)
  {
    /////////////////////////////////////
    /* Contructor Callback from Script */
    /////////////////////////////////////
    JAVASCRIPT.context["flutter"] = (content)
    {
      _connector = content;

      //////////////////
      /* Add Listener */
      //////////////////
      HTML.window.removeEventListener('message', _receive);
      HTML.window.addEventListener('message', _receive);

      return id;
    };

    //////////////////////////
    /* Register HTML iFrame */
    //////////////////////////
    // ignore: undefined_prefixed_name
    UI.platformViewRegistry.registerViewFactory(id, (int viewId)
    {
      final HTML.IFrameElement _frame = HTML.IFrameElement();
      _frame.id     = id;
      _frame.width  = '100%';
      _frame.height = '100%';
      _frame.src    = script;
      return _frame;
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
      List<dynamic> _parameters = [];
      if (parameters is String) _parameters.add(parameters);
      if (parameters is int)    _parameters.add(int);
      if (parameters is double) _parameters.add(double);
      if (parameters is num)    _parameters.add(num);
      if (parameters is List)   _parameters.addAll(parameters);

      if (_connector != null) _connector!.callMethod(functionName, _parameters);
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
      HTML.window.postMessage(json, "*");
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
      ////////////////////
      /* Decode Message */
      ////////////////////
      var json = event.data;
      var data = jsonDecode(json);

      Map<String, dynamic> map = <String, dynamic>{};
      if (data is Map) map.addAll(data as Map<String, dynamic>);

      String me        = 'DART-${this.id}';
      // String id        =  ((map.containsKey('message:id'))   && (map['message:id']   is String)) ? (map['message:id']   as String) : null;
      String? type      =  ((map.containsKey('message:type')) && (map['message:type'] is String)) ? (map['message:type'] as String?) : null;
      String? from      =  ((map.containsKey('message:from')) && (map['message:from'] is String)) ? (map['message:from'] as String?) : null;
      String? to        =  ((map.containsKey('message:to'))   && (map['message:to']   is String)) ? (map['message:to']   as String?) : null;

      /////////////////////
      /* Message for Me? */
      /////////////////////
      if ((to == me) && (!S.isNullOrEmpty(from)))
      {
        Log().debug('Message Received From: $from To: $to -> $json');
        map.remove('from');
        map.remove('to');
        notifyListeners(type, map);
      }
      else Log().debug('Message Received From: $from To: $to -> Wrong Address');

      ////////////////
      /* Return Map */
      ////////////////
      return jsonDecode(json);
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
      if (callbacks == null)
           callbacks = _listeners['*'];
      else callbacks.addAll(_listeners['*']!);
    }
    if (callbacks != null)
    callbacks.forEach((callback) => callback(parameters));
  }
}