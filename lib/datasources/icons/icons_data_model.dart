// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/graphics.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/datasources/base/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class IconsDataModel extends DataSourceModel implements IDataSource {

  @override
  bool get autoexecute => true;

  IconsDataModel(super.parent, super.id, {dynamic datastring});

  static IconsDataModel? fromXml(Model parent, XmlElement xml) {
    IconsDataModel? model = IconsDataModel(parent, Xml.get(node: xml, tag: 'id'));
    model.deserialize(xml);
    var data = generate();
    model.onSuccess(data, code: 200, message: "Ok");
    return model;
  }

  static Data generate() {
    Data data = Data();
    for (var key in Graphics.icons.keys) {
      var row = <String, dynamic>{};
      row["icon"] = key;
      data.add(row);
    }
    return data;
  }
}
