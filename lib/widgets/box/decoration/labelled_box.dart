import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

enum LabelledContainerSlot { label, container }

class LabelledBorderContainer extends SlottedMultiChildRenderObjectWidget<
    LabelledContainerSlot, RenderBox> {
  final BoxDecoration decoration;
  final Container container;
  final Widget label;

  const LabelledBorderContainer(this.container, this.label,
      {super.key, required this.decoration});

  @override
  Iterable<LabelledContainerSlot> get slots => LabelledContainerSlot.values;

  @override
  Widget? childForSlot(LabelledContainerSlot slot) {
    switch (slot) {
      case LabelledContainerSlot.label:
        return label;
      case LabelledContainerSlot.container:
        return container;
    }
  }

  @override
  LabelledContainerRenderer createRenderObject(BuildContext context) {
    return LabelledContainerRenderer(decoration: decoration);
  }

  @override
  void updateRenderObject(
      BuildContext context, LabelledContainerRenderer renderObject) {
    renderObject.decoration = decoration;
  }
}

class LabelledContainerRenderer extends RenderBox
    with SlottedContainerRenderObjectMixin<LabelledContainerSlot, RenderBox> {
  LabelledContainerRenderer({required BoxDecoration decoration})
      : _decoration = decoration;

  BoxDecoration? _decoration;
  BoxDecoration? get decoration => _decoration;
  set decoration(BoxDecoration? value) {
    assert(value != null);
    if (_decoration == value) {
      return;
    }
    _decoration = value;
    markNeedsPaint();
  }

  RenderBox? get label => childForSlot(LabelledContainerSlot.label);
  RenderBox? get container => childForSlot(LabelledContainerSlot.container);

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (label != null) visitor(label!);
    if (container != null) visitor(container!);
  }

  @override
  bool get sizedByParent => false;

  // Returns children in hit test order.
  @override
  Iterable<RenderBox> get children {
    return <RenderBox>[
      if (label != null) label!,
      if (container != null) container!,
    ];
  }

  final double gapPadding = 6.0;
  final double gapStart = 10.0;
  Offset get labelOffset => Offset(
      gapStart + (gapPadding / 2), ((label?.size.height ?? 0.0) / 2) * -1);

  @override
  void performLayout() {

    if (container == null) {
      size = Size.zero;
      return;
    }

    // layout main container
    container!.layout(constraints, parentUsesSize: true);
    _positionChild(container!, Offset.zero);

    // layout the label
    if (label != null) {

      var constraints = BoxConstraints(
          minWidth: 0,
          maxWidth: math.max(container!.size.width - gapStart - (gapPadding * 4),0.0),
          minHeight: 0,
          maxHeight: container!.size.height/2);

      label!.layout(constraints, parentUsesSize: true);
      _positionChild(label!, labelOffset);
    }

    // calculate the overall size
    size = Size(container!.size.width, container!.size.height);
  }

  void _positionChild(RenderBox child, Offset offset) {
    (child.parentData! as BoxParentData).offset = offset;
  }

  Offset paintChildOffset(
      RenderBox child, PaintingContext context, Offset offset) {
    final BoxParentData childParentData = child.parentData! as BoxParentData;
    return childParentData.offset + offset;
  }

  void paintChild(RenderBox child, PaintingContext context, Offset offset) {
    context.paintChild(child, paintChildOffset(child, context, offset));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // paint the widget
    paintChild(container!, context, offset);
    paintChild(label!, context, offset + Offset(gapPadding, 0));
    paintChildBorder(
        paintChildOffset(container!, context, offset),
        context.canvas,
        decoration!.border!.top,
        decoration!.borderRadius!.resolve(TextDirection.ltr));
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (final RenderBox child in children) {
      final BoxParentData parentData = child.parentData! as BoxParentData;
      final bool isHit = result.addWithPaintOffset(
        offset: parentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - parentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
    }
    return false;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    final double width = container?.getMinIntrinsicWidth(double.infinity) ?? 0;
    return width;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final double width = container?.getMaxIntrinsicWidth(double.infinity) ?? 0;
    return width;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final double height =
        container?.getMinIntrinsicHeight(double.infinity) ?? 0;
    return height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final double height =
        container?.getMaxIntrinsicHeight(double.infinity) ?? 0;
    return height;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    const BoxConstraints childConstraints = BoxConstraints();
    final Size containerSize =
        container?.computeDryLayout(childConstraints) ?? Size.zero;
    //final Size labelSize = label?.computeDryLayout(childConstraints) ?? Size.zero;
    return containerSize;
  }

  double? lerpDouble(num? a, num? b, double t) {
    if (a == b || (a?.isNaN ?? false) && (b?.isNaN ?? false)) {
      return a?.toDouble();
    }
    a ??= 0.0;
    b ??= 0.0;
    assert(
        a.isFinite, 'Cannot interpolate between finite and non-finite values');
    assert(
        b.isFinite, 'Cannot interpolate between finite and non-finite values');
    assert(t.isFinite, 't must be finite when interpolating between values');
    return a * (1.0 - t) + b * t;
  }

  void paintChildBorder(Offset offset, Canvas canvas, BorderSide borderSide,
      BorderRadius borderRadius) {
    final rect = Rect.fromLTRB(offset.dx, offset.dy,
        container!.size.width + offset.dx, container!.size.height + offset.dy);
    final paint = borderSide.toPaint();
    final outer = borderRadius.toRRect(rect);
    final center = outer.inflate(borderSide.width / 2);

    final gapExtent = label?.size.width ?? 0.0;
    if (gapExtent <= 0.0) return canvas.drawRRect(center, paint);

    final double extent = lerpDouble(0.0, gapExtent + gapPadding * 2.0, 1)!;
    final Path path = _gapBorderPath(canvas, borderSide, center,
        math.max(0.0, gapStart + (gapPadding / 2)), extent);
    canvas.drawPath(path, paint);
  }

  Path _gapBorderPath(Canvas canvas, BorderSide borderSide, RRect center,
      double start, double extent) {
    // When the corner radii on any side add up to be greater than the
    // given height, each radius has to be scaled to not exceed the
    // size of the width/height of the RRect.
    final RRect scaledRRect = center.scaleRadii();

    final Rect tlCorner = Rect.fromLTWH(
      scaledRRect.left,
      scaledRRect.top,
      scaledRRect.tlRadiusX * 2.0,
      scaledRRect.tlRadiusY * 2.0,
    );
    final Rect trCorner = Rect.fromLTWH(
      scaledRRect.right - scaledRRect.trRadiusX * 2.0,
      scaledRRect.top,
      scaledRRect.trRadiusX * 2.0,
      scaledRRect.trRadiusY * 2.0,
    );
    final Rect brCorner = Rect.fromLTWH(
      scaledRRect.right - scaledRRect.brRadiusX * 2.0,
      scaledRRect.bottom - scaledRRect.brRadiusY * 2.0,
      scaledRRect.brRadiusX * 2.0,
      scaledRRect.brRadiusY * 2.0,
    );
    final Rect blCorner = Rect.fromLTWH(
      scaledRRect.left,
      scaledRRect.bottom - scaledRRect.blRadiusY * 2.0,
      scaledRRect.blRadiusX * 2.0,
      scaledRRect.blRadiusY * 2.0,
    );

    // This assumes that the radius is circular (x and y radius are equal).
    // Currently, BorderRadius only supports circular radii.
    const double cornerArcSweep = math.pi / 2.0;
    final Path path = Path();

    // Top left corner
    if (scaledRRect.tlRadius != Radius.zero) {
      final double tlCornerArcSweep =
          math.acos(clampDouble(1 - start / scaledRRect.tlRadiusX, 0.0, 1.0));
      path.addArc(tlCorner, math.pi, tlCornerArcSweep);
    } else {
      // Because the path is painted with Paint.strokeCap = StrokeCap.butt, horizontal coordinate is moved
      // to the left using borderSide.width / 2.
      path.moveTo(scaledRRect.left - borderSide.width / 2, scaledRRect.top);
    }

    // Draw top border from top left corner to gap start.
    if (start > scaledRRect.tlRadiusX) {
      path.lineTo(scaledRRect.left + start, scaledRRect.top);
    }

    // Draw top border from gap end to top right corner and draw top right corner.
    const double trCornerArcStart = (3 * math.pi) / 2.0;
    const double trCornerArcSweep = cornerArcSweep;
    if (start + extent < scaledRRect.width - scaledRRect.trRadiusX) {
      path.moveTo(scaledRRect.left + start + extent, scaledRRect.top);
      path.lineTo(scaledRRect.right - scaledRRect.trRadiusX, scaledRRect.top);
      if (scaledRRect.trRadius != Radius.zero) {
        path.addArc(trCorner, trCornerArcStart, trCornerArcSweep);
      }
    } else if (start + extent < scaledRRect.width) {
      final double dx = scaledRRect.width - (start + extent);
      final double sweep =
          math.asin(clampDouble(1 - dx / scaledRRect.trRadiusX, 0.0, 1.0));
      path.addArc(trCorner, trCornerArcStart + sweep, trCornerArcSweep - sweep);
    }

    // Draw right border and bottom right corner.
    if (scaledRRect.brRadius != Radius.zero) {
      path.moveTo(scaledRRect.right, scaledRRect.top + scaledRRect.trRadiusY);
    }
    path.lineTo(scaledRRect.right, scaledRRect.bottom - scaledRRect.brRadiusY);
    if (scaledRRect.brRadius != Radius.zero) {
      path.addArc(brCorner, 0.0, cornerArcSweep);
    }

    // Draw bottom border and bottom left corner.
    path.lineTo(scaledRRect.left + scaledRRect.blRadiusX, scaledRRect.bottom);
    if (scaledRRect.blRadius != Radius.zero) {
      path.addArc(blCorner, math.pi / 2.0, cornerArcSweep);
    }

    // Draw left border
    path.lineTo(scaledRRect.left, scaledRRect.top + scaledRRect.tlRadiusY);

    return path;
  }
}
