// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:universal_html/html.dart';
import 'package:fml/datasources/sse/lib/src/channel.dart';
import 'package:stream_channel/stream_channel.dart';

class HtmlSseChannel extends StreamChannelMixin implements SseChannel
{
  late  EventSource source;
  Timer? _timer;
  final _controller = StreamController<String>();

  final _onConnected = Completer();
  Future<void> get onConnected => _onConnected.future;

  HtmlSseChannel(String url, List<String>? events)
  {
    source = EventSource(url, withCredentials: false);
    source.onOpen.first.whenComplete(()
    {
      _onConnected.complete();
    });

    // listen for specific message types
    source.addEventListener("message", _onMessage);
    events?.forEach((type) => source.addEventListener(type, _onMessage));

    source.onOpen.listen((_) => _timer?.cancel());
    source.onError.listen((error)
    {
      print('sse error');
      // By default the SSE client uses keep-alive.
      // Allow for a retry to connect before giving up.
      if (!(_timer?.isActive ?? false)) _timer = Timer(const Duration(seconds: 5), () => _closeWithError(error));
    });
  }

  factory HtmlSseChannel.connect(Uri url, {String? method, String? body, Map<String, String>? headers, List<String>? events}) => HtmlSseChannel(url.toString(), events);

  void _onMessage(Event message)
  {
    print('sse message');
    var msg = (message as MessageEvent).data;
    _controller.add(msg);
  }

  void close()
  {
    print('sse closed');
    source.close();
    _controller.close();
  }

  void _closeWithError(Object error)
  {
    print('sse closed with error');
    _controller.addError(error);
    close();

    // This call must happen after the call to close() which checks
    // whether the completer was completed earlier.
    if (!_onConnected.isCompleted) _onConnected.completeError(error);
  }

  @override
  StreamSink get sink => _controller.sink;

  @override
  Stream get stream => _controller.stream;
}
