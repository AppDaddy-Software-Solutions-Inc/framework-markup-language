// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

class ColumnModel extends BoxModel
{
  @override
  LayoutType layoutType = LayoutType.column;

  @override
  String? get layout => "column";

  /// Legacy - Use % height and/or % width
  @override
  set expand(dynamic expands)
  {
    expands = S.toBool(expands) ?? false;
    if (expands)
    {
      if (height == null && heightPercentage == null) height = "100%";
    }
  }


  @override
  bool isVerticallyExpanding()
  {
    if (height == null) return false;

    var expand = heightPercentage == 100;
    if (expand) return true;

    if (children != null)
    {
      for (var child in children!)
      {
        if (child is ViewableWidgetModel && child.visible && child.isVerticallyExpanding() && child.heightPercentage == null)
        {
          expand = true;
          break;
        }
      }}
    return expand;
  }

  @override
  bool isHorizontallyExpanding({bool ignoreFixedWidth = false})
  {
    if (width != null) return false;
    bool expand = false;
    if (children != null){
      for (var child in children!)
      {
        if (child is ViewableWidgetModel && child.visible && child.isHorizontallyExpanding() && child.widthPercentage == null)
        {
          expand = true;
          break;
        }
      }}
    return expand;
  }

  ColumnModel(WidgetModel parent, String? id) : super(parent, id);

  static ColumnModel? fromXml(WidgetModel parent, XmlElement xml)
  {
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
}
