import 'package:flutter/rendering.dart';
import 'package:fml/widgets/positioned/positioned_model.dart';
import 'package:fml/widgets/viewable/viewable_widget_mixin.dart';

enum FlexType { shrinking, fixed, expanding }

/// Parent data for use with [BoxRenderer].
class BoxData extends ContainerBoxParentData<RenderBox> {

  ViewableWidgetMixin? model;

  Size? parentSize;

  int? flex;
  FlexFit? fit;

  int runIndex = 0;

  bool get isPositioned => model is PositionedModel;
}