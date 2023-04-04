// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/layout_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/stack/stack_view.dart';
import 'package:fml/helper/common_helpers.dart';

class StackModel extends LayoutWidgetModel
{
  @override
  bool isHorizontallyConstrained() => constraints.model.hasHorizontalExpansionConstraints || constraints.system.hasHorizontalExpansionConstraints;

  @override
  bool isVerticallyConstrained() => constraints.model.hasVerticalExpansionConstraints || constraints.system.hasVerticalExpansionConstraints;

  @override
  MainAxisSize getVerticalAxisSize() => (expand && isHorizontallyConstrained()) ? MainAxisSize.max : MainAxisSize.min;

  @override
  MainAxisSize getHorizontalAxisSize() => MainAxisSize.min;

  StackModel(
    WidgetModel parent,
    String? id, {
    dynamic width,
    dynamic height,
    dynamic minwidth,
    dynamic minheight,
    dynamic maxwidth,
    dynamic maxheight,
    dynamic valign,
    dynamic halign,
    dynamic expand,
    dynamic center,
  }) : super(parent, id)
  {
    // constraints
    if (width     != null) this.width     = width;
    if (height    != null) this.height    = height;
    if (minwidth  != null) this.minWidth  = minwidth;
    if (minheight != null) this.minHeight = minheight;
    if (maxwidth  != null) this.maxWidth  = maxwidth;
    if (maxheight != null) this.maxHeight = maxheight;
    if (halign    != null) this.halign    = halign;
    if (valign    != null) this.valign    = valign;
    if (center    != null) this.center    = center;
    if (expand    != null) this.expand    = expand;
  }

  static StackModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    StackModel? model;
    try
    {
      // build model
      model = StackModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'stack.Model');
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
  dispose() {
    super.dispose();
  }

  Widget getView({Key? key}) => getReactiveView(StackView(this));
}
