// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'package:fml/event/event.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/framework/framework_view.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/tabview/tab_view.dart';
import 'package:fml/widgets/framework/framework_model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';

class TabModel extends DecoratedWidgetModel implements IViewableWidget
{
  LinkedHashMap<String, FrameworkView> views = LinkedHashMap<String, FrameworkView>();

  // index
  IntegerObservable? _index;
  set index(dynamic v)
  {
    int? i = S.toInt(v);
    if (i != null && (i >= views.length || i < 0)) v = null;
    if (_index != null)
         _index!.set(v);
    else _index = IntegerObservable(Binding.toKey(id, 'index'), v, scope: scope);
    onIndexChange(_index!);
  }
  int? get index => _index?.get();

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

  BooleanObservable? _tabbar;
  set tabbar (dynamic v)
  {
    if (_tabbar != null)
    {
      _tabbar!.set(v);
    }
    else if (v != null)
    {
      _tabbar = BooleanObservable(Binding.toKey(id, 'tabbar'), v, scope: scope);
    }
  }
  bool get tabbar => _tabbar?.get() ?? true;

  BooleanObservable? _tabbutton;
  set tabbutton (dynamic v)
  {
    if (_tabbutton != null)
    {
      _tabbutton!.set(v);
    }
    else if (v != null)
    {
      _tabbutton = BooleanObservable(Binding.toKey(id, 'tabbutton'), v, scope: scope);
    }
  }
  bool get tabbutton => _tabbutton?.get() ?? true;

  TabModel(WidgetModel parent, String? id, {String? type, String? title, dynamic visible, dynamic mandatory, dynamic gps, dynamic oncomplete, dynamic tabbar, dynamic tabbutton,}) : super(parent, id)
  {
    this.tabbar = tabbar;
    this.tabbutton = tabbutton;
  }

  void onIndexChange(Observable observable)
  {
    try
    {
      // lookup key and url
      String? key;
      String? url;
      if (index != null)
      {
        key = views.values.toList()[index!].model.dependency;
        url = views.keys.toList()[index!];
      }

      // broadcast the event
      EventManager.of(this)?.broadcastEvent(this,Event(EventTypes.focusnode, parameters: {'key': key, 'url': url}));

      // call property change on index
      onPropertyChange(observable);
    }
    catch(e)
    {
      Log().exception('Index out of range. Exception is $e');
    }
  }

  @override
  dispose()
  {
    // cleanup framework models
    views.values.forEach((view) => deleteView(view));
    super.dispose();
  }

  deleteView(Widget view)
  {
    // remove view
    views.removeWhere((key, value) => value == view);

    // cleanup framework models
    if (view is FrameworkView) view.model.dispose();
  }

  static TabModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    TabModel? model;

    try
    {
      model = TabModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'tab.Model');
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
    //page = Xml.get(node: xml, tag: 'page);
    tabbar    = Xml.get(node: xml, tag: 'tabbar');
    tabbutton = Xml.get(node: xml, tag: 'tabbutton');

    //////////////////
    /* Create Pages */
    //////////////////
    int i = 0;
    dynamic nodes = xml.findElements("TAB", namespace: "*");
    if (nodes != null)
    for (XmlElement node in nodes)
    {
      FrameworkModel? model = FrameworkModel.fromXml(this, node);
      if (model != null) views[Xml.attribute(node: node, tag: "id") ?? i.toString()] = model.getView() as FrameworkView;
      i++;
    }
  }

  Widget getView({Key? key}) => TabView(this);
}


