// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:io';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/datasources/base/model.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/datasources/socket/websocket.dart' as WEBSOCKET;
import 'package:fml/datasources/file/file.dart' as FILE;
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';

enum Methods {read, write}

class SocketModel extends DataSourceModel implements IDataSource, WEBSOCKET.IWebSocketListener
{
  WEBSOCKET.WebSocket? websocket;

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

  // file
  StringObservable? _file;
  set file(dynamic v)
  {
    if (_file != null)
    {
      _file!.set(v);
    }
    else if (v != null)
    {
      _file = StringObservable(Binding.toKey(id, 'file'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get file => _file?.get();
  
  SocketModel(WidgetModel parent, String? id) : super(parent, id);

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
    url  = Xml.get(node: xml, tag: 'url');
    file = Xml.get(node: xml, tag: 'file');
  }

  @override
  void dispose()
  {
    websocket?.dispose();
    websocket = null;
    super.dispose();
  }

  @override
  Future<bool> start({bool refresh: false, String? key}) async
  {
    bool ok = true;
    busy = true;

    if ((ok) && (!S.isNullOrEmpty(this.file))) ok = await stream();
    if ((ok) && (!S.isNullOrEmpty(this.body))) ok = await send();

    return ok;
  }

  @override
  Future<bool> stop() async
  {
    try
    {
      if (websocket != null)
      {
        // wait to complete
        await websocket!.socket.sink.done;

        // dispose
        websocket!.dispose();
        websocket = null;
      }
    }
    catch(e)
    {
      return false;
    }
    super.stop();
    return true;
  }

  Future<bool> stream() async
  {
    bool ok = true;
    busy = true;

    try
    {
      // send file
      FILE.File? file = scope!.files.containsKey(this.file) ? scope!.files[this.file!] : null;
      if (file != null)
      {
        // set file size
        bytes = file.size;

        // set url
        String url = Url.toAbsolute(this.url!, domain : System().secure ? "wss://${System().host}" : "ws://${System().host}");

        // open the socket
        websocket = WEBSOCKET.WebSocket(url, this);

        // send the file in chunks
        ok = await websocket!.stream(file);
      }
      else ok = false;
    }
    catch(e)
    {
      await onException(Data(), code: HttpStatus.internalServerError, message: e.toString());
      return false;
    }

    if (ok)
         await onSuccess(Data(), HttpStatus.ok, websocket!.socket.closeReason);
    else await onException(Data(), code: websocket!.socket.closeCode, message: websocket!.socket.closeReason);

    return ok;
  }

  Future<bool> send() async
  {
    bool ok = true;
    busy = true;

    try
    {
      // replace file references
      String? body = await scope?.replaceFileReferences(this.body);
      if (S.isNullOrEmpty(body)) body = null;

      if (ok)
      {
        // set bytes
        if (bytes != null) bytes = body?.length;

        // set url
        String url = Url.toAbsolute(this.url!, domain : System().secure ? "wss://${System().host}" : "ws://${System().host}");

        // open the socket
        websocket = WEBSOCKET.WebSocket(url, this);

        // send the message
        ok = await websocket!.send(body);

        // wait for remote to close the socket on completion
        if (ok)
        {
          // wait to complete
          await websocket!.socket.sink.done;

          // normal closure
          ok = (websocket!.socket.closeCode == 1000);
        }
      }
    }
    catch(e)
    {
      await onException(Data(), code: HttpStatus.internalServerError, message: e.toString());
      return false;
    }

    if (ok)
         await onSuccess(this.data ?? Data(), HttpStatus.ok, websocket!.socket.closeReason);
    else await onException(this.data ?? Data(), code: websocket!.socket.closeCode, message: websocket!.socket.closeReason);

    return ok;
  }

  onWebSocketMessage(String data)
  {
    // enabled?
    if (enabled == false) return;
    this.data = Data.fromData(data, root: root);
  }

  onWebSocketError(String error)
  {
    this.data = Data();
  }

  onWebSocketClosed(int? code, String? data)
  {
    // bool error = (code != WebSocketStatus.normalClosure);
    //this.data = Data.from(data);
  }

  @override
  Future<bool?> execute(String propertyOrFunction, List<dynamic> arguments) async
  {
    /// setter
    if (scope == null) return null;
    String function = propertyOrFunction.toLowerCase().trim();

    bool refresh = S.toBool(S.item(arguments,0)) ?? false;
    switch (function)
    {
      case "start" : return await start(refresh: refresh);
      case "fire" : return await start(refresh: refresh);
      case "stop" : return await stop();
    }
    return super.execute(propertyOrFunction, arguments);
  }
}
