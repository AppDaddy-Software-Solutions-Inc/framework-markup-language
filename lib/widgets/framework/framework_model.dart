// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/event/event.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/navigation/manager.dart';
import 'package:fml/widgets/modal/modal_model.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/system.dart';
import 'package:fml/template/template.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/header/header_model.dart';
import 'package:fml/widgets/footer/footer_model.dart';
import 'package:fml/widgets/drawer/drawer_model.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/widgets/variable/variable_model.dart';
import 'package:fml/widgets/framework/framework_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';

import 'package:uuid/uuid.dart';

class FrameworkModel extends DecoratedWidgetModel implements IViewableWidget, IModelListener, IEventManager
{
  /// Event Manager Host
  final EventManager manager = EventManager();
  registerEventListener(EventTypes type, OnEventCallback callback, {int? priority}) => manager.register(type, callback, priority: priority);
  removeEventListener(EventTypes type, OnEventCallback callback) => manager.remove(type, callback);
  broadcastEvent(WidgetModel source, Event event) => manager.broadcast(this, event);
  executeEvent(WidgetModel source, String event) => manager.execute(this, event);

  HeaderModel?  header;
  FooterModel?  footer;
  DrawerModel?  drawer;
  WidgetModel?  body;

  List<String?>? bindables;

  // disposed
  bool disposed = false;

  // xml node that created this template
  @override
  set element (XmlElement? element)
  {
    super.element = element;

    String? xml;
    if (element != null) xml = element.toXmlString(pretty: true);
    if ( _template == null)
         _template = StringObservable(Binding.toKey(id, 'template'), xml, scope: scope);
    else _template!.set(xml);
  }

  // template
  StringObservable? _template;
  set template (dynamic v) {}
  String? get template => _template?.get();

  // key
  StringObservable? _key;
  set key (dynamic v)
  {
    if (_key != null)
    {
      _key!.set(v);
      if (element != null) Xml.setAttribute(element!, 'key', v);
    }
    else if (v != null)
    {
      _key = StringObservable(Binding.toKey(id, 'key'), v, scope: scope);
      if (element != null) Xml.setAttribute(element!, 'key', v);
    }
  }
  String? get key => _key?.get();

