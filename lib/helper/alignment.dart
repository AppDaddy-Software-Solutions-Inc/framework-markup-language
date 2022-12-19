// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/cupertino.dart';


class AlignmentHelper {
  static Map<String, dynamic> alignWidgetAxis(
      int childrenLength,
      String? modelLayoutType,
      bool? modelCenter,
      String? modelHorizontalAlignment,
      String? modelVerticalAlignment) {
    String halign;
    String valign;
    CrossAxisAlignment crossAlignment = CrossAxisAlignment.start;
    MainAxisAlignment mainAlignment = MainAxisAlignment.start;
    WrapAlignment mainWrapAlignment = WrapAlignment.start;
    WrapCrossAlignment crossWrapAlignment = WrapCrossAlignment.start;
    Alignment aligned = Alignment.topLeft;
    Map<String, dynamic> alignMap = Map<String, dynamic>();

// halign override for center if set;
    if (modelHorizontalAlignment == null && modelCenter == true) {
      halign = 'center';
    } else if (modelHorizontalAlignment == null && modelCenter == false) {
      halign = 'start';
    } else {
      halign = modelHorizontalAlignment ?? 'start';
    }

// valign overrides center if set;
    if (modelVerticalAlignment == null && modelCenter == true) {
      valign = 'center';
    } else if (modelVerticalAlignment == null && modelCenter == false) {
      valign = 'start';
    } else {
      valign = modelVerticalAlignment ?? 'start';
    }

// determine the alignment for the layout type based on the axes;
    if (modelLayoutType == 'row') {
// cases for Cross axis

      switch (valign) {
        case 'center':
          crossAlignment = CrossAxisAlignment.center;
          crossWrapAlignment = WrapCrossAlignment.center;
          break;
        case 'start':
        case 'top':
          crossAlignment = CrossAxisAlignment.start;
          crossWrapAlignment = WrapCrossAlignment.start;
          break;
        case 'end':
        case 'bottom':
          crossAlignment = CrossAxisAlignment.end;
          crossWrapAlignment = WrapCrossAlignment.end;
          break;
        default:
          crossAlignment = CrossAxisAlignment.start;
          crossWrapAlignment = WrapCrossAlignment.start;
          break;
      }

// cases for main axis
      switch (halign) {
        case 'center':
          mainAlignment = MainAxisAlignment.center;
          mainWrapAlignment = WrapAlignment.center;
          break;
        case 'start':
        case 'left':
          mainAlignment = MainAxisAlignment.start;
          mainWrapAlignment = WrapAlignment.start;
          break;
        case 'end':
        case 'right':
          mainAlignment = MainAxisAlignment.end;
          mainWrapAlignment = WrapAlignment.end;
          break;
        case 'spacearound':
        case 'around':
          mainAlignment = MainAxisAlignment.spaceAround;
          mainWrapAlignment = WrapAlignment.spaceAround;
          break;
        case 'spacebetween':
        case 'between':
          mainAlignment = MainAxisAlignment.spaceBetween;
          mainWrapAlignment = WrapAlignment.spaceBetween;
          break;
        case 'spaceevenly':
        case 'evenly':
          mainAlignment = MainAxisAlignment.spaceEvenly;
          mainWrapAlignment = WrapAlignment.spaceEvenly;
          break;
        default:
          mainAlignment = MainAxisAlignment.start;
          mainWrapAlignment = WrapAlignment.start;
          break;
      }
    } else if (modelLayoutType == 'column' ||
        modelLayoutType == 'col') {
      switch (halign) {
        case 'center':
          crossAlignment = CrossAxisAlignment.center;
          crossWrapAlignment = WrapCrossAlignment.center;
          break;
        case 'start':
        case 'left':
          crossAlignment = CrossAxisAlignment.start;
          crossWrapAlignment = WrapCrossAlignment.start;
          break;
        case 'end':
        case 'right':
          crossAlignment = CrossAxisAlignment.end;
          crossWrapAlignment = WrapCrossAlignment.end;
          break;
        default:
          crossAlignment = CrossAxisAlignment.start;
          crossWrapAlignment = WrapCrossAlignment.start;
          break;
      }

// cases for main axis
      switch (valign) {
        case 'center':
          mainAlignment = MainAxisAlignment.center;
          mainWrapAlignment = WrapAlignment.center;
          break;
        case 'start':
        case 'top':
          mainAlignment = MainAxisAlignment.start;
          mainWrapAlignment = WrapAlignment.start;
          break;
        case 'end':
        case 'bottom':
          mainAlignment = MainAxisAlignment.end;
          mainWrapAlignment = WrapAlignment.end;
          break;
        case 'spacearound':
        case 'around':
          mainAlignment = MainAxisAlignment.spaceAround;
          mainWrapAlignment = WrapAlignment.spaceAround;
          break;
        case 'spacebetween':
        case 'between':
          mainAlignment = MainAxisAlignment.spaceBetween;
          mainWrapAlignment = WrapAlignment.spaceBetween;
          break;
        case 'spaceevenly':
        case 'evenly':
          mainAlignment = MainAxisAlignment.spaceEvenly;
          mainWrapAlignment = WrapAlignment.spaceEvenly;
          break;
        default:
          mainAlignment = MainAxisAlignment.start;
          mainWrapAlignment = WrapAlignment.start;
          break;
      }
    }

    if (modelLayoutType == 'row') {
// row Alignment for box align
      switch (valign) {
        case 'center':
          aligned = Alignment.centerLeft;
          break;
        case 'start':
        case 'top':
          aligned = Alignment.topLeft;
          break;
        case 'end':
        case 'bottom':
          aligned = Alignment.bottomLeft;
          break;
        default:
          aligned = Alignment.topLeft;
          break;
      }
    }

    if (modelLayoutType == 'column' ||
        modelLayoutType == 'col') {
// Column Alignment for box align
      switch (halign) {
        case 'center':
          aligned = Alignment.topCenter;
          break;
        case 'start':
        case 'left':
          aligned = Alignment.topLeft;
          break;
        case 'end':
        case 'right':
          aligned = Alignment.topRight;
          break;
        default:
          aligned = Alignment.topLeft;
          break;
      }
    }

    if (childrenLength == 1 || modelLayoutType == 'stack') {
      switch (valign + halign) {
        case 'center' + 'center':
          aligned = Alignment.center;
          break;
        case 'top' + 'center':
        case 'start' + 'center':
          aligned = Alignment.topCenter;
          break;
        case 'top' + 'left':
        case 'start' + 'left':
        case 'top' + 'start':
        case 'start' + 'start':
          aligned = Alignment.topLeft;
          break;
        case 'top' + 'right':
        case 'start' + 'right':
        case 'top' + 'end':
        case 'start' + 'end':
          aligned = Alignment.topRight;
          break;
        case 'end' + 'center':
        case 'bottom' + 'center':
          aligned = Alignment.bottomCenter;
          break;
        case 'end' + 'left':
        case 'bottom' + 'left':
        case 'end' + 'start':
        case 'bottom' + 'start':
          aligned = Alignment.bottomLeft;
          break;
        case 'end' + 'right':
        case 'bottom' + 'right':
        case 'end' + 'end':
        case 'bottom' + 'end':
          aligned = Alignment.bottomRight;
          break;
        default:
          aligned = Alignment.topLeft;
          break;
      }
    }

    alignMap = {
      'crossAlignment': crossAlignment,
      'mainAlignment': mainAlignment,
      'aligned': aligned,
      'mainWrapAlignment': mainWrapAlignment,
      'crossWrapAlignment': crossWrapAlignment,
    };

    return alignMap;
  }
}
