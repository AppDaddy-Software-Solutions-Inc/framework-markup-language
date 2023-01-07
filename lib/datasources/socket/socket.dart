// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:fml/helper/helper_barrel.dart';

import 'iSocketListener.dart';

class Socket
{
  late final String url;
  final ISocketListener listener;
  String? lastMessage;
  late WebSocketChannel socket;
  bool connected = false;

  Socket(String url, this.listener)
  {
    // set url
    this.url = Url.toAbsolute(url, domain : System().secure ? "wss://${System().host}" : "ws://${System().host}");
  }

  Future<bool> connect() async
  {
    Log().debug('SOCKET:: Connecting to $url');
    connected = false;
    try
    {
      // authorization must be sent as a query parameter since headers are not supported in web sockets
      String url = Url.addParameter(this.url, 'token', System().jwt?.token);
      socket = WebSocketChannel.connect(Uri.parse(url));
      socket.stream.listen(_onData, onError: _onError, onDone: _onDone);
      lastMessage = null;
      connected = true;
      listener.onConnected();
    }
    catch(e)
    {
      connected = false;
      Log().error('SOCKET:: Error Connecting to $url. Error is $e');
    }
    return connected;
  }

  Future<bool> disconnect() async
  {
    Log().debug('SOCKET:: Closing connection to $url');

    try
    {
      // Close the channel
      await socket.sink.close();
      connected = false;
    }
    on Exception catch(e)
    {
      Log().error('SOCKET:: Error closing connection to $url. Error is $e');
    }

    Log().debug('SOCKET:: Connection to $url closed');

    return true;
  }

  void _onData(data)
  {
    Log().debug('SOCKET:: Received message >> $data');
    if (data is String)
    {
      lastMessage = data;
      listener.onMessage(data);
    }
  }

  _onError(e)
  {
    String msg = (e is String) ? e : "?";
    Log().debug('SOCKET:: Error on $url. Error is $msg');
    listener.onError("<Error><message><![CDATA[$msg]]></message></Error>");
  }

  _onDone()
  {
    return;
    Log().debug('SOCKET:: Done. Close code is ${socket.closeCode} and reason is ${socket.closeReason}');
    if (connected)
    {
      connected = false;
      int? code = socket.closeCode;
      String? msg = socket.closeReason ?? lastMessage;
      listener.onDisconnected(code, msg);
    }
  }

  Future<bool> send(dynamic message) async
  {
    bool ok = true;
    try
    {
      if (!connected) await connect();
      if (connected && message != null) socket.sink.add(message);
    }
    catch(e)
    {
      ok = false;
      Log().error('SOCKET:: Error sending message to $url');
      Log().exception(e);
    }

    return ok;
  }

  dispose()
  {
    disconnect();
  }
}