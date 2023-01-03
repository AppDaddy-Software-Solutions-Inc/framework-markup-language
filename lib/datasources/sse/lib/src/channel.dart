import 'package:stream_channel/stream_channel.dart';
import 'connect.dart'
if (dart.library.html) 'connect.web.dart'
if (dart.library.io)   'connect.mobile.dart' as platform;
abstract class SseChannel extends StreamChannelMixin
{
  factory SseChannel.connect(Uri url, {String? method, String? body, Map<String, String>? headers, List<String>? events}) => platform.connect(url, method: method, body: body, headers: headers, events: events);
  close();
}
