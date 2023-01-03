import 'package:fml/datasources/sse/sse.mobile.dart';
import 'channel.dart';
SseChannel connect(Uri url, {String? method, String? body, Map<String, String>? headers, List<String>? events}) => IOSseChannel.connect(url, method: method, body: body, headers: headers, events: events);
