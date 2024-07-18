// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/event/event.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/framework/framework_model.dart';
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

  // the list item prototype
  XmlElement? prototype;

  // IDataSource
  IDataSource? myDataSource;

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
    if (tabs.isEmpty) return -1;
    var i = _index?.get() ?? 0;
    if (i >= tabs.length) i = tabs.length - 1;
    if (i < 0) i = 0;
    return i;
  }

  BooleanObservable? _showBar;
  set showBar(dynamic v) {
    if (_showBar != null) {
      _showBar!.set(v);
    } else if (v != null) {
      _showBar = BooleanObservable(Binding.toKey(id, 'bar'), v, scope: scope);
    }
  }
  bool get showBar => _showBar?.get() ?? true;

  BooleanObservable? _showMenu;
  set showMenu(dynamic v) {
    if (_showMenu != null) {
      _showMenu!.set(v);
    } else if (v != null) {
      _showMenu =
          BooleanObservable(Binding.toKey(id, 'menu'), v, scope: scope);
    }
  }
  bool get showMenu => _showMenu?.get() ?? true;

  // handle the back button
  BooleanObservable? _allowback;
  set allowback(dynamic v) {
    if (_allowback != null) {
      _allowback!.set(v);
    } else if (v != null) {
      _allowback =
          BooleanObservable(Binding.toKey(id, 'allowback'), v, scope: scope);
    }
  }
  bool get allowback => _allowback?.get() ?? true;

  TabViewModel(
    super.parent,
    super.id, {
    dynamic tabbar,
    dynamic tabbutton,
    dynamic allowback
  }) {
    this.showBar = tabbar;
    this.showMenu = tabbutton;
    this.allowback = allowback;
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
    showBar = Xml.get(node: xml, tag: 'bar') ?? Xml.get(node: xml, tag: 'tabbar');
    showMenu = Xml.get(node: xml, tag: 'menu') ?? Xml.get(node: xml, tag: 'tabbutton');
    allowback = Xml.get(node: xml, tag: 'allowback');

    // create Tabs
    var tabs = findChildrenOfExactType(TabModel).cast<TabModel>();

    // set prototype
    if (!isNullOrEmpty(datasource) && tabs.isNotEmpty) {

      // set prototype
      prototype = prototypeOf(tabs.first.element);
      tabs.removeAt(0);
    }

    // add remaining children
    for (var tab in tabs) {
      this.tabs.add(tab);
    }

    // remove tabs
    removeChildrenOfExactType(TabModel);
  }


  void onIndexChange(Observable observable) {

    try {
      // lookup key and url
      String? key;
      String? url;
      if (index >= 0) {
        var tab = tabs[index];
        if (tab is FrameworkModel) {
          key = (tab as FrameworkModel).dependency;
        }
        url = tab.url;
      }

      // broadcast the event
      EventManager.of(this)?.broadcastEvent(this, Event(EventTypes.focusnode, parameters: {'key': key, 'url': url}));

      // call property change on index
      onPropertyChange(observable);

    } catch (e) {
      Log().exception('OnIndexChange. Exception is $e');
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

  void showTab(String? url, {bool refresh = false, String? dependency, String? title, bool? closeable, String? icon}) {

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

      // icon
      icon = icon ?? uri.queryParameters['icon'];

      // closeable
      closeable = closeable ?? toBool(uri.queryParameters['closeable']) ?? true;

      // build tab
      tab = TabModel(this, id, url: uri.url, title: title, closeable: closeable, icon: icon);
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
      tabs.remove(tab);
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
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async {
    busy = true;

    // save pointer to data source
    myDataSource = source;

    // clear items
    for (var tab in tabs) {
      tab.dispose();
    }
    tabs.clear();

    // set data
    data = list ?? Data();

    // build tabs
    for (var d in data) {

      // scoped tab model
      var model = TabModel.fromXml(this, prototype, scoped: true, data: d);

      if (model != null) {
        tabs.add(model);
      }
    }

    // notify listeners
    notifyListeners('tabs', tabs);

    busy = false;
    return true;
  }

  @override
  Future<bool?> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    /// setter
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    switch (function) {

      case "open":

        // open by index
        var index = toInt(elementAt(arguments, 0));
        if (index != null) {
          this.index = index;
          return true;
        }

        // open by id
        var id = toStr(elementAt(arguments, 0));
        if (id != null) {
          var tab = tabs.firstWhereOrNull((t) => t.id == id);
          if (tab != null) {
            this.index = tabs.indexOf(tab);
            return true;
          }
        }

        // open by url
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

        // close by index
        var index = toInt(elementAt(arguments, 0));
        if (index != null) {
          if (index < 0) index = 0;
          if (index >= tabs.length) index = tabs.length - 1;
          deleteTab(tabs[index]);
          return true;
        }

        // close by id
        var id = toStr(elementAt(arguments, 0));
        if (id != null) {
          var tab = tabs.firstWhereOrNull((t) => t.id == id);
          if (tab != null) {
            deleteTab(tab);
            return true;
          }
        }

        // close by url
        var url = toStr(elementAt(arguments, 0));
        if (url != null) {
          var tab = tabs.firstWhereOrNull((t) => t.url == url);
          if (tab != null) {
            deleteTab(tab);
            return true;
          }
        }

        return true;

      case "add":
        var url = toStr(elementAt(arguments, 0));
        var title = toStr(elementAt(arguments, 1));
        var closeable = toBool(elementAt(arguments, 2));
        var icon = toStr(elementAt(arguments, 3));
        showTab(url, title: title, closeable: closeable, icon: icon);
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
