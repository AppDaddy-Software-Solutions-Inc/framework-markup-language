// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/datasources/base/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class TestDataModel extends DataSourceModel implements IDataSource {

  int rows = 100;

  @override
  bool get autoexecute => super.autoexecute ?? true;

  TestDataModel(super.parent, super.id, {dynamic datastring});

  static TestDataModel? fromXml(Model parent, XmlElement xml) {
    TestDataModel? model;
    try {

      model = TestDataModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);

      model.rows = toInt(Xml.get(node: xml, tag: 'rows'))  ?? 100;
      var delay = toInt(Xml.get(node: xml, tag: 'delay')) ?? 0;

      if (delay <= 0) {
        model.data = Data.testData(model.rows);
        return model;
      }

      model.busy = true;
      Future.delayed(Duration(seconds: delay), () {
        var data = Data.testData(model!.rows);
        model.onData(data);
        model.busy = false;
      });
    }
    catch (e) {
      Log().exception(e, caller: 'data.Model');
      model = null;
    }
    return model;
  }

  @override
  Future<bool?> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();
    switch (function) {
      case "start":
      case "load":
        data = Data.testData(toInt(elementAt(arguments, 0)) ?? rows);
        onSuccess(data!, code: 200, message: "Ok");
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }
}
