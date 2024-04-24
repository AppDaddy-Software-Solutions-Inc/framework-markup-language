// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fml/widgets/box/box_constraints.dart';
import 'package:fml/widgets/box/box_data.dart';
import 'package:fml/widgets/box/box_mixin.dart';
import 'package:fml/widgets/box/box_model.dart';

/// Implements the stack layout algorithm.
///
/// In a stack layout, the children are positioned on top of each other in the
/// order in which they appear in the child list. First, the non-positioned
/// children (those with null values for top, right, bottom, and left) are
/// laid out and initially placed in the upper-left corner of the stack. The
/// stack is then sized to enclose all of the non-positioned children. If there
/// are no non-positioned children, the stack becomes as large as possible.
///
/// The final location of non-positioned children is determined by the alignment
/// parameter. The left of each non-positioned child becomes the
/// difference between the child's width and the stack's width scaled by
/// alignment.x. The top of each non-positioned child is computed
/// similarly and scaled by alignment.y. So if the alignment x and y properties
/// are 0.0 (the default) then the non-positioned children remain in the
/// upper-left corner. If the alignment x and y properties are 0.5 then the
/// non-positioned children are centered within the stack.
///
/// Next, the positioned children are laid out. If a child has top and bottom
/// values that are both non-null, the child is given a fixed height determined
/// by subtracting the sum of the top and bottom values from the height of the stack.
/// Similarly, if the child has right and left values that are both non-null,
/// the child is given a fixed width derived from the stack's width.
/// Otherwise, the child is given unbounded constraints in the non-fixed dimensions.
///
/// Once the child is laid out, the stack positions the child
/// according to the top, right, bottom, and left properties of their
/// [BoxStackParentData]. For example, if the bottom value is 10.0, the
/// bottom edge of the child will be inset 10.0 pixels from the bottom
/// edge of the stack. If the child extends beyond the bounds of the
/// stack, the stack will clip the child's painting to the bounds of
/// the stack.
///
/// See also:
///
///  * [RenderFlow]
class StackRenderer extends RenderBox
    with
        BoxMixin,
        ContainerRenderObjectMixin<RenderBox, BoxData>,
        RenderBoxContainerDefaultsMixin<RenderBox, BoxData> {
  final BoxModel model;

  /// Creates a stack render object.
  ///
  /// By default, the non-positioned children of the stack are aligned by their
  /// top left corners.
  StackRenderer({
    required this.model,
    List<RenderBox>? children,
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    TextDirection? textDirection,
    StackFit fit = StackFit.loose,
    Clip clipBehavior = Clip.none,
  })  : _alignment = alignment,
        _textDirection = textDirection,
        _fit = fit,
        _clipBehavior = clipBehavior {
    addAll(children);
  }

  bool _hasVisualOverflow = false;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! BoxData) {
      child.parentData = BoxData();
    }
  }

  Alignment? _resolvedAlignment;

  void _resolve() {
    if (_resolvedAlignment != null) {
      return;
    }
    _resolvedAlignment = alignment.resolve(textDirection);
  }

  void _markNeedResolution() {
    _resolvedAlignment = null;
    markNeedsLayout();
  }

  /// How to align the non-positioned or partially-positioned children in the
  /// stack.
  ///
  /// The non-positioned children are placed relative to each other such that
  /// the points determined by [alignment] are co-located. For example, if the
  /// [alignment] is [Alignment.topLeft], then the top left corner of
  /// each non-positioned child will be located at the same global coordinate.
  ///
  /// Partially-positioned children, those that do not specify an alignment in a
  /// particular axis (e.g. that have neither `top` nor `bottom` set), use the
  /// alignment to determine how they should be positioned in that
  /// under-specified axis.
  ///
  /// If this is set to an [AlignmentDirectional] object, then [textDirection]
  /// must not be null.
  AlignmentGeometry get alignment => _alignment;
  AlignmentGeometry _alignment;
  set alignment(AlignmentGeometry value) {
    if (_alignment == value) {
      return;
    }
    _alignment = value;
    _markNeedResolution();
  }

  /// The text direction with which to resolve [alignment].
  ///
  /// This may be changed to null, but only after the [alignment] has been changed
  /// to a value that does not depend on the direction.
  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;
  set textDirection(TextDirection? value) {
    if (_textDirection == value) {
      return;
    }
    _textDirection = value;
    _markNeedResolution();
  }

  /// How to size the non-positioned children in the stack.
  ///
  /// The constraints passed into the [StackRenderer] from its parent are either
  /// loosened ([StackFit.loose]) or tightened to their biggest size
  /// ([StackFit.expand]).
  StackFit get fit => _fit;
  StackFit _fit;
  set fit(StackFit value) {
    if (_fit != value) {
      _fit = value;
      markNeedsLayout();
    }
  }

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge], and must not be null.
  Clip get clipBehavior => _clipBehavior;
  Clip _clipBehavior = Clip.hardEdge;
  set clipBehavior(Clip value) {
    if (value != _clipBehavior) {
      _clipBehavior = value;
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  /// Helper function for calculating the intrinsics metrics of a Stack.
  static double getIntrinsicDimension(RenderBox? firstChild,
      double Function(RenderBox child) mainChildSizeGetter) {
    double extent = 0.0;
    RenderBox? child = firstChild;
    while (child != null) {
      final BoxData childParentData = child.parentData! as BoxData;
      if (!childParentData.isPositioned) {
        extent = math.max(extent, mainChildSizeGetter(child));
      }
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }
    return extent;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return getIntrinsicDimension(
        firstChild, (RenderBox child) => child.getMinIntrinsicWidth(height));
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return getIntrinsicDimension(
        firstChild, (RenderBox child) => child.getMaxIntrinsicWidth(height));
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return getIntrinsicDimension(
        firstChild, (RenderBox child) => child.getMinIntrinsicHeight(width));
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return getIntrinsicDimension(
        firstChild, (RenderBox child) => child.getMaxIntrinsicHeight(width));
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  /// Lays out the positioned `child` according to `alignment` within a Stack of `size`.
  ///
  /// Returns true when the child has visual overflow.
  static bool layoutPositionedChild(RenderBox child, BoxData childParentData,
      Size size, Alignment alignment) {
    assert(childParentData.isPositioned);
    assert(child.parentData == childParentData);

    var position = childParentData.position;
    
    bool hasVisualOverflow = false;
    BoxConstraints childConstraints = const BoxConstraints();

    if (position.left != null && position.right != null) {
      childConstraints = childConstraints.tighten(
          width: size.width - position.right! - position.left!);
    } 
    else if (size.width.isFinite) {
      childConstraints = BoxConstraints(
          minWidth: childConstraints.minWidth,
          maxWidth: size.width,
          minHeight: childConstraints.minHeight,
          maxHeight: childConstraints.maxHeight);
    }

    if (position.top != null && position.bottom != null) {
      childConstraints = childConstraints.tighten(
          height: size.height - position.bottom! - position.top!);
    }

    else if (size.height.isFinite) {
      childConstraints = BoxConstraints(
          minWidth: childConstraints.minWidth,
          maxWidth: childConstraints.maxWidth,
          minHeight: childConstraints.minHeight,
          maxHeight: size.height);
    }

    // calculate the child's size by performing
    // a dry layout. We use LocalBoxConstraints in order to
    // override isTight, which is used in Layout() to determine if a
    // child size change forces a parent to resize.
    child.layout(LocalBoxConstraints.from(childConstraints),
        parentUsesSize: true);

    final double x;
    if (position.left != null) {
      x = position.left!;
    } else if (position.right != null) {
      x = size.width - position.right! - child.size.width;
    } else {
      x = alignment.alongOffset(size - child.size as Offset).dx;
    }

    if (x < 0.0 || x + child.size.width > size.width) {
      hasVisualOverflow = true;
    }

    final double y;
    if (position.top != null) {
      y = position.top!;
    } else if (position.bottom != null) {
      y = size.height - position.bottom! - child.size.height;
    } else {
      y = alignment.alongOffset(size - child.size as Offset).dy;
    }

    if (y < 0.0 || y + child.size.height > size.height) {
      hasVisualOverflow = true;
    }

    childParentData.offset = Offset(x, y);

    return hasVisualOverflow;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeSize(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.dryLayoutChild,
    );
  }

  Size _computeSize(
      {required BoxConstraints constraints,
      required ChildLayouter layoutChild}) {
    _resolve();
    assert(_resolvedAlignment != null);

    var myConstraints = constraints;
    var width = model.expandHorizontally && constraints.hasBoundedWidth
        ? myConstraints.maxWidth
        : myConstraints.minWidth;
    var height = model.expandVertically && constraints.hasBoundedHeight
        ? myConstraints.maxHeight
        : myConstraints.minHeight;

    // get my width from the model
    // and tighten the my width constraint's if not null
    bool hardSizedWidth = false;
    var parentWidth = widthOf(parent);
    var myWidth = model.getWidth(widthParent: parentWidth);
    if (myWidth != null) {

      // fix - olajos April 4, 2024
      width = min(myWidth, myConstraints.maxWidth);

      hardSizedWidth = true;
      myConstraints = BoxConstraints(
          minWidth: myConstraints.minWidth,
          maxWidth: width,
          minHeight: myConstraints.minHeight,
          maxHeight: myConstraints.maxHeight);
    }

    // get my width from the model
    // and tighten the my width constraint's if not null
    bool hardSizedHeight = false;
    var parentHeight =
        constraints.hasBoundedHeight ? constraints.maxHeight : heightOf(parent);
    var myHeight = model.getHeight(heightParent: parentHeight);
    if (myHeight != null) {

      // fix - olajos April 4, 2024
      height = min(myHeight, myConstraints.maxHeight);

      hardSizedHeight = true;
      myConstraints = BoxConstraints(
          minWidth: myConstraints.minWidth,
          maxWidth: myConstraints.maxWidth,
          minHeight: myConstraints.minHeight,
          maxHeight: height);
    }

    // height and/or width is based on non-positioned children
    RenderBox? child = firstChild;
    while (child != null) {
      final BoxData childData = child.parentData! as BoxData;
      if (!childData.isPositioned) {
        // get child constraints
        var childConstraints = myConstraints;
        if (childData.model != null) {
          childConstraints =
              getChildLayoutConstraints(constraints, child, childData.model!);
        }

        // calculate the child's size by performing
        // a dry layout. We use LocalBoxConstraints in order to
        // override isTight, which is used in Layout() to determine if a
        // child size change forces a parent to resize.
        doLayout(child, childConstraints, layoutChild);

        // size of stack is largest unpositioned child if not hard sized
        if (!hardSizedWidth) width = math.max(width, child.size.width);
        if (!hardSizedHeight) height = math.max(height, child.size.height);
      }
      child = childData.nextSibling;
    }

    // return the Stack Size
    return Size(width, height);
  }

  @override
  void performLayout() {

    final BoxConstraints constraints = this.constraints;
    _hasVisualOverflow = false;

    size = _computeSize(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.layoutChild,
    );

    assert(_resolvedAlignment != null);
    RenderBox? child = firstChild;
    while (child != null) {
      final BoxData childParentData = child.parentData! as BoxData;

      if (!childParentData.isPositioned) {
        childParentData.offset =
            _resolvedAlignment!.alongOffset(size - child.size as Offset);
      } else {
        _hasVisualOverflow = layoutPositionedChild(
                child, childParentData, size, _resolvedAlignment!) ||
            _hasVisualOverflow;
      }

      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }

    // set my size in the model
    model.layoutComplete(size, Offset(paintBounds.top, paintBounds.left));
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  /// Override in subclasses to customize how the stack paints.
  ///
  /// By default, the stack uses [defaultPaint]. This function is called by
  /// [paint] after potentially applying a clip to contain visual overflow.
  @protected
  void paintStack(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (clipBehavior != Clip.none && _hasVisualOverflow) {
      _clipRectLayer.layer = context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        paintStack,
        clipBehavior: clipBehavior,
        oldLayer: _clipRectLayer.layer,
      );
    } else {
      _clipRectLayer.layer = null;
      paintStack(context, offset);
    }
  }

  final LayerHandle<ClipRectLayer> _clipRectLayer =
      LayerHandle<ClipRectLayer>();

  @override
  void dispose() {
    _clipRectLayer.layer = null;
    super.dispose();
  }

  @override
  Rect? describeApproximatePaintClip(RenderObject child) {
    switch (clipBehavior) {
      case Clip.none:
        return null;
      case Clip.hardEdge:
      case Clip.antiAlias:
      case Clip.antiAliasWithSaveLayer:
        return _hasVisualOverflow ? Offset.zero & size : null;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<AlignmentGeometry>('alignment', alignment));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection));
    properties.add(EnumProperty<StackFit>('fit', fit));
    properties.add(EnumProperty<Clip>('clipBehavior', clipBehavior,
        defaultValue: Clip.hardEdge));
  }
}
