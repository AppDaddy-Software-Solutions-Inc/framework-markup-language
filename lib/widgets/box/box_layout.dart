import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_data.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';

class BoxLayout extends ParentDataWidget<BoxData> {

  final ViewableMixin model;

  const BoxLayout({
    super.key,
    required this.model,
    required super.child
  });

  @override
  void applyParentData(RenderObject renderObject) {

    if (renderObject.parentData is BoxData) {

      final data = renderObject.parentData! as BoxData;

      // determine if we need to draw (redraw) the box
      // boxes mark themselves as needing rebuild when their view size or position changes
      // This gets marked in onLayoutChange() of the visibleMixin
      bool needsLayout = data.model?.needsLayout ?? false;

      // model changed?
      if (data.model != model) {
        data.model = model;
        needsLayout = true;
      }

      // we need to rebuild the box
      if (needsLayout) {
        final RenderObject? targetParent = renderObject.parent;
        if (targetParent is RenderObject) {
          targetParent.markNeedsLayout();
        }
      }
    }
    else {
      if (kDebugMode) print('Error: applyParentData() called on a parentData that is not BoxData');
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => Flex;
}
