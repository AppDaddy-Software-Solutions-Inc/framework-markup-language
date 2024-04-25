// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';

enum Animations { fade, none }

class HeaderModel extends BoxModel {
  @override
  String? get layout => super.layout ?? "stack";

  @override
  double get height => super.height ?? maxHeight ?? minHeight ?? 100;

  HeaderModel(Model super.parent, super.id);

  static HeaderModel? fromXml(Model parent, XmlElement xml) {
    HeaderModel? model;
    try {
      model = HeaderModel(parent, null);
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'header.Model');
      model = null;
    }
    return model;
  }
}
