import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fml/widgets/box_layout/box_layout_element.dart';
import 'package:fml/widgets/box_layout/box_layout_object.dart';

class BoxLayout extends RenderObjectWidget
{
  final Widget child;
  final Widget overlay;

  const BoxLayout(
  {
    required this.child,
    required this.overlay,
  });

  @override
  RenderObjectElement createElement()
  {
    return BoxLayoutElement(this);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return BoxLayoutObject();
  }
}