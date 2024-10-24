// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/data/dotnotation.dart';
import 'package:universal_html/html.dart';
import 'package:collection/collection.dart';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/datasources/datasource_listener_interface.dart';
import 'package:fml/datasources/transforms/transform_interface.dart';
import 'package:fml/hive/data.dart' as hive;
import 'package:fml/datasources/data/model.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/event/handler.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

enum ListTypes { replace, lifo, fifo, append, prepend }

class DataSourceModel extends Model implements IDataSource {
  // data override
  @override
  Data? get data {
    if (super.data == null) return null;
    if (super.data is Data) {
      return super.data;
    } else {
      return Data(data: super.data);
    }
  }

  // indicates if the broker has been started after the view has loaded
  @override
  bool initialized = false;

  // framework is being disposed
  bool get disposed => (framework?.disposed == true);

  // hold list of model listeners
  final List<IDataSourceListener> listeners = [];

  // autoquery timer
  Timer? timer;
  onTimer(dynamic t) {
    if (!disposed && enabled) start();
  }

  // disable datasource by default when not top of stack
  // override by setting background="false"
  bool enabledInBackground = true;

  // position in stack
  bool isInBackground = false;

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

  bool get enabled {
    if (!enabledInBackground && isInBackground) return false;
    return _enabled?.get() ?? true;
  }

  // queue
  StringObservable? _queuetype;
  set queuetype(dynamic v) {
    if ((v != null) && (v is String)) v = v.toLowerCase();
    if (_queuetype != null) {
      _queuetype!.set(v);
    } else if (v != null) {
      _queuetype =
          StringObservable(Binding.toKey(id, 'queuetype'), v, scope: scope);
    }
  }

