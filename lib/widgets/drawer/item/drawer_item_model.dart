// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/drawer/drawer_model.dart';
import 'package:fml/widgets/drawer/drawer_view.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class DrawerItemModel extends BoxModel {
  final Drawers position;

  DrawerItemModel(Model super.parent, super.id, this.position);

  static DrawerItemModel? fromXml(
      Model parent, XmlElement? xml, Drawers position) {
    DrawerItemModel? model;
    try {
      model = DrawerItemModel(parent, Xml.get(node: xml, tag: 'id'), position);
      if (xml != null) {
        model.deserialize(xml);
      }
    } catch (e) {
      Log().exception(e, caller: 'drawerItem.Model');
      model = null;
    }
    return model;
  }

  @override
  Future<dynamic> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    if (scope == null) return null;

    var function = propertyOrFunction.toLowerCase().trim();
    switch (function) {
      case "open":
        DrawerViewState? drawer =
            parent?.findListenerOfExactType(DrawerViewState);
        if (drawer != null) return await drawer.openDrawer(position);
        break;

      case "close":
        DrawerViewState? drawer =
            parent?.findListenerOfExactType(DrawerViewState);
        if (drawer != null) return await drawer.closeDrawer(position);
        break;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }
}
