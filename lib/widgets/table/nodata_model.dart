// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class NoDataModel extends BoxModel {
  NoDataModel(Model super.parent, super.id);

  static NoDataModel? fromXml(Model parent, XmlElement xml) {
    NoDataModel? model;
    try {
      model = NoDataModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'NODATA');
      model = null;
    }
    return model;
  }
}
