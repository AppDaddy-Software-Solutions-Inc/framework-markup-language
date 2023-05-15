// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

class ColumnModel extends BoxModel
{
  @override
  LayoutType layoutType = LayoutType.column;

  @override
  String? get layout => "column";

  // expands in the horizontal
  @override
  bool get hasFlexibleWidth => false;

  ColumnModel(WidgetModel parent, String? id) : super(parent, id);

  static ColumnModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    ColumnModel? model;
    try
    {
      // build model
      model = ColumnModel(parent, Xml.get(node: xml, tag: 'id'));
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
