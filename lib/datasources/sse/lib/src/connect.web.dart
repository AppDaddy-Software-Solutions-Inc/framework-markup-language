import 'package:fml/datasources/sse/sse.web.dart';
import 'channel.dart';

SseChannel connect(Uri url,
        {String? method,
        String? body,
        Map<String, String>? headers,
        List<String>? events}) =>
    HtmlSseChannel.connect(url,
        method: method, body: body, headers: headers, events: events);
