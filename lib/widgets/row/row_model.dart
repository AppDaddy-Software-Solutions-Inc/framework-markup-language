// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/layout_widget_model.dart';
import 'package:fml/widgets/widget/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/row/row_view.dart';
import 'package:fml/helper/common_helpers.dart';

class RowModel extends LayoutWidgetModel
{
  // flexible children with no percent width specified
  List<ViewableWidgetModel> get flexibleChildren => viewableChildren.where((child) => ((child.flex ?? 0) > 0) && child.pctWidth == null).toList();

  // children sized by parents width
  List<ViewableWidgetModel> get sizedChildren => viewableChildren.where((child) => child.pctWidth != null).toList();

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

  @override
  List<Widget> inflate()
  {
    // layout fixed sized children
    List<Widget> views = [];
    children?.forEach((child)
    {
      if (child is ViewableWidgetModel)
      {
        if (child.pctWidth != null || child.flex != null)
        {
          child.setWidth(0);
        }
        views.add(child.getView());
      }
    });
    return views;
  }

  @override
  void onLayoutComplete(RenderBox? box, Offset? position)
  {
    super.onLayoutComplete(box, position);

    var x = flexibleChildren.toList();
    var y = sizedChildren.toList();
    var z = viewableChildren.toList();

    // if fewer than 1 sized child no need to do anything
    var allowSizing = (sizedChildren.length + flexibleChildren.length) <= 1;
    if (allowSizing) return;

    // calculate max width from system
    var max = calculateMaxWidth() ?? 0;

    // calculate sum of flex values
    double sum = 0;
    flexibleChildren.forEach((child) => sum += child.flex!);

    // calculate usable space
    var usable = max - (viewWidth ?? 0);

    // set width on % sized children
    sizedChildren.forEach((child)
    {
      var width = max * (child.pctWidth!/100);
      if (width != child.width)
      {
        child.width = width;
      }
    });

    // set width on flexible children
    flexibleChildren.forEach((child)
    {
      if (usable > 0)
      {
        var width = (child.flex! / sum) * usable;
        if (width != child.width)
        {
          child.width = width;
        }
        usable = usable - width;
      }
    });
  }

  Widget getView({Key? key}) => getReactiveView(RowView(this));
}
