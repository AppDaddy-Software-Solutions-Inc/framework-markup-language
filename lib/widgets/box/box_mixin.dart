import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';

mixin BoxMixin
{
  double? myHeight(RenderBox root, ViewableWidgetModel model)
  {
    double? height;
    var modelHeight = model.getHeight(heightParent: _myParentsHeight(root));
    if (modelHeight != null)
    {
      height = modelHeight;
    }
    return height;
  }

  double _myParentsHeight(RenderBox root)
  {
    double? height;

    // walk up to flex renderer parent
    AbstractNode? node = root.parent;

    // walk up the tree
    while (true)
    {
      if (node == null) break;
      if (node is RenderBox && node.constraints.hasBoundedHeight)
      {
        height = node.constraints.maxHeight;
        break;
      }
      node = node.parent;
    }

    return height ?? System().screenheight.toDouble();
  }

  double? myWidth(RenderBox root, ViewableWidgetModel model)
  {
    double? width;
    var modelWidth = model.getWidth(widthParent: _myParentsWidth(root));
    if (modelWidth != null)
    {
      width = modelWidth;
    }
    return width;
  }

  double _myParentsWidth(RenderBox root)
  {
    double? width;

    // walk up to flex renderer parent
    AbstractNode? node = root.parent;

    // walk up the tree
    while (true)
    {
      if (node == null) break;
      if (node is RenderBox && node.constraints.hasBoundedWidth)
      {
        width = node.constraints.maxWidth;
        break;
      }
      node = node.parent;
    }

    return width ?? System().screenwidth.toDouble();
  }

  BoxConstraints getChildLayoutConstraints(RenderBox parent, ViewableWidgetModel parentModel, BoxConstraints constraints, RenderBox child, ViewableWidgetModel childModel)
  {
    // get the child's width from the model
    // and tighten the child's width constraint
    var parentWidth = myWidth(parent, parentModel);
    var width = childModel.getWidth(widthParent: parentWidth);
    if (width != null)
    {
      constraints = constraints.tighten(width: width);
    }

    // get the child's height from the model
    // and tighten the child's height constraint
    var parentHeight = myHeight(parent, parentModel);
    var height = childModel.getHeight(heightParent: parentHeight);
    if (height != null)
    {
      constraints = constraints.tighten(height: height);
    }

    // If both of us are unconstrained in the horizontal axis,
    // tighten the child's width constraint prior to layout
    if (!constraints.hasBoundedWidth && childModel.canExpandInfinitelyWide)
    {
      constraints = BoxConstraints(minWidth: constraints.minWidth, maxWidth: _myParentsWidth(parent), minHeight: constraints.minHeight, maxHeight: constraints.maxHeight);
    }

    // If both of us are unconstrained in the vertical axis,
    // tighten the child's height constraint prior to layout
    if (!constraints.hasBoundedHeight && childModel.canExpandInfinitelyHigh)
    {
      constraints = BoxConstraints(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth, minHeight: constraints.minHeight, maxHeight: _myParentsHeight(parent));
    }

    return constraints.normalize();
  }
}