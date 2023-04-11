import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/layout_model.dart';

class WidgetAlignment
{
  Alignment          aligned = Alignment.topLeft;
  CrossAxisAlignment crossAlignment = CrossAxisAlignment.start;
  MainAxisAlignment  mainAlignment = MainAxisAlignment.start;
  WrapAlignment      mainWrapAlignment = WrapAlignment.start;
  WrapCrossAlignment crossWrapAlignment = WrapCrossAlignment.start;

  WidgetAlignment(LayoutType modelLayoutType, bool? modelCenter, HorizontalAlignmentType? modelHorizontalAlignment, VerticalAlignmentType? modelVerticalAlignment)
  {
    HorizontalAlignmentType halign;
    VerticalAlignmentType valign;

    // halign override for center if set;
    if (modelHorizontalAlignment == null && modelCenter == true)
      halign = HorizontalAlignmentType.center;
    else if (modelHorizontalAlignment == null && modelCenter == false)
      halign = HorizontalAlignmentType.left;
    else
      halign = modelHorizontalAlignment ?? HorizontalAlignmentType.left;

    // valign overrides center if set;
    if (modelVerticalAlignment == null && modelCenter == true)
      valign = VerticalAlignmentType.center;
    else if (modelVerticalAlignment == null && modelCenter == false)
      valign = VerticalAlignmentType.top;
    else
      valign = modelVerticalAlignment ?? VerticalAlignmentType.top;

    // determine the alignment for the layout type based on the axes;
    if (modelLayoutType == LayoutType.row)
    {
      // cases for Cross axis
      switch (valign)
      {
        case VerticalAlignmentType.center:
          crossAlignment = CrossAxisAlignment.center;
          crossWrapAlignment = WrapCrossAlignment.center;
          break;
        case VerticalAlignmentType.top:
          crossAlignment = CrossAxisAlignment.start;
          crossWrapAlignment = WrapCrossAlignment.start;
          break;
        case VerticalAlignmentType.bottom:
          crossAlignment = CrossAxisAlignment.end;
          crossWrapAlignment = WrapCrossAlignment.end;
          break;
        default:
          crossAlignment = CrossAxisAlignment.start;
          crossWrapAlignment = WrapCrossAlignment.start;
          break;
      }

      // cases for main axis
      switch (halign)
          {
        case HorizontalAlignmentType.center:
          mainAlignment = MainAxisAlignment.center;
          mainWrapAlignment = WrapAlignment.center;
          break;
        case HorizontalAlignmentType.left:
          mainAlignment = MainAxisAlignment.start;
          mainWrapAlignment = WrapAlignment.start;
          break;
        case HorizontalAlignmentType.right:
          mainAlignment = MainAxisAlignment.end;
          mainWrapAlignment = WrapAlignment.end;
          break;
        case HorizontalAlignmentType.around:
          mainAlignment = MainAxisAlignment.spaceAround;
          mainWrapAlignment = WrapAlignment.spaceAround;
          break;
        case HorizontalAlignmentType.between:
          mainAlignment = MainAxisAlignment.spaceBetween;
          mainWrapAlignment = WrapAlignment.spaceBetween;
          break;
        case HorizontalAlignmentType.evenly:
          mainAlignment = MainAxisAlignment.spaceEvenly;
          mainWrapAlignment = WrapAlignment.spaceEvenly;
          break;
        default:
          mainAlignment = MainAxisAlignment.start;
          mainWrapAlignment = WrapAlignment.start;
          break;
      }
    }
    else if (modelLayoutType == LayoutType.column)
    {
      switch (halign)
      {
        case HorizontalAlignmentType.center:
          crossAlignment = CrossAxisAlignment.center;
          crossWrapAlignment = WrapCrossAlignment.center;
          break;
        case HorizontalAlignmentType.left:
          crossAlignment = CrossAxisAlignment.start;
          crossWrapAlignment = WrapCrossAlignment.start;
          break;
        case HorizontalAlignmentType.right:
          crossAlignment = CrossAxisAlignment.end;
          crossWrapAlignment = WrapCrossAlignment.end;
          break;
        default:
          crossAlignment = CrossAxisAlignment.start;
          crossWrapAlignment = WrapCrossAlignment.start;
          break;
      }

      // cases for main axis
      switch (valign)
          {
        case VerticalAlignmentType.center:
          mainAlignment = MainAxisAlignment.center;
          mainWrapAlignment = WrapAlignment.center;
          break;
        case VerticalAlignmentType.top:
          mainAlignment = MainAxisAlignment.start;
          mainWrapAlignment = WrapAlignment.start;
          break;
        case VerticalAlignmentType.bottom:
          mainAlignment = MainAxisAlignment.end;
          mainWrapAlignment = WrapAlignment.end;
          break;
        case VerticalAlignmentType.around:
          mainAlignment = MainAxisAlignment.spaceAround;
          mainWrapAlignment = WrapAlignment.spaceAround;
          break;
        case VerticalAlignmentType.between:
          mainAlignment = MainAxisAlignment.spaceBetween;
          mainWrapAlignment = WrapAlignment.spaceBetween;
          break;
        case VerticalAlignmentType.evenly:
          mainAlignment = MainAxisAlignment.spaceEvenly;
          mainWrapAlignment = WrapAlignment.spaceEvenly;
          break;
        default:
          mainAlignment = MainAxisAlignment.start;
          mainWrapAlignment = WrapAlignment.start;
          break;
      }
    }

    if (modelLayoutType == LayoutType.row)
    {
      // row Alignment for box align
      switch (valign)
      {
        case VerticalAlignmentType.center:
          aligned = Alignment.centerLeft;
          break;
        case VerticalAlignmentType.top:
          aligned = Alignment.topLeft;
          break;
        case VerticalAlignmentType.bottom:
          aligned = Alignment.bottomLeft;
          break;
        default:
          aligned = Alignment.topLeft;
          break;
      }
    }

    if (modelLayoutType == LayoutType.column)
    {
      // Column Alignment for box align
      switch (halign)
      {
        case HorizontalAlignmentType.center:
          aligned = Alignment.topCenter;
          break;
        case HorizontalAlignmentType.left:
          aligned = Alignment.topLeft;
          break;
        case HorizontalAlignmentType.right:
          aligned = Alignment.topRight;
          break;
        default:
          aligned = Alignment.topLeft;
          break;
      }
    }

    if (modelLayoutType == LayoutType.stack)
    {
      switch (valign)
      {
        case VerticalAlignmentType.top:
          if (halign == HorizontalAlignmentType.left) aligned = Alignment.topLeft;
          if (halign == HorizontalAlignmentType.center) aligned = Alignment.topCenter;
          if (halign == HorizontalAlignmentType.right) aligned = Alignment.topRight;
          break;

        case VerticalAlignmentType.center:
          if (halign == HorizontalAlignmentType.center) aligned = Alignment.center;
          break;

        case VerticalAlignmentType.bottom:
          if (halign == HorizontalAlignmentType.left) aligned = Alignment.bottomLeft;
          if (halign == HorizontalAlignmentType.center) aligned = Alignment.bottomCenter;
          if (halign == HorizontalAlignmentType.right) aligned = Alignment.bottomRight;
          break;

        default: aligned = Alignment.topLeft;
      }
    }
  }

