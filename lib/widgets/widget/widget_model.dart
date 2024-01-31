// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/datasources/datasource_listener_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/framework/framework_model.dart';
import 'package:fml/widgets/widget/widget_model_interface.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class WidgetModel implements IDataSourceListener {
  // primary identifier
  late final String id;

  // returns pointer to itself
  WidgetModel get model => this;

  // framework
  FrameworkModel? framework;

  // xml node
  XmlElement? element;
  String get elementName => element?.localName.toUpperCase() ?? '$runtimeType';
  String? get elementNamespace => element?.namespacePrefix?.toLowerCase();

  // datasource
  List<IDataSource>? datasources;
  String? datasource;

  // used to silence notifications
  // during data manipulation or
  // batch updates
  bool notificationsEnabled = true;

  // data element
  ListObservable? _data;
  set data(dynamic v)
  {
    if (_data != null)
    {
      _data!.set(v);
    }

    else if (v != null)
    {
      final key = Binding.toKey(id, 'data');

      _data = ListObservable(key,
          null,
          scope: scope,
          listener: onPropertyChange,

          // inline setter
          // used to set values within the data element
          // when twoway binding is used
          setter: (dynamic value, {Observable? setter})
          {
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
  WidgetModel? parent;

  // children
  List<WidgetModel>? children;

  // scope
  Scope? scope;

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
    return applicationKey.currentContext;
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

  WidgetModel(this.parent, String? id, {Scope? scope, dynamic data})
  {
    // set the id
    this.id = getUniqueId(id);

    // set the scope
    this.scope = scope ?? Scope.of(this);

    // set the framework
    framework = findAncestorOfExactType(FrameworkModel);

    // set the data
    if (data != null) this.data = data;

    // register the model
    this.scope?.registerModel(this);
  }

  static RegExp onlyAlpha = RegExp(r'''[^a-zA-Z0-9\s.]''');
  String getUniqueId(String? id)
  {
    // user supplied id
    if (!isNullOrEmpty(id)) return id!;

    // auto generated id
    String prefix = "auto";
    if (kDebugMode)
    {
      prefix = "$runtimeType";
      prefix = prefix.replaceAll(onlyAlpha,'');
      if (prefix.endsWith('model')) prefix = prefix.substring(0, prefix.lastIndexOf('model'));
    }
    return newId(prefix: prefix);
  }

  static WidgetModel? fromXml(WidgetModel parent, XmlElement node, {Scope? scope, dynamic data})
  {
    // clone node?
    node = cloneNode(node, scope ?? parent.scope);

    // exclude this element?
    if (excludeFromTemplate(node, parent.scope)) return null;

    // build the element model
    return fromXmlNode(parent, node, scope, data);
  }

  void deserialize(XmlElement xml)
  {
    // Busy
    busy = true;

    // retain the xml node
    element = xml;

    // Global Properties
    datasource = Xml.attribute(node: xml, tag: 'data') ?? Xml.attribute(node: xml, tag: 'datasource');
    debug = Xml.get(node: xml, tag: 'debug');

    //var data = Xml.getElement(node: xml, tag: 'DATA');
    //if (data != null)
    //{
    //  this.data = Data.from(data);
    //}

    // register as datasource
    if (this is IDataSource && scope != null)
    {
      scope!.registerDataSource(this as IDataSource);
    }

    // Deserialize Children
    if (children != null) children!.clear();
    _deserializeDataSources(xml);
    _deserialize(xml);

    // register listener
    if (datasource != null && scope != null) {
      IDataSource? source = scope!.getDataSource(datasource);
      if (source != null) source.register(this);
    }

    // Busy
    busy = false;
  }

  void _deserializeDataSources(XmlElement xml) {
    // find and deserialize all datasources
    for (XmlNode node in xml.children) {
      if (node is XmlElement && isDataSource(node.localName)) {
        // build the data source model
        dynamic model = WidgetModel.fromXml(this, node);
        if (model is IDataSource) {
          datasources ??= [];
          datasources!.add(model);
        }
      }
    }
  }

  void _deserialize(XmlElement xml) {
    // deserialize all non-datasource children
    for (XmlNode node in xml.children) {
      if (node is XmlElement && !isDataSource(node.localName)) {
        // build the model
        dynamic model = WidgetModel.fromXml(this, node);
        if (model is WidgetModel) {
          children ??= [];
          children!.add(model);
        }
      }
    }
  }

  void dispose() {
    // remove listeners
    removeAllListeners();

    // dispose of datasources
    if (datasources != null) {
      for (var datasource in datasources!) {
        if (datasource.parent == this) datasource.dispose();
      }
    }
    datasources?.clear();

    // remove model and all of its bindables from the scope
    scope?.unregisterModel(this);

    // dispose of all children
    children?.forEach((child) => child.dispose());
    children?.clear();
  }

  registerListener(IModelListener listener) {
    _listeners ??= [];
    if (!_listeners!.contains(listener)) _listeners!.add(listener);
  }

  removeListener(IModelListener listener) {
    if ((_listeners != null) && (_listeners!.contains(listener))) {
      _listeners!.remove(listener);
      if (_listeners!.isEmpty) _listeners = null;
    }
  }

  removeAllListeners() {
    if (_listeners != null) _listeners!.clear();
  }

  rebuild() => notifyListeners("rebuild", true);

  notifyListeners(String? property, dynamic value, {bool notify = false}) {
    if (_listeners != null)
    {
      for (var listener in _listeners!)
      {
        listener.onModelChange(this, property: property, value: value);
      }
    }
  }

  /// notifies listeners of any changes to a property
  void onPropertyChange(Observable observable) => notificationsEnabled ? notifyListeners(observable.key, observable.get()) : null;

  Future<void> initialize() async {
    // start datasources
    if (datasources != null) {
      for (var datasource in datasources!) {
        // already started?
        if (!datasource.initialized)
        {
          // mark as started
          datasource.initialized = true;

          // announce data for late binding
          if ((datasource.data != null) && (datasource.data!.isNotEmpty))
          {
            datasource.notify();
          }

          // start the datasource if autoexecute = true
          if (datasource.autoexecute == true)
          {
            datasource.start();
          }
        }
      }
    }
  }

  static void unfocus()
  {
    try
    {
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    }
    catch (e)
    {
      Log().exception(e);
    }
  }

  /// Returns true if the template references observable => key
  static bool isBound(WidgetModel model, String? key) {
    if ((model.framework == null) || (isNullOrEmpty(key))) return false;
    return model.framework!.bindables!.contains(key);
  }

  dynamic firstAncestorWhere(Function(dynamic element) test)
  {
    if (parent == null) return null;
    if (test(parent)) return parent;
    return parent?.firstAncestorWhere(test);
  }


  dynamic findAncestorOfExactType(Type T,
      {String? id, bool includeSiblings = false}) {
    List<dynamic>? list =
        findAncestorsOfExactType(T, id: id, includeSiblings: includeSiblings);
    return ((list != null) && (list.isNotEmpty)) ? list.first : null;
  }

  List<dynamic>? get ancestors => findAncestorsOfExactType(null);

  List<dynamic>? findAncestorsOfExactType(Type? T,
      {String? id, bool includeSiblings = false}) {
    if (parent == null) return null;
    return parent!._findAncestorsOfExactType(T, id, includeSiblings);
  }

  List<dynamic> _findAncestorsOfExactType(
      Type? T, String? id, bool includeSiblings) {
    List<dynamic> list = [];

    // evaluate me
    if ((runtimeType == (T ?? runtimeType)) && (this.id == (id ?? this.id))) {
      list.add(this);
    }

    // evaluate my siblings
    if ((includeSiblings) && (children != null)) {
      for (var child in children!) {
        if ((child.runtimeType == T) && (child.id == (id ?? child.id))) {
          list.add(child);
        }
      }
    }

    // evaluate my ancestors
    if (parent != null) {
      list.addAll(parent!._findAncestorsOfExactType(T, id, includeSiblings));
    }

    return list;
  }

  List<dynamic>? get descendants => findDescendantsOfExactType(null);

  dynamic findDescendantOfExactType(Type? T, {String? id}) {
    List<dynamic>? list = findDescendantsOfExactType(T, id: id);
    return list.isNotEmpty ? list.first : null;
  }

  List<dynamic> findDescendantsOfExactType(Type? T, {String? id, Type? breakOn})
  {
    List<dynamic> list = [];
    if (children != null)
    {
      for (var child in children!)
      {
        if (child.runtimeType != breakOn)
        {
          list.addAll(child._findDescendantsOfExactType(T, id));
        }
      }
    }
    return list;
  }

  List<dynamic> _findDescendantsOfExactType(Type? T, String? id) {
    List<dynamic> list = [];

    // evaluate me
    if ((runtimeType == (T ?? runtimeType)) && (this.id == (id ?? this.id))) {
      list.add(this);
    }

    // evaluate my children
    if (children != null) {
      for (WidgetModel child in children!) {
        list.addAll(child._findDescendantsOfExactType(T, id));
      }
    }

    return list;
  }

  dynamic findParentOfExactType(Type T, {String? id}) {
    if ((parent != null) &&
        (parent.runtimeType == (T)) &&
        (parent!.id == (id ?? parent!.id))) return parent;
    return null;
  }

  dynamic findChildOfExactType(Type T, {String? id}) {
    if (children != null)
    {
      var child = children!.firstWhereOrNull((child) => child.runtimeType == (T) && (child.id == (id ?? child.id)));
      return child;
    }
    return null;
  }

  List<dynamic> findChildrenOfExactType(Type T, {String? id}) {
    List<dynamic> list = [];
    if (children != null)
    {
      for (WidgetModel child in children!)
      {
        if ((child.runtimeType == (T)) && (child.id == (id ?? child.id)))
        {
          list.add(child);
        }
      }
    }
    return list;
  }

  void removeChildrenOfExactType(Type T) {
    if (children != null) {
      children!.removeWhere((child) => (child.runtimeType == (T)));
    }
  }

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
    //notifyListeners('list', list);
    return true;
  }

  @override
  onDataSourceException(IDataSource source, Exception exception) {
    busy = false;
    //notifyListeners('error', exception);
  }

  @override
  onDataSourceBusy(IDataSource source, bool busy) {
    this.busy = busy;
    //notifyListeners('busy', this.busy);
  }

  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async {

    if (scope == null) return null;

    var function = propertyOrFunction.toLowerCase().trim();

    switch (function)
    {
      case 'set':
        return set(this, caller, propertyOrFunction, arguments, scope!);

      case 'addchild':

        addChild(this, arguments);

        // force rebuild
        notifyListeners("rebuild", "true");

        return true;

      case 'removechild':

        removeChild(this, arguments);

        // force rebuild
        notifyListeners("rebuild", "true");

        return true;

      case 'removechildren':

        removeChildren(this, arguments);

        // force rebuild
        notifyListeners("rebuild", "true");

        return true;

      case 'replacechild':

        replaceChild(this, arguments);

        // force rebuild
        notifyListeners("rebuild", "true");

        return true;

      case 'replacechildren':

        replaceChildren(this, arguments);

        // force rebuild
        notifyListeners("rebuild", "true");

        return true;

      case 'removewidget':

        removeWidget(this, arguments);

        // force rebuild
        notifyListeners("rebuild", "true");

        return true;

      case 'replacewidget':

        replaceWidget(this, arguments);

        // force rebuild
        notifyListeners("rebuild", "true");

        return true;
    }

    return false;
  }

  static bool set(WidgetModel model, String caller, String propertyOrFunction, List<dynamic> arguments, Scope scope)
  {
    // value
    var value = elementAt(arguments, 0);

    // property - default is value
    // we can now use dot notation to specify the property
    // rather than pass it as an attribute
    var property = elementAt(arguments, 1);
    property ??= Binding.fromString(caller)?.toString() ?? property;

    // set the variable
    scope.setObservable(property, value?.toString());
    return true;
  }
}
