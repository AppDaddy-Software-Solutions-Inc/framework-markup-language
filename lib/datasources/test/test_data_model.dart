// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/datasources/base/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

class TestDataModel extends DataSourceModel implements IDataSource
{
  @override
  bool get autoexecute => super.autoexecute ?? true;

  TestDataModel(WidgetModel parent, String? id, {dynamic datastring}) : super(parent, id);

  static TestDataModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    TestDataModel? model;
    try
    {
      model = TestDataModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);

      var rows = S.toInt(Xml.get(node: xml, tag: 'rows')) ?? 100;
      model.data = Data.testData(rows);
    }
    catch(e)
    {
      Log().exception(e, caller: 'data.Model');
      model = null;
    }
    return model;
  }
}
