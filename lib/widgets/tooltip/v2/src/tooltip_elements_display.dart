import 'package:flutter/material.dart';
import 'package:fml/widgets/tooltip/v2/src/position_manager.dart';
import 'element_box.dart';

/// [ToolTipElementsDisplay] holds the size, position and style
/// for the tooltip and the arrow.
class ToolTipElementsDisplay {
  final ElementBox bubble;
  final ElementBox arrow;
  final TooltipPosition position;
  final BorderRadiusGeometry? radius;

  ToolTipElementsDisplay({
    required this.bubble,
    required this.arrow,
    required this.position,
    this.radius,
  });
}
