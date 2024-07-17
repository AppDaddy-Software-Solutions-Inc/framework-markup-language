// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:fml/event/event.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/framework/framework_model.dart';
import 'package:fml/widgets/framework/framework_view.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:fml/widgets/tabview/tab_model.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/widgets/tabview/tabview_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class TabViewModel extends BoxModel {

  // holds the current view
  final List<TabModel> tabs = [];

  @override
  LayoutType get layoutType => LayoutType.column;

  @override
  List<ViewableMixin> get viewableChildren {
    List<ViewableMixin> list = [];
    for (var tab in tabs) {
      list.add(tab);
    }
    return list;
  }

  // current index
  IntegerObservable? _index;
  set index(dynamic v) {
    int? i = toInt(v);
    if (i != null && (i >= tabs.length || i < 0)) v = null;
    if (_index != null) {
      _index!.set(v);
    } else {
      _index = IntegerObservable(Binding.toKey(id, 'index'), v, scope: scope);
    }
    onIndexChange(_index!);
  }
  int get index {
    var i = _index?.get() ?? 0;
    if (i >= tabs.length) i = tabs.length - 1;
    if (i < 0) i = 0;
    return i;
  }

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
      if (index >= 0) {
        var view = tabs[index].getView();
        if (view is FrameworkView) {
          key = view.model.dependency;
        }
        url = tabs[index].url;
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

  // returns the current tab
  TabModel? get currentTab => index == -1 ? null : tabs[index];

  @override
  dispose() {
    // cleanup view models
    for (var tab in tabs) {
      tab.dispose();
    }
    super.dispose();
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
    index = Xml.get(node: xml, tag: 'index');
    tabbar = Xml.get(node: xml, tag: 'tabbar');
    tabbutton = Xml.get(node: xml, tag: 'tabbutton');

    // create Tabs
    var tabs = findChildrenOfExactType(TabModel).cast<TabModel>();
    for (var tab in tabs) {
      this.tabs.add(tab);
    }

    // remove tabs
    removeChildrenOfExactType(TabModel);
  }

  void showPreviousTab()
  {
    if (index == -1) return;
    int i = index - 1;
    if (i.isNegative) i = tabs.length - 1;
    index = i;
  }

  void showNextTab() {
    if (index == -1) return;
    int i = index + 1;
    if (i >= tabs.length) i = 0;
    index = i;
  }

  void showFirstTab() => index = 0;

  void showLastTab() {
    int i = tabs.length - 1;
    if (i.isNegative) i = 0;
    index = i;
  }

  void showTab(String? url, {bool refresh = false, String? dependency, String? title, bool? closeable}) {

    // String template = uri.host;
    var uri = URI.parse(url);
    if (uri == null) return;

    var id = uri.url.toLowerCase();
    if (id == 'previous') return showPreviousTab();
    if (id == 'next') return showNextTab();
    if (id == 'first') return showFirstTab();
    if (id == 'last') return showLastTab();

    // get tab by matching id
    var tab = tabs.firstWhereOrNull((tab) => tab.url == id);

    // New Tab
    if (tab == null || refresh) {

      // title
      title = title ?? uri.queryParameters['title'] ?? uri.page.toString();

      // closeable
      closeable = closeable ?? toBool(uri.queryParameters['closeable']) ?? true;

      // build tab
      tab = TabModel(this, id, url: uri.url, title: title, closeable: closeable);
      tabs.add(tab);

      // add framework child
      tab.children ??= [];
      tab.children!.add(FrameworkModel.fromUrl(tab, uri.url, dependency: dependency));
    }

    // set the current index
    index = tabs.indexOf(tab);
  }

  void deleteTab(TabModel tab) {
    if (tabs.contains(tab)) {
      tab.dispose();
      showPreviousTab();
    }
  }

  void deleteAllTabsExcept(int index) {
    if (index < 0 || index >= tabs.length) return;
    var keep = tabs[index];
    var discard = tabs.where((t) => t != keep).toList();
    for (var tab in discard) {
      if (tab.closeable) {
        tab.dispose();
        tabs.remove(tab);
      }
    }
  }

  // fire triggers across each tab
  void fireTriggers(Event event) {
    for (var tab in tabs) {
      tab.fireTriggers(event);
    }
  }

  @override
  Future<bool?> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    /// setter
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    switch (function) {

      case "open":

        // set the index
        var index = toInt(elementAt(arguments, 0));
        if (index != null) {
          this.index = index;
          return true;
        }

        // id
        var id = toStr(elementAt(arguments, 0));
        if (id != null) {
          var tab = tabs.firstWhereOrNull((t) => t.id == id);
          if (tab != null) {
            this.index = tabs.indexOf(tab);
            return true;
          }
        }

        // url
        var url = toStr(elementAt(arguments, 0));
        if (url != null) {
          var tab = tabs.firstWhereOrNull((t) => t.url == url);
          if (tab != null) {
            this.index = tabs.indexOf(tab);
            return true;
          }
        }

        return true;

      // close specified tab
      case "close":
        var index = toInt(elementAt(arguments, 0)) ?? this.index;
        if (tabs.isEmpty) return true;
        if (index < 0) index = 0;
        if (index >= tabs.length) index = tabs.length - 1;
        deleteTab(tabs[index]);
        return true;

      case "add":
        var url = toStr(elementAt(arguments, 0));
        var title = toStr(elementAt(arguments, 1));
        var closeable = toBool(elementAt(arguments, 2));
        showTab(url, title: title, closeable: closeable);
        return true;

      // close specified tab
      case "next":
        showNextTab();
        return true;

      case "prev":
      case "previous":
        showPreviousTab();
        return true;

      case "first":
        showPreviousTab();
        return true;

      case "last":
        showPreviousTab();
        return true;

    }

    return super.execute(caller, propertyOrFunction, arguments);
  }

  @override
  Widget getView({Key? key}) {
    var view = TabView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}
