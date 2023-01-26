// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/drawer/drawer_view.dart' as DRAWER;
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/widgets/box/box_model.dart' as BOX;
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

enum DrawerPositions {top, bottom, left, right}

class DrawerItemModel extends BOX.BoxModel
{
  final DrawerPositions position;

  DrawerItemModel(WidgetModel parent, String? id, this.position) : super(parent, id);

  static DrawerItemModel? fromXml(WidgetModel parent, XmlElement? xml, DrawerPositions position)
  {
    DrawerItemModel? model;
    try
    {
      model = DrawerItemModel(parent, Xml.get(node: xml, tag: 'id'), position);
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'drawerItem.Model');
      model = null;
    }
    return model;
  }

  @override
  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async
  {
    if (scope == null) return null;

    var function = propertyOrFunction.toLowerCase().trim();
    switch (function)
    {
      case "open" :
        DRAWER.DrawerViewState? drawer = this.parent?.findListenerOfExactType(DRAWER.DrawerViewState);
        if (drawer != null) return await drawer.openDrawer(S.fromEnum(this.position));
        break;

      case "close" :
        DRAWER.DrawerViewState? drawer = this.parent?.findListenerOfExactType(DRAWER.DrawerViewState);
        if (drawer != null) return await drawer.closeDrawer(S.fromEnum(this.position));
        break;

    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

}