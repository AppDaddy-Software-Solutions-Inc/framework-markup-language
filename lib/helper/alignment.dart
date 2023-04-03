// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/alignment.dart';

enum LayoutType {none, row, column, stack}
enum VerticalAlignmentType {top, bottom, center, around, between, evenly}
enum HorizontalAlignmentType {left, right, center, around, between, evenly}

class AlignmentHelper
{
  static WidgetAlignment alignWidgetAxis(LayoutType modelLayoutType, bool? modelCenter, HorizontalAlignmentType? modelHorizontalAlignment, VerticalAlignmentType? modelVerticalAlignment)
  {
    HorizontalAlignmentType halign;
    VerticalAlignmentType valign;

    var alignment =  WidgetAlignment();

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
          alignment.crossAlignment = CrossAxisAlignment.center;
          alignment.crossWrapAlignment = WrapCrossAlignment.center;
          break;
        case VerticalAlignmentType.top:
          alignment.crossAlignment = CrossAxisAlignment.start;
          alignment.crossWrapAlignment = WrapCrossAlignment.start;
          break;
        case VerticalAlignmentType.bottom:
          alignment.crossAlignment = CrossAxisAlignment.end;
          alignment.crossWrapAlignment = WrapCrossAlignment.end;
          break;
        default:
          alignment.crossAlignment = CrossAxisAlignment.start;
          alignment.crossWrapAlignment = WrapCrossAlignment.start;
          break;
      }

      // cases for main axis
      switch (halign)
          {
        case HorizontalAlignmentType.center:
          alignment.mainAlignment = MainAxisAlignment.center;
          alignment.mainWrapAlignment = WrapAlignment.center;
          break;
        case HorizontalAlignmentType.left:
          alignment.mainAlignment = MainAxisAlignment.start;
          alignment.mainWrapAlignment = WrapAlignment.start;
          break;
        case HorizontalAlignmentType.right:
          alignment.mainAlignment = MainAxisAlignment.end;
          alignment.mainWrapAlignment = WrapAlignment.end;
          break;
        case HorizontalAlignmentType.around:
          alignment.mainAlignment = MainAxisAlignment.spaceAround;
          alignment.mainWrapAlignment = WrapAlignment.spaceAround;
          break;
        case HorizontalAlignmentType.between:
          alignment.mainAlignment = MainAxisAlignment.spaceBetween;
          alignment.mainWrapAlignment = WrapAlignment.spaceBetween;
          break;
        case HorizontalAlignmentType.evenly:
          alignment.mainAlignment = MainAxisAlignment.spaceEvenly;
          alignment.mainWrapAlignment = WrapAlignment.spaceEvenly;
          break;
        default:
          alignment.mainAlignment = MainAxisAlignment.start;
          alignment.mainWrapAlignment = WrapAlignment.start;
          break;
      }
    }
    else if (modelLayoutType == LayoutType.column)
    {
      switch (halign)
      {
        case HorizontalAlignmentType.center:
          alignment.crossAlignment = CrossAxisAlignment.center;
          alignment.crossWrapAlignment = WrapCrossAlignment.center;
          break;
        case HorizontalAlignmentType.left:
          alignment.crossAlignment = CrossAxisAlignment.start;
          alignment.crossWrapAlignment = WrapCrossAlignment.start;
          break;
        case HorizontalAlignmentType.right:
          alignment.crossAlignment = CrossAxisAlignment.end;
          alignment.crossWrapAlignment = WrapCrossAlignment.end;
          break;
        default:
          alignment.crossAlignment = CrossAxisAlignment.start;
          alignment.crossWrapAlignment = WrapCrossAlignment.start;
          break;
      }

      // cases for main axis
      switch (valign)
      {
        case VerticalAlignmentType.center:
          alignment.mainAlignment = MainAxisAlignment.center;
          alignment.mainWrapAlignment = WrapAlignment.center;
          break;
        case VerticalAlignmentType.top:
          alignment.mainAlignment = MainAxisAlignment.start;
          alignment.mainWrapAlignment = WrapAlignment.start;
          break;
        case VerticalAlignmentType.bottom:
          alignment.mainAlignment = MainAxisAlignment.end;
          alignment.mainWrapAlignment = WrapAlignment.end;
          break;
        case VerticalAlignmentType.around:
          alignment.mainAlignment = MainAxisAlignment.spaceAround;
          alignment.mainWrapAlignment = WrapAlignment.spaceAround;
          break;
        case VerticalAlignmentType.between:
          alignment.mainAlignment = MainAxisAlignment.spaceBetween;
          alignment.mainWrapAlignment = WrapAlignment.spaceBetween;
          break;
        case VerticalAlignmentType.evenly:
          alignment.mainAlignment = MainAxisAlignment.spaceEvenly;
          alignment.mainWrapAlignment = WrapAlignment.spaceEvenly;
          break;
        default:
          alignment.mainAlignment = MainAxisAlignment.start;
          alignment.mainWrapAlignment = WrapAlignment.start;
          break;
      }
    }

    if (modelLayoutType == LayoutType.row)
    {
      // row Alignment for box align
      switch (valign)
      {
        case VerticalAlignmentType.center:
          alignment.aligned = Alignment.centerLeft;
          break;
        case VerticalAlignmentType.top:
          alignment.aligned = Alignment.topLeft;
          break;
        case VerticalAlignmentType.bottom:
          alignment.aligned = Alignment.bottomLeft;
          break;
        default:
          alignment.aligned = Alignment.topLeft;
          break;
      }
    }

    if (modelLayoutType == LayoutType.column)
    {
      // Column Alignment for box align
      switch (halign)
      {
        case HorizontalAlignmentType.center:
          alignment.aligned = Alignment.topCenter;
          break;
        case HorizontalAlignmentType.left:
          alignment.aligned = Alignment.topLeft;
          break;
        case HorizontalAlignmentType.right:
          alignment.aligned = Alignment.topRight;
          break;
        default:
          alignment.aligned = Alignment.topLeft;
          break;
      }
    }

    if (modelLayoutType == LayoutType.stack)
    {
      switch (valign)
      {
        case VerticalAlignmentType.top:
          if (halign == HorizontalAlignmentType.left) alignment.aligned = Alignment.topLeft;
          if (halign == HorizontalAlignmentType.center) alignment.aligned = Alignment.topCenter;
          if (halign == HorizontalAlignmentType.right) alignment.aligned = Alignment.topRight;
          break;

        case VerticalAlignmentType.center:
          if (halign == HorizontalAlignmentType.center) alignment.aligned = Alignment.center;
          break;

        case VerticalAlignmentType.bottom:
          if (halign == HorizontalAlignmentType.left) alignment.aligned = Alignment.bottomLeft;
          if (halign == HorizontalAlignmentType.center) alignment.aligned = Alignment.bottomCenter;
          if (halign == HorizontalAlignmentType.right) alignment.aligned = Alignment.bottomRight;
          break;

        default: alignment.aligned = Alignment.topLeft;
      }
    }
    return alignment;
  }

  static LayoutType getLayoutType(String? layout, {LayoutType defaultLayout = LayoutType.column})
  {
    switch (layout?.toLowerCase().trim())
    {
      case 'col':
      case 'column':
        return LayoutType.column;

      case 'row':
        return LayoutType.row;

      case 'stack':
        return LayoutType.stack;

      default: return defaultLayout;
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
