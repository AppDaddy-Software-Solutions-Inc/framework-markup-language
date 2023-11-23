// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/boolean.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:fml/widgets/scroller/scroller_interface.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/menu/menu_view.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/menu/item/menu_item_model.dart';
import 'package:fml/helpers/helpers.dart';

class MenuModel extends DecoratedWidgetModel implements IScrollable
{
  static final String typeList   = "list";
  static final String typeButton = "button";

  // to be implemented
  @override
  bool moreUp = false;

  @override
  bool moreDown = false;

  @override
  bool moreLeft = false;

  @override
  bool moreRight = false;

  // items
  List<MenuItemModel> items = [];

  // data sourced prototype
  XmlElement? prototype;

  @override
  bool get canExpandInfinitelyWide => !hasBoundedWidth;

  @override
  bool get canExpandInfinitelyHigh => !hasBoundedHeight;

  // allow drag
  BooleanObservable? _allowDrag;
  set allowDrag(dynamic v) {
    if (_allowDrag != null) {
      _allowDrag!.set(v);
    } else if (v != null) {
      _allowDrag = BooleanObservable(Binding.toKey(id, 'allowdrag'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get allowDrag => _allowDrag?.get() ?? false;

  MenuModel(WidgetModel? parent, String?  id) : super(parent, id)
  {
    // instantiate busy observable
    busy = false;
  }

  static MenuModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    MenuModel? model;
    try
    {
      model = MenuModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'menu.Model');
      model = null;
    }
    return model;
  }

  static MenuModel? fromMap(WidgetModel parent, Map<String, String> map)
  {
    MenuModel? model;
    try
    {
      model = MenuModel(parent, newId());
      model.unmap(map);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'menu.Model');
      model = null;
    }
    return model;
  }

  void unmap(Map<String, String> map)
  {
    map.forEach((key, value)
    {
      MenuItemModel item = MenuItemModel(
        this,
        newId(),
        // url: ,
        title: key,
        // subtitle: ,
        icon: Icons.navigation_outlined,
      );
      items.add(item);
    });
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize 
    super.deserialize(xml);

    // allow mouse drag
    allowDrag = Xml.get(node: xml, tag: 'allowDrag');

    // clear items
    for (var item in items) {
      item.dispose();
    }
    items.clear();

    // build menu items
    _buildItems();
  }

  void _buildItems()
  {
    // build items
    List<MenuItemModel> items = findChildrenOfExactType(MenuItemModel).cast<MenuItemModel>();

    // set prototype
    if ((!isNullOrEmpty(datasource)) && (items.isNotEmpty))
    {
      prototype = prototypeOf(items.first.element);
      items.removeAt(0);
    }

    // build items
    this.items.addAll(items);
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async
  {
    busy = true;

    // build options
    if ((list != null))
    {
      // clear items
      for (var item in items)
      {
        item.dispose();
      }
      items.clear();

      for (var row in list)
      {
        var model = MenuItemModel.fromXml(this, prototype, data: row);
        if (model != null) items.add(model);
      }

      notifyListeners('list', items);
    }

    busy = false;

    return true;
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');

    // clear items
    for (var item in items) {
      item.dispose();
    }
    items.clear();

    super.dispose();
  }

  @override
  void scrollUp(int pixels)
  {
    MenuViewState? view = findListenerOfExactType(MenuViewState);
    if (view == null) return;

    // already at top
    if (view.controller.offset == 0) return;

    var to = view.controller.offset - pixels;
    to = (to < 0) ? 0 : to;

    view.controller.jumpTo(to);
  }

  @override
  void scrollDown(int pixels)
  {
    MenuViewState? view = findListenerOfExactType(MenuViewState);
    if (view == null) return;

    if (view.controller.position.pixels >= view.controller.position.maxScrollExtent) return;

    var to = view.controller.offset + pixels;
    to = (to > view.controller.position.maxScrollExtent) ? view.controller.position.maxScrollExtent : to;

    view.controller.jumpTo(to);
  }

  @override
  Offset? positionOf()
  {
    MenuViewState? view = findListenerOfExactType(MenuViewState);
    return view?.positionOf();
  }

  @override
  Size? sizeOf()
  {
    MenuViewState? view = findListenerOfExactType(MenuViewState);
    return view?.sizeOf();
  }

  @override
  Widget getView({Key? key}) => getReactiveView(MenuView(this));
}