  // model is initialized
  BooleanObservable? _initialized;
  set initialized (dynamic v)
  {
    if (_initialized != null)
    {
      _initialized!.set(v);
    }
    else if (v != null)
    {
      _initialized = BooleanObservable(Binding.toKey(id, 'initialized'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get initialized => _initialized?.get() ?? false;

  // page stack index
  // This property indicates your position on the stack, 0 being the top
  IntegerObservable? get indexObservable => _index;
  IntegerObservable? _index;
  set index (dynamic v)
  {
    if (_index != null)
    {
      _index!.set(v);
    }
    else if (v != null)
    {
      _index = IntegerObservable(Binding.toKey(id, 'index'), v, scope: scope);
    }
  }
  int? get index
  {
    if (_index == null) return -1;
    return _index?.get();
  }

  ////////////////////
  /* dependency key */
  ////////////////////
  StringObservable? _dependency;
  set dependency (dynamic v)
  {
    if (_dependency != null)
    {
      _dependency!.set(v);
      if (element != null) Xml.setAttribute(element!, 'dependency', v);
    }
    else if (v != null)
    {
      _dependency = StringObservable(Binding.toKey(id, 'dependency'), v, scope: scope);
      if (element != null) Xml.setAttribute(element!, 'dependency', v);
    }
  }
  String? get dependency => _dependency?.get();

  /////////////
  /* title */
  /////////////
  StringObservable? _title;
  set title (dynamic v)
  {
    if (_title != null)
    {
      _title!.set(v);
    }
    else if (v != null)
    {
      _title = StringObservable(Binding.toKey(id, 'title'), v, scope: scope, listener: (_) => onTitleChange(context));
    }
  }
  String? get title => _title?.get();

  /////////////
  /* version */
  /////////////
  StringObservable? _version;
  set version (dynamic v)
  {
    if (_version != null)
    {
      _version!.set(v);
    }
    else if (v != null)
    {
      _version = StringObservable(Binding.toKey('TEMPLATE', 'version'), v, scope: scope);
    }
  }
  String? get version
  {
    return _version?.get();
  }

  //////////////
  /* onstart */
  //////////////
  StringObservable? _onstart;
  set onstart (dynamic v)
  {
    if (_onstart != null)
    {
      _onstart!.set(v);
    }
    else if (v != null)
    {
      _onstart = StringObservable(Binding.toKey(id, 'onstart'), v, scope: scope, lazyEval: true);
    }
  }
  String? get onstart
  {
    return _onstart?.get();
  }

  //////////////
  /* onstart */
  //////////////
  StringObservable? _orientation;
  set orientation (dynamic v)
  {
    if (_orientation != null)
    {
      _orientation!.set(v);
    }
    else if (v != null)
    {
      _orientation = StringObservable(Binding.toKey(id, 'orientation'), v, scope: scope);
    }
  }
  String? get orientation
  {
    if (_orientation == null) return null;
    return _orientation?.get();
  }

  //////////////
  /* onreturn */
  //////////////
  StringObservable? _onreturn;
  set onreturn (dynamic v)
  {
    if (_onreturn != null)
    {
      _onreturn!.set(v);
    }
    else if (v != null)
    {
      _onreturn = StringObservable(Binding.toKey(id, 'onreturn'), v, scope: scope, lazyEval: true);
    }
  }
  String? get onreturn
  {
    return _onreturn?.get();
  }

  /////////
  /* url */
  /////////
  StringObservable? _url;
  set url (dynamic v)
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

  // return parameters
  Map<String?, String> get parameters
  {
    Map<String?, String> _parameters = Map<String?, String>();
    List<dynamic>? variables = findDescendantsOfExactType(VariableModel);
    if (variables != null)
      variables.forEach((variable)
      {
        VariableModel v = (variable as VariableModel);
        if (!S.isNullOrEmpty(v.returnas))
        {
          String? name  = v.returnas;
          String value = v.value ?? "";
          _parameters[name] = value;
        }
      });
    return _parameters;
  }

  FrameworkModel(WidgetModel parent, String? id, {dynamic key, dynamic dependency, dynamic version, dynamic onstart, dynamic onreturn, dynamic orientation}) : super(parent, id, scope: Scope(id))
  {
    // model is initializing
    initialized = false;

    this.key         = key;
    this.dependency  = dependency;
    this.version     = version;
    this.onstart     = onstart;
    this.orientation = orientation;
    this.onreturn    = onreturn;
  }

  static FrameworkModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    FrameworkModel? model;
    try
    {
      model = FrameworkModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().debug(e.toString());
      model = null;
    }
    return model;
  }

  static FrameworkModel fromUrl(WidgetModel parent, String url, {String? id, bool? refresh, String? dependency})
  {
    FrameworkModel model = FrameworkModel(parent, id, dependency: dependency);
    model.loadAsync(url, refresh: refresh ?? false);
    return model;
  }

  Future<void> loadAsync(String url, {required bool refresh, String? dependency}) async
  {
    try
    {
      // parse the url
      Uri? uri = Url.parse(url);
      if (uri == null) throw('Error');

      // fetch the template
      Template template = await Template.fetch(url: url, parameters: uri.queryParameters, refresh: refresh);

      // get the xml
      var xml = template.document!.rootElement;

      // template requires rights?
      int? requiredRights = S.toInt(Xml.attribute(node: xml, tag: 'rights'));
      if (requiredRights != null)
      {
        int? myrights = S.toInt(System().userProperty('rights') ?? 0);
        bool connected = S.toBool(System().userProperty('connected') ?? false)!;

        // logged on?
        if (!connected)
        {
          // fetch logon template
          var login = Application?.loginPage;
          if (!S.isNullOrEmpty(login)) template = await Template.fetch(url:login!, refresh: refresh);
          xml = template.document!.rootElement;
        }

        // authorized?
        else if (myrights! < requiredRights)
        {
          // fetch not authorized template
          var unauthorized = Application?.unauthorizedPage;
          if (!S.isNullOrEmpty(unauthorized)) template = await Template.fetch(url: unauthorized!, refresh: refresh);
          xml = template.document!.rootElement;
        }
      }

      // deserialize from xml
      deserialize(xml);

      // inject debug window
      if (!S.isNullOrEmpty(Application?.debugPage)) await _injectDebugModal(this, refresh);

      // set template name
      templateName = url.split("?")[0];
      if (dependency != null) this.dependency = dependency;

      // initialize
      model.initialize();
    }
    catch(e)
    {
      String msg = "Error building model from template $url";
      Log().error(msg);
      return Future.error(msg);
    }
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // remember xml node
    this.element = xml;

    // get bindings
    bindables = Binding.getBindingKeys(xml.toXmlString());
    if (bindables == null) bindables = [];

    // stack index
    this.index = -1;

    // deserialize 
    super.deserialize(xml);

    // properties
    key          = xml.getAttribute('key')                ?? key ?? Uuid().v4();
    dependency   = xml.getAttribute('dependency')         ?? dependency;
    title        = Xml.get(node: xml, tag: 'title')       ?? title;
    version      = Xml.get(node: xml, tag: 'version')     ?? version;
    onstart      = Xml.get(node: xml, tag: 'onstart')     ?? onstart;
    url          = Xml.get(node: xml, tag: 'url')         ?? url;
    orientation  = Xml.get(node: xml, tag: 'orientation') ?? orientation;
    onreturn     = Xml.get(node: xml, tag: 'onreturn')    ?? onreturn;

    // header
    List<HeaderModel> headers = findChildrenOfExactType(HeaderModel).cast<HeaderModel>();
      headers.forEach((header)
      {
        if (header == headers.first)
        {
          this.header = header;
          this.header!.registerListener(this);
        }
        if (children!.contains(header)) children!.remove(header);
      });

    // remove from view stream
    removeChildrenOfExactType(HeaderModel);

    // footer
    List<FooterModel> footers = findChildrenOfExactType(FooterModel).cast<FooterModel>();
    footers.forEach((footer)
    {
      if (footer == footers.first)
      {
        this.footer = footer;
        this.footer!.registerListener(this);
      }
      if (children!.contains(footer)) children!.remove(footer);
    });

    // remove from view stream
    removeChildrenOfExactType(FooterModel);

    // build drawers
    List<XmlElement>? nodes;
    nodes = Xml.getChildElements(node: xml, tag: "DRAWER");
    if (nodes != null && nodes.isNotEmpty) drawer = DrawerModel.fromXmlList(this, nodes);

    // sort children by depth
    if (children != null) {
      children?.sort((a, b) {
        if(a.depth != null && b.depth != null)return a.depth?.compareTo(b.depth!) ?? 0;
        return 0;
      });
    }

    // ready
    initialized = true;
  }

  @override
  dispose()
  {
    disposed = true;

    Log().debug('dispose called on => <TEMPLATE url="$url">');

    header?.dispose();
    footer?.dispose();
    drawer?.dispose();

    scope?.dispose();

    // clear event listeners
    manager.listeners.clear();

    super.dispose();
  }

  static Future<FrameworkModel> build(String templateName, {Map<String, String?>? parameters, IModelListener? listener, required bool refresh, String? dependency}) async
  {
    Template template = await Template.fetch(url: templateName, parameters: parameters, refresh: refresh);

    // get xml
    var xml = template.document!.rootElement;

    // template requires rights?
    int? requiredRights = S.toInt(Xml.attribute(node: xml, tag: 'rights'));
    if (requiredRights != null)
    {
      int?  myrights  = S.toInt(System().userProperty('rights') ?? 0);
      bool connected = S.toBool(System().userProperty('connected') ?? false)!;

      // logged on?
      if (!connected)
      {
        var login = Application?.loginPage;
        if (!S.isNullOrEmpty(login)) template = await Template.fetch(url: login!, refresh: refresh);
        xml = template.document!.rootElement;
      }

      // authorized?
      else if (myrights! < requiredRights)
      {
        var unauthorized = Application?.unauthorizedPage;
        if (!S.isNullOrEmpty(unauthorized)) template = await Template.fetch(url: unauthorized!, refresh: refresh);
        xml = template.document!.rootElement;
      }
    }

    FrameworkModel? model = FrameworkModel.fromXml(System(), xml);
    if (model != null)
    {
      // inject debug window
      if (!S.isNullOrEmpty(Application?.debugPage)) await _injectDebugModal(model, refresh);

      model.templateName = templateName.split("?")[0];
      if (model.dependency != null) model.dependency = dependency;

      if (listener != null) model.registerListener(listener);
      model.initialize();
    }
    else
    {
      String msg = "Error model from template  " + templateName + "";
      Log().error(msg);
      return Future.error(msg);
    }
    return model;
  }

  static Future<void> _injectDebugModal(FrameworkModel model, bool refresh) async
  {
    {
      // get the debug template
      var debug = Application?.debugPage;
      if (!S.isNullOrEmpty(debug))
      {
        // get the debug template
        var doc = await Template.fetch(url: debug!, refresh: refresh);

        // build modal node
        XmlElement node = XmlElement(XmlName("MODAL"));
        node.attributes.add(XmlAttribute(XmlName("id"), "DEBUG"));
        doc.document!.rootElement.children.forEach((child) => node.children.insert(0, child.copy()));

        // build modal model
        ModalModel? modal = ModalModel.fromXml(model,node);
        if (modal != null)
        {
          if (model.children == null) model.children = [];
          model.children!.insert(0, modal);
        }
      }
    }
  }

  Future<bool> onStart(BuildContext context) async
  {
    await NavigationManager().onPageLoaded();
    return await EventHandler(this).execute(_onstart);
  }

  Future<bool> onPush(Map<String?, String> parameters) async
  {
    //////////////////////////////////////////
    /* Set Variables from Return Parameters */
    //////////////////////////////////////////
    if ((scope != null)) parameters.forEach((key, value) => scope!.setObservable(key, value));

    /////////////////////////
    /* Fire OnReturn Event */
    /////////////////////////
    if (!S.isNullOrEmpty(onreturn)) EventHandler(this).execute(_onreturn);

    return true;
  }

  // get return parameters
  Map<String?, String> onPop() => parameters;

  /// Callback function for when the model changes, used to force a rebuild with setState()
  onModelChange(WidgetModel model,{String? property, dynamic value})
  {
    try
    {
      Binding? b = Binding.fromString(property);
      if ((b?.property == 'visible') || (b?.property == 'height') || (b?.property == 'minheight') || (b?.property == 'maxheight')) notifyListeners(property, value);
    }
    catch(e)
    {
      Log().exception(e, caller: 'Framework.View');
    }
  }

  void onTitleChange(BuildContext? context)
  {
    // set tab title
    if (index == 0) System().setApplicationTitle(title);

    // update page title
    if (context != null) NavigationManager().setPageTitle(context, title);
  }

  Widget getView({Key? key}) => FrameworkView(this);
}

abstract class IDragListener
{
  onDragOpen(DragStartDetails details, String dir);
  onDragEnd(DragEndDetails details, String dir, bool isOpen);
  onDragSheet(DragUpdateDetails details, String dir, bool isOpen);
}
