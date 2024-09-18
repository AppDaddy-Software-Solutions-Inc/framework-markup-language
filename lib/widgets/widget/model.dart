// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/datasources/datasource_listener_interface.dart';
import 'package:fml/fml.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/framework/framework_model.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:fml/widgets/widget/model_interface.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class Model implements IDataSourceListener {

  // primary identifier
  // needs to be unique within the scope
  late String id;

  // scope
  Scope? scope;
  bool _scopeIsLocal = false;

  // this is used in the renderer to determine if the widget
  // should rebuild on layout changes
  bool needsLayout = false;

  // framework
  FrameworkModel? framework;

  // xml element
  StringObservable? _xml;
  XmlElement? _element;
  set element (XmlElement? v) {
    _element = v;
    if (Model.isBound(this, Binding.toKey(id, 'xml'))) {
      _xml = StringObservable(Binding.toKey(id, 'xml'), v, scope: scope);
    }
  }
  String? get xml => _xml?.get();
  XmlElement? get element => _element;
  String get elementName => element?.localName.toUpperCase() ?? '$runtimeType';

  // datasource
  List<IDataSource>? datasources;
  String? datasource;

  // used to silence notifications
  // during data manipulation or
  // batch updates
  bool _notificationsEnabled = true;
  void enableNotifications() => _notificationsEnabled = true;
  void disableNotifications() => _notificationsEnabled = false;

  // data element
  ListObservable? _data;
  set data(dynamic v) {
    if (_data != null) {
      _data!.set(v);
    } else if (v != null) {
      final key = Binding.toKey(id, 'data');

      _data =
          ListObservable(key, null, scope: scope, listener: onPropertyChange,

              // inline setter
              // used to set values within the data element
              // when twoway binding is used
              setter: (dynamic value, {Observable? setter}) {
        if (setter?.twoway == null) return value;
        var bdg = Binding.fromString(setter?.signature);
        var tag = bdg?.toString().replaceFirst("$key.", "");
        Data.write(data, tag, value);
        return data;
      });

      // set the value
      _data!.set(v);
    }
  }
  get data => _data?.get();

  void onDataChange() => _data?.notifyListeners();

  // listeners
  List<IModelListener>? _listeners;

  // debug
  BooleanObservable? _debug;
  set debug(dynamic v) {
    if (_debug != null) {
      _debug!.set(v);
    } else if (v != null) {
      _debug = BooleanObservable(Binding.toKey(id, 'debug'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get debug => _debug?.get() ?? false;

  // parent model
  Model? parent;

  // children
  List<Model>? children;

  // context
  BuildContext? get context {
    if (_listeners != null) {
      for (IModelListener listener in _listeners!) {
        if (listener is State && (listener as State).mounted == true) {
          return (listener as State).context;
        }
      }
    }
    if (parent != null) return parent!.context;
    return FmlEngine.key.currentContext;
  }

  // busy
  BooleanObservable? get busyObservable => _busy;
  BooleanObservable? _busy;
  set busy(dynamic v) {
    if (_busy != null) {
      _busy!.set(v);
    } else {
      _busy = BooleanObservable(Binding.toKey(id, 'busy'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get busy => _busy?.get() ?? false;

  // used in the sort process to deserialize
  static final List<String> _topmost = [
    "VAR",
    "BARCODE",
    "BEACON",
    "BIOMETRIC",
    "DATA",
    "DELETE",
    "DETECTOR",
    "FILEPICKER",
    "GET",
    "GPS",
    "HTTP",
    "ICONS",
    "LOG",
    "MQTT",
    "NFC",
    "OCR",
    "PACKAGE",
    "PKG",
    "PATCH",
    "POST",
    "PUT",
    "SOCKET",
    "SSE",
    "STASH",
    "TESTDATA",
    "ZEBRA"
  ];

  Model(this.parent, String? id, {Scope? scope, dynamic data}) {
    // set the id
    this.id = getUniqueId(id);

    // set the scope
    this.scope = scope ?? Scope.of(this);

    // we want to know if the scope is local so we can dispose of it
    // whene the model is destroyed
    if (scope != null) _scopeIsLocal = true;

    // set the framework
    framework = findAncestorOfExactType(FrameworkModel);

    // set the data
    if (data != null) this.data = data;

    // register the model
    this.scope?.registerModel(this);
  }

  static Model? fromXml(Model parent, XmlElement node,
      {Scope? scope, dynamic data}) {

    // clone node?
    // node = cloneNode(node, scope ?? parent.scope);

    // exclude this element?
    if (excludeFromTemplate(node, parent.scope)) return null;

    // build the element model
    return fromXmlNode(parent, node, scope, data);
  }

  void deserialize(XmlElement xml) {
    // set busy
    busy = true;

    // scoped widget?
    var scope = Xml.get(node: xml, tag: 'scope');
    if (!isNullOrEmpty(scope)) {

        // unregister from the current scope
        this.scope?.unregisterModel(this);

        // create a new scope
        this.scope = Scope(parent: parent?.scope, id: scope);

        // register this model with the new scope
        this.scope?.registerModel(this);

        // we want to know if the scope is local so we can dispose of it
        // when the model is destroyed
        _scopeIsLocal = true;
    }

    // retain a pointer to the xml
    element = xml;

    // properties
    debug = Xml.get(node: xml, tag: 'debug');
    datasource = Xml.get(node: xml, tag: 'datasource') ?? Xml.get(node: xml, tag: 'data');

    // register a listener to the datasource if specified
    IDataSource? source = this.scope?.getDataSource(datasource);
    source?.register(this);

    // we first sort the elements moving vars and datasources to the top of the
    // deserialization sequence in order to avoid excessive deferred bindings
    var elements = xml.children.whereType<XmlElement>().toList();
    if (elements.length > 1) {
      var topmost = elements
          .where((element) => _topmost.contains(element.name.toString()))
          .toList();
      if (topmost.isNotEmpty && topmost.length != elements.length) {
        elements.removeWhere((element) => topmost.contains(element));
        elements.insertAll(0, topmost);
      }
    }

    // deserialize children
    children?.clear();
    for (var element in elements) {
      // deserialize the model
      var model = Model.fromXml(this, element);

      if (model != null)
      {
        // add model to the datasource list
        if (model is IDataSource) {
          (datasources ??= []).add(model as IDataSource);
        }

        // add model to the child list
        // in cases like camera, it is both a viewable widget as well
        // as a data source.
        if (model is! IDataSource || model is ViewableMixin) {
          (children ??= []).add(model);
        }
      }
    }

    // set idle
    busy = false;
  }

  /// disposes of the model releasing resources and removing bindings
  void dispose() {
    // remove listeners
    removeAllListeners();

    // dispose of datasources
    datasources?.forEach((datasource) =>
        datasource.parent == this ? datasource.dispose() : null);
    datasources?.clear();

    // remove model and all of its bindables from the scope
    scope?.unregisterModel(this);

    // dispose of all children
    children?.forEach((child) => child.dispose());
    children?.clear();

    // dispose of the local scope
    if (_scopeIsLocal) {
      scope?.dispose();
    }
  }

  /// adds a models listener to the list
  registerListener(IModelListener listener) {
    _listeners ??= [];
    if (!_listeners!.contains(listener)) _listeners!.add(listener);
  }

  /// removes a model listener from the list
  removeListener(IModelListener listener) {
    if ((_listeners != null) && (_listeners!.contains(listener))) {
      _listeners!.remove(listener);
      if (_listeners!.isEmpty) _listeners = null;
    }
  }

  /// removes all model listeners
  removeAllListeners() => _listeners?.clear();

  /// model listener notifications
  notifyListeners(String? property, dynamic value, {bool notify = false}) =>
      _listeners?.forEach((listener) =>
          listener.onModelChange(this, property: property, value: value));

  /// notifies property listeners of any changes to a property
  void onPropertyChange(Observable observable) {
    if(_notificationsEnabled) {
      notifyListeners(observable.key, observable.get());
    }
  }

  /// initializes the model by starting brokers
  Future<void> initialize() async {
    // start datasources
    datasources?.forEach((datasource) {
      // skip if the datasource has already been initialized
      if (!datasource.initialized) {
        // mark as started
        datasource.initialized = true;

        // announce data for late binding
        if (datasource.data?.isNotEmpty ?? false) datasource.notify();

        // start the datasource if autoexecute="true"
        if (datasource.autoexecute == true) datasource.start();
      }
    });
  }

  static RegExp onlyAlpha = RegExp(r'''[^a-zA-Z0-9\s.]''');
  String getUniqueId(String? id) {

    // user supplied id
    if (!isNullOrEmpty(id)) return id!;

    // auto generated id
    String prefix = "auto";
    if (kDebugMode) {
      prefix = "$runtimeType";
      prefix = prefix.replaceAll(onlyAlpha, '');
      if (prefix.endsWith('model')) {
        prefix = prefix.substring(0, prefix.lastIndexOf('model'));
      }
    }

    return newId(prefix: prefix);
  }

  // force unfocus on currently focused node
  static unfocus() async {
    try {
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    } catch(_) {}
  }

  /// Returns true if the template references observable => key
  static bool isBound(Model model, String? key) {
    if ((model.framework == null) || (isNullOrEmpty(key))) return false;
    return model.framework!.bindables!.contains(key);
  }

  dynamic firstAncestorWhere(Function(dynamic element) test) {
    if (parent == null) return null;
    if (test(parent)) return parent;
    return parent?.firstAncestorWhere(test);
  }

  dynamic findAncestorOfExactType(Type T,
      {String? id, bool includeSiblings = false}) {
    var list =
        findAncestorsOfExactType(T, id: id, includeSiblings: includeSiblings);
    return (list?.isNotEmpty ?? false) ? list?.first : null;
  }

  List<dynamic>? get ancestors => findAncestorsOfExactType(null);

  List<dynamic>? findAncestorsOfExactType(Type? T,
          {String? id, bool includeSiblings = false}) =>
      parent?._findAncestorsOfExactType(T, id, includeSiblings);

  List<dynamic> _findAncestorsOfExactType(
      Type? T, String? id, bool includeSiblings) {
    var list = [];

    // evaluate me
    if ((runtimeType == (T ?? runtimeType)) && (this.id == (id ?? this.id))) {
      list.add(this);
    }

    // evaluate my siblings
    if (includeSiblings) {
      children?.forEach((child) {
        if (child.runtimeType == T && child.id == (id ?? child.id)) {
          list.add(child);
        }
      });
    }

    // evaluate my ancestors
    if (parent != null) {
      list.addAll(parent!._findAncestorsOfExactType(T, id, includeSiblings));
    }

    return list;
  }

  List<dynamic>? get descendants => findDescendantsOfExactType(null);

  dynamic findDescendantOfExactType(Type? T, {String? id}) {
    var list = findDescendantsOfExactType(T, id: id);
    return list.isNotEmpty ? list.first : null;
  }

  List<dynamic> findDescendantsOfExactType(Type? T,
      {String? id, Type? breakOn}) {
    var list = [];
    children?.forEach((child) {
      if (child.runtimeType != breakOn) {
        list.addAll(child._findDescendantsOfExactType(T, id));
      }
    });
    return list;
  }

  List<dynamic> _findDescendantsOfExactType(Type? T, String? id) {
    var list = [];

    // evaluate me
    if ((runtimeType == (T ?? runtimeType)) && (this.id == (id ?? this.id))) {
      list.add(this);
    }

    // evaluate my children
    children?.forEach(
        (child) => list.addAll(child._findDescendantsOfExactType(T, id)));

    return list;
  }

  dynamic findParentOfExactType(Type T, {String? id}) {
    if ((parent != null) &&
        (parent.runtimeType == (T)) &&
        (parent!.id == (id ?? parent!.id))) return parent;
    return null;
  }

  dynamic findChildOfExactType(Type T, {String? id}) =>
      children?.firstWhereOrNull((child) =>
          child.runtimeType == (T) && (child.id == (id ?? child.id)));

  List<dynamic> findChildrenOfExactType(Type T, {String? id}) {
    var list = [];
    children?.forEach((child) {
      if (child.runtimeType == (T) && child.id == (id ?? child.id)) {
        list.add(child);
      }
    });
    return list;
  }

  void removeChildrenOfExactType(Type T) =>
      children?.removeWhere((child) => (child.runtimeType == (T)));

  dynamic findListenerOfExactType(Type T) {
    if (_listeners != null) {
      for (dynamic listener in _listeners!) {
        if (listener.runtimeType == T) return listener;
      }
    }
    return null;
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async {
    busy = false;
    return true;
  }

  @override
  onDataSourceException(IDataSource source, Exception exception) {
    busy = false;
  }

  @override
  onDataSourceBusy(IDataSource source, bool busy) {
    this.busy = busy;
  }

  // this call walks up the model tree notifying ancestor widgets that the child list has changed
  // some widgets like form and list need to know when children are added or removed
  void notifyAncestorsOfDescendantChange() => parent?.notifyAncestorsOfDescendantChange();

  Future<dynamic> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    if (scope == null) return null;

    var function = propertyOrFunction.toLowerCase().trim();

    switch (function) {
      // set property
      case 'set':
        return set(this, caller, propertyOrFunction, arguments, scope!);

      // add child
      case 'addchild':

        addChild(this, arguments);

        // notifies child list has changed
        notifyAncestorsOfDescendantChange();

        // force rebuild
        notifyListeners("rebuild", true);

        return true;

      // remove child
      case 'removechild':

        removeChild(this, arguments);

        // notifies child list has changed
        notifyAncestorsOfDescendantChange();

        // force rebuild
        notifyListeners("rebuild", true);

        return true;

      // remove all children
      case 'removechildren':

        removeChildren(this, arguments);

        // notifies child list has changed
        notifyAncestorsOfDescendantChange();

        // force rebuild
        notifyListeners("rebuild", true);

        return true;

      // replace child
      case 'replacechild':

        replaceChild(this, arguments);

        // notifies child list has changed
        notifyAncestorsOfDescendantChange();

        // force rebuild
        notifyListeners("rebuild", true);

        return true;

      // replace all children
      case 'replacechildren':

        replaceChildren(this, arguments);

        // notifies child list has changed
        notifyAncestorsOfDescendantChange();

        // force rebuild
        notifyListeners("rebuild", true);

        return true;

      // remove me
      case 'removewidget':

        removeWidget(this, arguments);

        // notifies child list has changed
        parent?.notifyAncestorsOfDescendantChange();

        // force rebuild
        parent?.notifyListeners("rebuild", true);

        return true;

      // replace me
      case 'replacewidget':

        replaceWidget(this, arguments);

        // notifies child list has changed
        parent?.notifyAncestorsOfDescendantChange();

        // force rebuild
        parent?.notifyListeners("rebuild", true);

        return true;
    }

    return false;
  }

  static bool set(Model model, String id, String propertyOrFunction,
      List<dynamic> arguments, Scope scope) {
    // value
    var value = elementAt(arguments, 0);

    // property - default is value
    // we can now use dot notation to specify the property
    // rather than pass it as an attribute
    var property = elementAt(arguments, 1);
    var key = Binding.toKey(id, property);

    // set the binding value
    scope.setObservable(key, value?.toString());

    return true;
  }
}
