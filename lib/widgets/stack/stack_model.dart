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
  MainAxisSize get verticalAxisSize   => (expand && verticallyConstrained)   ? MainAxisSize.max : MainAxisSize.min;

  @override
  MainAxisSize get horizontalAxisSize => (expand && horizontallyConstrained) ? MainAxisSize.max : MainAxisSize.min;

  @override
  int? get flex
  {
    if (!expand) return null;
    if (this.parent is LayoutModel) return super.flex ?? 1;
    return null;
  }

  @override
  double? get pctWidth
  {
    if (fixedWidth) return null;
    if (super.pctWidth != null) return super.pctWidth;
    if (this.parent is LayoutModel && expand) return 100;
    return null;
  }

  @override
  double? get pctHeight
  {
    if (fixedHeight) return null;
    if (super.pctHeight != null) return super.pctHeight;
    if (this.parent is LayoutModel && expand) return 100;
    return null;
  }


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
