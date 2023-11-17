// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/sse/lib/src/channel.dart';
import 'package:fml/datasources/http/model.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class SseModel extends HttpModel implements IDataSource
{
  late final SseChannel channel;

  String? events;

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
  
  SseModel(WidgetModel parent, String? id) : super(parent, id)
  {
    connected = false;
  }

  static SseModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    SseModel? model;
    try
    {
      model = SseModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'SseModel');
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
    events = Xml.get(node: xml, tag: 'events');
  }

  @override
  void dispose()
  {
    stop();
    super.dispose();
  }

  @override
  Future<bool> start({bool refresh = false, String? key}) async
  {
    bool ok = true;
    busy = true;

    try
    {
      var uri = URI.parse(url!);
      connected = false;
      if (uri != null) {
        channel = SseChannel.connect(uri,
            headers: headers,
            body: body,
            method: method,
            events: events?.split(","));
        channel.stream.listen(_onData, onError: _onError, onDone: _onDone);
        connected = true;
      }
    }
    catch(e)
    {
      connected = false;
      Log().error('Error Connecting to $url. Error is $e',  caller: 'SseModel');
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
    Log().debug('Received message >> $msg', caller: 'SseModel');
    Data data = Data.from(msg, root: root);
    onSuccess(data);
  }

  _onError(var msg)
  {
    Log().debug('Error is $msg', caller: 'SseModel');
    Data data = Data.from(msg);
    onFail(data);
  }

  _onDone()
  {
    Log().debug('Done', caller: 'SseModel');
    connected = false;
  }

  @override
  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async
  {
    /// setter
    if (scope == null) return null;
    String function = propertyOrFunction.toLowerCase().trim();

    bool refresh = toBool(elementAt(arguments,0)) ?? false;
    switch (function)
    {
      case "start" : return await start(refresh: refresh);
      case "stop"  : return await stop();
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }
}
