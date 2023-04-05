// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/layout_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/column/column_view.dart';
import 'package:fml/helper/common_helpers.dart';

class ColumnModel extends LayoutWidgetModel
{
  @override
  bool isVerticallyConstrained() => constraints.model.hasVerticalExpansionConstraints || constraints.system.hasVerticalExpansionConstraints;

  @override
  bool isHorizontallyConstrained() => true;

  @override
  MainAxisSize getVerticalAxisSize() => (expand && isVerticallyConstrained()) ? MainAxisSize.max : MainAxisSize.min;

  @override
  String? get layout => 'column';

  ColumnModel(WidgetModel? parent, String? id, {dynamic halign, dynamic valign, dynamic expand,
    dynamic expanded,
  }) : super(parent, id) {
    this.halign = halign;
    this.valign = valign;
    this.expand = expand;
  }

  static ColumnModel? fromXml(WidgetModel? parent, XmlElement xml) {
    ColumnModel? model;
    try
    {
      // build model
      model = ColumnModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'column.Model');
      model = null;
    }
    return model;
  }

  Widget getView({Key? key}) => getReactiveView(ColumnView(this));
}
