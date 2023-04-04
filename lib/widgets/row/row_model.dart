// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/helper/measured.dart';
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
  @override
  bool isVerticallyConstrained() => true;

  @override
  bool isHorizontallyConstrained() => constraints.model.hasHorizontalExpansionConstraints || constraints.system.hasHorizontalExpansionConstraints;

  @override
  MainAxisSize getHorizontalAxisSize() => MainAxisSize.min;//(expand && isHorizontallyConstrained()) ? MainAxisSize.max : MainAxisSize.min;

  // flexible children with no percent width specified
  List<ViewableWidgetModel> get flexibleChildren => viewableChildren.where((child) => ((child.flex ?? 0) > 0) && child.pctWidth == null).toList();

  // children sized by parents width
  List<ViewableWidgetModel> get percentChildren => viewableChildren.where((child) => child.pctWidth != null).toList();

  // children that do not have % width or flex sizing
  List<ViewableWidgetModel> get unsizedChildren => viewableChildren.where((child) => child.flex == null && child.pctWidth == null).toList();

  // children that have a % width or flex sizing
  List<ViewableWidgetModel> get sizedChildren => viewableChildren.where((child) => child.flex != null || child.pctWidth != null).toList();

  // if there are 2 or more viewable children and any one of them is
  // sized then we need to perform layout sizing
  bool get performLayoutSizing => (viewableChildren.length > 1 && sizedChildren.isNotEmpty);

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
    // set width on all `sized children to zero
    List<Widget> views = [];
    if (performLayoutSizing)
    {
      List<Widget> children = [];
      unsizedChildren.forEach((model) => children.add(model.getView()));
      var measured = MeasuredView(UnconstrainedBox(child: Row(mainAxisSize: MainAxisSize.min, children: children)),OnWidgetSized);
      views.add(measured);
    }
    else views = super.inflate();
    return views;
  }

  void OnWidgetSized(Size size, {dynamic data})
  {
    var w = size.width;
    var h = size.height;

    // calculate max width from system
    var max = calculateMaxWidth() ?? 0;

    // calculate sum of flex values
    double sum = 0;
    flexibleChildren.forEach((child) => sum += child.flex!);

    // calculate used width
    double used = 0;
    unsizedChildren.forEach((child) => used += (child.viewWidth ?? 0));

    var xxx = unsizedChildren;

    // calculate usable space
    var usable = max - used;

    // set width on % sized children
    percentChildren.forEach((child)
    {
      var width = usable * (child.pctWidth!/100);
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

    notifyListeners(null, null);
  }

  Widget getView({Key? key}) => getReactiveView(RowView(this));
}
