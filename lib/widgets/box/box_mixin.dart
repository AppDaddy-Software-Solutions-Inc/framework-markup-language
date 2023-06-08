import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';

mixin BoxMixin
{
  // finds the parent RenderConstrainedLayoutBuilder of
  // the node
  AbstractNode? parentOf(AbstractNode child)
  {
    AbstractNode? node = child.parent;
    while (true)
    {
      if (node == null) break;
      if (node is RenderConstrainedLayoutBuilder)
      {
        node = node.parent;
        break;
      }
      node = node.parent;
    }
    return node;
  }

  // walk up the render tree
  // to find first constrained height
  double heightOf(AbstractNode? node)
  {
    double? height;
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

  // walk up the render tree
  // to find first constrained width
  double widthOf(AbstractNode? node)
  {
    double? width;
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
    return width ?? System().screenheight.toDouble();
  }

  BoxConstraints getChildLayoutConstraints(BoxConstraints constraints, RenderBox child, ViewableWidgetModel model)
  {
    // get the child's width from the model
    // and tighten the child's width constraint
    var parentWidth = widthOf(child.parent);
    var childWidth  = model.getWidth(widthParent: parentWidth);
    if (childWidth != null)
    {
      constraints = constraints.tighten(width: childWidth);
    }

    // get the child's height from the model
    // and tighten the child's height constraint
    var parentHeight = heightOf(child.parent);
    var childHeight  = model.getHeight(heightParent: parentHeight);
    if (childHeight != null)
    {
      constraints = constraints.tighten(height: childHeight);
    }

    // If both of us are unconstrained in the horizontal axis,
    // tighten the child's width constraint prior to layout
    if (!constraints.hasBoundedWidth && model.canExpandInfinitelyWide)
    {
      constraints = BoxConstraints(minWidth: constraints.minWidth, maxWidth: parentWidth, minHeight: constraints.minHeight, maxHeight: constraints.maxHeight);
    }

    // If both of us are unconstrained in the vertical axis,
    // tighten the child's height constraint prior to layout
    if (!constraints.hasBoundedHeight && model.canExpandInfinitelyHigh)
    {
      constraints = BoxConstraints(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth, minHeight: constraints.minHeight, maxHeight: parentHeight);
    }

    // visible?
    if (!model.visible)
    {
      constraints = BoxConstraints(minWidth: 0, maxWidth: 0, minHeight: 0, maxHeight: 0);
    }

    return constraints.normalize();
  }
}