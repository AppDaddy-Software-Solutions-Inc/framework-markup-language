// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:typed_data';

import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:fml/datasources/file/file.dart' as FILE;
import 'package:fml/helper/helper_barrel.dart';

abstract class IWebSocketListener
{
  onWebSocketMessage(String message);
  onWebSocketError(String error);
  onWebSocketClosed(int? status, String? message);
}

class WebSocket
{
  final String url;
  final IWebSocketListener listener;

  String? lastMessage;

  late WebSocketChannel socket;
  bool connected = false;

  WebSocket(this.url, this.listener);

  Future<bool> connect() async
  {
    Log().debug('WEBSOCKET:: Connecting to $url');
    connected = false;
    try
    {
      // authorization must be sent as a query parameter since headers are not supported in web sockets
      String url = Url.addParameter(this.url, 'token', System().jwt?.token);
      socket = WebSocketChannel.connect(Uri.parse(url));
      socket.stream.listen(_onData, onError: _onError, onDone: _onDone);
      lastMessage = null;
      connected = true;
    }
    catch(e)
    {
      connected = false;
      Log().error('WEBSOCKET:: Error Connecting to $url. Error is $e');
    }
    return connected;
  }

  Future<bool> disconnect() async
  {
    Log().debug('WEBSOCKET:: Closing connection to $url');

    try
    {
      // Close the channel
      socket.sink.close();
      connected = false;
    }
    on Exception catch(e)
    {
      Log().error('WEBSOCKET:: Error closing connection to $url. Error is $e');
    }

    Log().debug('WEBSOCKET:: Connection to $url closed');

    return true;
  }

  void _onData(data)
  {
    Log().debug('WEBSOCKET:: Received message >> $data');

      if (data is String)
      {
        lastMessage = data;
        listener.onWebSocketMessage(data);
      }
  }

  _onError(e)
  {
    String msg = (e is String) ? e : "?";
    Log().debug('WEBSOCKET:: Error on $url. Error is $msg');
   listener.onWebSocketError("<Error><message><![CDATA[$msg]]></message></Error>");
  }

  _onDone()
  {
    Log().debug('WEBSOCKET:: Done. Close code is ${socket.closeCode} and reason is ${socket.closeReason}');
    if (connected)
    {
      connected = false;
      int? code = socket.closeCode;
      String? msg = socket.closeReason ?? lastMessage;
      listener.onWebSocketClosed(code, msg);
    }
  }

  Future<bool> send(String? message) async
  {
    bool ok = true;
    try
    {
      if (!connected) await connect();
      if (connected) socket.sink.add(message);
    }
    catch(e)
    {
      ok = false;
      Log().error('WEBSOCKET:: Error sending message to $url');
      Log().exception(e);
    }

    return ok;
  }

  Future<bool> stream(FILE.File file,{int chunksize = 30000}) async
  {
    bool ok = false;
    try
    {
      if (!connected) await connect();
      if (connected)
      {
        // start of message stream
        socket.sink.add("SOM");

        if (chunksize <= 0) chunksize = file.size ?? 0;
        int parts = (file.size ?? 0/ chunksize).ceil();

        for (int i = 0; i < parts; i++)
        {
          int start = i * chunksize;
          int end   = start + chunksize;

          Uint8List? bytes = await file.read(start: start, end: end);
          socket.sink.add(bytes);
        }

        // end of message stream
        socket.sink.add("EOM");
        ok = true;
      }
    }
    catch(e)
    {
      Log().error('WEBSOCKET:: Error sending message to $url. Error is $e');
    }

    return ok;
  }

  dispose()
  {
    disconnect();
  }
}