// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/drawer/drawer_view.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/widgets/box/box_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

enum DrawerPositions {top, bottom, left, right}

class DrawerItemModel extends BoxModel
{
  final DrawerPositions position;

  DrawerItemModel(WidgetModel parent, String? id, this.position) : super(parent, id);

  static DrawerItemModel? fromXml(WidgetModel parent, XmlElement? xml, DrawerPositions position)
  {
    DrawerItemModel? model;
    try
    {
      model = DrawerItemModel(parent, Xml.get(node: xml, tag: 'id'), position);
      if (xml != null)
      {
        model.deserialize(xml);
      }
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
        DrawerViewState? drawer = parent?.findListenerOfExactType(DrawerViewState);
        if (drawer != null) return await drawer.openDrawer(S.fromEnum(position));
        break;

      case "close" :
        DrawerViewState? drawer = parent?.findListenerOfExactType(DrawerViewState);
        if (drawer != null) return await drawer.closeDrawer(S.fromEnum(position));
        break;

    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

}