  String get queuetype => _queuetype?.get() ?? 'replace';

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
          scope: scope, lazyEvaluation: true);
    }
  }

  String? get onsuccess => _onsuccess?.get();

  StringObservable? get onWriteSuccessObservable => _onwritesuccess;
  StringObservable? _onwritesuccess;
  set onwritesuccess(dynamic v) {
    if (_onwritesuccess != null) {
      _onwritesuccess!.set(v);
    } else if (v != null) {
      _onwritesuccess = StringObservable(Binding.toKey(id, 'onwritesuccess'), v,
          scope: scope, lazyEvaluation: true);
    }
  }

  String? get onwritesuccess => _onwritesuccess?.get();

  StringObservable? get onReadSuccessObservable => _onreadsuccess;
  StringObservable? _onreadsuccess;
  set onreadsuccess(dynamic v) {
    if (_onreadsuccess != null) {
      _onreadsuccess!.set(v);
    } else if (v != null) {
      _onreadsuccess = StringObservable(Binding.toKey(id, 'onreadsuccess'), v,
          scope: scope, lazyEvaluation: true);
    }
  }
  String? get onreadsuccess => _onreadsuccess?.get();

  // on fail event
  StringObservable? get onFailObservable => _onfail;
  StringObservable? _onfail;
  set onfail(dynamic v) {
    if (_onfail != null) {
      _onfail!.set(v);
    } else if (v != null) {
      _onfail = StringObservable(Binding.toKey(id, 'onfail'), v,
          scope: scope, lazyEvaluation: true);
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
  Timer? _statusTimer;
  StringObservable? _status;
  set status(dynamic v) {
    if (_status != null) {
      _status!.set(v);
    } else if (v != null) {
      _status = StringObservable(Binding.toKey(id, 'status'), v, scope: scope);
    }
    if ((v == "success" || v == "error") && timetoidle > 0) {
      _statusTimer =
          Timer(Duration(seconds: timetoidle), () => status = "idle");
    }
  }

  String? get status => _status?.get();

  // status code
  IntegerObservable? _statuscode;
  set statuscode(dynamic v) {
    if (_statuscode != null) {
      _statuscode!.set(v);
    } else if (v != null) {
      _statuscode =
          IntegerObservable(Binding.toKey(id, 'statuscode'), v, scope: scope);
    }
  }

  int? get statuscode => _statuscode?.get();

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

    int factor = 1;
    if (ttl is String) {
      ttl = ttl.trim().toLowerCase();
      if (ttl.endsWith('s')) factor = 1000;
      if (ttl.endsWith('m')) factor = 1000 * 60;
      if (ttl.endsWith('h')) factor = 1000 * 60 * 60;
      if (ttl.endsWith('d')) factor = 1000 * 60 * 60 * 24;
      if (factor > 1) {
        ttl = (ttl.length > 1) ? ttl.substring(0, ttl.length - 1) : null;
      }
    }

    if (isNumeric(ttl)) {
      int t = toInt(ttl)! * factor;
      if (t >= 0) _timetolive = t;
    }
  }

  int get timetolive => toInt(_timetolive) ?? 0;

  // autoexecute
  BooleanObservable? _autoexecute;
  @override
  set autoexecute(dynamic v) {
    if (_autoexecute != null) {
      _autoexecute!.set(v);
    } else if (v != null) {
      _autoexecute =
          BooleanObservable(Binding.toKey(id, 'autoexecute'), v, scope: scope);
    }
  }

  @override
  bool? get autoexecute => _autoexecute?.get();

  // autoquery
  int? _autoquery;
  set autoquery(dynamic autoquery) {
    _autoquery = 0;
    if (autoquery == null) return;

    int factor = 1;
    if (autoquery is String) {
      autoquery = autoquery.trim().toLowerCase();
      if (autoquery.endsWith('s')) {
        factor = 1;
      } else if (autoquery.endsWith('m')) {
        factor = 1 * 60;
      } else if (autoquery.endsWith('h')) {
        factor = 1 * 60 * 60;
      } else if (autoquery.endsWith('d')) {
        factor = 1 * 60 * 60 * 24;
      }
      if (autoquery.endsWith('s') ||
          autoquery.endsWith('m') ||
          autoquery.endsWith('h') ||
          autoquery.endsWith('d')) {
        autoquery = (autoquery.length > 1)
            ? autoquery.substring(0, autoquery.length - 1)
            : null;
      }
    }

    if (isNumeric(autoquery)) {
      int t = toInt(autoquery)! * factor;
      if (t >= 0) _autoquery = t;
    }
  }

  int? get autoquery => _autoquery;

  @override
  set busy(dynamic v) {
    bool oldBusy = busy;
    super.busy = v;
    if (busy != oldBusy) {
      for (var listener in listeners) {
        listener.onDataSourceBusy(this, busy);
      }
    }

    // Set Status
    if (busy) {
      status = "busy";
    } else if (_statusTimer == null) {
      status = "idle";
    }
  }

  // value
  ListObservable? _value;
  set value(dynamic v) {
    if (_value != null) {
      _value!.set(v);
    } else {
      if (v != null) {
        _value = ListObservable(Binding.toKey(id, 'value'), v,
            scope: scope, setter: _valueSetter);

        // the setter will have already fired if the value (v) is an eval
        // or contains bindings, so no need to fire it again.
        if ((_value?.bindings?.isEmpty ?? true) || !(_value?.isEval ?? false)) {
          _value!.set(v);
        }
      }
    }
  }

  // stores a serialized copy of the first item
  String? template;

  dynamic _valueSetter(dynamic jsonOrXml,
      {Observable? setter, DotNotation? dotnotation}) {
    var data = Data.from(jsonOrXml, root: root);

    if (jsonOrXml != null && jsonOrXml is! String) {
      // clone the data so the datasource does not manipulate its inherited widgets data in the original source.
      data = data.clone();
    }
    onSuccess(data, code: HttpStatus.ok);
    return data;
  }

  // root
  StringObservable? _root;
  @override
  set root(dynamic v) {
    if (_root != null) {
      _root!.set(v);
    } else if (v != null) {
      _root = StringObservable(Binding.toKey(id, 'root'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  @override
  String? get root => _root?.get();

  // rowcount
  // indicates the number of rows in the
  // data set
  IntegerObservable? _rowcount;
  set rowcount(dynamic v) {
    if (_rowcount != null) {
      _rowcount!.set(v);
    } else {
      _rowcount = IntegerObservable(Binding.toKey(id, 'rowcount'), v ?? 0,
          scope: scope, listener: onPropertyChange);
    }
  }

  int get rowcount => _rowcount?.get() ?? 0;

  // posting body
  @override
  StringObservable? get bodyObservable => _body;
  StringObservable? _body;
  @override
  set body(dynamic v) {
    if (_body != null) {
      _body!.set(v);
    } else if (v != null) {
      var formatter = _bodyType != null ? _encodeBody : null;
      _body = StringObservable(Binding.toKey(id, 'body'), v,
          scope: scope, listener: onPropertyChange, formatter: formatter);
    }
  }

  @override
  String? get body => _body?.get();

  bool _bodyIsCustom = false;
  @override
  bool get custombody => _bodyIsCustom;

  // body type
  String? _bodyType;

  DataSourceModel(Model super.parent, super.id);

  @override
  void deserialize(XmlElement xml) {
    // extract body

    // deserialize
    super.deserialize(xml);

    rowcount = 0;

    // properties
    queuetype = Xml.get(node: xml, tag: 'queuetype');
    timetolive = Xml.get(node: xml, tag: 'ttl');
    timetoidle = toInt(Xml.get(node: xml, tag: 'tti'));
    autoexecute = Xml.get(node: xml, tag: 'autoexecute');
    autoquery = Xml.get(node: xml, tag: 'autoquery');
    onsuccess = Xml.get(node: xml, tag: 'onsuccess');
    onreadsuccess = Xml.get(node: xml, tag: 'onreadsuccess');
    onwritesuccess = Xml.get(node: xml, tag: 'onwritesuccess');
    onfail = Xml.get(node: xml, tag: 'onfail');
    statuscode = Xml.get(node: xml, tag: 'statuscode');
    statusmessage = Xml.get(node: xml, tag: 'statusmessage');
    maxrecords = Xml.get(node: xml, tag: 'maxrecords');
    root = Xml.attribute(node: xml, tag: 'root');
    value = Xml.get(node: xml, tag: 'value');
    template = Xml.get(node: xml, tag: 'template');
    enabled = Xml.get(node: xml, tag: 'enabled');

    // set the body
    body = _getBody(xml);
    if (body != null) {
      // set body as custom
      _bodyIsCustom = true;

      // set the data
      data = Data.from(body, root: root);
    }
    // ensure future bodies that contain bindables don't bind
    if (_body == null) body = "";

    // register the datasource with the scope manager
    if (scope != null) scope!.registerDataSource(this);

    // disable in background
    enabledInBackground =
        toBool(Xml.get(node: xml, tag: 'background')) ?? enabledInBackground;
    if (!enabledInBackground) {
      framework?.indexObservable?.registerListener(onIndexChange);
    }
  }

  String? _getBody(XmlElement xml) {
    // custom body defined?
    XmlElement? body = Xml.getChildElement(node: xml, tag: 'BODY');
    if (body != null) {
      // set body type (format)
      _bodyType = Xml.attribute(node: body, tag: 'type')?.trim().toLowerCase();

      // body is all text (cdata or text only)?
      bool isText = (body.children.firstWhereOrNull((child) =>
              (child is XmlCDATA || child is XmlText || child is XmlComment)
                  ? false
                  : true) ==
          null);

      return isText ? body.innerText.trim() : body.innerXml.trim();
    }

    // no child nodes?
    if (xml.children.isEmpty) return null;

    // no model children?
    if (children != null && children!.isNotEmpty) return null;

    // more than 1 non-textual element?
    if (xml.childElements.length > 1) return null;

    // legacy - <value/> tag specified
    if (xml.childElements.length == 1 && xml.childElements.first.localName == 'value') {
      return null;
    }

    // single non-textual element
    //if (xml.childElements.length == 1) {
    //  return xml.childElements.first.toXmlString();
    //}

    // find cdata node
    var cdata = xml.children.firstWhereOrNull((child) => child is XmlCDATA);
    if (data != null) return cdata!.value?.trim();

    // no body
    return null;
  }

  void onIndexChange(Observable index) {
    isInBackground = (toInt(index.get()) != 0);
  }

  @override
  register(IDataSourceListener listener) {
    if (!listeners.contains(listener)) listeners.add(listener);
  }

  @override
  Future<void> notify() async {
    // notify listeners
    var list = listeners.toList();
    for (IDataSourceListener listener in list) {
      await listener.onDataSourceSuccess(this, data);
    }
  }

  @override
  remove(IDataSourceListener listener) {
    if (listeners.contains(listener)) listeners.remove(listener);
  }

  /// finds the element in data either by object or by index
  dynamic getElement(dynamic element) {
    if (data == null) return null;

    // by object
    if (data!.contains(element)) {
      return element;
    }

    // by index
    if (isNumeric(element)) {
      var index = toInt(element) ?? -1;
      return (!index.isNegative && index < data!.length) ? data![index] : null;
    }

    // by first item in a list
    if (element is List &&
        element.isNotEmpty &&
        element.length == 1 &&
        data!.contains(element.first)) {
      return element.first;
    }

    return null;
  }

  Future<bool> copy(dynamic from, dynamic to) async {
    var fromElement = getElement(from);
    if (fromElement == null) return false;

    // get json
    var json = Json.encode(Json.copy(fromElement, withValues: true));

    // get index
    int? index = isNumeric(to) ? toInt(to) : null;

    // before specific object?
    if (index == null) {
      var toElement = getElement(to);
      if (toElement != null) index = data?.indexOf(toElement);
    }

    // insert the values
    return await insert(json, index);
  }

  @override
  Future<bool> clear({int? start, int? end}) async {
    if (data != null && data!.isNotEmpty) {
      int from = 0;
      int to = data!.length - 1;

      if (start != null) {
        if (start.isNegative) {
          from = data!.length + start;
        } else {
          from = start;
        }
        if (end == null) to = from;
      }

      if (end != null) {
        if (end >= 0) {
          to = end;
          if (to >= data!.length) to = data!.length - 1;
        } else {
          to = data!.length + end;
        }
      }

      if ((from <= to) &&
          (from >= 0) &&
          (from < data!.length) &&
          (to >= 0) &&
          (to < data!.length)) {
        Data data = Data();
        int i = 0;
        for (var row in this.data!) {
          if ((i < from) || (i > to)) data.add(row);
          i++;
        }
        this.data = data;
      }

      // notify listeners of data change
      notify();
      onDataChange();
    }
    return true;
  }

  @override
  Future<bool> insert(String? jsonOrXml, int? index,
      {bool notifyListeners = true}) async {
    // make a copy of the first item if no
    // jsonOrXml is specified
    if (isNullOrEmpty(jsonOrXml)) {
      jsonOrXml = (data?.isNotEmpty ?? true)
          ? Json.encode(Json.copy(data![0], withValues: false))
          : null;
    }
    if (isNullOrEmpty(jsonOrXml)) return true;

    // set the index
    index ??= data?.length ?? 0;
    if (index.isNegative) index = 0;

    // add to existing data set
    data ??= Data();
    for (var item in Data.from(jsonOrXml)) {
      if (index! < data!.length) {
        data!.insert(index, item);
      } else {
        data!.add(item);
      }
      index++;
    }

    // template the first record
    template ??= (data?.isEmpty ?? true)
        ? null
        : Json.encode(Json.copy(data![0], withValues: false));

    // notify listeners of data change
    if (notifyListeners) notify();
    onDataChange();

    return true;
  }

  @override
  Future<bool> delete(dynamic index, {bool notifyListeners = true}) async {
    var element = getElement(index);
    if (element != null) {
      data!.remove(element);

      // notify listeners of data change
      if (notifyListeners) notify();
      onDataChange();
    }
    return true;
  }

  @override
  Future<bool> move(dynamic from, dynamic to,
      {bool notifyListeners = true}) async {
    var fromElement = getElement(from);
    var toElement = getElement(to);
    if (fromElement != null && toElement != null) {
      // remove element
      int i = data!.indexOf(toElement);
      data!.remove(fromElement);
      data!.insert(i, fromElement);

      // notify listeners of data change
      if (notifyListeners) notify();
      onDataChange();
    }

    return true;
  }


  Future<bool> reverse() async {
    data = data?.reversed;

    // notify listeners of data change
    onDataChange();

    return true;
  }

  @override
  Future<bool> onSuccess(Data data,
      {int? code, String? message, Observable? onSuccessOverride}) async {
    // set busy
    busy = true;

    // max records
    int maxrecords = this.maxrecords ?? 10000;
    if (maxrecords.isNegative) maxrecords = 0;

    // apply data transforms
    if (children != null) {
      for (Model model in children!) {
        if (model is ITransform) {
          await (model as ITransform).apply(data);
        }
      }
    }

    // type - default is replace
    ListTypes? type = toEnum(queuetype, ListTypes.values);

    // Fifo - Oldest -> Newest
    if (type == ListTypes.fifo) {
      Data temp = Data();
      if (this.data != null) {
        for (var element in this.data!) {
          temp.add(element);
        }
      }
      for (var element in data) {
        temp.add(element);
      }
      if (temp.length > maxrecords) {
        temp.removeRange(0, temp.length - maxrecords);
      }
      data = temp;
    }

    // Lifo - Newest > Oldest
    if (type == ListTypes.lifo) {
      Data temp = Data();
      for (var element in data) {
        temp.add(element);
      }
      if (this.data != null) {
        for (var element in this.data!) {
          temp.add(element);
        }
      }
      if (temp.length > maxrecords) {
        temp.removeRange(temp.length - maxrecords - 1, temp.length);
      }
      data = temp;
    }

    // Append
    if (type == ListTypes.append) {
      Data temp = Data();
      if (this.data != null) {
        for (var element in this.data!) {
          temp.add(element);
        }
      }
      for (var element in data) {
        temp.add(element);
      }
      data = temp;
    }

    // Prepend
    if (type == ListTypes.prepend) {
      Data temp = Data();
      for (var element in data) {
        temp.add(element);
      }
      if (this.data != null) {
        for (var element in this.data!) {
          temp.add(element);
        }
      }
      data = temp;
    }

    // Truncate List
    if (data.length > maxrecords) data.removeRange(maxrecords, data.length);

    // Return Success
    return await onData(data,
        code: code, message: message, onSuccessOverride: onSuccessOverride);
  }

  Future<bool> onFail(Data data,
      {int? code, String? message, Observable? onFailOverride}) async {
    // set data
    this.data = data;

    // set rowcount
    rowcount = this.data?.length ?? 0;

    // set status
    status = "error";

    // set status code
    statuscode = code;

    // set status message
    //statusmessage = (data == null) ? (message ?? '') : '';
    statusmessage = message ?? 'Error: $code';

    // log exception
    Log().exception(
        "$statusmessage [$statuscode] id: $id, object: 'DataBroker'");

    // fire on fail event
    if (onFailOverride != null || !isNullOrEmpty(onfail)) {
      EventHandler handler = EventHandler(this);
      await handler.execute(onFailOverride ?? _onfail);
    }

    // notify listeners
    for (IDataSourceListener listener in listeners) {
      listener.onDataSourceException(this, Exception(statusmessage));
    }

    // busy
    busy = false;

    // requery?
    if (((autoquery ?? 0) > 0) && (timer == null) && (!disposed)) {
      timer = Timer.periodic(Duration(seconds: autoquery!), onTimer);
    }

    return false;
  }

  Future<bool> onData(Data data,
      {int? code, String? message, Observable? onSuccessOverride}) async {
    bool ok = true;

    // set status
    status = "success";

    // set status code
    statuscode = code;

    // set status message
    statusmessage = message ?? 'Ok';

    // Set the source value
    this.data = data;

    // set rowcount
    rowcount = this.data?.length ?? 0;

    // notify listeners
    notify();

    // fire on success event
    if (onSuccessOverride != null || !isNullOrEmpty(onsuccess)) {
      EventHandler handler = EventHandler(this);
      await handler.execute(onSuccessOverride ?? _onsuccess);
    }

    // notify nested data sources
    if (datasources != null) {
      for (IDataSource model in datasources!) {
        if (model is DataModel) {
          // clone the data
          model.onSuccess(data.clone(), code: code, message: message);
        }
      }
    }

    // requery?
    if (((autoquery ?? 0) > 0) && (timer == null) && (!disposed)) {
      timer = Timer.periodic(Duration(seconds: autoquery!), onTimer);
    }

    // busy
    busy = false;

    return ok;
  }

  Future<String?> fromHive(String? key, bool refresh) async {
    // get data from cache
    if ((timetolive > 0) && (!refresh)) {
      // found cached data?
      hive.Data? row = await hive.Data.find(key!);

      // expired?
      bool expired = true;
      if ((row?.expires ?? 0) >= DateTime.now().millisecondsSinceEpoch) {
        expired = false;
      }

      // Return Cached Data
      if (!expired) return row!.value;
    }
    return null;
  }

  Future toHive(String? key, String? data) async {
    if (timetolive > 0) {
      hive.Data d = hive.Data(
          key: key,
          value: data,
          expires: DateTime.now().millisecondsSinceEpoch + timetolive);
      await d.insert();
    }
  }

  String? _encodeBody(dynamic value) => encode(value, _bodyType);
  static String? encode(dynamic value, String? type) {
    if (value == null || value is! String || type == null) return value;
    switch (type) {
      case "json":
        value = Json.escape(value);
        break;
      case "xml":
        value = Xml.encodeIllegalCharacters(value);
        break;
      default:
        break;
    }
    return value;
  }

  // override this function
  @override
  Future<bool> start({bool refresh = false, String? key}) async => true;

  // override this function
  @override
  Future<bool> stop() async => true;

  @override
  Future<dynamic> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {

    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    // template the first record
    template ??= (data?.isEmpty ?? true)
        ? null
        : Json.encode(Json.copy(data![0], withValues: false));

    switch (function) {
      // clear the list
      case "clear":
        return await clear(
            start: toInt(elementAt(arguments, 0)),
            end: toInt(elementAt(arguments, 1)));

      // add element to the list
      case "add":
      case "insert":
        var jsonOrXml = toStr(elementAt(arguments, 0)) ?? template;
        return await insert(jsonOrXml, toInt(elementAt(arguments, 1)));

      // remove element from the list
      case "delete":
      case "remove":
        return await delete(elementAt(arguments, 0));

      // copies an element in the list the the specified index
      case "copy":
        return await copy(elementAt(arguments, 0), elementAt(arguments, 1));

      // move element in the list
      case "move":
        return await move(elementAt(arguments, 0), elementAt(arguments, 1));

      // reverse the list
      case "reverse":
      case "reversed":
        return await reverse();

      // notify
      case "notify":
        notify();
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  @override
  void dispose() {
    if (timer != null) timer!.cancel();
    if ((scope != null) && (scope != System().scope)) {
      scope!.removeDataSource(this);
    }
    if ((framework != null) && (framework!.indexObservable != null)) {
      framework!.indexObservable!.removeListener(onIndexChange);
    }
    super.dispose();
  }
}
