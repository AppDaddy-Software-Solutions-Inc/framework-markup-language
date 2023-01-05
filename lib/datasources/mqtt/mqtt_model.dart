// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/iDataSource.dart';
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
  }

  @override
  Future<bool> start({bool refresh: false, String? key}) async
  {
    bool ok = true;
    if (mqtt == null && url != null) mqtt = IMqtt.create(url!, this);
    if (mqtt != null)
         ok = await mqtt!.connect();
    else ok = false;
    connected = ok;
    return ok;
  }

  Future<bool> stop() async
  {
    mqtt?.disconnect();
    super.stop();
    connected = false;
    return true;
  }

  onMqttData({Payload? payload})
  {
    // enabled?
    if (enabled == false) return;

    busy = false;
    if (payload != null)
    {
      Map<dynamic, dynamic> map = Map<dynamic, dynamic>();
      XmlDocument? document = Xml.tryParse(payload.payload, silent: true);
      if (document != null) map = Xml.toMap(node: document.rootElement);

      map['topic'] = payload.topic;
      map['body']  = payload.payload;

      Data data = Data();
      data.add(map);
      onResponse(data, code: 200);
    }
  }

  @override
  Future<bool?> execute(String propertyOrFunction, List<dynamic> arguments) async
  {
    var function = propertyOrFunction.toLowerCase().trim();
    switch (function)
    {
      case "publish":
        String? topic = S.toStr(S.item(arguments, 0));
        String? message = S.toStr(S.item(arguments, 1));
        if (mqtt != null && topic != null && message != null) mqtt!.publish(topic, message);
        return true;

      case "subscribe":
        String? topic = S.toStr(S.item(arguments, 0));
        if (mqtt != null && topic != null) mqtt!.subscribe(topic);
        return true;

      case "connect":
        return await start();

      case "disconnect":
        return await stop();
    }
    return super.execute(propertyOrFunction, arguments);
  }
}
