import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';

enum FlexType {shrinking, fixed, expanding}

/// Parent data for use with [BoxRenderer].
class BoxData extends ContainerBoxParentData<RenderBox>
{
  ViewableWidgetModel? model;

  Size? parentSize;

  int? flex;
  FlexFit? fit;

  int runIndex = 0;

  /// The distance by which the child's top edge is inset from the top of the stack.
  double? top;

  /// The distance by which the child's right edge is inset from the right of the stack.
  double? right;

  /// The distance by which the child's bottom edge is inset from the bottom of the stack.
  double? bottom;

  /// The distance by which the child's left edge is inset from the left of the stack.
  double? left;

  /// The child's width.
  ///
  /// Ignored if both left and right are non-null.
  double? width;

  /// The child's height.
  ///
  /// Ignored if both top and bottom are non-null.
  double? height;

  /// Whether this child is considered positioned.
  ///
  /// A child is positioned if any of the top, right, bottom, or left properties
  /// are non-null. Positioned children do not factor into determining the size
  /// of the stack but are instead placed relative to the non-positioned
  /// children in the stack.
  bool get isPositioned => top != null || right != null || bottom != null || left != null || width != null || height != null;
}

class LayoutBoxChildData extends ParentDataWidget<BoxData>
{
  final ViewableWidgetModel model;

  /// The distance by which the child's top edge is inset from the top of the stack.
  final double? top;

  /// The distance by which the child's right edge is inset from the right of the stack.
  final double? right;

  /// The distance by which the child's bottom edge is inset from the bottom of the stack.
  final double? bottom;

  /// The distance by which the child's left edge is inset from the left of the stack.
  final double? left;

  /// The child's width.
  ///
  /// Ignored if both left and right are non-null.
  final double? width;

  /// The child's height.
  ///
  /// Ignored if both top and bottom are non-null.
  final double? height;

  const LayoutBoxChildData({super.key,
    required this.model,
    required super.child,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
  });

  @override
  void applyParentData(RenderObject renderObject)
  {
    if (renderObject.parentData is BoxData)
    {
      final BoxData parentData = renderObject.parentData! as BoxData;

      bool needsLayout = false;

      if (parentData.model != model)
      {
        parentData.model = model;
        needsLayout = true;
      }

      if (parentData.left != left)
      {
        parentData.left = left;
        needsLayout = true;
      }

      if (parentData.top != top) {
        parentData.top = top;
        needsLayout = true;
      }

      if (parentData.right != right) {
        parentData.right = right;
        needsLayout = true;
      }

      if (parentData.bottom != bottom) {
        parentData.bottom = bottom;
        needsLayout = true;
      }

      if (parentData.width != width) {
        parentData.width = width;
        needsLayout = true;
      }

      if (parentData.height != height) {
        parentData.height = height;
        needsLayout = true;
      }

      if (needsLayout)
      {
        final RenderObject? targetParent = renderObject.parent;
        if (targetParent is RenderObject)
        {
          targetParent.markNeedsLayout();
        }
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => Flex;
}
