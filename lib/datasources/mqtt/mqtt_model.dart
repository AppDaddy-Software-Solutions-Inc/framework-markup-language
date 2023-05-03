// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:io';

import 'package:fml/data/data.dart';
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/datasources/base/model.dart';
import 'package:xml/xml.dart';
import 'iMqtt.dart';
import 'iMqttListener.dart';
import 'payload.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class MqttModel extends DataSourceModel implements IDataSource, IMqttListener
{
  IMqtt? mqtt;

  // message count
  late IntegerObservable _received;
  int get received => _received.get() ?? 0;

  // topic
  late StringObservable _topic;
  String? get topic => _topic.get();

  // message
  late StringObservable _message;
  String? get message => _message.get();

  // on connected event
  StringObservable? _onconnected;
  set onconnected(dynamic v) 
  {
    if (_onconnected != null) 
    {
      _onconnected!.set(v);
    } 
    else if (v != null) 
    {
      _onconnected = StringObservable(Binding.toKey(id, 'onconnected'), v, scope: scope, lazyEval: true);
    }
  }
  String? get onconnected => _onconnected?.get();

  // on disconnected event
  StringObservable? _ondisconnected;
  set ondisconnected(dynamic v)
  {
    if (_ondisconnected != null)
    {
      _ondisconnected!.set(v);
    }
    else if (v != null)
    {
      _ondisconnected = StringObservable(Binding.toKey(id, 'ondisconnected'), v, scope: scope, lazyEval: true);
    }
  }
  String? get ondisconnected => _ondisconnected?.get();

  // on subscribed event
  StringObservable? _onsubscribed;
  set onsubscribed(dynamic v)
  {
    if (_onsubscribed != null)
    {
      _onsubscribed!.set(v);
    }
    else if (v != null)
    {
      _onsubscribed = StringObservable(Binding.toKey(id, 'onsubscribed'), v, scope: scope, lazyEval: true);
    }
  }
  String? get onsubscribed => _onsubscribed?.get();

  // on ununsubscribed event
  StringObservable? _onunsubscribed;
  set onunsubscribed(dynamic v)
  {
    if (_onunsubscribed != null)
    {
      _onunsubscribed!.set(v);
    }
    else if (v != null)
    {
      _onunsubscribed = StringObservable(Binding.toKey(id, 'onunsubscribed'), v, scope: scope, lazyEval: true);
    }
  }
  String? get onunsubscribed => _onunsubscribed?.get();
  
  // on published event
  StringObservable? _onpublished;
  set onpublished(dynamic v)
  {
    if (_onpublished != null)
    {
      _onpublished!.set(v);
    }
    else if (v != null)
    {
      _onpublished = StringObservable(Binding.toKey(id, 'onpublished'), v, scope: scope, lazyEval: true);
    }
  }
  String? get onpublished => _onpublished?.get();

  // on onerror event
  StringObservable? _onerror;
  set onerror(dynamic v)
  {
    if (_onerror != null)
    {
      _onerror!.set(v);
    }
    else if (v != null)
    {
      _onerror = StringObservable(Binding.toKey(id, 'onerror'), v, scope: scope, lazyEval: true);
    }
  }
  String? get onerror => _onerror?.get();

  // on message event
  StringObservable? _onmessage;
  set onmessage(dynamic v)
  {
    if (_onmessage != null)
    {
      _onmessage!.set(v);
    }
    // its important that we instantiate the onmessage observable
    // on every call since it overrides the onsuccess
    // else if (v != null)
    {
      _onmessage = StringObservable(Binding.toKey(id, 'onmessage'), v, scope: scope);
    }
  }
  String? get onmessage => _onmessage?.get();

  // connected
  BooleanObservable? _connected;
  set connected (dynamic v)
  {
    if (_connected != null)
    {
      _connected!.set(v);
    }
    else if (v != null)
    {
      _connected = BooleanObservable(Binding.toKey(id, 'connected'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get connected => _connected?.get() ?? false;

  // url
  StringObservable? _url;
  set url(dynamic v)
  {
    if (_url != null)
    {
      _url!.set(v);
    }
    else if (v != null)
    {
      _url = StringObservable(Binding.toKey(id, 'url'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get url => _url?.get();

  // username
  StringObservable? _username;
  set username(dynamic v)
  {
    if (_username != null)
    {
      _username!.set(v);
    }
    else if (v != null)
    {
      _username = StringObservable(Binding.toKey(id, 'username'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get username => _username?.get();
  
  // password
  StringObservable? _password;
  set password(dynamic v)
  {
    if (_password != null)
    {
      _password!.set(v);
    }
    else if (v != null)
    {
      _password = StringObservable(Binding.toKey(id, 'password'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get password => _password?.get();
  
  // subscriptions
  List<String> subscriptions = [];

  MqttModel(WidgetModel parent, String? id) : super(parent, id)
  {
    _received = IntegerObservable(Binding.toKey(id, 'received'), 0, scope: scope);
    _topic    = StringObservable(Binding.toKey(id, 'topic'), null, scope: scope);
    _message  = StringObservable(Binding.toKey(id, 'message'), null, scope: scope);
  }

  static MqttModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    MqttModel? model;
    try
    {
      model = MqttModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'mqtt.Model');
      model = null;
    }
    return model;
  }

  @override
  void dispose()
  {
    mqtt?.dispose();
    super.dispose();
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    // properties
    url = Xml.get(node: xml, tag: 'url');
    onconnected = Xml.get(node: xml, tag: 'onconnected');
    ondisconnected = Xml.get(node: xml, tag: 'ondisconnected');
    onsubscribed = Xml.get(node: xml, tag: 'onsubscribed');
    onunsubscribed = Xml.get(node: xml, tag: 'onunsubscribed');
    onpublished = Xml.get(node: xml, tag: 'onpublished');
    onerror = Xml.get(node: xml, tag: 'onerror');
    onmessage = Xml.get(node: xml, tag: 'onmessage');
    username = Xml.get(node: xml, tag: 'username');
    password = Xml.get(node: xml, tag: 'password');
    
    // subscriptions
    var subscriptions = Xml.get(node: xml, tag: 'subscriptions')?.split(",");
    subscriptions?.forEach((subscription)
    {
      if (!S.isNullOrEmpty(subscription) && !this.subscriptions.contains(subscription.trim())) this.subscriptions.add(subscription.trim());
    });
  }

  @override
  Future<bool> start({bool refresh = false, String? key}) async
  {
    bool ok = true;
    if (mqtt == null && url != null) mqtt = IMqtt.create(url!, this, username: username, password: password);
    if (mqtt != null)
    {
         ok = await mqtt!.connect();
         connected = ok;
    }
    else
    {
      connected = false;
      ok = false;
    }
    return ok;
  }

  Future<bool> stop() async
  {
    mqtt?.disconnect();
    super.stop();
    connected = false;
    return true;
  }

  @override
  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async
  {
    var function = propertyOrFunction.toLowerCase().trim();
    switch (function)
    {
      case "write":
      case "publish":
        String? topic   = S.toStr(S.item(arguments, 0));
        String? message = S.toStr(S.item(arguments, 1));
        if (mqtt != null && topic != null && message != null) mqtt!.publish(topic,message);
        return true;

      case "read":
      case "subscribe":
        String? topic = S.toStr(S.item(arguments, 0));
        if (!S.isNullOrEmpty(topic)) mqtt?.subscribe(topic!);
        return true;

      case "unsubscribe":
        String? topic = S.toStr(S.item(arguments, 0));
        if (mqtt != null && topic != null) mqtt!.unsubscribe(topic);
        return true;

      case "connect":
        return await start();

      case "disconnect":
        return await stop();
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  onMessage(Payload payload)
  {
    // enabled?
    if (enabled == false) return;

    // increment the number of messages received
    _received.set(received + 1);

    // set last topic bindable
    _topic.set(payload.topic);

    // set last message bindable
    _message.set(payload.message);

    // deserialize the data
    Data data = Data.from(payload.message, root: root);

    // if the message didn't deserialize (length 0)
    // so create a simple map with topic and message bindables <id>.data.topic and <id>.data.message
    // otherwise the data is the deserialized message payload
    if (data.isEmpty) data.insert(0, {'topic': payload.topic , 'message' : payload.message});

    // fire the onresponse
    onSuccess(data, code: HttpStatus.ok, onSuccessOverride: _onmessage);
  }

  @override
  onConnected() async
  {
    for (var topic in subscriptions) await mqtt?.subscribe(topic);
    if (!S.isNullOrEmpty(onconnected))
    {
      EventHandler handler = EventHandler(this);
      await handler.execute(_onconnected);
    }
  }

  @override
  onDisconnected(String origin) async
  {
    if (!S.isNullOrEmpty(ondisconnected))
    {
      EventHandler handler = EventHandler(this);
      await handler.execute(_ondisconnected);
    }
    onData(data ?? Data(), code: HttpStatus.ok, message: "Disconnected by $origin");
  }

  @override
  onPublished(String topic, String message) async
  {
    if (!S.isNullOrEmpty(onpublished))
    {
      EventHandler handler = EventHandler(this);
      await handler.execute(_onpublished);
    }
  }

  @override
  onSubscribed(String topic) async
  {
    if (!S.isNullOrEmpty(onsubscribed))
    {
      EventHandler handler = EventHandler(this);
      await handler.execute(_onsubscribed);
    }
  }

  @override
  onUnsubscribed(String topic) async
  {
    if (!S.isNullOrEmpty(onunsubscribed))
    {
      EventHandler handler = EventHandler(this);
      await handler.execute(_onunsubscribed);
    }
  }

  @override
  onError(String error) async
  {
    if (!S.isNullOrEmpty(onerror))
    {
      EventHandler handler = EventHandler(this);
      await handler.execute(_onerror);
    }
  }
}
