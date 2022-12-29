import 'channel.dart';

/// Creates a new Server Sent Events connection.
SseChannel connect(Uri url, {String? method, String? body, Map<String, String>? headers, List<String>? messageTypes})
{
  throw UnsupportedError('No implementation of the connect api provided');
}
