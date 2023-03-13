import 'dart:async';
import 'dart:convert';

typedef RetryIndicator = void Function(Duration retry);

class SseTransformer implements StreamTransformer<List<int>, Event> {
  RetryIndicator? retryIndicator;
  late final StreamController<Event> _controller;

  SseTransformer({this.retryIndicator});

  @override
  Stream<Event> bind(Stream<List<int>> stream)
  {
    _controller = StreamController(onListen: () {
      // the event we are currently building
      var currentEvent = Event();
      // the regexes we will use later
      var lineRegex = RegExp(r'^([^:]*)(?::)?(?: )?(.*)?$');
      var removeEndingNewlineRegex = RegExp(r'^((?:.|\n)*)\n$');
      // This stream will receive chunks of data that is not necessarily a
      // single event. So we build events on the fly and broadcast the event as
      // soon as we encounter a double newline, then we start a new one.
      stream
          .transform(Utf8Decoder())
          .transform(LineSplitter())
          .listen((String line) {
        if (line.isEmpty) {
          // event is done
          // strip ending newline from data
          if (currentEvent.data != null) {
            var match =
                removeEndingNewlineRegex.firstMatch(currentEvent.data!)!;
            currentEvent.data = match.group(1);
          }
          _controller.add(currentEvent);
          currentEvent = Event();
          return;
        }
        // match the line prefix and the value using the regex
        Match match = lineRegex.firstMatch(line)!;
        var field = match.group(1)!;
        var value = match.group(2) ?? '';
        if (field.isEmpty) {
          // lines starting with a colon are to be ignored
          return;
        }
        switch (field) {
          case 'event':
            currentEvent.event = value;
            break;
          case 'data':
            currentEvent.data = '${currentEvent.data ?? ''}$value\n';
            break;
          case 'id':
            currentEvent.id = value;
            break;
          case 'retry':
            if (retryIndicator != null) {
              retryIndicator!(Duration(milliseconds: int.parse(value)));
            }
            break;
        }
      });
    });
    return _controller.stream;
  }

  dispose()
  {
    if (!_controller.isClosed) _controller.close();
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() =>
      StreamTransformer.castFrom<List<int>, Event, RS, RT>(this);
}

class Event implements Comparable<Event> {
  Event({this.id, this.event, this.data});

  Event.message({this.id, this.data}) : event = 'put';

  /// An identifier that can be used to allow a client to replay
  /// missed Events by returning the Last-Event-Id header.
  /// Return empty string if not required.
  String? id;

  /// The name of the event. Return empty string if not required.
  String? event;

  /// The payload of the event.
  String? data;

  @override
  int compareTo(Event other) => id!.compareTo(other.id!);
}
