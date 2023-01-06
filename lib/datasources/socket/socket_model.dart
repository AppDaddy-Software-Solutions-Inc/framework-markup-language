// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/datasources/base/model.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/datasources/socket/socket.dart';
import 'package:fml/datasources/file/file.dart' as FILE;
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';
import 'iSocketListener.dart';

class SocketModel extends DataSourceModel implements IDataSource, ISocketListener
{
  Socket? socket;

  // message count
  late IntegerObservable _received;
  int get received => _received.get() ?? 0;

  // message
  late StringObservable _message;
  String? get message => _message.get();

  // connected
  BooleanObservable? _connected;
  set connected (dynamic v)
  {
    if (_connected != null)
    {
      _connected!.set(v);
    }
    else if (v != null)
    {
      _connected = BooleanObservable(Binding.toKey(id, 'connected'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get connected => _connected?.get() ?? false;

  // url
  StringObservable? _url;
  set url(dynamic v)
  {
    if (_url != null)
    {
      _url!.set(v);
    }
    else if (v != null)
    {
      _url = StringObservable(Binding.toKey(id, 'url'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get url => _url?.get();

  // on connected event
  StringObservable? _onconnected;
  set onconnected(dynamic v)
  {
    if (_onconnected != null)
    {
      _onconnected!.set(v);
    }
    else if (v != null)
    {
      _onconnected = StringObservable(Binding.toKey(id, 'onconnected'), v, scope: scope, lazyEval: true);
    }
  }
  String? get onconnected => _onconnected?.get();

  // on disconnected event
  StringObservable? _ondisconnected;
  set ondisconnected(dynamic v)
  {
    if (_ondisconnected != null)
    {
      _ondisconnected!.set(v);
    }
    else if (v != null)
    {
      _ondisconnected = StringObservable(Binding.toKey(id, 'ondisconnected'), v, scope: scope, lazyEval: true);
    }
  }
  String? get ondisconnected => _ondisconnected?.get();

  // on onerror event
  StringObservable? _onerror;
  set onerror(dynamic v)
  {
    if (_onerror != null)
    {
      _onerror!.set(v);
    }
    else if (v != null)
    {
      _onerror = StringObservable(Binding.toKey(id, 'onerror'), v, scope: scope, lazyEval: true);
    }
  }
  String? get onerror => _onerror?.get();
  
  SocketModel(WidgetModel parent, String? id) : super(parent, id)
  {
    _received = IntegerObservable(Binding.toKey(id, 'received'), 0, scope: scope);
    _message  = StringObservable(Binding.toKey(id, 'message'), null, scope: scope);
  }

  static SocketModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    SocketModel? model;
    try
    {
      model = SocketModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'iframe.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    // properties
    url = Xml.get(node: xml, tag: 'url');
    onconnected = Xml.get(node: xml, tag: 'onconnected');
    ondisconnected = Xml.get(node: xml, tag: 'ondisconnected');
    onerror = Xml.get(node: xml, tag: 'onerror');
  }

  @override
  void dispose()
  {
    socket?.dispose();
    socket = null;
    super.dispose();
  }

  @override
  Future<bool> start({bool refresh: false, String? key}) async
  {
    bool ok = true;
    if (socket == null && url != null) socket = Socket(url!, this);
    if (socket != null)
    {
      ok = await socket!.connect();
      connected = ok;
    }
    else
    {
      connected = false;
      ok = false;
    }
    return ok;
  }


  @override
  Future<bool> stop() async
  {
    try
    {
      if (socket != null)
      {
        socket!.dispose();
        socket = null;
      }
      connected = false;
    }
    catch(e)
    {
      return false;
    }
    super.stop();
    return true;
  }

  Future<bool> stream(String message, {int? chunksize = 30000}) async
  {
    bool ok = true;
    busy = true;
    if ((chunksize ?? 0) <= 0) chunksize = 30000;

    // mark start of transfer
    await start();

    // Message is a file?
    FILE.File? file = scope!.files.containsKey(message) ? scope!.files[message] : null;
    if (file != null)
         ok = await _streamFile(file, chunksize!);
    else ok = await _streamMessage(message, chunksize!);

    // mark end of transfer
    //await stop();

    // reconnect
    //if (autoexecute == true) start();

    return ok;
  }

  Future<bool> _streamFile(FILE.File file, int chunksize) async
  {
    bool ok = true;

    try
    {
      int size = file.size ?? 0;
      int parts = (size/chunksize).ceil();

      // start of message
      // await socket?.send("SOM;$size;$parts;");

      // message body
      for (int i = 0; i < parts; i++)
      {
        int start = i * chunksize;
        int end   = start + chunksize;

        Uint8List? bytes = await file.read(start: start, end: end);
        socket!.send(bytes);
      }

      // end of message stream
      // await send("EOM");

      ok = true;
    }
    catch(e)
    {
      Log().error("Error streaming file. Error is $e");
      ok = false;
    }
    return ok;
  }

  Future<bool> _streamMessage(String message, int chunksize) async
  {
    bool ok = true;

    try
    {
      int size = message.length;
      int parts = (size/chunksize).ceil();

      // start of message
      // await socket?.send("SOM;$size;$parts;");

      // message body
      for (int i = 0; i < parts; i++)
      {
        int start = i * chunksize;
        int end   = start + chunksize;
        if (end >= message.length) end = message.length - 1;
        if (start > end) start = end;
        String bytes = message.substring(start, end);
        socket!.send(bytes);
      }

      // end of message stream
      // await send("EOM");
      ok = true;
    }
    catch(e)
    {
      Log().error("Error streaming file. Error is $e");
      ok = false;
    }
    return ok;
  }

  Future<bool> send(String message) async
  {
    busy = true;

    // ensure socket is connected
    await start();

    // send the message
    await socket?.send(message);

    busy = false;
    return true;
  }

  @override
  onMessage(String message)
  {
    // enabled?
    if (enabled == false) return;

    // increment the number of messages received
    _received.set(received + 1);

    // set last message bindable
    _message.set(message);

    // deserialize the data
    Data data = Data.from(message, root: root);

    // if the message didn't deserialize (length 0)
    // so create a simple map with message bindable <id>.data.message
    // otherwise the data is the deserialized message payload
    if (data.length == 0) data.insert(0, {'message' : message});

    // fire the onresponse
    onResponse(data, code: HttpStatus.ok);
  }

  @override
  onConnected() async
  {
    if (!S.isNullOrEmpty(onconnected))
    {
      EventHandler handler = EventHandler(this);
      await handler.execute(_onconnected);
    }
    connected = true;
  }

  @override
  onDisconnected(int? code, String? message) async
  {
    if (!S.isNullOrEmpty(ondisconnected))
    {
      EventHandler handler = EventHandler(this);
      await handler.execute(_ondisconnected);
    }
    connected = false;
  }

  @override
  onError(String error) async
  {
    if (!S.isNullOrEmpty(onerror))
    {
      EventHandler handler = EventHandler(this);
      await handler.execute(_onerror);
    }
  }

  @override
  Future<bool?> execute(String propertyOrFunction, List<dynamic> arguments) async
  {
    /// setter
    if (scope == null) return null;
    String function = propertyOrFunction.toLowerCase().trim();

    switch (function)
    {
      case "send":
      case "write":
        String? message = S.toStr(S.item(arguments, 0));
        if (message != null) send(message);
        return true;

      case "post":
        String? message = await scope?.replaceFileReferences(this.body);
        if (message != null) send(message);
        return true;

      case "stream":
        String? message = S.toStr(S.item(arguments, 0));
        int? chunksize = S.toInt(S.item(arguments, 1));
        if (message != null) stream(message, chunksize: chunksize);
        return true;

      case "read":
      case "connect":
        return await start();

      case "disconnect":
        return await stop();
    }
    return super.execute(propertyOrFunction, arguments);
  }
}
