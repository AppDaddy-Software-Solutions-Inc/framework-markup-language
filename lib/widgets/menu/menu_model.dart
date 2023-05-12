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
import 'package:fml/helper/common_helpers.dart';

class MenuModel extends DecoratedWidgetModel
{
  static final String typeList   = "list";
  static final String typeButton = "button";

  // prototype
  String? prototype;

  // items
  List<MenuItemModel> items = [];

  @override
  bool get canExpandInfinitelyWide
  {
    if (hasBoundedWidth) return false;
    return true;
  }

  @override
  bool get canExpandInfinitelyHigh
  {
    if (hasBoundedHeight) return false;
    return true;
  }

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
      model = MenuModel(parent, S.newId());
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
    map.forEach((key, value) {
      MenuItemModel item = MenuItemModel(
        null,
        S.newId(),
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
    for (var item in this.items) {
      item.dispose();
    }
    this.items.clear();

    // build items
    List<MenuItemModel> items = findChildrenOfExactType(MenuItemModel).cast<MenuItemModel>();

    // set prototype
    if ((!S.isNullOrEmpty(datasource)) && (items.isNotEmpty))
    {
      prototype = S.toPrototype(items[0].element.toString());
      items.removeAt(0);
    }

    // build items
    for (var item in items) {
      this.items.add(item);
    }
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async
  {
    busy = true;

    // build options
    int i = 0;
    if ((list != null))
    {
      // clear items
      for (var item in items) {
        item.dispose();
      }
      items.clear();

      for (var row in list) {
        XmlElement? prototype = S.fromPrototype(this.prototype, "$id-$i");
        i = i + 1;

        var model = MenuItemModel.fromXml(parent, prototype, data: row);
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
