import 'package:fml/datasources/eventsource/event_source.web.dart';
import 'channel.dart';
SseChannel connect(Uri url, {String? method, String? body, Map<String, String>? headers, List<String>? messageTypes}) => HtmlSseChannel.connect(url, method: method, body: body, headers: headers, messageTypes: messageTypes);
