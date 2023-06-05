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

  // walk up the render tree
  // to find first constrained height
  double _myParentsHeight(RenderBox node)
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

  // walk up the render tree
  // to find first constrained width
  double _myParentsWidth(RenderBox node)
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

  BoxConstraints getChildLayoutConstraints(RenderBox parent, ViewableWidgetModel parentModel, BoxConstraints constraints, RenderBox child, ViewableWidgetModel childModel)
  {
    // get the child's width from the model
    // and tighten the child's width constraint
    var parentWidth = myWidth(parent, parentModel);
    var childWidth  = childModel.getWidth(widthParent: parentWidth);
    if (childWidth != null)
    {
      constraints = constraints.tighten(width: childWidth);
    }

    // get the child's height from the model
    // and tighten the child's height constraint
    var parentHeight = myHeight(parent, parentModel);
    var childHeight  = childModel.getHeight(heightParent: parentHeight);
    if (childHeight != null)
    {
      constraints = constraints.tighten(height: childHeight);
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

    // visible?
    if (!childModel.visible)
    {
      constraints = BoxConstraints(minWidth: 0, maxWidth: 0, minHeight: 0, maxHeight: 0);
    }

    return constraints.normalize();
  }
}