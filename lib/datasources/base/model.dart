// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/datasources/iDataSourceListener.dart';
import 'package:fml/hive/data.dart' as HIVE;
import 'package:fml/datasources/transforms/transform_model.dart' as TRANSFORM;
import 'package:fml/datasources/data/model.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/event/handler.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';

enum ListTypes { replace, lifo, fifo, append, prepend }

class DataSourceModel extends DecoratedWidgetModel implements IDataSource {
  // data override
  Data? get data {
    if (super.data == null) return null;
    if (super.data is Data)
      return super.data;
    else
      return Data(data: super.data);
  }

  // indicates if the broker has been started after the view has loaded
  bool? initialized = false;

  // framework is being disposed
  bool get disposed => (framework?.disposed == true);

  // hold list of model listeners
  final List<IDataSourceListener> listeners = [];

  // autoquery timer
  Timer? timer;
  onTimer(dynamic t)
  {
    if (!disposed && enabled) start();
  }

  // enabled
  BooleanObservable? _enabled;
  set enabled(dynamic v) {
    if (_enabled != null) {
      _enabled!.set(v);
    } else if (v != null) {
      _enabled = BooleanObservable(Binding.toKey(id, 'enabled'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get enabled => _enabled?.get() ?? true;

  // type
  StringObservable? _type;
  set type(dynamic v) {
    if ((v != null) && (v is String)) v = v.toLowerCase();
    if (_type != null) {
      _type!.set(v);
    } else if (v != null) {
      _type = StringObservable(Binding.toKey(id, 'type'), v, scope: scope);
    }
  }
  String get type => _type?.get() ?? 'replace';

  // max record to retain
  IntegerObservable? _maxrecords;
  set maxrecords(dynamic v) {
    if (_maxrecords != null) {
      _maxrecords!.set(v);
    } else if (v != null) {
      _maxrecords = IntegerObservable(Binding.toKey(id, 'maxrecords'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  int? get maxrecords => _maxrecords?.get();

  // on success event
  StringObservable? get onSuccessObservable => _onsuccess;
  StringObservable? _onsuccess;
  set onsuccess(dynamic v) {
    if (_onsuccess != null) {
      _onsuccess!.set(v);
    } else if (v != null) {
      _onsuccess = StringObservable(Binding.toKey(id, 'onsuccess'), v,
          scope: scope, lazyEval: true);
    }
  }
  String? get onsuccess => _onsuccess?.get();

  // on fail event
  StringObservable? get onFail => _onfail;
  StringObservable? _onfail;
  set onfail(dynamic v) {
    if (_onfail != null) {
      _onfail!.set(v);
    } else if (v != null) {
      _onfail = StringObservable(Binding.toKey(id, 'onfail'), v,
          scope: scope, lazyEval: true);
    }
  }

  String? get onfail => _onfail?.get();

  // time to idle - clears status message field
  IntegerObservable? _timetoidle;
  set timetoidle(dynamic v) {
    if (_timetoidle != null) {
      _timetoidle!.set(v);
    } else if (v != null) {
      _timetoidle = IntegerObservable(Binding.toKey(id, 'timetoidle'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  int get timetoidle => _timetoidle?.get() ?? 5;

  // status
  Timer? t;
  StringObservable? _status;
  set status(dynamic v) {
    if (_status != null) {
      _status!.set(v);
    } else if (v != null) {
      _status = StringObservable(Binding.toKey(id, 'status'), v, scope: scope);
    }
    if (((v == "success") || (v == "error")) && (timetoidle > 0))
      t = Timer(Duration(seconds: timetoidle), () => status = "idle");
  }
  String? get status => _status?.get();

  // status code
  StringObservable? _statuscode;
  set statuscode(dynamic v) {
    if (_statuscode != null) {
      _statuscode!.set(v);
    } else if (v != null) {
      _statuscode =
          StringObservable(Binding.toKey(id, 'statuscode'), v, scope: scope);
    }
  }
  String? get statuscode => _statuscode?.get();

  // status message
  StringObservable? _statusmessage;
  set statusmessage(dynamic v) {
    if (_statusmessage != null) {
      _statusmessage!.set(v);
    } else if (v != null) {
      _statusmessage =
          StringObservable(Binding.toKey(id, 'statusmessage'), v, scope: scope);
    }
  }
  String? get statusmessage => _statusmessage?.get();

  // Time to Live in Seconds
  int? _timetolive;

  set timetolive(dynamic ttl) {
    _timetolive = 0;
    if (ttl == null) return;
    ttl = ttl.trim().toLowerCase();

    int factor = 1;
    if (ttl.endsWith('s')) factor = 1000;
    if (ttl.endsWith('m')) factor = 1000 * 60;
    if (ttl.endsWith('h')) factor = 1000 * 60 * 60;
    if (ttl.endsWith('d')) factor = 1000 * 60 * 60 * 24;
    if (factor > 1) ttl = (ttl.length > 1) ? ttl.substring(0, ttl.length - 1) : null;

    if (S.isNumber(ttl)) {
      int t = S.toInt(ttl)! * factor;
      if (t >= 0) _timetolive = t;
    }
  }
  int get timetolive => S.toInt(_timetolive) ?? 0;

  // autoexecute
  BooleanObservable? _autoexecute;
  set autoexecute(dynamic v) {
    if (_autoexecute != null) {
      _autoexecute!.set(v);
    } else if (v != null) {
      _autoexecute =
          BooleanObservable(Binding.toKey(id, 'autoexecute'), v, scope: scope);
    }
  }

  bool? get autoexecute => _autoexecute?.get();

  // autoquery
  int? _autoquery;
  set autoquery(dynamic autoquery) {
    _autoquery = 0;

    if (autoquery == null) return;
    autoquery = autoquery.trim().toLowerCase();

    int factor = 1;
    if (autoquery.endsWith('s')) factor = 1;
    if (autoquery.endsWith('m')) factor = 1 * 60;
    if (autoquery.endsWith('h')) factor = 1 * 60 * 60;
    if (autoquery.endsWith('d')) factor = 1 * 60 * 60 * 24;
    if (factor > 1)
      autoquery = (autoquery.length > 1)
          ? autoquery.substring(0, autoquery.length - 1)
          : null;

    if (S.isNumber(autoquery)) {
      int t = S.toInt(autoquery)! * factor;
      if (t >= 0) _autoquery = t;
    }
  }
  int? get autoquery => _autoquery;

  // busy
  @override
  set busy(dynamic v) {
    dynamic old = busy;
    super.busy = v;

    if (busy != old)
      listeners.forEach((listener) {
        listener.onDataSourceBusy(this, busy);
      });

    // Set Status
    status = (busy == true) ? "busy" : (status ?? "idle");
  }

  // root
  StringObservable? _root;
  set root(dynamic v) {
    if (_root != null) {
      _root!.set(v);
    } else if (v != null) {
      _root = StringObservable(Binding.toKey(id, 'root'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get root => _root?.get();

  // rowcount
  IntegerObservable? _rowcount;
  set rowcount(dynamic v)
  {
    if (_rowcount != null)
    {
      _rowcount!.set(v);
    }
    else
    {
      _rowcount = IntegerObservable(Binding.toKey(id, 'rowcount'), v ?? 0, scope: scope, listener: onPropertyChange);
    }
  }
  int get rowcount => _rowcount?.get() ?? 0;

  // posting body
  StringObservable? get bodyObservable => _body;
  StringObservable? _body;
  set body(dynamic v)
  {
    if (_body != null)
    {
      _body!.set(v);
    }
    else if (v != null)
    {
      _body = StringObservable(Binding.toKey(id, 'body'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get body => _body?.get();

  bool _custombody = false;
  bool get custombody => _custombody;

  DataSourceModel(WidgetModel parent, String? id) : super(parent, id);

  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    rowcount = 0;

    // properties
    type = Xml.get(node: xml, tag: 'type');
    timetolive = Xml.get(node: xml, tag: 'ttl');
    timetoidle = S.toInt(Xml.get(node: xml, tag: 'tti'));
    autoexecute = Xml.get(node: xml, tag: 'autoexecute');
    autoquery = Xml.get(node: xml, tag: 'autoquery');
    onsuccess = Xml.get(node: xml, tag: 'onsuccess');
    onfail = Xml.get(node: xml, tag: 'onfail');
    statuscode = Xml.get(node: xml, tag: 'statuscode');
    statusmessage = Xml.get(node: xml, tag: 'statusmessage');
    maxrecords = Xml.get(node: xml, tag: 'maxrecords');
    root = Xml.attribute(node: xml, tag: 'root');

    String? value = Xml.get(node: xml, tag: 'value');
    if (!S.isNullOrEmpty(value)) onResponse(Data.from(value, root: root));

    // custom body defined?
    XmlElement? body = Xml.getChildElement(node: xml, tag: 'body');
    if (body != null)
    {
      // set body type
      _custombody = true;

      // body is all text (cdata or text only)?
      bool isText = (body.children.firstWhereOrNull((child) => (child is XmlCDATA || child is XmlText || child is XmlComment) ? false : true) == null);
      if (isText)
           this.body = body.innerText.trim();
      else this.body = body.innerXml.trim();
    }

    // This Line Ensures Future Bodies that Contain Bindables won't Bind
    if (_body == null) this.body = "";

    // register the datasource with the scope manager
    if (scope != null) scope!.registerDataSource(this);

    // disable the datasource when the framework isn't active (i.e. top of stack)
    bool? runInBackground = S.toBool(Xml.get(node: xml, tag: 'background'));
    if ((runInBackground == false) &&
        (framework != null) &&
        (framework!.indexObservable != null))
      framework!.indexObservable!.registerListener(onIndexChange);
  }

  void onIndexChange(Observable index) {
    this.enabled = (S.toInt(index.get()) == 0);
  }

  register(IDataSourceListener listener) {
    if (!listeners.contains(listener)) listeners.add(listener);
  }

  Future<void> notify() async
  {
    // notify listeners
    for (IDataSourceListener listener in listeners) await listener.onDataSourceSuccess(this, data);
  }

  remove(IDataSourceListener listener) {
    if (listeners.contains(listener)) listeners.remove(listener);
  }

  Future<bool> clear({int? start, int? end}) async {
    if ((this.data != null) && (data!.isNotEmpty)) {
      int from = 0;
      int to = data!.length - 1;

      if (start != null) {
        if (start < 0)
          from = data!.length + start;
        else
          from = start;
        if (end == null) to = from;
      }

      if (end != null) {
        if (end >= 0) {
          to = end;
          if (to >= data!.length) to = data!.length - 1;
        } else
          to = data!.length + end;
      }

      if ((from <= to) &&
          (from >= 0) &&
          (from < data!.length) &&
          (to >= 0) &&
          (to < data!.length)) {
        Data data = Data();
        int i = 0;
        this.data!.forEach((row) {
          if ((i < from) || (i > to)) data.add(row);
          i++;
        });
        this.data = data;
      }
    }
    return true;
  }

  Future<bool> onResponse(Data data, {int? code, String? message}) async
  {
    // set busy
    busy = true;

    // max records
    int maxrecords = this.maxrecords ?? 10000;
    if (maxrecords < 0) maxrecords = 0;

    // apply data transforms
    if (children != null)
      for (WidgetModel model in this.children!)
        if (model is TRANSFORM.IDataTransform) await (model as TRANSFORM.IDataTransform).apply(data);

    // type - default is replace
    ListTypes? type = S.toEnum(this.type, ListTypes.values);

    // Fifo - Oldest -> Newest
    if (type == ListTypes.fifo) {
      Data temp = Data();
      if (this.data != null) this.data!.forEach((element) => temp.add(element));
      data.forEach((element) => temp.add(element));
      if (temp.length > maxrecords)
        temp.removeRange(0, temp.length - maxrecords);
      data = temp;
    }

    // Lifo - Newest > Oldest
    if (type == ListTypes.lifo) {
      Data temp = Data();
      data.forEach((element) => temp.add(element));
      if (this.data != null) this.data!.forEach((element) => temp.add(element));
      if (temp.length > maxrecords)
        temp.removeRange(temp.length - maxrecords - 1, temp.length);
      data = temp;
    }

    // Append
    if (type == ListTypes.append) {
      Data temp = Data();
      if (this.data != null) this.data!.forEach((element) => temp.add(element));
      data.forEach((element) => temp.add(element));
      data = temp;
    }

    // Prepend
    if (type == ListTypes.prepend) {
      Data temp = Data();
      data.forEach((element) => temp.add(element));
      if (this.data != null) this.data!.forEach((element) => temp.add(element));
      data = temp;
    }

    // Truncate List
    if (data.length > maxrecords) data.removeRange(maxrecords, data.length);

    // Return Success
    return await onSuccess(data, code, message);
  }

  Future<bool> onSuccess(Data data, int? code, String? message) async
  {
    bool ok = true;

    // set status
    status = "success";

    // set status code
    this.statuscode = code;

    // set status message
    statusmessage = message ?? 'Ok';

    // Set the source value
    this.data = data;

    // set rowcount
    rowcount = this.data?.length ?? 0;

    // notify listeners
    notify();

    // fire on success event
    if (onsuccess != null)
    {
      EventHandler handler = EventHandler(this);
      await handler.execute(_onsuccess);
    }

    // notify nested data sources
    if (datasources != null)
      for (IDataSource model in this.datasources!)
        if (model is DataModel) model.onResponse(data.clone());

    // requery?
    if (((autoquery ?? 0) > 0) && (timer == null) && (!disposed)) timer = Timer.periodic(Duration(seconds: autoquery!), onTimer);

    // busy
    busy = false;

    return ok;
  }

  Future<bool> onException(Data data, {int? code, String? message}) async
  {
    // set data
    this.data = data;

    // set rowcount
    rowcount = this.data?.length ?? 0;

    // set status
    status = "error";

    // set status code
    this.statuscode = code;

    // set status message
    //statusmessage = (data == null) ? (message ?? '') : '';
    statusmessage = message ?? 'Error: $code';

    // log exception
    Log().exception("$statusmessage [$statuscode] id: $id, object: 'DataBroker'");

    // on fail event
    if (!S.isNullOrEmpty(onfail))
    {
      EventHandler handler = EventHandler(this);
      await handler.execute(_onfail);
    }

    // notify listeners
    for (IDataSourceListener listener in listeners) listener.onDataSourceException(this, Exception(statusmessage));

    // busy
    busy = false;

    return false;
  }

  Future<String?> fromHive(String? key, bool refresh) async {
    // get data from cache
    if ((timetolive > 0) && (!refresh)) {
      // found cached data?
      HIVE.Data? row = await HIVE.Data.find(key!);

      // expired?
      bool expired = true;
      if ((row?.expires ?? 0) >= DateTime.now().millisecondsSinceEpoch)
        expired = false;

      // Return Cached Data
      if (!expired) return row!.value;
    }
    return null;
  }

  Future toHive(String? key, String? data) async {
    if (timetolive > 0)
    {
      HIVE.Data table = HIVE.Data(
          key: key,
          value: data,
          expires: DateTime.now().millisecondsSinceEpoch + timetolive);
      await table.insert();
    }
  }

  // override this function
  Future<bool> start({bool refresh: false, String? key}) async {
    return true;
  }

  // override this function
  Future<bool> stop() async {
    return true;
  }

  @override
  Future<bool?> execute(String propertyOrFunction, List<dynamic> arguments) async
  {
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();
    switch (function)
    {
      // clear the list
      case "clear":
        int? start = S.toInt(S.item(arguments, 0)) ?? null;
        int? end = S.toInt(S.item(arguments, 1)) ?? null;
        return await clear(start: start, end: end);

      // add to the list
      case "add":
        String? jsonOrXml  = S.toStr(S.item(arguments, 0)) ?? null;
        int index = S.toInt(S.item(arguments, 1)) ?? (this.data != null ? this.data!.length : 0);
        if (jsonOrXml != null)
        {
          Data? d = Data.from(jsonOrXml);
          if (data != null)
          {
            if (index > d.length) index = d.length;
            if (index < 0) index = 0;
            d.forEach((element) => data!.insert(index++, element));
          }
          else data = Data.from(d);

          // notify listeners of data change
          notify();
        }
        return true;

      // remove from the list
      case "remove":
        int index = S.toInt(S.item(arguments, 1)) ?? (this.data != null ? this.data!.length : 0);
        if (this.data != null)
        {
          if (index >= this.data!.length) index = this.data!.length - 1;
          if (index < 0) index = 0;
          this.data!.removeAt(index);
          notify();
        }
        return true;

      // reverse the list
      case "reverse":
        if (this.data != null)
        {
          this.data = this.data!.reversed;
          notify();
        }
        return true;
    }
    return super.execute(propertyOrFunction, arguments);
  }

  @override
  void dispose() {
    if (timer != null) timer!.cancel();
    if ((scope != null) && (scope != System().scope))
      scope!.removeDataSource(this);
    if ((framework != null) && (framework!.indexObservable != null))
      framework!.indexObservable!.removeListener(onIndexChange);
    super.dispose();
  }
}
