// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
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
import 'package:fml/helper/helper_barrel.dart';

class MqttModel extends DataSourceModel implements IDataSource, IMqttListener
{
  IMqtt? mqtt;

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
  
  // subscriptions
  List<String> subscriptions = [];

  MqttModel(WidgetModel parent, String? id) : super(parent, id);

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
      Log().exception(e,  caller: 'iframe.Model');
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
    
    // subscriptions
    var subscriptions = Xml.get(node: xml, tag: 'subscriptions')?.split(",");
    subscriptions?.forEach((subscription)
    {
      if (!S.isNullOrEmpty(subscription) && !this.subscriptions.contains(subscription.trim())) this.subscriptions.add(subscription.trim());
    });
  }

  @override
  Future<bool> start({bool refresh: false, String? key}) async
  {
    bool ok = true;
    if (mqtt == null && url != null) mqtt = IMqtt.create(url!, this);
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
  Future<bool?> execute(String propertyOrFunction, List<dynamic> arguments) async
  {
    var function = propertyOrFunction.toLowerCase().trim();
    switch (function)
    {
      case "write":
      case "post":
      case "publish":
        String? topic   = S.toStr(S.item(arguments, 0));
        String? message = (function == "post") ? body : S.toStr(S.item(arguments, 1));
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
    return super.execute(propertyOrFunction, arguments);
  }

  onMessage(Payload payload)
  {
    // enabled?
    if (enabled == false) return;

    busy = false;
    if (payload != null)
    {
      Data data = Data.from(payload.message);
      if (data.length == 0) data.insert(0, {'topic': payload.topic , 'message' : payload.message});
      onResponse(data, code: 200);
    }
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
  onDisconnected() async
  {
    if (!S.isNullOrEmpty(ondisconnected))
    {
      EventHandler handler = EventHandler(this);
      await handler.execute(_ondisconnected);
    }
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
