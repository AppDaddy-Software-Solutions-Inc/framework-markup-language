// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/layout_widget_model.dart';
import 'package:fml/widgets/widget/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/column/column_view.dart';
import 'package:fml/helper/common_helpers.dart';

class ColumnModel extends LayoutWidgetModel
{
  // flexible children with no percent specified
  List<ViewableWidgetModel> get flexibleChildren => viewableChildren.where((child) => ((child.flex ?? 0) > 0) && child.pctHeight == null).toList();

  // children sized by parents height
  List<ViewableWidgetModel> get sizedChildren => viewableChildren.where((child) => child.pctHeight != null).toList();

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
    viewableChildren.forEach((child)
    {
      // set height on percent and flex children to zero
      if (child.pctHeight != null || child.flex != null)
      {
        child.height = 0;
      }
      views.add(child.getView());
    });
    return views;
  }

  @override
  void onLayoutComplete(RenderBox? box, Offset? position)
  {
    super.onLayoutComplete(box, position);

    // if fewer than 1 sized child no need to do anything
    var allowSizing = (sizedChildren.length + flexibleChildren.length) <= 1;
    if (allowSizing) return;

    // calculate max height from system
    var max = calculateMaxHeight() ?? 0;

    // calculate sum of flex values
    double sum = 0;
    flexibleChildren.forEach((child) => sum += child.flex!);

    // calculate usable space
    var usable = max - (viewHeight ?? 0);

    // set height on % sized children
    sizedChildren.forEach((child)
    {
      var height = max * (child.pctHeight! / 100);
      if (height != child.height)
      {
        child.height = height;
      }
    });

    // set height on flex values
    flexibleChildren.forEach((child)
    {
      if (usable > 0)
      {
        var height = (child.flex! / sum) * usable;
        if (height != child.height)
        {
          child.height = height;
        }
        usable = usable - height;
      }
    });
  }

  Widget getView({Key? key}) => getReactiveView(ColumnView(this));
}
