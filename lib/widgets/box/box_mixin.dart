import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';

mixin BoxMixin
{
  AbstractNode? _parentOf(AbstractNode child)
  {
    AbstractNode? node = child.parent;
    while (true)
    {
      if (node == null) break;
      if (node is  RenderConstrainedLayoutBuilder)
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
  double parentMaxHeight(RenderBox node)
  {
    double? height;

    // find the nodes parent
    AbstractNode? parent = _parentOf(node);

    // walk up the tree
    while (true)
    {
      if (parent == null) break;
      if (parent is RenderBox && parent.constraints.hasBoundedHeight)
      {
        height = parent.constraints.maxHeight;
        break;
      }
      parent = parent.parent;
    }

    return height ?? System().screenheight.toDouble();
  }

  // walk up the render tree
  // to find first constrained width
  double parentMaxWidth(RenderBox node)
  {
    double? width;

    // find the nodes parent
    AbstractNode? parent = _parentOf(node);

    // walk up the tree
    while (true)
    {
      if (parent == null) break;
      if (parent is RenderBox && parent.constraints.hasBoundedWidth)
      {
        width = parent.constraints.maxWidth;
        break;
      }
      parent = parent.parent;
    }

    return width ?? System().screenheight.toDouble();
  }

  BoxConstraints getChildLayoutConstraints(BoxConstraints constraints, RenderBox child, ViewableWidgetModel model)
  {
    // get the child's width from the model
    // and tighten the child's width constraint
    var childWidth  = model.getWidth(widthParent: parentMaxWidth(child));
    if (childWidth != null)
    {
      constraints = constraints.tighten(width: childWidth);
    }

    // get the child's height from the model
    // and tighten the child's height constraint
    var childHeight  = model.getHeight(heightParent: parentMaxHeight(child));
    if (childHeight != null)
    {
      constraints = constraints.tighten(height: childHeight);
    }

    // If both of us are unconstrained in the horizontal axis,
    // tighten the child's width constraint prior to layout
    if (!constraints.hasBoundedWidth && model.canExpandInfinitelyWide)
    {
      constraints = BoxConstraints(minWidth: constraints.minWidth, maxWidth: parentMaxWidth(child), minHeight: constraints.minHeight, maxHeight: constraints.maxHeight);
    }

    // If both of us are unconstrained in the vertical axis,
    // tighten the child's height constraint prior to layout
    if (!constraints.hasBoundedHeight && model.canExpandInfinitelyHigh)
    {
      constraints = BoxConstraints(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth, minHeight: constraints.minHeight, maxHeight: parentMaxHeight(child));
    }

    // visible?
    if (!model.visible)
    {
      constraints = BoxConstraints(minWidth: 0, maxWidth: 0, minHeight: 0, maxHeight: 0);
    }

    return constraints.normalize();
  }
}