// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/layout/layout_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/stack/stack_view.dart';
import 'package:fml/helper/common_helpers.dart';

class StackModel extends LayoutModel
{
  @override
  LayoutType layoutType = LayoutType.stack;

  @override
  String? get layout => "stack";

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
  MainAxisSize get horizontalAxisSize
  {
    // expand and constrained by system
    if (expand) return horizontallyConstrained ? MainAxisSize.max : MainAxisSize.min;

    // not expand but constrained in model
    if (constraints.model.hasHorizontalExpansionConstraints) return MainAxisSize.max;

    return MainAxisSize.min;
  }

  @override
  bool get isVerticallyExpanding => expand;

  @required
  bool get isHorizontallyExpanding => expand;

  StackModel(WidgetModel parent, String? id) : super(parent, id);

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

  @override
  List<Widget> inflate()
  {
    List<Widget> views = [];
    var children = viewableChildren;
    children.sort((a, b)
    {
      if(a.depth != null && b.depth != null) return a.depth?.compareTo(b.depth!) ?? 0;
      return 0;
    });
    children.forEach((model) => views.add(model.getView()));
    return views;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement? xml)
  {
    // deserialize
    super.deserialize(xml);

    // sort the children
    this.children?.sort((a, b)
    {
      if(a.depth != null && b.depth != null) return a.depth?.compareTo(b.depth!) ?? 0;
      return 0;
    });
  }

  @override
  void dispose()
  {
    super.dispose();
  }

  Widget getView({Key? key}) => getReactiveView(StackView(this));
}
