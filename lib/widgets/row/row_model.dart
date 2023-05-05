// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/layout/layout_model.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/row/row_view.dart';
import 'package:fml/helper/common_helpers.dart';

class RowModel extends LayoutModel
{
  @override
  LayoutType layoutType = LayoutType.row;

  @override
  String? get layout => "row";

  @override
  MainAxisSize get verticalAxisSize => MainAxisSize.min;

  @override
  MainAxisSize get horizontalAxisSize
  {
    // expand and constrained by system
    if (expand) return horizontallyConstrained ? MainAxisSize.max : MainAxisSize.min;

    // not expand but constrained in model
    if (constraints.model.hasHorizontalExpansionConstraints) return MainAxisSize.max;

    return MainAxisSize.min;
  }

  @override
  bool get isVerticallyExpanding {
    if (isFixedHeight) return false;
    bool expand = false;
    if (children != null){
      for (var child in children!) {
        if (child is ViewableWidgetModel && child.visible &&
            child.isVerticallyExpanding) {
          expand = true;
          break;
        }
      }
  }
    return expand;
  }

  @override
  @required
  bool get isHorizontallyExpanding
  {
    if (isFixedWidth) return false;
    var expand = this.expand;
    if (expand) return true;
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

  RowModel(WidgetModel parent, String? id) : super(parent, id);

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

  @override
  Widget getView({Key? key}) => getReactiveView(RowView(this));
}
