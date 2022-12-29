// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/eventsource/lib/src/channel.dart';
import 'package:fml/datasources/http/model.dart';
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:xml/xml.dart';
import 'package:fml/helper/helper_barrel.dart';

class EventSourceModel extends HttpModel implements IDataSource
{
  late final SseChannel channel;

  String? messageTypes;

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
  
  EventSourceModel(WidgetModel parent, String? id) : super(parent, id)
  {
    connected = false;
  }

  static EventSourceModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    EventSourceModel? model;
    try
    {
      model = EventSourceModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'EventSourceModel');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    // properties
    messageTypes = Xml.get(node: xml, tag: 'messagetypes');
  }

  @override
  void dispose()
  {
    stop();
    super.dispose();
  }

  @override
  Future<bool> start({bool refresh: false, String? key}) async
  {
    bool ok = true;
    busy = true;

    try
    {
      connected = false;
      channel = SseChannel.connect(Uri.parse(url!), headers: headers, body: body, method: method, messageTypes: messageTypes?.split(","));
      channel.stream.listen(_onData, onError: _onError, onDone: _onDone);
      connected = true;
    }
    catch(e)
    {
      connected = false;
      Log().error('Error Connecting to $url. Error is $e',  caller: 'EventSourceModel');
    }

    busy = false;
    return ok;
  }

  @override
  Future<bool> stop() async
  {
    bool ok = true;
    try
    {
      channel.close();
    }
    catch(e)
    {
      ok = false;
    }
    super.stop();
    return ok;
  }

  void _onData(var msg)
  {
    Log().debug('Received message >> $msg', caller: 'EventSourceModel');
    Data data = Data.from(msg);
    onResponse(data);
  }

  _onError(var msg)
  {
    Log().debug('Error is $msg', caller: 'EventSourceModel');
    Data data = Data.from(msg);
    onException(data);
  }

  _onDone()
  {
    Log().debug('Done', caller: 'EventSourceModel');
    connected = false;
  }

  @override
  Future<bool?> execute(String propertyOrFunction, List<dynamic> arguments) async
  {
    /// setter
    if (scope == null) return null;
    String function = propertyOrFunction.toLowerCase().trim();

    bool refresh = S.toBool(S.item(arguments,0)) ?? false;
    switch (function)
    {
      case "start" : return await start(refresh: refresh);
      case "stop"  : return await stop();
    }
    return super.execute(propertyOrFunction, arguments);
  }
}
