import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/box/box_constraints.dart';
import 'package:fml/widgets/box/box_data.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';

mixin BoxMixin {

  // lays out the child
  // and sets its size in the model
  doLayout(RenderBox child, BoxConstraints constraints, ChildLayouter layoutChild) {

    // calculate the child's size by performing
    // a dry layout. We use LocalBoxConstraints in order to
    // override isTight, which is used in Layout() to determine if a
    // child size change forces a parent to resize.
    layoutChild(child, LocalBoxConstraints.from(constraints));

    // set child size in its model
    if (child.parentData is BoxData) {
      (child.parentData as BoxData).model?.layoutComplete(
          child.size, Offset(child.paintBounds.left, child.paintBounds.top));
    }
  }

  // finds the parent RenderConstrainedLayoutBuilder of
  // the node
  RenderObject? parentOf(RenderObject child) {
    RenderObject? node = child.parent;
    while (true) {
      if (node == null) break;
      if (node is RenderConstrainedLayoutBuilder) {
        node = node.parent;
        break;
      }
      node = node.parent;
    }
    return node;
  }

  // walk up the render tree
  // to find first constrained height
  double heightOf(RenderObject? node) {
    double? height;
    while (true) {
      if (node == null) break;
      if (node is RenderBox && node.constraints.hasBoundedHeight) {
        height = node.constraints.maxHeight;
        break;
      }
      node = node.parent;
    }
    return height ?? System().screenheight.toDouble();
  }

  // walk up the render tree
  // to find first constrained width
  double widthOf(RenderObject? node) {
    double? width;
    while (true) {
      if (node == null) break;
      if (node is RenderBox && node.constraints.hasBoundedWidth) {
        width = node.constraints.maxWidth;
        break;
      }
      node = node.parent;
    }
    return width ?? System().screenheight.toDouble();
  }

  BoxConstraints getChildLayoutConstraints(
      BoxConstraints constraints, RenderBox child, ViewableMixin model) {
    // get the child's width from the model
    // and tighten the child's width constraint
    var parentWidth = widthOf(child.parent);
    var childWidth = model.getWidth(widthParent: parentWidth);
    if (childWidth != null) {
      //constraints = constraints.tighten(width: childWidth);
      constraints = BoxConstraints(
          minWidth: childWidth,
          maxWidth: childWidth,
          minHeight: constraints.minHeight,
          maxHeight: constraints.maxHeight);
    }

    // get the child's height from the model
    // and tighten the child's height constraint
    var parentHeight = heightOf(child.parent);
    var childHeight = model.getHeight(heightParent: parentHeight);
    if (childHeight != null) {
      //constraints = constraints.tighten(height: childHeight);
      constraints = BoxConstraints(
          minWidth: constraints.minWidth,
          maxWidth: constraints.maxWidth,
          minHeight: childHeight,
          maxHeight: childHeight);
    }

    // set child min/max widths as defined in the model
    if (!constraints.hasTightWidth) {
      var childMinWidth = model.getMinWidth(widthParent: parentHeight);
      if (childMinWidth != null && childMinWidth > constraints.minWidth) {
        constraints = BoxConstraints(
            minWidth: childMinWidth,
            maxWidth: constraints.maxWidth,
            minHeight: constraints.minHeight,
            maxHeight: constraints.maxHeight);
      }
      var childMaxWidth = model.getMaxWidth(widthParent: parentHeight);
      if (childMaxWidth != null && childMaxWidth < constraints.maxWidth) {
        constraints = BoxConstraints(
            minWidth: constraints.minWidth,
            maxWidth: childMaxWidth,
            minHeight: constraints.minHeight,
            maxHeight: constraints.maxHeight);
      }
    }

    // set child min/max heights as defined in the model
    if (!constraints.hasTightHeight) {
      var childMinHeight = model.getMinHeight(heightParent: parentHeight);
      if (childMinHeight != null && childMinHeight > constraints.minHeight) {
        constraints = BoxConstraints(
            minWidth: constraints.minWidth,
            maxWidth: constraints.maxWidth,
            minHeight: childMinHeight,
            maxHeight: constraints.maxHeight);
      }
      var childMaxHeight = model.getMaxHeight(heightParent: parentHeight);
      if (childMaxHeight != null && childMaxHeight < constraints.maxHeight) {
        constraints = BoxConstraints(
            minWidth: constraints.minWidth,
            maxWidth: constraints.maxWidth,
            minHeight: constraints.minHeight,
            maxHeight: childMaxHeight);
      }
    }

    // If both of us are unconstrained in the horizontal axis,
    // tighten the child's width constraint prior to layout
    if (!constraints.hasBoundedWidth && model.canExpandInfinitelyWide) {
      constraints = BoxConstraints(
          minWidth: constraints.minWidth,
          maxWidth: parentWidth,
          minHeight: constraints.minHeight,
          maxHeight: constraints.maxHeight);
    }

    // If both of us are unconstrained in the vertical axis,
    // tighten the child's height constraint prior to layout
    if (!constraints.hasBoundedHeight && model.canExpandInfinitelyHigh) {
      constraints = BoxConstraints(
          minWidth: constraints.minWidth,
          maxWidth: constraints.maxWidth,
          minHeight: constraints.minHeight,
          maxHeight: parentHeight);
    }

    // if the model wants to expand in the horizontal and has an unbounded
    // width, then set the min width to the parent width. This happens for
    // instance when a <box expand="true"/> is inside a <scroller/>. Normally the
    // expand would be set to false in the view. This ensures the widget is at least as
    // wide as the first parent with a constrained width.
    // if (model.expandHorizontally && !constraints.hasBoundedWidth)
    // {
    //   constraints = BoxConstraints(minWidth: parentWidth, maxWidth: constraints.maxWidth, minHeight: constraints.minHeight, maxHeight: constraints.maxHeight);
    // }

    // if the model wants to expand in the vertical and has an unbounded
    // height, then set the min height to the parent height. This happens for
    // instance when a <box expand="true"/> is inside a <scroller/>. Normally the
    // expand would be set to false in the view. This ensures the widget is at least as
    // high as the first parent with a constrained height.
    // if (model.expandVertically && !constraints.hasBoundedHeight)
    // {
    //   constraints = BoxConstraints(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth, minHeight: parentHeight, maxHeight: constraints.maxHeight);
    // }

    // visible?
    if (!model.visible) {
      constraints = const BoxConstraints(
          minWidth: 0, maxWidth: 0, minHeight: 0, maxHeight: 0);
    }

    // normalize
    return constraints.normalize();
  }
}
