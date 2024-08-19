// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/event/event.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/framework/framework_model.dart';
import 'package:fml/widgets/tabview/tabview_model.dart';
import 'package:fml/widgets/trigger/trigger_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class TabModel extends BoxModel {

  @override
  LayoutType layoutType = LayoutType.column;

  @override
  bool get expand => true;

  // the defined view
  Widget? _view;

  // url
  StringObservable? _url;
  set url(dynamic v) {
    if (_url != null) {
      _url!.set(v);
    } else if (v != null) {
      _url = StringObservable(Binding.toKey(id, 'url'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get url => _url?.get();

  /// The title of the tab
  StringObservable? _title;
  set title(dynamic v) {
    if (_title != null) {
      _title!.set(v);
    } else if (v != null) {
      _title = StringObservable(Binding.toKey(id, 'title'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String get title => _title?.get() ?? _url?.get() ?? id;

  // closeable
  BooleanObservable? _closeable;
  set closeable(dynamic v) {
    if (_closeable != null) {
      _closeable!.set(v);
    } else if (v != null) {
      _closeable = BooleanObservable(Binding.toKey(id, 'closeable'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get closeable => _closeable?.get() ?? true;

  // show tooltips
  StringObservable? _tooltip;
  set tooltip(dynamic v) {
    if (_tooltip != null) {
      _tooltip!.set(v);
    } else if (v != null) {
      _tooltip = StringObservable(Binding.toKey(id, 'tooltip'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get tooltip => _tooltip?.get();

  // icon
  IconObservable? _icon;
  set icon(dynamic v) {
    if (_icon != null) {
      _icon!.set(v);
    } else if (v != null) {
      _icon = IconObservable(Binding.toKey(id, 'icon'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  IconData? get icon => _icon?.get();

  // dependency key
  StringObservable? _dependency;
  set dependency(dynamic v) {
    if (_dependency != null) {
      _dependency!.set(v);
      if (element != null) Xml.setAttribute(element!, 'dependency', v);
    } else if (v != null) {
      _dependency =
          StringObservable(Binding.toKey(id, 'dependency'), v, scope: scope);
      if (element != null) Xml.setAttribute(element!, 'dependency', v);
    }
  }
  String? get dependency => _dependency?.get();

  TabModel(super.parent, super.id, {bool scoped = false, dynamic data, dynamic url, dynamic icon, String? dependency, String? title, bool? closeable, String? tooltip})
      : super(scope: scoped ? Scope(parent: parent?.scope) : null) {
    this.data = data;
    this.url = url;
    this.title = title;
    this.closeable = closeable;
    this.tooltip = tooltip;
    this.icon = icon;
    this.dependency = dependency;
  }

  static TabModel? fromXml(Model? parent, XmlElement? xml,
      {bool scoped = false, dynamic data, dynamic onTap, dynamic onLongPress}) {
    TabModel? model;
    try {
      // build model
      model = TabModel(parent, Xml.get(node: xml, tag: 'id'), data: data, scoped: scoped);
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'TabModel');
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
    url = Xml.get(node: xml, tag: 'url');
    title = Xml.get(node: xml, tag: 'title');

    // can window be closed?
    closeable = Xml.get(node: xml, tag: 'closeable');
    if (_closeable == null && _url == null && viewableChildren.isNotEmpty) closeable = false;

    tooltip = Xml.get(node: xml, tag: 'tooltip');
    icon = Xml.get(node: xml, tag: 'icon');

    // add framework child
    if (viewableChildren.isEmpty && url != null) {
      var uri = URI.parse(url);
      if (uri != null) {
        children ??= [];
        children!.add(FrameworkModel.fromUrl(this, uri.url));
      }
    }
  }

  // fires framework triggers
  void fireTriggers(Event event) {

    var model = children?.first;

    // tab is a framework
    if (model is FrameworkModel) {

      // broadcast the event to the tab
      model.eventManager.broadcast(model, event);

      // fire the tab triggers
      List<TriggerModel> triggers = model.findDescendantsOfExactType(TriggerModel).cast();
      for (var trigger in triggers) {
        if (event.parameters?['id'] == trigger.id) {
          trigger.trigger();
        }
      }
    }
  }

  @override
  Future<dynamic> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    /// setter
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    switch (function) {

      case "open":
        // set the index
        if (parent is TabViewModel)
        {
          // set the parent index
          var index = (parent as TabViewModel).tabs.indexOf(this);
          (parent as TabViewModel).index = index;
        }
        return true;

    // close specified tab
      case "close":
      // set the index
        if (parent is TabViewModel)
        {
          (parent as TabViewModel).deleteTab(this);
        }
        return true;
    }

    return super.execute(caller, propertyOrFunction, arguments);
  }

  @override
  Widget getView({Key? key}) {

    // cached view?
    if (_view != null) return _view!;

    // wrapped framework?
    if (children?.first is FrameworkModel) _view = (children!.first as FrameworkModel).getView();

    // box view
    _view ??= BoxView(this, (_,__) => inflate());

    return _view!;
  }
}
