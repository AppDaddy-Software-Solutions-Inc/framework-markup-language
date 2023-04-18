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
  int? get flex => expand ? super.flex : null;

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

  @override
  void onLayoutComplete() async
  {
    super.onLayoutComplete();
    var w = this.viewWidth;
    var h = this.viewHeight;
    int i = 0;
  }
  Widget getView({Key? key}) => getReactiveView(RowView(this));
}
