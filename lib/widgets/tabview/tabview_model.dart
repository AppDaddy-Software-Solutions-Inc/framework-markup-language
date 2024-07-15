// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'package:fml/event/event.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/framework/framework_view.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:fml/widgets/tabview/tab_model.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/widgets/tabview/tabview_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class TabViewModel extends BoxModel {

  LinkedHashMap<String, Widget> views = LinkedHashMap<String, Widget>();

  @override
  LayoutType get layoutType => LayoutType.column;

  // index
  IntegerObservable? _index;
  set index(dynamic v) {
    int? i = toInt(v);
    if (i != null && (i >= views.length || i < 0)) v = null;
    if (_index != null) {
      _index!.set(v);
    } else {
      _index = IntegerObservable(Binding.toKey(id, 'index'), v, scope: scope);
    }
    onIndexChange(_index!);
  }

  int? get index => _index?.get();

  BooleanObservable? _tabbar;
  set tabbar(dynamic v) {
    if (_tabbar != null) {
      _tabbar!.set(v);
    } else if (v != null) {
      _tabbar = BooleanObservable(Binding.toKey(id, 'tabbar'), v, scope: scope);
    }
  }

  bool get tabbar => _tabbar?.get() ?? true;

  BooleanObservable? _tabbutton;
  set tabbutton(dynamic v) {
    if (_tabbutton != null) {
      _tabbutton!.set(v);
    } else if (v != null) {
      _tabbutton =
          BooleanObservable(Binding.toKey(id, 'tabbutton'), v, scope: scope);
    }
  }

  bool get tabbutton => _tabbutton?.get() ?? true;

  TabViewModel(
    Model super.parent,
    super.id, {
    dynamic tabbar,
    dynamic tabbutton,
  }) {
    this.tabbar = tabbar;
    this.tabbutton = tabbutton;
  }

  void onIndexChange(Observable observable) {
    try {

      // lookup key and url
      String? key;
      String? url;
      if (index != null) {
        var view = views.values.toList()[index!];
        if (view is FrameworkView) {
          key = view.model.dependency;
        }
        url = views.keys.toList()[index!];
      }

      // broadcast the event
      EventManager.of(this)?.broadcastEvent(this,
          Event(EventTypes.focusnode, parameters: {'key': key, 'url': url}));

      // call property change on index
      onPropertyChange(observable);
    } catch (e) {
      Log().exception('Index out of range. Exception is $e');
    }
  }

  @override
  dispose() {
    // cleanup framework models
    var views = this.views.values.toList();
    for (var view in views) {
      deleteView(view);
    }
    super.dispose();
  }

  deleteView(Widget view) {

    // remove specified view
    views.removeWhere((key, value) => value == view);

    // cleanup framework models
    if (view is FrameworkView) {
      view.model.dispose();
    }
  }

  deleteAllIndexesExcept(int index) {
    LinkedHashMap<String, FrameworkView> except = LinkedHashMap<String, FrameworkView>();

    List viewKeys = views.keys.toList();
    List viewList = views.values.toList();
    for (int i = 0; i < viewList.length; i++) {
      if (i == index) {
        except[viewKeys[i]] = viewList[i];
      }
      else {
        var view = views[viewKeys[i]];
        if (view is ViewableWidgetView) {
          (view as ViewableWidgetView).model.dispose();
        }
      }
    }
    views = except;
  }

  static TabViewModel? fromXml(Model parent, XmlElement xml) {
    TabViewModel? model;

    try {
      model = TabViewModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'tab.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement? xml) {

    if (xml == null) return;

    // deserialize
    super.deserialize(xml);

    // properties
    //page = Xml.get(node: xml, tag: 'page);
    tabbar = Xml.get(node: xml, tag: 'tabbar');
    tabbutton = Xml.get(node: xml, tag: 'tabbutton');

    // create Tabs
    List<TabModel> tabs = findChildrenOfExactType(TabModel).cast<TabModel>();
    for (var tab in tabs) {
          views[tab.id] = tab.getView();
        }
  }

  @override
  Widget getView({Key? key}) {
    var view = TabView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}
