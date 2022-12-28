// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/datasources/eventsource/lib/src/channel.dart';
import 'package:fml/datasources/eventsource/lib/src/transformer.dart';
import 'package:http/http.dart';
import 'package:stream_channel/stream_channel.dart';

typedef OnConnected = void Function();

class IOSseChannel extends StreamChannelMixin implements SseChannel
{
  late final StreamController<String?> _controller;
  final _onConnected = Completer();

  final Uri url;
  late final String? method;
  late final String? body;
  late final Map<String, String>? headers;

  IOSseChannel._(this.url, {String? method, String? body, Map<String, String>? headers, List<String>? messageTypes})
  {
    this.method = method;
    this.headers = headers;
    this.body = body;
    _controller = StreamController<String?>.broadcast(onListen: _onListen, onCancel: _onCancel);
  }

  factory IOSseChannel.connect(Uri url, {String? method, String? body, Map<String, String>? headers, List<String>? messageTypes}) => IOSseChannel._(url, method: method, body: body, headers: headers, messageTypes: messageTypes);

  _onListen() async
  {
    var request = new Request(method ?? "GET", url);

    request.headers["cache-control"] = "no-cache";
    request.headers["accept"] = "text/event-stream";
    headers?.forEach((k, v) => request.headers[k] = v);
    request.body = body ?? "";

    final client = Client();
    await client.send(request).then((response)
    {
      if (response.statusCode == 200)
      {
        response.stream.transform(EventSourceTransformer()).listen((event)
        {
          if (!_controller.isClosed) _controller.sink.add(event.data);
        });
        _onConnected.complete();
      }
    });
  }

  _onCancel()
  {
    _controller.close();
  }

  void close()
  {
    _controller.close();
  }

  @override
  StreamSink get sink => _controller.sink;

  @override
  Stream get stream => _controller.stream;
}
