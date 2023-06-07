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
import 'package:fml/widgets/box/stack_renderer.dart';
import 'package:fml/widgets/box/wrap_renderer.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';

// change to false to allow write messages
final debug = kDebugMode && true;

/// Displays its children in a one-dimensional array.
///
/// ## Layout algorithm
///
/// _This section describes how the framework causes [FlexRenderer] to position
/// its children._
/// _See [BoxConstraints] for an introduction to box layout models._
///
/// Layout for a [FlexRenderer] proceeds in six steps:
///
/// 1. Layout each child a null or zero flex factor with unbounded main axis
///    constraints and the incoming cross axis constraints. If the
///    [crossAxisAlignment] is [CrossAxisAlignment.stretch], instead use tight
///    cross axis constraints that match the incoming max extent in the cross
///    axis.
/// 2. Divide the remaining main axis space among the children with non-zero
///    flex factors according to their flex factor. For example, a child with a
///    flex factor of 2.0 will receive twice the amount of main axis space as a
///    child with a flex factor of 1.0.
/// 3. Layout each of the remaining children with the same cross axis
///    constraints as in step 1, but instead of using unbounded main axis
///    constraints, use max axis constraints based on the amount of space
///    allocated in step 2. Children with [Flexible.fit] properties that are
///    [FlexFit.tight] are given tight constraints (i.e., forced to fill the
///    allocated space), and children with [Flexible.fit] properties that are
///    [FlexFit.loose] are given loose constraints (i.e., not forced to fill the
///    allocated space).
/// 4. The cross axis extent of the [FlexRenderer] is the maximum cross axis
///    extent of the children (which will always satisfy the incoming
///    constraints).
/// 5. The main axis extent of the [FlexRenderer] is determined by the
///    [mainAxisSize] property. If the [mainAxisSize] property is
///    [MainAxisSize.max], then the main axis extent of the [FlexRenderer] is the
///    max extent of the incoming main axis constraints. If the [mainAxisSize]
///    property is [MainAxisSize.min], then the main axis extent of the [Flex]
///    is the sum of the main axis extents of the children (subject to the
///    incoming constraints).
/// 6. Determine the position for each child according to the
///    [mainAxisAlignment] and the [crossAxisAlignment]. For example, if the
///    [mainAxisAlignment] is [MainAxisAlignment.spaceBetween], any main axis
///    space that has not been allocated to children is divided evenly and
///    placed between the children.
///
/// See also:
///
///  * [Flex], the widget equivalent.
///  * [Row] and [Column], direction-specific variants of [Flex].
class FlexRenderer extends RenderBox
    with
        BoxMixin,
        ContainerRenderObjectMixin<RenderBox, BoxData>,
        RenderBoxContainerDefaultsMixin<RenderBox, BoxData>,
        DebugOverflowIndicatorMixin
{

  final BoxModel model;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! BoxData) {
      child.parentData = BoxData();
    }
  }

  /// Creates a flex render object.
  ///
  /// By default, the flex layout is horizontal and children are aligned to the
  /// start of the main axis and the center of the cross axis.
  FlexRenderer({
    required this.model,
    Axis direction = Axis.horizontal,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    Clip clipBehavior = Clip.none,
  })  : _direction = direction,
        _mainAxisAlignment = mainAxisAlignment,
        _mainAxisSize = mainAxisSize,
        _crossAxisAlignment = crossAxisAlignment,
        _textDirection = textDirection,
        _verticalDirection = verticalDirection,
        _textBaseline = textBaseline,
        _clipBehavior = clipBehavior;

  /// The direction to use as the main axis.
  Axis get direction => _direction;
  Axis _direction;
  set direction(Axis value) {
    if (_direction != value) {
      _direction = value;
      markNeedsLayout();
    }
  }

  /// How the children should be placed along the main axis.
  ///
  /// If the [direction] is [Axis.horizontal], and the [mainAxisAlignment] is
  /// either [MainAxisAlignment.start] or [MainAxisAlignment.end], then the
  /// [textDirection] must not be null.
  ///
  /// If the [direction] is [Axis.vertical], and the [mainAxisAlignment] is
  /// either [MainAxisAlignment.start] or [MainAxisAlignment.end], then the
  /// [verticalDirection] must not be null.
  MainAxisAlignment get mainAxisAlignment => _mainAxisAlignment;
  MainAxisAlignment _mainAxisAlignment;
  set mainAxisAlignment(MainAxisAlignment value) {
    if (_mainAxisAlignment != value) {
      _mainAxisAlignment = value;
      markNeedsLayout();
    }
  }

  /// How much space should be occupied in the main axis.
  ///
  /// After allocating space to children, there might be some remaining free
  /// space. This value controls whether to maximize or minimize the amount of
  /// free space, subject to the incoming layout constraints.
  ///
  /// If some children have a non-zero flex factors (and none have a fit of
  /// [FlexFit.loose]), they will expand to consume all the available space and
  /// there will be no remaining free space to maximize or minimize, making this
  /// value irrelevant to the final layout.
  MainAxisSize get mainAxisSize => _mainAxisSize;
  MainAxisSize _mainAxisSize;
  set mainAxisSize(MainAxisSize value) {
    if (_mainAxisSize != value) {
      _mainAxisSize = value;
      markNeedsLayout();
    }
  }

  /// How the children should be placed along the cross axis.
  ///
  /// If the [direction] is [Axis.horizontal], and the [crossAxisAlignment] is
  /// either [CrossAxisAlignment.start] or [CrossAxisAlignment.end], then the
  /// [verticalDirection] must not be null.
  ///
  /// If the [direction] is [Axis.vertical], and the [crossAxisAlignment] is
  /// either [CrossAxisAlignment.start] or [CrossAxisAlignment.end], then the
  /// [textDirection] must not be null.
  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;
  CrossAxisAlignment _crossAxisAlignment;
  set crossAxisAlignment(CrossAxisAlignment value) {
    if (_crossAxisAlignment != value) {
      _crossAxisAlignment = value;
      markNeedsLayout();
    }
  }

  /// Determines the order to lay children out horizontally and how to interpret
  /// `start` and `end` in the horizontal direction.
  ///
  /// If the [direction] is [Axis.horizontal], this controls the order in which
  /// children are positioned (left-to-right or right-to-left), and the meaning
  /// of the [mainAxisAlignment] property's [MainAxisAlignment.start] and
  /// [MainAxisAlignment.end] values.
  ///
  /// If the [direction] is [Axis.horizontal], and either the
  /// [mainAxisAlignment] is either [MainAxisAlignment.start] or
  /// [MainAxisAlignment.end], or there's more than one child, then the
  /// [textDirection] must not be null.
  ///
  /// If the [direction] is [Axis.vertical], this controls the meaning of the
  /// [crossAxisAlignment] property's [CrossAxisAlignment.start] and
  /// [CrossAxisAlignment.end] values.
  ///
  /// If the [direction] is [Axis.vertical], and the [crossAxisAlignment] is
  /// either [CrossAxisAlignment.start] or [CrossAxisAlignment.end], then the
  /// [textDirection] must not be null.
  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;
  set textDirection(TextDirection? value) {
    if (_textDirection != value) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  /// Determines the order to lay children out vertically and how to interpret
  /// `start` and `end` in the vertical direction.
  ///
  /// If the [direction] is [Axis.vertical], this controls which order children
  /// are painted in (down or up), the meaning of the [mainAxisAlignment]
  /// property's [MainAxisAlignment.start] and [MainAxisAlignment.end] values.
  ///
  /// If the [direction] is [Axis.vertical], and either the [mainAxisAlignment]
  /// is either [MainAxisAlignment.start] or [MainAxisAlignment.end], or there's
  /// more than one child, then the [verticalDirection] must not be null.
  ///
  /// If the [direction] is [Axis.horizontal], this controls the meaning of the
  /// [crossAxisAlignment] property's [CrossAxisAlignment.start] and
  /// [CrossAxisAlignment.end] values.
  ///
  /// If the [direction] is [Axis.horizontal], and the [crossAxisAlignment] is
  /// either [CrossAxisAlignment.start] or [CrossAxisAlignment.end], then the
  /// [verticalDirection] must not be null.
  VerticalDirection get verticalDirection => _verticalDirection;
  VerticalDirection _verticalDirection;
  set verticalDirection(VerticalDirection value) {
    if (_verticalDirection != value) {
      _verticalDirection = value;
      markNeedsLayout();
    }
  }

  /// If aligning items according to their baseline, which baseline to use.
  ///
  /// Must not be null if [crossAxisAlignment] is [CrossAxisAlignment.baseline].
  TextBaseline? get textBaseline => _textBaseline;
  TextBaseline? _textBaseline;
  set textBaseline(TextBaseline? value) {
    assert(_crossAxisAlignment != CrossAxisAlignment.baseline || value != null);
    if (_textBaseline != value) {
      _textBaseline = value;
      markNeedsLayout();
    }
  }

  // Set during layout if overflow occurred on the main axis.
  double _overflow = 0;
  // Check whether any meaningful overflow is present. Values below an epsilon
  // are treated as not overflowing.
  bool get _hasOverflow => _overflow > precisionErrorTolerance;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.none], and must not be null.
  Clip get clipBehavior => _clipBehavior;
  Clip _clipBehavior = Clip.none;
  set clipBehavior(Clip value) {
    if (value != _clipBehavior) {
      _clipBehavior = value;
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  bool get _canComputeIntrinsics =>
      crossAxisAlignment != CrossAxisAlignment.baseline;

  double _getIntrinsicSize({
    required Axis sizingDirection,
    required double
        extent, // the extent in the direction that isn't the sizing direction
    required _ChildSizingFunction
        childSize, // a method to find the size in the sizing direction
  }) {
    if (!_canComputeIntrinsics) {
      // Intrinsics cannot be calculated without a full layout for
      // baseline alignment. Throw an assertion and return 0.0 as documented
      // on [RenderBox.computeMinIntrinsicWidth].
      assert(
        RenderObject.debugCheckingIntrinsics,
        'Intrinsics are not available for CrossAxisAlignment.baseline.',
      );
      return 0.0;
    }
    if (_direction == sizingDirection) {
      // INTRINSIC MAIN SIZE
      // Intrinsic main size is the smallest size the flex container can take
      // while maintaining the min/max-content contributions of its flex items.
      double totalFlex = 0.0;
      double inflexibleSpace = 0.0;
      double maxFlexFractionSoFar = 0.0;
      RenderBox? child = firstChild;
      while (child != null) {
        final int flex = _getFlex(child);
        totalFlex += flex;
        if (flex > 0) {
          final double flexFraction =
              childSize(child, extent) / _getFlex(child);
          maxFlexFractionSoFar = math.max(maxFlexFractionSoFar, flexFraction);
        } else {
          inflexibleSpace += childSize(child, extent);
        }
        final BoxData childParentData = child.parentData! as BoxData;
        child = childParentData.nextSibling;
      }
      return maxFlexFractionSoFar * totalFlex + inflexibleSpace;
    } else {
      // INTRINSIC CROSS SIZE
      // Intrinsic cross size is the max of the intrinsic cross sizes of the
      // children, after the flexible children are fit into the available space,
      // with the children sized using their max intrinsic dimensions.

      // Get inflexible space using the max intrinsic dimensions of fixed children in the main direction.
      final double availableMainSpace = extent;
      int totalFlex = 0;
      double inflexibleSpace = 0.0;
      double maxCrossSize = 0.0;
      RenderBox? child = firstChild;
      while (child != null) {
        final int flex = _getFlex(child);
        totalFlex += flex;
        late final double mainSize;
        late final double crossSize;
        if (flex == 0) {
          switch (_direction) {
            case Axis.horizontal:
              mainSize = child.getMaxIntrinsicWidth(double.infinity);
              crossSize = childSize(child, mainSize);
              break;
            case Axis.vertical:
              mainSize = child.getMaxIntrinsicHeight(double.infinity);
              crossSize = childSize(child, mainSize);
              break;
          }
          inflexibleSpace += mainSize;
          maxCrossSize = math.max(maxCrossSize, crossSize);
        }
        final BoxData childParentData = child.parentData! as BoxData;
        child = childParentData.nextSibling;
      }

      // Determine the spacePerFlex by allocating the remaining available space.
      // When you're overconstrained spacePerFlex can be negative.
      final double spacePerFlex =
          math.max(0.0, (availableMainSpace - inflexibleSpace) / totalFlex);

      // Size remaining (flexible) items, find the maximum cross size.
      child = firstChild;
      while (child != null) {
        final int flex = _getFlex(child);
        if (flex > 0) {
          maxCrossSize =
              math.max(maxCrossSize, childSize(child, spacePerFlex * flex));
        }
        final BoxData childParentData = child.parentData! as BoxData;
        child = childParentData.nextSibling;
      }

      return maxCrossSize;
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _getIntrinsicSize(
      sizingDirection: Axis.horizontal,
      extent: height,
      childSize: (RenderBox child, double extent) =>
          child.getMinIntrinsicWidth(extent),
    );
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _getIntrinsicSize(
      sizingDirection: Axis.horizontal,
      extent: height,
      childSize: (RenderBox child, double extent) =>
          child.getMaxIntrinsicWidth(extent),
    );
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _getIntrinsicSize(
      sizingDirection: Axis.vertical,
      extent: width,
      childSize: (RenderBox child, double extent) =>
          child.getMinIntrinsicHeight(extent),
    );
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _getIntrinsicSize(
      sizingDirection: Axis.vertical,
      extent: width,
      childSize: (RenderBox child, double extent) =>
          child.getMaxIntrinsicHeight(extent),
    );
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    if (_direction == Axis.horizontal) {
      return defaultComputeDistanceToHighestActualBaseline(baseline);
    }
    return defaultComputeDistanceToFirstActualBaseline(baseline);
  }

  int _getFlex(RenderBox child)
  {
    final BoxData childParentData = child.parentData! as BoxData;
    return childParentData.flex ?? 0;
  }

  FlexFit _getFit(RenderBox child)
  {
    final BoxData childParentData = child.parentData! as BoxData;
    return childParentData.fit ?? FlexFit.tight;
  }

  double _getCrossSize(Size size) {
    switch (_direction) {
      case Axis.horizontal:
        return size.height;
      case Axis.vertical:
        return size.width;
    }
  }

  double _getMainSize(Size size) {
    switch (_direction) {
      case Axis.horizontal:
        return size.width;
      case Axis.vertical:
        return size.height;
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (!_canComputeIntrinsics) {
      assert(debugCannotComputeDryLayout(
        reason:
            'Dry layout cannot be computed for CrossAxisAlignment.baseline, which requires a full layout.',
      ));
      return Size.zero;
    }

    final _LayoutSizes sizes = _computeSizes(
      layoutChild: ChildLayoutHelper.dryLayoutChild,
      constraints: constraints,
    );

    switch (_direction) {
      case Axis.horizontal:
        return constraints.constrain(Size(sizes.mainSize, sizes.crossSize));
      case Axis.vertical:
        return constraints.constrain(Size(sizes.crossSize, sizes.mainSize));
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_hasOverflow) {
      if (size > Size.zero && model.color != null) {
        //context.canvas.drawRect(offset & size, Paint()..color = Colors.green);
      }
      defaultPaint(context, offset);
      return;
    }

    // There's no point in drawing the children if we're empty.
    if (size.isEmpty) {
      return;
    }

    _clipRectLayer.layer = context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      defaultPaint,
      clipBehavior: clipBehavior,
      oldLayer: _clipRectLayer.layer,
    );

    assert(() {
      final List<DiagnosticsNode> debugOverflowHints = <DiagnosticsNode>[
        ErrorDescription(
          'The overflowing $runtimeType has an orientation of $_direction.',
        ),
        ErrorDescription(
          'The edge of the $runtimeType that is overflowing has been marked '
          'in the rendering with a yellow and black striped pattern. This is '
          'usually caused by the contents being too big for the $runtimeType.',
        ),
        ErrorHint(
          'Consider applying a flex factor (e.g. using an Expanded widget) to '
          'force the children of the $runtimeType to fit within the available '
          'space instead of being sized to their natural size.',
        ),
        ErrorHint(
          'This is considered an error condition because it indicates that there '
          'is content that cannot be seen. If the content is legitimately bigger '
          'than the available space, consider clipping it with a ClipRect widget '
          'before putting it in the flex, or using a scrollable container rather '
          'than a Flex, like a ListView.',
        ),
      ];

      // Simulate a child rect that overflows by the right amount. This child
      // rect is never used for drawing, just for determining the overflow
      // location and amount.
      final Rect overflowChildRect;
      switch (_direction) {
        case Axis.horizontal:
          overflowChildRect =
              Rect.fromLTWH(0.0, 0.0, size.width + _overflow, 0.0);
          break;
        case Axis.vertical:
          overflowChildRect =
              Rect.fromLTWH(0.0, 0.0, 0.0, size.height + _overflow);
          break;
      }
      paintOverflowIndicator(
          context, offset, Offset.zero & size, overflowChildRect,
          overflowHints: debugOverflowHints);
      return true;
    }());
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
        return _hasOverflow ? Offset.zero & size : null;
    }
  }

  @override
  String toStringShort() {
    String header = super.toStringShort();
    if (!kReleaseMode) {
      if (_hasOverflow) {
        header += ' OVERFLOWING';
      }
    }
    return header;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<Axis>('direction', direction));
    properties.add(EnumProperty<MainAxisAlignment>(
        'mainAxisAlignment', mainAxisAlignment));
    properties.add(EnumProperty<MainAxisSize>('mainAxisSize', mainAxisSize));
    properties.add(EnumProperty<CrossAxisAlignment>(
        'crossAxisAlignment', crossAxisAlignment));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection,
        defaultValue: null));
    properties.add(EnumProperty<VerticalDirection>(
        'verticalDirection', verticalDirection,
        defaultValue: null));
    properties.add(EnumProperty<TextBaseline>('textBaseline', textBaseline,
        defaultValue: null));
  }

  BoxConstraints _getChildLayoutConstraints(RenderBox child, ViewableWidgetModel model, double maxExtent)
  {
    BoxConstraints constraints = BoxConstraints(maxHeight: this.constraints.maxHeight, maxWidth: this.constraints.maxWidth);

    // set constraints flex child
    switch (_direction)
    {
      case Axis.horizontal:
        constraints = BoxConstraints(
            maxWidth: maxExtent,
            maxHeight: constraints.maxHeight);
        break;

      case Axis.vertical:
        constraints = BoxConstraints(
            maxWidth: constraints.maxWidth,
            maxHeight: maxExtent);
        break;
    }

    return getChildLayoutConstraints(constraints, child, model);
  }

  void _setChildFlex(BoxData data, ViewableWidgetModel model)
  {
    data.flex = null;
    data.fit  = null;
    switch (_direction)
    {
      case Axis.horizontal:

        // if we are constrained in the horizontal and not shrinking in width,
        // then the child can potentially flex in width
        if (constraints.hasBoundedWidth && _horizontalFlex != FlexType.shrinking)
        {
          data.flex = model.flexWidth;
          if (data.flex != null) data.fit = model.flexFit;
        }
        break;

      case Axis.vertical:
        // if we are constrained in the vertical and not shrinking in height,
        // then the child can potentially flex in height
        if (constraints.hasBoundedHeight && _verticalFlex != FlexType.shrinking)
        {
          data.flex = model.flexHeight();
          if (data.flex != null) data.fit = model.flexFit;
        }
    }
  }

  Size calculateFixedChildSizes(ChildLayouter layoutChild)
  {
    var allocatedWidth = 0.0;
    var allocatedHeight = 0.0;

    double maxChildExtent = _direction == Axis.horizontal ? constraints.maxWidth : constraints.maxHeight;

    RenderBox? child = firstChild;
    while (child != null)
    {
      // perform layout
      if (child.parentData is BoxData && (child.parentData as BoxData).model != null)
      {
        var childData = (child.parentData as BoxData);
        var childModel = childData.model!;

        // var idParent = model.id;
        // var idChild = childModel.id;
        // var constr = constraints;

        // assign flex value
        _setChildFlex(childData, childModel);

        // layout child
        if (childData.flex == null)
        {
          // get layout constraints
          var childConstraints = _getChildLayoutConstraints(child, childModel, maxChildExtent);

          // calculate the child's size by performing
          // a dry layout. We use LocalBoxConstraints in order to
          // override isTight, which is used in Layout() to determine if a
          // child size change forces a parent to resize.
          layoutChild(child, LocalBoxConstraints.from(childConstraints));

          // set width
          allocatedWidth = _direction == Axis.horizontal ? (allocatedWidth + (child.size.width)) : max(allocatedWidth, (child.size.width));

          // set height
          allocatedHeight = _direction == Axis.horizontal ? max(allocatedHeight, (child.size.height)) : allocatedHeight + (child.size.height);
        }
      }
      // get next child
      child = childAfter(child);
    }

    return Size(allocatedWidth, allocatedHeight);
  }

  Size calculateFlexChildSizes(ChildLayouter layoutChild,
      {required double freeSpace}) {

    var allocatedWidth = 0.0;
    var allocatedHeight = 0.0;

    // calculate total flex
    int totalFlex = 0;
    RenderBox? child = firstChild;
    RenderBox? lastFlexChild;
    while (child != null) {
      final BoxData data = child.parentData! as BoxData;
      final int flex = _getFlex(child);
      if (flex > 0) {
        totalFlex += flex;
        lastFlexChild = child;
      }
      child = data.nextSibling;
    }

    // layout flexible children
    if (totalFlex > 0) {
      // Distribute free space to flexible children.
      double flexSpaceUsed = 0.0;

      // layout flexible children
      final double spacePerFlex = freeSpace / totalFlex;
      child = firstChild;
      while (child != null)
      {
        // perform layout
        if (child.parentData is BoxData &&
            (child.parentData as BoxData).model != null) {
          var childModel = (child.parentData as BoxData).model!;

          //var idChild = childModel.id;

          final int flex = _getFlex(child);
          if (flex > 0)
          {
            var fit = _getFit(child);

            // get the childs max extent
            double maxExtent = (child == lastFlexChild) ? (freeSpace - flexSpaceUsed) : spacePerFlex * flex;

            // get the childs min extent
            // switch (fit)
            // {
            //   case FlexFit.tight:
            //     minExtent = maxExtent;
            //     break;
            //   case FlexFit.loose:
            //     minExtent = 0.0;
            //     break;
            // }

            // how much of the free space can I consume?
            var maxSpace = (flex / totalFlex) * freeSpace;
            if (maxExtent > maxSpace)
            {
              maxExtent = maxSpace;
            }

            // get child layout constraints
            var childConstraints = _getChildLayoutConstraints(child, childModel, maxExtent);

            // calculate the child's size by performing
            // a dry layout. We use LocalBoxConstraints in order to
            // override isTight, which is used in Layout() to determine if a
            // child size change forces a parent to resize.
            layoutChild(child, LocalBoxConstraints.from(childConstraints));

            // set used flex space
            switch (fit)
            {
              case FlexFit.tight:
                flexSpaceUsed = flexSpaceUsed + maxExtent;
                break;
              case FlexFit.loose:
                flexSpaceUsed = flexSpaceUsed + min(maxExtent, (_direction == Axis.horizontal ? child.size.width : child.size.height));
                break;
            }

            // set width
            allocatedWidth = _direction == Axis.horizontal ? (allocatedWidth + child.size.width) : max(allocatedWidth, child.size.width);

            // set height
            allocatedHeight = _direction == Axis.horizontal ? max(allocatedHeight, child.size.height) : allocatedHeight + child.size.height;
          }
        }

        // get next child
        child = childAfter(child);
      }
    }

    return Size(allocatedWidth, allocatedHeight);
  }

  FlexType get _verticalFlex {
    if (model.hasBoundedHeight) {
      return FlexType.fixed;
    }
    if (model.expandVertically && constraints.hasBoundedHeight) {
      return FlexType.expanding;
    }
    return FlexType.shrinking;
  }

  FlexType get _horizontalFlex {
    if (model.hasBoundedWidth)
    {
      return FlexType.fixed;
    }
    if (model.expandHorizontally && constraints.hasBoundedWidth) {
      return FlexType.expanding;
    }
    return FlexType.shrinking;
  }

  _LayoutSizes _computeSizes({required BoxConstraints constraints, required ChildLayouter layoutChild})
  {
    // size fixed children
    var fixedSize = calculateFixedChildSizes(layoutChild);

    var maxWidth = 0.0;
    switch (_horizontalFlex)
    {
      case FlexType.shrinking:
        maxWidth = fixedSize.width;
        break;

      case FlexType.fixed:
        var parent = parentOf(this);
        if (constraints.hasBoundedWidth && (parent is FlexRenderer || parent is StackRenderer || parent is WrapRenderer))
        {
          maxWidth = constraints.maxWidth;
        }
        else
        {
          maxWidth = model.getWidth(widthParent: widthOf(this.parent)) ?? 0;
        }
        break;

      case FlexType.expanding:
        maxWidth = constraints.hasBoundedWidth ? constraints.maxWidth : 0.0;
        break;
    }

    var maxHeight = 0.0;
    switch (_verticalFlex)
    {
      case FlexType.shrinking:
        maxHeight = fixedSize.height;
        break;

      case FlexType.fixed:
        var parent = parentOf(this);
        if (constraints.hasBoundedHeight && (parent is FlexRenderer || parent is StackRenderer || parent is WrapRenderer))
        {
          maxHeight = constraints.maxHeight;
        }
        else
        {
          maxHeight = model.getHeight(heightParent: heightOf(parent)) ?? 0;
        }
        break;

      case FlexType.expanding:
        maxHeight = constraints.hasBoundedHeight ? constraints.maxHeight : 0.0;
        break;
    }

    // calculate the free space
    // for flex children
    var freeSpace = math.max(0.0, (_direction == Axis.horizontal ? maxWidth : maxHeight) - (_direction == Axis.horizontal ? fixedSize.width : fixedSize.height));

    // size fixed children
    var flexSize = calculateFlexChildSizes(layoutChild, freeSpace: freeSpace);

    // set width
    var width = 0.0;
    switch (_horizontalFlex)
    {
      case FlexType.shrinking:
        width = direction == Axis.horizontal ? fixedSize.width + flexSize.width : max(fixedSize.width, flexSize.width);
        break;

      case FlexType.fixed:
      case FlexType.expanding:
        width = maxWidth;
        break;
    }
    if (width < constraints.minWidth) width = constraints.minWidth;

    // set height
    var height = 0.0;
    switch (_verticalFlex)
    {
      case FlexType.shrinking:
        height = direction == Axis.horizontal ? max(fixedSize.height, flexSize.height) : fixedSize.height + flexSize.height;
        break;

      case FlexType.fixed:
      case FlexType.expanding:
        height = maxHeight;
        break;
    }
    if (height < constraints.minHeight) height = constraints.minHeight;

    // set main axis size
    var mainAxisSize = _direction == Axis.horizontal ? width : height;

    // set cross axis size
    var crossAxisSize = _direction == Axis.horizontal ? height : width;

    // return sizes
    return _LayoutSizes(
        mainSize: mainAxisSize,
        crossSize: crossAxisSize,
        allocatedSize: (_direction == Axis.horizontal
            ? (fixedSize.width + flexSize.width)
            : (fixedSize.height + flexSize.height)));
  }

  @override
  void performLayout()
  {
    final _LayoutSizes sizes = _computeSizes(layoutChild: ChildLayoutHelper.layoutChild, constraints: constraints);

    final double allocatedSize = sizes.allocatedSize;
    double mainAxisSize = sizes.mainSize;
    double crossAxisSize = sizes.crossSize;

    double maxBaselineDistance = 0.0;
    if (crossAxisAlignment == CrossAxisAlignment.baseline) {
      RenderBox? child = firstChild;
      double maxSizeAboveBaseline = 0;
      double maxSizeBelowBaseline = 0;
      while (child != null) {
        assert(() {
          if (textBaseline == null) {
            throw FlutterError(
                'To use FlexAlignItems.baseline, you must also specify which baseline to use using the "baseline" argument.');
          }
          return true;
        }());
        final double? distance =
            child.getDistanceToBaseline(textBaseline!, onlyReal: true);
        if (distance != null) {
          maxBaselineDistance = math.max(maxBaselineDistance, distance);
          maxSizeAboveBaseline = math.max(
            distance,
            maxSizeAboveBaseline,
          );
          maxSizeBelowBaseline = math.max(
            child.size.height - distance,
            maxSizeBelowBaseline,
          );
          crossAxisSize = math.max(
              maxSizeAboveBaseline + maxSizeBelowBaseline, crossAxisSize);
        }
        final BoxData childParentData = child.parentData! as BoxData;
        child = childParentData.nextSibling;
      }
    }

    // Align items along the main axis.
    switch (_direction) {
      case Axis.horizontal:
        size = constraints.constrain(Size(mainAxisSize, crossAxisSize));
        mainAxisSize = size.width;
        crossAxisSize = size.height;
        break;
      case Axis.vertical:
        size = constraints.constrain(Size(crossAxisSize, mainAxisSize));
        mainAxisSize = size.height;
        crossAxisSize = size.width;
        break;
    }
    final double actualSizeDelta = mainAxisSize - allocatedSize;
    _overflow = math.max(0.0, -actualSizeDelta);
    final double remainingSpace = math.max(0.0, actualSizeDelta);
    late final double leadingSpace;
    late final double betweenSpace;
    // flipMainAxis is used to decide whether to lay out
    // left-to-right/top-to-bottom (false), or right-to-left/bottom-to-top
    // (true). The _startIsTopLeft will return null if there's only one child
    // and the relevant direction is null, in which case we arbitrarily decide
    // to flip, but that doesn't have any detectable effect.
    final bool flipMainAxis =
        !(_startIsTopLeft(direction, textDirection, verticalDirection) ?? true);
    switch (_mainAxisAlignment) {
      case MainAxisAlignment.start:
        leadingSpace = 0.0;
        betweenSpace = 0.0;
        break;
      case MainAxisAlignment.end:
        leadingSpace = remainingSpace;
        betweenSpace = 0.0;
        break;
      case MainAxisAlignment.center:
        leadingSpace = remainingSpace / 2.0;
        betweenSpace = 0.0;
        break;
      case MainAxisAlignment.spaceBetween:
        leadingSpace = 0.0;
        betweenSpace = childCount > 1 ? remainingSpace / (childCount - 1) : 0.0;
        break;
      case MainAxisAlignment.spaceAround:
        betweenSpace = childCount > 0 ? remainingSpace / childCount : 0.0;
        leadingSpace = betweenSpace / 2.0;
        break;
      case MainAxisAlignment.spaceEvenly:
        betweenSpace = childCount > 0 ? remainingSpace / (childCount + 1) : 0.0;
        leadingSpace = betweenSpace;
        break;
    }

    // Position elements
    double childMainPosition =
        flipMainAxis ? mainAxisSize - leadingSpace : leadingSpace;
    RenderBox? child = firstChild;
    while (child != null) {
      final BoxData data = child.parentData! as BoxData;

      final double childCrossPosition;
      switch (_crossAxisAlignment) {
        case CrossAxisAlignment.start:
        case CrossAxisAlignment.end:
          childCrossPosition = _startIsTopLeft(
                      flipAxis(direction), textDirection, verticalDirection) ==
                  (_crossAxisAlignment == CrossAxisAlignment.start)
              ? 0.0
              : crossAxisSize - _getCrossSize(child.size);
          break;
        case CrossAxisAlignment.center:
          childCrossPosition =
              crossAxisSize / 2.0 - _getCrossSize(child.size) / 2.0;
          break;
        case CrossAxisAlignment.stretch:
          childCrossPosition = 0.0;
          break;
        case CrossAxisAlignment.baseline:
          if (_direction == Axis.horizontal) {
            assert(textBaseline != null);
            final double? distance =
                child.getDistanceToBaseline(textBaseline!, onlyReal: true);
            if (distance != null) {
              childCrossPosition = maxBaselineDistance - distance;
            } else {
              childCrossPosition = 0.0;
            }
          } else {
            childCrossPosition = 0.0;
          }
          break;
      }
      if (flipMainAxis) {
        childMainPosition -= _getMainSize(child.size);
      }
      switch (_direction) {
        case Axis.horizontal:
          data.offset = Offset(childMainPosition, childCrossPosition);
          break;
        case Axis.vertical:
          data.offset = Offset(childCrossPosition, childMainPosition);
          break;
      }
      if (flipMainAxis) {
        childMainPosition -= betweenSpace;
      } else {
        childMainPosition += _getMainSize(child.size) + betweenSpace;
      }
      child = data.nextSibling;
    }
  }
}

class _LayoutSizes {
  const _LayoutSizes({
    required this.mainSize,
    required this.crossSize,
    required this.allocatedSize,
  });

  final double mainSize;
  final double crossSize;
  final double allocatedSize;
}

typedef _ChildSizingFunction = double Function(RenderBox child, double extent);

bool? _startIsTopLeft(Axis direction, TextDirection? textDirection,
    VerticalDirection? verticalDirection) {
  // If the relevant value of textDirection or verticalDirection is null, this returns null too.
  switch (direction) {
    case Axis.horizontal:
      switch (textDirection) {
        case TextDirection.ltr:
          return true;
        case TextDirection.rtl:
          return false;
        case null:
          return null;
      }
    case Axis.vertical:
      switch (verticalDirection) {
        case VerticalDirection.down:
          return true;
        case VerticalDirection.up:
          return false;
        case null:
          return null;
      }
  }
}
