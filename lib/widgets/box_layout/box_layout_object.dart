import 'package:flutter/rendering.dart';

class BoxLayoutObject extends RenderBox
{
  RenderBox? _child;
  RenderBox? _overlay;

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    _child?.attach(owner);
    _overlay?.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    _child?.detach();
    _overlay?.detach();
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (_child != null) visitor(_child!);
    if (_overlay != null) visitor(_overlay!);
  }

  @override
  void redepthChildren() {
    super.redepthChildren();
    _child?.redepthChildren();
    _overlay?.redepthChildren();
  }

  void insertRenderObjectChild(RenderBox child, bool slot) {
    if (slot) {
      _child = child;
    } else {
      _overlay = child;
    }
    adoptChild(child);
  }

  void moveRenderObjectChild(RenderBox child, bool oldSlot, bool newSlot) {
    if (oldSlot) {
      _child = null;
    } else {
      _overlay = null;
    }
    if (newSlot) {
      _child = child;
    } else {
      _overlay = child;
    }
  }

  void removeRenderObjectChild(RenderBox child, bool slot) {
    if (slot) {
      _child = null;
    } else {
      _overlay = null;
    }
    dropChild(child);
  }

  @override
  void performLayout()
  {
    var followerConstraints = constraints;

    final child = _child;
    if (child != null) {
      child.layout(constraints, parentUsesSize: true);
      followerConstraints = BoxConstraints.tight(child.size);
    }

    final overlay = _overlay;
    if (overlay != null) {
      overlay.layout(followerConstraints, parentUsesSize: true);
    }

    size = _child?.size ?? _overlay?.size ?? constraints.smallest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_child != null) {
      context.paintChild(_child!, offset);
    }
    if (_overlay != null) {
      context.paintChild(_overlay!, offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (_overlay?.hitTest(result, position: position) == true) {
      return true;
    }
    if (_child?.hitTest(result, position: position) == true) {
      return true;
    }
    return false;
  }
}
