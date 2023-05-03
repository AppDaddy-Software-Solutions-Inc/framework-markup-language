// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:fml/helper/common_helpers.dart';

import 'iSocketListener.dart';

class Socket
{
  Uri? _uri;
  set uri (dynamic url)
  {
    if (url is String)
    {
      var scheme = (System.app?.secure ?? false) ? "wss" : "ws";
      _uri = URI.parse(url)?.replace(scheme: scheme);
    }
    else if (url is Uri) {
      _uri = url;
    }
  }
  Uri? get uri => _uri;

  String? get url => _uri?.toString();

  final ISocketListener listener;
  String? lastMessage;
  WebSocketChannel? _socket;
  bool connected = false;

  Socket(String? url, this.listener)
  {
    uri = url;
    if (!S.isNullOrEmpty(url) && uri == null) Log().error('SOCKET:: Invalid Url');
  }

  Future reconnect(String? url) async
  {
    // set the uri if url is passed and reconnect
    if (!S.isNullOrEmpty(url))
    {
      Log().info('SOCKET:: Attempting Reconnect ...');

      // set the uri
      Uri? uri = Uri.tryParse(url!);

      // valid url?
      if (uri != null)
      {
        // reconnect
        if (connected && this.url != uri.toString())
        {
          Log().info('SOCKET:: Reconnecting ...');

          // disconnect from existing
          await disconnect();

          // set new uri
          this.uri = uri;

          // reconnect
          await connect(forceReconnect: true);
        }
      }

      // invalid url?
      else
      {
        Log().error('SOCKET:: The supplied url => $url is invalid');

        // disconnect?
        if (connected) await disconnect();

        // clear existing uri
        this.uri = null;
      }
    }
  }

  Future<bool> connect({bool forceReconnect = false}) async
  {
    // cannot connect to an invalid uri
    if (uri == null)
    {
      Log().error('SOCKET:: Uri has not been set. Cannot connect');
      return false;
    }

    try
    {
      // connect to the socket
      if (!connected || forceReconnect)
      {
        Log().debug('SOCKET:: Connecting to $url');

        lastMessage = null;

        // close the old socket
        if (_socket != null) await _socket!.sink.close();

        // connect
        connected = false;
        _socket = WebSocketChannel.connect(uri!);
        connected = true;

        Log().debug('SOCKET:: Connected');

        // listen for messages
        _socket!.stream.listen(_onData, onError: _onError, onDone: _onDone);

        // notify listener of connection
        listener.onConnected();
      }
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
      if (_socket != null)
      {await _socket!.sink.close();}
      connected = false;
    }
    on Exception catch(e)
    {
      Log().error('SOCKET:: Error closing connection to $url. Error is $e');
    }

    Log().debug('SOCKET:: Connection Closed');

    return true;
  }

  void _onData(data)
  {
    Log().debug('SOCKET:: Received message >> $data');
    connected = true;
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
    Log().debug('SOCKET:: Done. Close code is ${_socket?.closeCode} and reason is ${_socket?.closeReason}');
    if (connected && _socket?.closeCode != null)
    {
      connected = false;
      int? code = _socket?.closeCode;
      String? msg = _socket?.closeReason ?? lastMessage;
      listener.onDisconnected(code, msg);
    }
  }

  Future<bool> send(dynamic message) async
  {
    bool ok = true;
    try
    {
      // ensure connected
      await connect();

      // send the message
      if (connected && message != null && _socket != null) _socket!.sink.add(message);
    }
    catch(e)
    {
      ok = false;
      Log().error('SOCKET:: Error sending message to $url');
      Log().exception(e);
    }

    return ok;
  }

  dispose() => disconnect();
}
