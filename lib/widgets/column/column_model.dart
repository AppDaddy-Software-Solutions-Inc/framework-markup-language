// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class ColumnModel extends BoxModel
{
  @override
  LayoutType layoutType = LayoutType.column;

  @override
  String? get layout => "column";

  // indicates if the widget will grow in
  // its horizontal axis
  @override
  bool get expandHorizontally
  {
    if (!super.expandHorizontally) return false;
    bool flexible = false;
    for (var child in viewableChildren)
    {
      if (child.visible && child.expandHorizontally)
      {
        flexible = true;
        break;
      }
    }
    return flexible;
  }

  ColumnModel(WidgetModel parent, String? id, {Scope? scope, dynamic data}) : super(parent, id, scope: scope, data: data);

  static ColumnModel? fromXml(WidgetModel parent, XmlElement xml, {Scope? scope, dynamic data})
  {
    ColumnModel? model;
    try
    {
      // build model
      model = ColumnModel(parent, Xml.get(node: xml, tag: 'id'), scope: scope, data: data);
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'column.Model');
      model = null;
    }
    return model;
  }
}
