// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class TableNoRowsModel extends BoxModel
{
  TableNoRowsModel(WidgetModel parent, String? id) : super(parent, id);

  static TableNoRowsModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    TableNoRowsModel? model;
    try
    {
      model = TableNoRowsModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'norows.Model');
      model = null;
    }
    return model;
  }
}
