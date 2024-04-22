// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

/// Card [CardModel]
///
/// DEPRECATED
/// Defines the properties used to build a [CARD.CardView]
class CardModel extends BoxModel {
  @override
  double get elevation => super.elevation ?? 1;

  @override
  String get borderRadius => super.borderRadius ?? "4";

  double get padding => super.paddingTop ?? 5;

  @override
  String get border => 'all';

  //overrides
  double? get margins => super.marginTop ?? 5;

  @override
  String get halign => super.halign ?? "start";

  @override
  String get valign => super.valign ?? "start";

  @override
  Color? get color => super.color ?? Colors.white;

  CardModel(Model super.parent, super.id) : super(expandDefault: false);

  static CardModel? fromXml(Model parent, XmlElement xml) {
    CardModel? model;
    try {
      // build model
      model = CardModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'card.Model');
      model = null;
    }
    return model;
  }

  @override
  void deserialize(XmlElement? xml) {
    if (xml == null) return;

    /// override of expand
    var expand = Xml.get(node: xml, tag: 'expand');
    if (expand == null) this.expand = false;

    // deserialize
    super.deserialize(xml);
  }

  @override
  Widget getView({Key? key}) => getReactiveView(BoxView(this, (_,__) => inflate()));
}
