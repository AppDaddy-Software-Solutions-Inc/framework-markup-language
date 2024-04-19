// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/datasources/base/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class DataModel extends DataSourceModel implements IDataSource {
  @override
  bool get autoexecute => super.autoexecute ?? true;

  DataModel(super.parent, super.id, {dynamic datastring});

  static DataModel? fromXml(Model parent, XmlElement xml) {
    DataModel? model;
    try {
      model = DataModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'data.Model');
      model = null;
    }
    return model;
  }
}