  static VerticalAlignmentType? getVerticalAlignmentType(String? alignment, {VerticalAlignmentType? defaultType})
  {
    switch (alignment?.toLowerCase().trim())
    {
      case 'top':
      case 'start':
        return VerticalAlignmentType.top;

      case 'bottom':
      case 'end':
        return VerticalAlignmentType.bottom;

      case 'center':
        return VerticalAlignmentType.center;

      case 'spacearound':
      case 'around':
        return VerticalAlignmentType.around;

      case 'spacebetween':
      case 'between':
        return VerticalAlignmentType.between;

      case 'spacearound':
      case 'around':
        return VerticalAlignmentType.around;

      default: return defaultType;
    }
  }

  static HorizontalAlignmentType? getHorizontalAlignmentType(String? alignment, {HorizontalAlignmentType? defaultType})
  {
    switch (alignment?.toLowerCase().trim())
    {
      case 'left':
      case 'start':
        return HorizontalAlignmentType.left;

      case 'right':
      case 'end':
        return HorizontalAlignmentType.right;

      case 'center':
        return HorizontalAlignmentType.center;

      case 'spacearound':
      case 'around':
        return HorizontalAlignmentType.around;

      case 'spacebetween':
      case 'between':
        return HorizontalAlignmentType.between;

      case 'spacearound':
      case 'around':
        return HorizontalAlignmentType.around;

      default: return defaultType;
    }
  }
}

