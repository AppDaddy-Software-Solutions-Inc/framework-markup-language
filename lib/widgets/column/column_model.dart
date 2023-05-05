// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/layout/layout_model.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/column/column_view.dart';
import 'package:fml/helper/common_helpers.dart';

class ColumnModel extends LayoutModel
{
  @override
  LayoutType layoutType = LayoutType.column;

  @override
  String? get layout => "column";

  @override
  MainAxisSize get verticalAxisSize
  {
    // expand and constrained by system
    if (expand) return verticallyConstrained ? MainAxisSize.max : MainAxisSize.min;

    // not expand but constrained in model
    if (constraints.model.hasVerticalExpansionConstraints) return MainAxisSize.max;

    return MainAxisSize.min;
  }

  @override
  MainAxisSize get horizontalAxisSize => MainAxisSize.min;

  @override
  bool get isVerticallyExpanding
  {
    if (isFixedHeight) return false;
    var expand = this.expand;
    if (expand) return true;

    if (children != null)
    {
      for (var child in children!)
      {
        if (child is ViewableWidgetModel && child.visible && child.isVerticallyExpanding && child.heightPercentage == null)
        {
          expand = true;
          break;
        }
      }}
    return expand;
  }

  @override
  bool get isHorizontallyExpanding
  {
    if (isFixedWidth) return false;
    bool expand = false;
    if (children != null){
      for (var child in children!)
      {
        if (child is ViewableWidgetModel && child.visible && child.isHorizontallyExpanding && child.widthPercentage == null)
        {
          expand = true;
          break;
        }
      }}
    return expand;
  }

  ColumnModel(WidgetModel parent, String? id) : super(parent, id);

  static ColumnModel? fromXml(WidgetModel parent, XmlElement xml)
  {
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

  @override
  Widget getView({Key? key}) => getReactiveView(ColumnView(this));
}
