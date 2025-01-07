// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/datasources/http/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class HttpGetModel extends HttpModel {

  @override
  HttpMethods get method => HttpMethods.get;

  @override
  bool get autoexecute => super.autoexecute ?? true;

  HttpGetModel(super.parent, super.id);

  static HttpGetModel? fromXml(Model parent, XmlElement xml) {
    HttpGetModel? model;
    try {
      model = HttpGetModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'get.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    super.deserialize(xml);
  }

  @override
  Future<dynamic> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    bool refresh = toBool(elementAt(arguments, 0)) ?? false;
    switch (function) {
      case "get":
        return await start(refresh: refresh);
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }
}
