// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

class RowModel extends BoxModel
{
  @override
  LayoutType layoutType = LayoutType.row;

  @override
  String? get layout => "row";

  /// Legacy - Use % height and/or % width
  @override
  set expand(dynamic expands)
  {
    expands = S.toBool(expands) ?? false;
    if (expands)
    {
      if (width == null && widthPercentage == null) width = "100%";
    }
  }

  @override
  bool isVerticallyExpanding()
  {
    if (height != null) return false;
    bool expand = false;
    if (children != null){
      for (var child in children!) {
        if (child is ViewableWidgetModel && child.visible &&
            child.isVerticallyExpanding()) {
          expand = true;
          break;
        }
      }
    }
    return expand;
  }

  @override
  bool isHorizontallyExpanding({bool ignoreFixedWidth = false})
  {
    if (width != null) return false;
    var expand = widthPercentage == 100;
    if (expand) return true;
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
}
