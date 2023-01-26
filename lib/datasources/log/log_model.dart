// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/datasources/base/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

class LogModel extends DataSourceModel implements IDataSource
{
  LogModel(WidgetModel parent, String? id) : super(parent, id);

  @override
  Data? get data => Log().data;

  static LogModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    LogModel? model;
    try
    {
      model = LogModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'iframe.Model');
      model = null;
    }
    return model;
  }

  @override
  Future<bool?> execute(String propertyOrFunction, List<dynamic> arguments) async
  {
    var function = propertyOrFunction.toLowerCase().trim();
    switch (function)
    {
      case "write":
        String? message = S.toStr(S.item(arguments, 0));
        if (message != null) Log().info(message, caller: id);
        return true;

      case "export":
        String format  =  S.toStr(S.item(arguments, 0))?.toLowerCase() ?? "html";
        bool   history =  S.toBool(S.item(arguments, 1)) ?? false;
        Log().export(format: format, withHistory: history);
        return true;

      case "clear":
        Log().clear();
        return true;
    }
    return super.execute(propertyOrFunction, arguments);
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    super.deserialize(xml);
  }
}