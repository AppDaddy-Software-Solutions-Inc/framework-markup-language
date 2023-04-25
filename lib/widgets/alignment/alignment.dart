import 'package:flutter/material.dart';
import 'package:fml/widgets/layout/layout_model.dart';

class WidgetAlignment
{
  Alignment          aligned = Alignment.topLeft;
  CrossAxisAlignment crossAlignment     = CrossAxisAlignment.start;
  MainAxisAlignment  mainAlignment      = MainAxisAlignment.start;
  WrapAlignment      mainWrapAlignment  = WrapAlignment.start;
  WrapCrossAlignment crossWrapAlignment = WrapCrossAlignment.start;

  WidgetAlignment(LayoutType modelLayoutType, bool? center, String? halign, String? valign)
  {
    center = center ?? false;

    HorizontalAlignmentType _halign = WidgetAlignment.getHorizontalAlignmentType(halign) ?? (center ? HorizontalAlignmentType.center : HorizontalAlignmentType.left);
    VerticalAlignmentType   _valign = WidgetAlignment.getVerticalAlignmentType(valign)   ?? (center ? VerticalAlignmentType.center   : VerticalAlignmentType.top);

    // determine the alignment for the layout type based on the axes;
    switch (modelLayoutType)
    {
      case LayoutType.row:
        _setRowAlignment(_halign, _valign);
        break;

      case LayoutType.column:
        _setColumnAlignment(_halign, _valign);
        break;

      case LayoutType.stack:
      default:
        break;
    }

    _setBoxAlignment(center, _halign, _valign);
  }

  _setBoxAlignment(bool center, HorizontalAlignmentType halign, VerticalAlignmentType valign)
  {
    switch (valign)
    {
      case VerticalAlignmentType.top:
        if (halign == HorizontalAlignmentType.left)   aligned = Alignment.topLeft;
        else if (halign == HorizontalAlignmentType.center) aligned = Alignment.topCenter;
        else if (halign == HorizontalAlignmentType.right)  aligned = Alignment.topRight;
        else aligned = Alignment.topLeft;
        break;

      case VerticalAlignmentType.center:
        if (halign == HorizontalAlignmentType.center) aligned = Alignment.center;
        else if (halign == HorizontalAlignmentType.right) aligned = Alignment.centerRight;
        else if (halign == HorizontalAlignmentType.left) aligned = Alignment.centerLeft;
        else aligned = Alignment.centerLeft;
        break;

      case VerticalAlignmentType.bottom:
        if (halign == HorizontalAlignmentType.left)   aligned = Alignment.bottomLeft;
        else if (halign == HorizontalAlignmentType.center) aligned = Alignment.bottomCenter;
        else if (halign == HorizontalAlignmentType.right)  aligned = Alignment.bottomRight;
        else aligned = Alignment.bottomLeft;
        break;

      default: aligned = center ? Alignment.center : Alignment.topLeft;
    }
  }

  _setRowAlignment(HorizontalAlignmentType halign, VerticalAlignmentType valign)
  {
    // cases for Cross axis
    switch (valign)
    {
      case VerticalAlignmentType.center:
        crossAlignment     = CrossAxisAlignment.center;
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

  _setColumnAlignment(HorizontalAlignmentType halign, VerticalAlignmentType valign)
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

      case 'spaceevenly':
      case 'evenly':
        return VerticalAlignmentType.evenly;

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

      case 'spaceevenly':
      case 'evenly':
        return HorizontalAlignmentType.evenly;

      default: return defaultType;
    }
  }
}

