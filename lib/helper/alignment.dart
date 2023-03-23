// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/alignment.dart';

class AlignmentHelper
{
  static WidgetAlignment alignWidgetAxis(int childrenLength, String? modelLayoutType, bool? modelCenter, String? modelHorizontalAlignment, String? modelVerticalAlignment)
  {
    String halign;
    String valign;

    var alignment =  WidgetAlignment();

    // halign override for center if set;
    if (modelHorizontalAlignment == null && modelCenter == true)
    {
      halign = 'center';
    }
    else if (modelHorizontalAlignment == null && modelCenter == false)
    {
      halign = 'start';
    }
    else
    {
      halign = modelHorizontalAlignment ?? 'start';
    }

    // valign overrides center if set;
    if (modelVerticalAlignment == null && modelCenter == true)
    {
      valign = 'center';
    }
    else if (modelVerticalAlignment == null && modelCenter == false)
    {
      valign = 'start';
    }
    else
    {
      valign = modelVerticalAlignment ?? 'start';
    }

    // determine the alignment for the layout type based on the axes;
    if (modelLayoutType == 'row')
    {
      // cases for Cross axis
      switch (valign)
      {
        case 'center':
          alignment.crossAlignment = CrossAxisAlignment.center;
          alignment.crossWrapAlignment = WrapCrossAlignment.center;
          break;
        case 'start':
        case 'top':
          alignment.crossAlignment = CrossAxisAlignment.start;
          alignment.crossWrapAlignment = WrapCrossAlignment.start;
          break;
        case 'end':
        case 'bottom':
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
        case 'center':
          alignment.mainAlignment = MainAxisAlignment.center;
          alignment.mainWrapAlignment = WrapAlignment.center;
          break;
        case 'start':
        case 'left':
          alignment.mainAlignment = MainAxisAlignment.start;
          alignment.mainWrapAlignment = WrapAlignment.start;
          break;
        case 'end':
        case 'right':
          alignment.mainAlignment = MainAxisAlignment.end;
          alignment.mainWrapAlignment = WrapAlignment.end;
          break;
        case 'spacearound':
        case 'around':
          alignment.mainAlignment = MainAxisAlignment.spaceAround;
          alignment.mainWrapAlignment = WrapAlignment.spaceAround;
          break;
        case 'spacebetween':
        case 'between':
          alignment.mainAlignment = MainAxisAlignment.spaceBetween;
          alignment.mainWrapAlignment = WrapAlignment.spaceBetween;
          break;
        case 'spaceevenly':
        case 'evenly':
          alignment.mainAlignment = MainAxisAlignment.spaceEvenly;
          alignment.mainWrapAlignment = WrapAlignment.spaceEvenly;
          break;
        default:
          alignment.mainAlignment = MainAxisAlignment.start;
          alignment.mainWrapAlignment = WrapAlignment.start;
          break;
      }
    }
    else if (modelLayoutType == 'column' || modelLayoutType == 'col')
    {
      switch (halign)
      {
        case 'center':
          alignment.crossAlignment = CrossAxisAlignment.center;
          alignment.crossWrapAlignment = WrapCrossAlignment.center;
          break;
        case 'start':
        case 'left':
          alignment.crossAlignment = CrossAxisAlignment.start;
          alignment.crossWrapAlignment = WrapCrossAlignment.start;
          break;
        case 'end':
        case 'right':
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
        case 'center':
          alignment.mainAlignment = MainAxisAlignment.center;
          alignment.mainWrapAlignment = WrapAlignment.center;
          break;
        case 'start':
        case 'top':
          alignment.mainAlignment = MainAxisAlignment.start;
          alignment.mainWrapAlignment = WrapAlignment.start;
          break;
        case 'end':
        case 'bottom':
          alignment.mainAlignment = MainAxisAlignment.end;
          alignment.mainWrapAlignment = WrapAlignment.end;
          break;
        case 'spacearound':
        case 'around':
          alignment.mainAlignment = MainAxisAlignment.spaceAround;
          alignment.mainWrapAlignment = WrapAlignment.spaceAround;
          break;
        case 'spacebetween':
        case 'between':
          alignment.mainAlignment = MainAxisAlignment.spaceBetween;
          alignment.mainWrapAlignment = WrapAlignment.spaceBetween;
          break;
        case 'spaceevenly':
        case 'evenly':
          alignment.mainAlignment = MainAxisAlignment.spaceEvenly;
          alignment.mainWrapAlignment = WrapAlignment.spaceEvenly;
          break;
        default:
          alignment.mainAlignment = MainAxisAlignment.start;
          alignment.mainWrapAlignment = WrapAlignment.start;
          break;
      }
    }

    if (modelLayoutType == 'row')
    {
      // row Alignment for box align
      switch (valign)
      {
        case 'center':
          alignment.aligned = Alignment.centerLeft;
          break;
        case 'start':
        case 'top':
          alignment.aligned = Alignment.topLeft;
          break;
        case 'end':
        case 'bottom':
          alignment.aligned = Alignment.bottomLeft;
          break;
        default:
          alignment.aligned = Alignment.topLeft;
          break;
      }
    }

    if (modelLayoutType == 'column' || modelLayoutType == 'col')
    {
      // Column Alignment for box align
      switch (halign)
      {
        case 'center':
          alignment.aligned = Alignment.topCenter;
          break;
        case 'start':
        case 'left':
          alignment.aligned = Alignment.topLeft;
          break;
        case 'end':
        case 'right':
          alignment.aligned = Alignment.topRight;
          break;
        default:
          alignment.aligned = Alignment.topLeft;
          break;
      }
    }

    if (childrenLength == 1 || modelLayoutType == 'stack')
    {
      switch (valign + halign)
      {
        case 'center' + 'center':
          alignment.aligned = Alignment.center;
          break;
        case 'top' + 'center':
        case 'start' + 'center':
          alignment.aligned = Alignment.topCenter;
          break;
        case 'top' + 'left':
        case 'start' + 'left':
        case 'top' + 'start':
        case 'start' + 'start':
          alignment.aligned = Alignment.topLeft;
          break;
        case 'top' + 'right':
        case 'start' + 'right':
        case 'top' + 'end':
        case 'start' + 'end':
          alignment.aligned = Alignment.topRight;
          break;
        case 'end' + 'center':
        case 'bottom' + 'center':
          alignment.aligned = Alignment.bottomCenter;
          break;
        case 'end' + 'left':
        case 'bottom' + 'left':
        case 'end' + 'start':
        case 'bottom' + 'start':
          alignment.aligned = Alignment.bottomLeft;
          break;
        case 'end' + 'right':
        case 'bottom' + 'right':
        case 'end' + 'end':
        case 'bottom' + 'end':
          alignment.aligned = Alignment.bottomRight;
          break;
        default:
          alignment.aligned = Alignment.topLeft;
          break;
      }
    }

    return alignment;
  }
}
