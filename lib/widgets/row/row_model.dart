// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/layout_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/row/row_view.dart';
import 'package:fml/helper/common_helpers.dart';

class RowModel extends LayoutWidgetModel
{
  @override
  bool isHorizontallyConstrained() => constraints.model.hasHorizontalExpansionConstraints || constraints.system.hasHorizontalExpansionConstraints;

  @override
  MainAxisSize getHorizontalAxisSize() => (expand && isHorizontallyConstrained()) ? MainAxisSize.max : MainAxisSize.min;

  @override
  String? get layout => 'row';

  RowModel(
    WidgetModel parent,
    String? id, {
    dynamic valign,
    dynamic halign,
    dynamic wrap,
    dynamic center,
    dynamic expand,
  }) : super(parent, id)
  {
    this.center = center;
    this.halign = halign;
    this.wrap = wrap;
    this.expand = expand;
  }

  static RowModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    RowModel? model;
    try
    {
      // build model
      model = RowModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'row.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement? xml)
  {
    // deserialize 
    super.deserialize(xml);
  }

  Widget getView({Key? key}) => getReactiveView(RowView(this));
}
