// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/helper/uri.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/datasources/base/model.dart';
import 'package:fml/event/handler.dart' ;
import 'package:xml/xml.dart';
import 'payload.dart';
import 'iNfcListener.dart';
import 'nfc.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';

enum METHODS {read, write}

class NcfModel extends DataSourceModel implements IDataSource, INfcListener
{
  @override
  bool get autoexecute => super.autoexecute ?? true;

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

  NcfModel(WidgetModel parent, String? id) : super(parent, id);

  static NcfModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    NcfModel? model;
    try
    {
      model = NcfModel(parent, Xml.get(node: xml, tag: 'id'));
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
    Reader().removeListener(this);
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
      case "fire" : return await start(refresh: refresh);
      case "stop" : return await stop();
    }
    return super.execute(propertyOrFunction, arguments);
  }

  Future<bool> start({bool refresh: false, String? key}) async
  {
    bool ok = true;

    if (!isMobile)
    {
      System.toast("NFC is only available on mobile devices");
      return ok;
    }

    METHODS method = S.toEnum(this.method, METHODS.values) ?? METHODS.read;
    switch (method)
    {
      case METHODS.read:
        Reader().registerListener(this);
        break;

      case METHODS.write:
        if (!S.isNullOrEmpty(body))
        {
          Log().debug('NFC WRITE: Polling for 60 seconds');
          String stripTags = body!.replaceAll('\r', '').replaceAll('\t', '').replaceAll('\n', '');
          stripTags = stripTags.replaceAll(RegExp("\<[^\>]*\>", caseSensitive: false), '');
          Writer writer = Writer(stripTags, callback: onResult);
          writer.write();
        }
        break;
    }

    return true;
  }

  Future<bool> stop() async
  {
    Reader().removeListener(this);
    super.stop();
    return true;
  }

  onResult(bool b)
  {
    // success
    if (b && onsuccess != null) EventHandler(this).execute(onSuccessObservable);

    // fail
    if (!b && onfail != null) EventHandler(this).execute(onFail);
  }

  onNfcData({Payload? payload})
  {
    // enabled?
    if (enabled == false) return;

    busy = false;
    if ((payload == null) || (S.isNullOrEmpty(payload.serial))) return;

    // build the data
    Data data = Data();
    Map<String, dynamic> map = Map<String, dynamic>();
    data.add(map);

    // add payload url parameters
    Uri? uri = URI.parse('http://localhost' + '?' + payload.payload.toString());
    if (uri != null && uri.hasQuery)
    {
      Map<String, String> parameters = Map<String, String>();
      uri.queryParameters.forEach((k, v) => parameters[k] = v);
      map["payload"] = parameters;
    }

    // add generic parameters
    map["serial"]  = payload.serial;
    map["id"]      = payload.serial;
    map["value"]   = payload.payload!.substring(payload.payload!.indexOf('text=')+5);

    // notify
    onResponse(data, code: 200);
  }
}
