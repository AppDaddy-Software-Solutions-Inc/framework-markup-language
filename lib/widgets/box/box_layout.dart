import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_data.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';

class BoxLayout extends ParentDataWidget<BoxData> {

  final ViewableWidgetMixin model;

  const BoxLayout({
    super.key,
    required this.model,
    required super.child
  });

  @override
  void applyParentData(RenderObject renderObject) {
    if (renderObject.parentData is BoxData) {
      final BoxData parentData = renderObject.parentData! as BoxData;

      bool needsLayout = false;

      if (parentData.model != model) {
        parentData.model = model;
        needsLayout = true;
      }

      if (needsLayout) {
        final RenderObject? targetParent = renderObject.parent;
        if (targetParent is RenderObject) {
          targetParent.markNeedsLayout();
        }
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => Flex;
}
