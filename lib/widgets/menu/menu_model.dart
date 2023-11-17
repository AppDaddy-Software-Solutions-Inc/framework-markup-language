// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/menu/menu_view.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/menu/item/menu_item_model.dart';
import 'package:fml/helpers/helpers.dart';

class MenuModel extends DecoratedWidgetModel
{
  static final String typeList   = "list";
  static final String typeButton = "button";

  // items
  List<MenuItemModel> items = [];

  // data sourced prototype
  XmlElement? prototype;

  @override
  bool get canExpandInfinitelyWide => !hasBoundedWidth;

  @override
  bool get canExpandInfinitelyHigh => !hasBoundedHeight;

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
      prototype = WidgetModel.prototypeOf(items.first.element);
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
  Widget getView({Key? key}) => getReactiveView(MenuView(this));
}
