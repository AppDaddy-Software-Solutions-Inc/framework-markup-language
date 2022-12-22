// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/datasources/base/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helper/helper_barrel.dart';

class DataModel extends DataSourceModel implements IDataSource
{
  DataModel(WidgetModel parent, String? id) : super(parent, id);

  @override
  bool get autoexecute => super.autoexecute ?? true;

  static DataModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    DataModel? model;
    try
    {
      model = DataModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'data.Model');
      model = null;
    }
    return model;
  }
}
