// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/datasources/base/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class LogModel extends DataSourceModel implements IDataSource {
  LogModel(super.parent, super.id);

  @override
  bool get autoexecute => super.autoexecute ?? true;

  static LogModel? fromXml(Model parent, XmlElement xml) {
    LogModel? model;
    try {
      model = LogModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'log_model');
      model = null;
    }
    return model;
  }

  @override
  Future<bool> start({bool refresh = false, String? key}) async {
    if (!enabled) return false;
    busy = true;
    Data data = Log().data;
    busy = false;
    return await super.onSuccess(data);
  }

  @override
  Future<dynamic> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    var function = propertyOrFunction.toLowerCase().trim();
    switch (function) {

      case "write":
        String? message = toStr(elementAt(arguments, 0));
        if (message != null) Log().info(message, caller: id);
        return true;

      case "export":
        String format = toStr(elementAt(arguments, 0))?.toLowerCase() ?? "html";
        bool history = toBool(elementAt(arguments, 1)) ?? false;
        Log().export(format: format, withHistory: history);
        return true;

      case "clear":
        Log().clear();
        return true;

      case 'start':
      case 'fire':
        super.onSuccess(Log().data);
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    super.deserialize(xml);
  }
}
