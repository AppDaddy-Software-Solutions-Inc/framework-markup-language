// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/datasources/base/model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/datasources/socket/socket.dart';
import 'package:fml/datasources/file/file.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';
import 'socket_listener_interface.dart';

class SocketModel extends DataSourceModel
    implements IDataSource, ISocketListener {
  Socket? socket;

  static int minPartSize = 1024;

  // message count
  late IntegerObservable _received;
  int get received => _received.get() ?? 0;

  // message
  late StringObservable _message;
  String? get message => _message.get();

  // connected
  BooleanObservable? _connected;
  set connected(dynamic v) {
    if (_connected != null) {
      _connected!.set(v);
    } else if (v != null) {
      _connected =
          BooleanObservable(Binding.toKey(id, 'connected'), v, scope: scope);
    }
  }

  bool get connected => _connected?.get() ?? false;

  // url
  StringObservable? _url;
  set url(dynamic v) {
    if (_url != null) {
      _url!.set(v);
    } else if (v != null) {
      _url = StringObservable(Binding.toKey(id, 'url'), v,
          scope: scope, listener: onUrlChange);
    }
  }

  String? get url => _url?.get();

  // on connected event
  StringObservable? _onconnected;
  set onconnected(dynamic v) {
    if (_onconnected != null) {
      _onconnected!.set(v);
    } else if (v != null) {
      _onconnected =
          StringObservable(Binding.toKey(id, 'onconnected'), v, scope: scope);
    }
  }

  String? get onconnected => _onconnected?.get();

  // on disconnected event
  StringObservable? _ondisconnected;
  set ondisconnected(dynamic v) {
    if (_ondisconnected != null) {
      _ondisconnected!.set(v);
    } else if (v != null) {
      _ondisconnected = StringObservable(Binding.toKey(id, 'ondisconnected'), v,
          scope: scope);
    }
  }

  String? get ondisconnected => _ondisconnected?.get();

  // on onerror event
  StringObservable? _onerror;
  set onerror(dynamic v) {
    if (_onerror != null) {
      _onerror!.set(v);
    } else if (v != null) {
      _onerror =
          StringObservable(Binding.toKey(id, 'onerror'), v, scope: scope);
    }
  }

  String? get onerror => _onerror?.get();

  // on message event
  StringObservable? _onmessage;
  set onmessage(dynamic v) {
    if (_onmessage != null) {
      _onmessage!.set(v);
    }
    // its important that we instantiate the onmessage observable
    // on every call since it overrides the onsuccess
    // else if (v != null)
    else {
      _onmessage =
          StringObservable(Binding.toKey(id, 'onmessage'), v, scope: scope);
    }
  }

  String? get onmessage => _onmessage?.get();

  SocketModel(Model parent, String? id) : super(parent, id) {
    _received =
        IntegerObservable(Binding.toKey(id, 'received'), 0, scope: scope);
    _message =
        StringObservable(Binding.toKey(id, 'message'), null, scope: scope);
  }

  static SocketModel? fromXml(Model parent, XmlElement xml) {
    SocketModel? model;
    try {
      model = SocketModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'socket.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);

    // properties
    url = Xml.get(node: xml, tag: 'url');
    onconnected = Xml.get(node: xml, tag: 'onconnected');
    ondisconnected = Xml.get(node: xml, tag: 'ondisconnected');
    onerror = Xml.get(node: xml, tag: 'onerror');
    onmessage = Xml.get(node: xml, tag: 'onmessage');
  }

  @override
  void dispose() {
    socket?.dispose();
    socket = null;
    super.dispose();
  }

  @override
  Future<bool> start({bool refresh = false, String? key}) async {
    bool ok = true;
    if (socket == null && url != null) socket = Socket(url!, this);
    if (socket != null) {
      ok = await socket!.connect();
      connected = ok;
    } else {
      connected = false;
      ok = false;
    }
    return ok;
  }

  @override
  Future<bool> stop() async {
    try {
      if (socket != null) {
        socket!.dispose();
        socket = null;
      }
      connected = false;
    } catch (e) {
      return false;
    }
    super.stop();
    return true;
  }

  Future<bool> send(String message, {bool? asBinary, int? maxPartSize}) async {
    bool ok = true;

    busy = true;

    // ensure broker is started
    ok = await start();
    if (!ok) return ok;

    // message is a file pointer?
    File? file =
        scope!.files.containsKey(message) ? scope!.files[message] : null;

    // send message
    if (file == null) {
      ok = await _send(message, asBinary: asBinary, maxPartSize: maxPartSize);
    } else {
      ok = await _sendFile(file, asBinary: asBinary, maxPartSize: maxPartSize);
    }

    busy = false;

    return ok;
  }

  Future<bool> _send(String message, {bool? asBinary, int? maxPartSize}) async {
    bool ok = true;

    // default format for message is string
    asBinary ??= false;

    try {
      int size = message.length;

      // nothing to send
      if (size == 0) return ok;

      // replace file references
      if (scope != null) {
        message = await scope!.replaceFileReferences(message) ?? "";
      }

      // send message in parts?
      if (maxPartSize != null &&
          maxPartSize >= minPartSize &&
          maxPartSize < size) {
        // determine number of parts to send
        int parts = (size / maxPartSize).ceil();

        Log().debug(
            'SOCKET:: Sending message (binary:  $asBinary, parts: $parts) to $url');

        // send each file part as an single message
        for (int i = 0; i < parts; i++) {
          int start = i * maxPartSize;
          int end = start + maxPartSize;
          if (end >= message.length) end = message.length - 1;
          if (start <= end) {
            String part = message.substring(start, end);

            // send as binary
            if (asBinary) {
              await socket?.send(utf8.encode(part));
            } else {
              await socket?.send(part);
            }
          }
        }
      }

      // send file as a single message
      else {
        Log().debug(
            'SOCKET:: Sending message (binary: $asBinary, bytes:${message.length}) to $url');

        // send as binary
        if (asBinary) {
          await socket?.send(utf8.encode(message));
        } else {
          await socket?.send(message);
        }
      }

      ok = true;
    } catch (e) {
      Log().error("Error sending file. Error is $e");
      ok = false;
    }
    return ok;
  }

  Future<bool> _sendFile(File file, {bool? asBinary, int? maxPartSize}) async {
    bool ok = true;

    // default format for a file is binary
    asBinary ??= true;

    try {
      int size = file.size ?? 0;

      // nothing to send
      if (size == 0) return ok;

      // send in parts?
      if (maxPartSize != null &&
          maxPartSize >= minPartSize &&
          maxPartSize < size) {
        // determine number of parts to send
        int parts = (size / maxPartSize).ceil();

        Log().debug(
            'SOCKET:: Sending file (binary:  $asBinary, parts: $parts) to $url');

        // send each file part as an single message
        for (int i = 0; i < parts; i++) {
          int start = i * maxPartSize;
          int end = start + maxPartSize;

          // read part from file
          Uint8List? bytes = await file.read(start: start, end: end);

          // send as binary
          if (asBinary) {
            await socket?.send(bytes);
          } else {
            await socket?.send(bytes);
          }
        }
      }

      // send file as a single message
      else {
        Uint8List? bytes = await file.read();

        Log().debug(
            'SOCKET:: Sending file (binary: $asBinary, bytes:${bytes?.length}) to $url');

        if (bytes != null) {
          // send as binary
          if (asBinary) {
            await socket?.send(bytes);
          } else {
            String? text;
            try {
              text = utf8.decode(bytes);
              await socket?.send(text);
            } catch (e) {
              Log().exception(e);
            }
          }
        }
      }

      ok = true;
    } catch (e) {
      Log().error("Error sending file. Error is $e");
      ok = false;
    }
    return ok;
  }

  @override
  onMessage(String message) {
    // enabled?
    if (!enabled) return;

    // increment the number of messages received
    _received.set(received + 1);

    // set last message bindable
    _message.set(message);

    // deserialize the data
    Data data = Data.from(message, root: root);

    // if the message didn't deserialize (length 0)
    // so create a simple map with message bindable <id>.data.message
    // otherwise the data is the deserialized message payload
    if (data.isEmpty) data.insert(0, {'message': message});

    // fire the onresponse
    onSuccess(data, code: HttpStatus.ok, onSuccessOverride: _onmessage);
  }

  @override
  onConnected() async {
    if (!isNullOrEmpty(onconnected)) {
      EventHandler handler = EventHandler(this);
      await handler.execute(_onconnected);
    }
    connected = true;
  }

  @override
  onDisconnected(int? code, String? message) async {
    if (!isNullOrEmpty(ondisconnected)) {
      EventHandler handler = EventHandler(this);
      await handler.execute(_ondisconnected);
    }

    // deserialize the data
    Data data = Data.from(message, root: root);

    //success or fail
    if (code == 1000) {
      onData(data, code: code, message: message);
    } else {
      onFail(data, code: code, message: message);
    }

    connected = false;
  }

  @override
  onError(String error) async {
    if (!isNullOrEmpty(onerror)) {
      EventHandler handler = EventHandler(this);
      await handler.execute(_onerror);
    }
  }

  @override
  Future<bool?> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    /// setter
    if (scope == null) return null;
    String function = propertyOrFunction.toLowerCase().trim();

    switch (function) {
      case "send":
      case "write":
        String? message = toStr(elementAt(arguments, 0)) ?? body;
        bool? asBinary = toBool(elementAt(arguments, 1));
        int? maxPartSize = toInt(elementAt(arguments, 2));
        if (!isNullOrEmpty(message)) {
          send(message!, asBinary: asBinary, maxPartSize: maxPartSize);
        }
        return true;

      case "read":
      case "connect":
        return await start();

      case "disconnect":
        return await stop();
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  onUrlChange(Observable observable) async {
    // reconnect if the url changes
    if (initialized && enabled && autoexecute == true) {
      await socket?.reconnect(url);
    }
  }
}
