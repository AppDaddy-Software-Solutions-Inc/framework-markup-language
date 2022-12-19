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

enum Methods {read, write}

class MqttModel extends DataSourceModel implements IDataSource, IMqttListener
{
  IMqtt? mqtt;

  // method
  StringObservable? _method;
  set method(dynamic v)
  {
    if (_method != null)
    {
      _method!.set(v);
    }
    else if (v != null)
    {
      _method = StringObservable(Binding.toKey(id, 'method'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get method => _method?.get();

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
    mqtt?.removeListener(this);
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
    method = Xml.get(node: xml, tag: 'method');
    url    = Xml.get(node: xml, tag: 'url');
  }

  Future<bool> start({bool refresh: false, String? key}) async
  {
    bool ok = true;

    if (mqtt == null) mqtt = IMqtt.create(url);
    if (mqtt != null)
    {
      mqtt!.registerListener(this);

      Methods method = S.toEnum(this.method, Methods.values) ?? Methods.read;
      if (method == Methods.write)
      {
          // replace file references
          String? body = await scope?.replaceFileReferences(this.body);

          // publish the message
          ok = await mqtt!.publish(msg: body);

          // process response
          ok = await onResponse(Data(), code: ok ? 200 : 500);
      }
    }
    else ok = false;
    return ok;
  }

  Future<bool> stop() async
  {
    if (mqtt != null) mqtt!.removeListener(this);
    super.stop();
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
      map['body'] = payload.payload;

      Data data = Data();
      data.add(map);
      onResponse(data, code: 200);
    }
  }
}
