// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/layout/layout_model.dart';
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
  MainAxisSize get horizontalAxisSize => (expand && horizontallyConstrained) ? MainAxisSize.max : MainAxisSize.min;

  @override
  int? get flex
  {
    // parent must be a layout model
    if (this.parent is! LayoutModel) return null;

    // doesn't flex in the horizontal
    if (!expand) return super.flex;

    // flex based on parent layout
    switch ((this.parent as LayoutModel).layoutType)
    {
      // my parent is a column (main axis differs)
      case LayoutType.column:

        // specified height overrides flex
        if (fixedHeight) return null;

        // flex only if specified
        return super.flex;

      // my parent is a row (main axis is the same)
      case LayoutType.row:

        // specified width overrides flex
        if (fixedWidth) return null;

        // flex as specified otherwise by 1
        return super.flex ?? 1;

      // my parent is a stack (main axis is the same)
      case LayoutType.stack:

        // specified width overrides flex
        if (fixedWidth) return null;

        // flex as specified otherwise by 1
        return super.flex ?? 1;

      default:
        break;
    }
    return null;
  }

  @override
  double? get pctWidth
  {
    if (fixedWidth) return null;
    if (super.pctWidth != null) return super.pctWidth;
    if (this.parent is LayoutModel)
      switch ((this.parent as LayoutModel).layoutType)
      {
        case LayoutType.stack:
        case LayoutType.column:
          if (expand) return 100;
          break;
        default:
          break;
      }
    return null;
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

  Widget getView({Key? key}) => getReactiveView(RowView(this));
}
