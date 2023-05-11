// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/box/stack_renderer.dart';
export 'package:flutter/animation.dart';

/// A widget that positions its children relative to the edges of its box.
///
/// This class is useful if you want to overlap several children in a simple
/// way, for example having some text and an image, overlaid with a gradient and
/// a button attached to the bottom.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=liEGSeD3Zt8}
///
/// Each child of a [StackObject] widget is either _positioned_ or _non-positioned_.
/// Positioned children are those wrapped in a [Positioned] widget that has at
/// least one non-null property. The stack sizes itself to contain all the
/// non-positioned children, which are positioned according to [alignment]
/// (which defaults to the top-left corner in left-to-right environments and the
/// top-right corner in right-to-left environments). The positioned children are
/// then placed relative to the stack according to their top, right, bottom, and
/// left properties.
///
/// The stack paints its children in order with the first child being at the
/// bottom. If you want to change the order in which the children paint, you
/// can rebuild the stack with the children in the new order. If you reorder
/// the children in this way, consider giving the children non-null keys.
/// These keys will cause the framework to move the underlying objects for
/// the children to their new locations rather than recreate them at their
/// new location.
///
/// For more details about the stack layout algorithm, see [StackRenderer].
///
/// If you want to lay a number of children out in a particular pattern, or if
/// you want to make a custom layout manager, you probably want to use
/// [CustomMultiChildLayout] instead. In particular, when using a [StackObject] you
/// can't position children relative to their size or the stack's own size.
///
/// {@tool snippet}
///
/// Using a [StackObject] you can position widgets over one another.
///
/// ![The sample creates a blue box that overlaps a larger green box, which itself overlaps an even larger red box.](https://flutter.github.io/assets-for-api-docs/assets/widgets/stack.png)
///
/// ```dart
/// Stack(
///   children: <Widget>[
///     Container(
///       width: 100,
///       height: 100,
///       color: Colors.red,
///     ),
///     Container(
///       width: 90,
///       height: 90,
///       color: Colors.green,
///     ),
///     Container(
///       width: 80,
///       height: 80,
///       color: Colors.blue,
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// This example shows how [StackObject] can be used to enhance text visibility
/// by adding gradient backdrops.
///
/// ![The gradient fades from transparent to dark grey at the bottom, with white text on top of the darker portion.](https://flutter.github.io/assets-for-api-docs/assets/widgets/stack_with_gradient.png)
///
/// ```dart
/// SizedBox(
///   width: 250,
///   height: 250,
///   child: Stack(
///     children: <Widget>[
///       Container(
///         width: 250,
///         height: 250,
///         color: Colors.white,
///       ),
///       Container(
///         padding: const EdgeInsets.all(5.0),
///         alignment: Alignment.bottomCenter,
///         decoration: BoxDecoration(
///           gradient: LinearGradient(
///             begin: Alignment.topCenter,
///             end: Alignment.bottomCenter,
///             colors: <Color>[
///               Colors.black.withAlpha(0),
///               Colors.black12,
///               Colors.black45
///             ],
///           ),
///         ),
///         child: const Text(
///           'Foreground Text',
///           style: TextStyle(color: Colors.white, fontSize: 20.0),
///         ),
///       ),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [Align], which sizes itself based on its child's size and positions
///    the child according to an [Alignment] value.
///  * [CustomSingleChildLayout], which uses a delegate to control the layout of
///    a single child.
///  * [CustomMultiChildLayout], which uses a delegate to position multiple
///    children.
///  * [Flow], which provides paint-time control of its children using transform
///    matrices.
///  * The [catalog of layout widgets](https://flutter.dev/widgets/layout/).
class StackObject extends MultiChildRenderObjectWidget
{

  final BoxModel model;

  /// Creates a stack layout widget.
  ///
  /// By default, the non-positioned children of the stack are aligned by their
  /// top left corners.
  StackObject({
    super.key,
    required this.model,
    this.alignment = AlignmentDirectional.topStart,
    this.textDirection,
    this.fit = StackFit.loose,
    this.clipBehavior = Clip.hardEdge,
    super.children,
  }) : assert(clipBehavior != null);

  /// How to align the non-positioned and partially-positioned children in the
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
  /// Defaults to [AlignmentDirectional.topStart].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry alignment;

  /// The text direction with which to resolve [alignment].
  ///
  /// Defaults to the ambient [Directionality].
  final TextDirection? textDirection;

  /// How to size the non-positioned children in the stack.
  ///
  /// The constraints passed into the [StackObject] from its parent are either
  /// loosened ([StackFit.loose]) or tightened to their biggest size
  /// ([StackFit.expand]).
  final StackFit fit;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  bool _debugCheckHasDirectionality(BuildContext context) {
    if (alignment is AlignmentDirectional && textDirection == null) {
      assert(debugCheckHasDirectionality(
        context,
        why: "to resolve the 'alignment' argument",
        hint: alignment == AlignmentDirectional.topStart ? "The default value for 'alignment' is AlignmentDirectional.topStart, which requires a text direction." : null,
        alternative: "Instead of providing a Directionality widget, another solution would be passing a non-directional 'alignment', or an explicit 'textDirection', to the $runtimeType.",
      ));
    }
    return true;
  }

  @override
  StackRenderer createRenderObject(BuildContext context) {
    assert(_debugCheckHasDirectionality(context));
    return StackRenderer(
      model: model,
      alignment: alignment,
      textDirection: textDirection ?? Directionality.maybeOf(context),
      fit: fit,
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(BuildContext context, StackRenderer renderObject) {
    assert(_debugCheckHasDirectionality(context));
    renderObject
      ..alignment = alignment
      ..textDirection = textDirection ?? Directionality.maybeOf(context)
      ..fit = fit
      ..clipBehavior = clipBehavior;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AlignmentGeometry>('alignment', alignment));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection, defaultValue: null));
    properties.add(EnumProperty<StackFit>('fit', fit));
    properties.add(EnumProperty<Clip>('clipBehavior', clipBehavior, defaultValue: Clip.hardEdge));
  }
}
