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
  @override
  bool isVerticallyConstrained() => constraints.model.hasVerticalExpansionConstraints || constraints.system.hasVerticalExpansionConstraints;

  @override
  bool isHorizontallyConstrained() => true;

  @override
  MainAxisSize getVerticalAxisSize() => (expand && isVerticallyConstrained()) ? MainAxisSize.max : MainAxisSize.min;

  // flexible children with no percent specified
  List<ViewableWidgetModel> get flexibleChildren => viewableChildren.where((child) => ((child.flex ?? 0) > 0) && child.pctHeight == null).toList();

  // children sized by parents height
  List<ViewableWidgetModel> get percentChildren => viewableChildren.where((child) => child.pctHeight != null).toList();

  // children that do not have % height or flex sizing
  List<ViewableWidgetModel> get unsizedChildren => viewableChildren.where((child) => child.flex == null && child.pctHeight == null).toList();

  // children that have a % height or flex sizing
  List<ViewableWidgetModel> get sizedChildren => viewableChildren.where((child) => child.flex != null || child.pctHeight != null).toList();

  // if there are 2 or more viewable children and any one of them is
  // sized then we need to perform layout sizing
  bool get performLayoutSizing => (viewableChildren.length > 1 && sizedChildren.isNotEmpty);

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
    // set height on all sized children to zero
    if (performLayoutSizing) sizedChildren.forEach((child) => child.setHeight(0));
    return super.inflate();
  }

  @override
  void onLayoutComplete(RenderBox? box, Offset? position)
  {
    super.onLayoutComplete(box, position);
    if (performLayoutSizing)
    {
      var x = flexibleChildren.toList();
      var y = percentChildren.toList();
      var z = viewableChildren.toList();
      var w = viewWidth;
      var h = viewHeight;

      // calculate max height from system
      var max = calculateMaxHeight() ?? 0;

      // calculate sum of flex values
      double sum = 0;
      flexibleChildren.forEach((child) => sum += child.flex!);

      // calculate used height
      double used = 0;
      unsizedChildren.forEach((child) => used += (child.viewHeight ?? 0));

      var xxx = unsizedChildren;

      // calculate usable space
      var usable = max - used;

      // set width on % sized children
      percentChildren.forEach((child)
      {
        var height = usable * (child.pctHeight!/100);
        if (height != child.height)
        {
          child.height = height;
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
  }

  Widget getView({Key? key}) => getReactiveView(ColumnView(this));
}
