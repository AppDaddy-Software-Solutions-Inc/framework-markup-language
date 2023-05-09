import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fml/widgets/box_layout/box_layout.dart';
import 'package:fml/widgets/box_layout/box_layout_object.dart';

class BoxLayoutElement extends RenderObjectElement
{
  Element? _child;
  Element? _overlay;

  BoxLayoutElement(BoxLayout widget) : super(widget);

  @override
  BoxLayout get widget {
    return super.widget as BoxLayout;
  }

  @override
  BoxLayoutObject get renderObject
  {
    return super.renderObject as BoxLayoutObject;
  }

  @override
  void mount(Element? parent, newSlot)
  {
    super.mount(parent, newSlot);

    _child = inflateWidget(widget.child, true);
    _overlay = inflateWidget(widget.overlay, false);
  }

  @override
  void update(BoxLayout newWidget) {
    super.update(newWidget);

    _child = updateChild(_child, newWidget.child, true);
    _overlay = updateChild(_overlay, newWidget.overlay, false);
  }

  @override
  void unmount() {
    super.unmount();

    _child = null;
    _overlay = null;
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_child != null) visitor(_child!);
    if (_overlay != null) visitor(_overlay!);
  }

  @override
  void forgetChild(Element child) {
    super.forgetChild(child);
    if (_child == child) _child = null;
    if (_overlay == child) _overlay = null;
  }

  @override
  void insertRenderObjectChild(RenderBox child, bool slot) {
    renderObject.insertRenderObjectChild(child, slot);
  }

  @override
  void moveRenderObjectChild(RenderBox child, bool oldSlot, bool newSlot) {
    renderObject.moveRenderObjectChild(child, oldSlot, newSlot);
  }

  @override
  void removeRenderObjectChild(RenderBox child, bool slot) {
    renderObject.removeRenderObjectChild(child, slot);
  }
}