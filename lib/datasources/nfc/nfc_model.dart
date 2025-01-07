// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/datasources/base/model.dart';
import 'package:fml/event/handler.dart';
import 'package:xml/xml.dart';
import 'payload.dart';
import 'nfc_listener_interface.dart';
import 'nfc.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

// platform
import 'package:fml/platform/platform.vm.dart'
if (dart.library.io) 'package:fml/platform/platform.vm.dart'
if (dart.library.html) 'package:fml/platform/platform.web.dart';

class NcfModel extends DataSourceModel implements IDataSource, INfcListener {
  @override
  bool get autoexecute => super.autoexecute ?? true;

  // message count
  late IntegerObservable _received;
  int get received => _received.get() ?? 0;

  // serial
  late StringObservable _serial;
  String? get serial => _serial.get();

  // message
  late StringObservable _message;
  String? get message => _message.get();

  StringObservable? _method;
  set method(dynamic v) {
    if (_method != null) {
      _method!.set(v);
    } else if (v != null) {
      _method = StringObservable(Binding.toKey(id, 'method'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get method => _method?.get() ?? "read";

  // on write fail event
  StringObservable? get onWriteFailObservable => _onwritefail;
  StringObservable? _onwritefail;
  set onwritefail(dynamic v) {
    if (_onwritefail != null) {
      _onwritefail!.set(v);
    } else if (v != null) {
      _onwritefail = StringObservable(Binding.toKey(id, 'onwritefail'), v,
          scope: scope, lazyEvaluation: true);
    }
  }

  String? get onwritefail => _onwritefail?.get();

  // on read fail event
  StringObservable? get onReadFailObservable => _onreadfail;
  StringObservable? _onreadfail;
  set onreadfail(dynamic v) {
    if (_onreadfail != null) {
      _onreadfail!.set(v);
    } else if (v != null) {
      _onreadfail = StringObservable(Binding.toKey(id, 'onreadfail'), v,
          scope: scope, lazyEvaluation: true);
    }
  }

  String? get onreadfail => _onreadfail?.get();

  // on timeout event
  StringObservable? get onTimeoutObservable => _ontimeout;
  StringObservable? _ontimeout;
  set ontimeout(dynamic v) {
    if (_ontimeout != null) {
      _ontimeout!.set(v);
    } else if (v != null) {
      _ontimeout = StringObservable(Binding.toKey(id, 'ontimeout'), v,
          scope: scope, lazyEvaluation: true);
    }
  }

  String? get ontimeout => _ontimeout?.get();

  NcfModel(Model parent, String? id) : super(parent, id) {
    _received =
        IntegerObservable(Binding.toKey(id, 'received'), 0, scope: scope);
    _serial = StringObservable(Binding.toKey(id, 'serial'), null, scope: scope);
    _message =
        StringObservable(Binding.toKey(id, 'payload'), null, scope: scope);
  }

  static NcfModel? fromXml(Model parent, XmlElement xml) {
    NcfModel? model;
    try {
      model = NcfModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'nfc.Model');
      model = null;
    }
    return model;
  }

  @override
  void dispose() {
    Reader().removeListener(this);
    super.dispose();
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);
    method = Xml.attribute(node: xml, tag: 'method');
    ontimeout = Xml.get(node: xml, tag: 'ontimeout');
    onreadfail = Xml.get(node: xml, tag: 'onwritefail');
    onwritefail = Xml.get(node: xml, tag: 'onreadfail');
  }

  @override
  Future<bool> start() async {
    bool ok = true;

    if (!isMobile) {
      System.toast("NFC is only available on mobile devices", duration: 4);
      return ok;
    }

    switch (method?.toLowerCase().trim()) {
      case "read":
        Reader().registerListener(this);
        statusmessage = "Approach an NFC tag to Read";
        break;

      case "write":
        statusmessage = "Approach an NFC tag to Write";
        return await _write(body);
    }

    return true;
  }

  @override
  Future<bool> stop() async {
    Reader().removeListener(this);
    super.stop();
    return true;
  }

  Future<bool> _write(String? message, {bool restart = false}) async {
    if (!isNullOrEmpty(message)) {
      Log().debug('NFC WRITE: Polling for 60 seconds');
      String stripTags = message!
          .replaceAll('\r', '')
          .replaceAll('\t', '')
          .replaceAll('\n', '')
          .replaceAll(RegExp("<[^>]*>", caseSensitive: false), '');
      Writer writer = Writer(stripTags, callback: onResult);
      try {
        bool ok = await writer.write();

        // write succeeded
        if (ok) {
          if (!isNullOrEmpty(onsuccess) || !isNullOrEmpty(onwritesuccess)) {
            EventHandler handler = EventHandler(this);
            await handler.execute(onSuccessObservable);
            await handler.execute(onWriteSuccessObservable);
          }
          statusmessage = "Write Successful";
          if (restart) start();
        }

        // write failed
        else if (!ok) {
          if (!isNullOrEmpty(onfail) || !isNullOrEmpty(onwritefail)) {
            EventHandler handler = EventHandler(this);
            await handler.execute(onFailObservable);
            await handler.execute(onWriteFailObservable);
          }
          statusmessage = "Write Failed";
          if (restart) start();
        }
      } on CustomException catch (e) {
        if (e.code == 408) {
          if (!isNullOrEmpty(ontimeout)) {
            EventHandler handler = EventHandler(this);
            await handler.execute(onTimeoutObservable);
          }
          statusmessage = e.message;
          if (restart) start();
        }
        if (e.code == 405) {
          if (!isNullOrEmpty(onfail) || !isNullOrEmpty(onwritefail)) {
            EventHandler handler = EventHandler(this);
            await handler.execute(onFailObservable);
            await handler.execute(onWriteFailObservable);
          }
          statusmessage = e.message;
          if (restart) start();
        }
      }
    }
    return true;
  }

  onResult(bool b) {
    // success
    if (b && onsuccess != null) {
      EventHandler(this).execute(onSuccessObservable);
      EventHandler(this).execute(onReadSuccessObservable);
      statusmessage = "Read Successul";
    }

    // fail
    if (!b && onfail != null) {
      EventHandler(this).execute(onFailObservable);
      EventHandler(this).execute(onWriteSuccessObservable);
      statusmessage = "Read Failed";
    }
  }

  @override
  Future<dynamic> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    /// setter
    if (scope == null) return null;

    if (!isMobile) {
      System.toast("NFC is only available on mobile devices", duration: 4);
      statusmessage = "NFC is only available on mobile devices";
      return false;
    }

    String function = propertyOrFunction.toLowerCase().trim();
    if (function == "write") {
      statusmessage = "Approach an NFC tag to Write";
      String? message = toStr(elementAt(arguments, 0));
      return await _write(message, restart: true);
    } else if (method?.toLowerCase().trim() == "read") {
      switch (function) {
        case "read":
        case "start":
          statusmessage = "Approach an NFC tag to read";
          Reader().registerListener(this);
          return true;
        case "stop":
          statusmessage = "Please Start NFC Reader";
          return await stop();
      }
    } else if (method?.toLowerCase().trim() == "write") {
      switch (function) {
        case "start":
        case "write":
          statusmessage = "Approach an NFC tag to write";
          String? message = body;
          return await _write(message);
        case "stop":
          statusmessage = "Please Start NFC Reader";
          return await stop();
      }
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  @override
  onMessage(Payload payload) {
    // enabled?
    if (!enabled) return;

    // increment the number of messages received
    _received.set(received + 1);

    // set last serial received
    _serial.set(payload.id);

    // set last message bindable
    _message.set(payload.message);

    // deserialize the data
    Data data = Data.from(payload.message, root: root);

    // if the message didn't deserialize (length 0)
    // is the payload url encoded?
    if (data.isEmpty && payload.message != null) {
      // is a valid url query string?
      String msg = payload.message!.trim();

      // parse the string
      Uri? uri = URI.parse(msg);
      if (uri != null && !uri.hasQuery) uri = URI.parse("?$msg");
      if (uri != null && uri.hasQuery) {
        // add payload url parameters
        Map<String, dynamic> map = <String, dynamic>{};
        uri.queryParameters.forEach((k, v) => map[k] = v);
        if (!map.containsKey('payload')) map['payload'] = payload.message;
        if (!map.containsKey('serial')) map['serial'] = payload.id;
        data.add(map);
      }
    }

    // if the message didn't deserialize (length 0)
    // create a simple map with topic and message bindables <id>.data.topic and <id>.data.message
    // otherwise the data is the deserialized message payload
    if (data.isEmpty) {
      data.insert(0,
          {'id': payload.id, 'serial': payload.id, 'payload': payload.message});
    }

    // fire the onresponse
    onSuccess(data, code: 200);
  }
}
