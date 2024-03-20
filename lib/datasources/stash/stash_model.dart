// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/hive/stash.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/datasources/base/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class StashModel extends DataSourceModel implements IDataSource {
  StashModel(super.parent, super.id);

  @override
  bool get autoexecute => super.autoexecute ?? true;

  static StashModel? fromXml(WidgetModel parent, XmlElement xml) {
    StashModel? model;
    try {
      model = StashModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'stash_model');
      model = null;
    }
    return model;
  }

  @override
  Future<bool> start({bool refresh = false, String? key}) async {
    if (enabled == false) return false;

    busy = true;
    Data data = await Stash.getData();
    busy = false;
    return await super.onSuccess(data);
  }

  @override
  Future<bool?> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    var function = propertyOrFunction.toLowerCase().trim();
    switch (function) {
      // case "export":
      //   String format  =  toStr(elementAt(arguments, 0))?.toLowerCase() ?? "html";
      //   bool   history =  toBool(elementAt(arguments, 1)) ?? false;
      //   Stash().export(format: format, withHistory: history);
      //   return true;

      // case "clear":
      //   Stash().delete();
      //   return true;

      case 'start':
      case 'fire':
        Data data = await Stash.getData();
        super.onSuccess(data);
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
