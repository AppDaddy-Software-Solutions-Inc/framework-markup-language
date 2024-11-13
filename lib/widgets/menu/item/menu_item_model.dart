// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/event/manager.dart';
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:fml/widgets/dragdrop/drag_drop_interface.dart';
import 'package:fml/widgets/menu/item/menu_item_view.dart';
import 'package:fml/widgets/menu/menu_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/event/event.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

// platform
import 'package:fml/platform/platform.vm.dart'
if (dart.library.io) 'package:fml/platform/platform.vm.dart'
if (dart.library.html) 'package:fml/platform/platform.web.dart';

class MenuItemModel extends ViewableModel {

  @override
  double get width  => super.width ?? (isMobile ? 160 : 250);

  @override
  double get height => super.height ?? (isMobile ? 160 : 250);

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

  // onclick
  StringObservable? _onclick;
  set onclick(dynamic v) {
    if (_onclick != null) {
      _onclick!.set(v);
    } else if (v != null) {
      _onclick = StringObservable(Binding.toKey(id, 'onclick'), v,
          scope: scope, listener: onPropertyChange, lazyEvaluation: true);
    }
  }
  String? get onclick => _onclick?.get();

  // title
  StringObservable? _title;
  set title(dynamic v) {
    if (_title != null) {
      _title!.set(v);
    } else if (v != null) {
      _title = StringObservable(Binding.toKey(id, 'title'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get title => _title?.get();

  // subtitle
  StringObservable? _subtitle;
  set subtitle(dynamic v) {
    if (_subtitle != null) {
      _subtitle!.set(v);
    } else if (v != null) {
      _subtitle = StringObservable(Binding.toKey(id, 'subtitle'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get subtitle => _subtitle?.get();

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

  // icon size
  DoubleObservable? _iconsize;
  set iconsize(dynamic v) {
    if (_iconsize != null) {
      _iconsize!.set(v);
    } else if (v != null) {
      _iconsize = DoubleObservable(Binding.toKey(id, 'iconsize'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double? get iconsize => _iconsize?.get();

  // icon color
  ColorObservable? _iconcolor;
  set iconcolor(dynamic v) {
    if (_iconcolor != null) {
      _iconcolor!.set(v);
    } else if (v != null) {
      _iconcolor = ColorObservable(Binding.toKey(id, 'iconcolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  Color? get iconcolor => _iconcolor?.get();

  // font size
  DoubleObservable? _fontsize;
  set fontsize(dynamic v) {
    if (_fontsize != null) {
      _fontsize!.set(v);
    } else if (v != null) {
      _fontsize = DoubleObservable(Binding.toKey(id, 'fontsize'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double? get fontsize => _fontsize?.get();

  // font color
  ColorObservable? _fontcolor;
  set fontcolor(dynamic v) {
    if (_fontcolor != null) {
      _fontcolor!.set(v);
    } else if (v != null) {
      _fontcolor = ColorObservable(Binding.toKey(id, 'fontcolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  Color? get fontcolor => _fontcolor?.get();

  // indicates if this item has been selected
  BooleanObservable? _selected;
  set selected(dynamic v) {
    if (_selected != null) {
      _selected!.set(v);
    } else if (v != null) {
      _selected =
          BooleanObservable(Binding.toKey(id, 'selected'), v, scope: scope);
    }
  }
  bool get selected => _selected?.get() ?? false;

  VoidCallback? onLongPress;
  VoidCallback? onTap;
  UriData? image;

  MenuItemModel(Model super.parent, super.id,
      {super.data,
      dynamic url,
      dynamic title,
      dynamic onclick,
      dynamic subtitle,
      dynamic fontsize,
      dynamic fontcolor,
      dynamic fontweight,
      dynamic icon,
      dynamic iconcolor,
      dynamic iconsize,
      dynamic color,
      this.onLongPress,
      this.onTap,
      dynamic radius,
      dynamic enabled,
      String? image})
      : super(scope: Scope(parent: parent.scope)) {

    this.title = title;
    this.subtitle = subtitle;

    this.url = url;
    this.onclick = onclick;

    this.icon = icon;
    this.iconsize = iconsize;
    this.iconcolor = iconcolor;

    this.fontcolor = fontcolor;
    this.fontsize = fontsize;

    this.color = color;

    this.enabled = enabled;

    if (image != null) this.image = toDataUri(image);
  }

  static MenuItemModel? fromXml(Model parent, XmlElement? xml,
      {dynamic data, dynamic onTap, dynamic onLongPress}) {
    MenuItemModel? model;
    try {
      // build model
      model = MenuItemModel(parent, Xml.get(node: xml, tag: 'id'),
          data: data, onTap: onTap, onLongPress: onLongPress);
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'menu.item.Model');
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
    title = Xml.get(node: xml, tag: 'title');
    subtitle = Xml.get(node: xml, tag: 'subtitle');

    url = Xml.get(node: xml, tag: 'url');
    onclick = Xml.get(node: xml, tag: 'onclick');

    fontsize = Xml.get(node: xml, tag: 'fontsize');
    fontcolor = Xml.get(node: xml, tag: 'fontcolor');

    icon = Xml.get(node: xml, tag: 'icon');
    iconsize = Xml.get(node: xml, tag: 'iconsize');
    iconcolor = Xml.get(node: xml, tag: 'iconcolor');

    enabled = Xml.get(node: xml, tag: 'enabled');
  }

  Future<bool?> onClick() async {

    var menu = findAncestorOfExactType(MenuModel);
    if (menu is MenuModel) {
      menu.onTap(this);
    }

    if (url != null && onclick == null) {
      String? bc;
      try {
        Uri? uri = URI.parse(url!);
        bc = uri?.queryParameters['breadcrumb'];
      } catch (e) {
        Log().debug('$e');
      }
      return EventManager.of(this)?.broadcastEvent(
          this,
          Event(EventTypes.open,
              bubbles: true,
              parameters: {'url': url, 'breadcrumb': bc ?? title}));
    }
    if (onclick == null) return true;
    return await EventHandler(this).execute(_onclick);
  }

  @override
  void onDrop(IDragDrop draggable, {Offset? dropSpot}) {
    if (parent is MenuModel) {
      (parent as MenuModel).onDragDrop(this, draggable, dropSpot: dropSpot);
    }
  }

  @override
  Widget getView({Key? key}) {
    var view = MenuItemView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}
