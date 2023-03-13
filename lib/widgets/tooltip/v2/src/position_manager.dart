// MIT License
//
// Copyright (c) 2022 Marcelo Gil
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'package:flutter/material.dart';
import 'element_box.dart';
import 'tooltip_elements_display.dart';

enum TooltipPosition {
  topStart,
  topCenter,
  topEnd,
  rightStart,
  rightCenter,
  rightEnd,
  bottomStart,
  bottomCenter,
  bottomEnd,
  leftStart,
  leftCenter,
  leftEnd,
}


/// Calculates the position of the tooltip and the arrow on the screen
/// Verifies if the desired position fits the screen.
/// If it doesn't the position changes automatically.
class PositionManager
{
  final bool showArrow;

  /// [arrowBox] width, height, position x and y of the arrow.
  final ElementBox arrowBox;

  /// [triggerBox] width, height, position x and y of the trigger.
  final ElementBox triggerBox;

  /// [overlayBox] width, height, position x and y of the overlay.
  final ElementBox overlayBox;

  /// [screenSize] width and height of the current screen.
  final ElementBox screenSize;

  /// [distance] between the tooltip and the trigger button.
  final double distance;

  /// [radius] border radius amount of the tooltip.
  final double radius;

  PositionManager({
    required this.showArrow,
    required this.arrowBox,
    required this.triggerBox,
    required this.overlayBox,
    required this.screenSize,
    this.distance = 0.0,
    this.radius = 0.0,
  });

  ToolTipElementsDisplay _topStart() {
    return ToolTipElementsDisplay(
      arrow: ElementBox(
        w: overlayBox.w,
        h: overlayBox.h,
        x: (triggerBox.x + _half(triggerBox.w)).floorToDouble(),
        y: (triggerBox.y - distance - arrowBox.h).floorToDouble(),
      ),
      bubble: ElementBox(
        w: overlayBox.w,
        h: overlayBox.h,
        x: triggerBox.x + _half(triggerBox.w),
        y: triggerBox.y - overlayBox.h - distance - arrowBox.h,
      ),
      position: TooltipPosition.topStart,
      radius: showArrow ? BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
        bottomLeft: Radius.zero,
        bottomRight: Radius.circular(radius),
      ) : BorderRadius.all(Radius.circular(radius)),
    );
  }

  ToolTipElementsDisplay _topCenter() {
    return ToolTipElementsDisplay(
      arrow: ElementBox(
        w: arrowBox.w,
        h: arrowBox.h,
        x: (triggerBox.x + _half(triggerBox.w) - _half(arrowBox.w))
            .floorToDouble(),
        y: (triggerBox.y - distance - arrowBox.h).floorToDouble(),
      ),
      bubble: ElementBox(
        w: overlayBox.w,
        h: overlayBox.h,
        x: triggerBox.x + _half(triggerBox.w) - _half(overlayBox.w),
        y: triggerBox.y - overlayBox.h - distance - arrowBox.h,
      ),
      position: TooltipPosition.topCenter,
      radius: BorderRadius.all(Radius.circular(radius)),
    );
  }

  ToolTipElementsDisplay _topEnd() {
    return ToolTipElementsDisplay(
      arrow: ElementBox(
        w: arrowBox.w,
        h: arrowBox.h,
        x: (triggerBox.x + _half(triggerBox.w) - arrowBox.w).floorToDouble(),
        y: (triggerBox.y - distance - arrowBox.h).floorToDouble(),
      ),
      bubble: ElementBox(
        w: arrowBox.w,
        h: arrowBox.h,
        x: triggerBox.x - overlayBox.w + _half(triggerBox.w),
        y: triggerBox.y - overlayBox.h - distance - arrowBox.h,
      ),
      position: TooltipPosition.topEnd,
      radius: showArrow ? BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.zero,
      ) : BorderRadius.all(Radius.circular(radius)),
    );
  }

  ToolTipElementsDisplay _bottomStart() {
    return ToolTipElementsDisplay(
      arrow: ElementBox(
        w: overlayBox.w,
        h: overlayBox.h,
        x: (triggerBox.x + _half(triggerBox.w)).ceilToDouble(),
        y: (triggerBox.y + triggerBox.h + distance).ceilToDouble(),
      ),
      bubble: ElementBox(
        w: overlayBox.w,
        h: overlayBox.h,
        x: triggerBox.x + _half(triggerBox.w),
        y: triggerBox.y + triggerBox.h + distance + arrowBox.h,
      ),
      position: TooltipPosition.bottomStart,
      radius: showArrow ? BorderRadius.only(
        topLeft: Radius.zero,
        topRight: Radius.circular(radius),
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      ) : BorderRadius.all(Radius.circular(radius)),
    );
  }

  ToolTipElementsDisplay _bottomCenter() {
    return ToolTipElementsDisplay(
      arrow: ElementBox(
        w: arrowBox.w,
        h: arrowBox.h,
        x: (triggerBox.x + _half(triggerBox.w) - _half(arrowBox.w))
            .ceilToDouble(),
        y: (triggerBox.y + triggerBox.h + distance).ceilToDouble(),
      ),
      bubble: ElementBox(
        w: overlayBox.w,
        h: overlayBox.h,
        x: triggerBox.x + _half(triggerBox.w) - _half(overlayBox.w),
        y: triggerBox.y + triggerBox.h + distance + arrowBox.h,
      ),
      position: TooltipPosition.bottomCenter,
      radius: BorderRadius.all(Radius.circular(radius)),
    );
  }

  ToolTipElementsDisplay _bottomEnd() {
    return ToolTipElementsDisplay(
      arrow: ElementBox(
        w: overlayBox.w,
        h: overlayBox.h,
        x: (triggerBox.x + _half(triggerBox.w) - arrowBox.w),
        y: (triggerBox.y + triggerBox.h + distance).ceilToDouble(),
      ),
      bubble: ElementBox(
        w: overlayBox.w,
        h: overlayBox.h,
        x: triggerBox.x + _half(triggerBox.w) - overlayBox.w,
        y: triggerBox.y + triggerBox.h + distance + arrowBox.h,
      ),
      position: TooltipPosition.bottomEnd,
      radius: showArrow ? BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.zero,
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      ) : BorderRadius.all(Radius.circular(radius)),
    );
  }

  ToolTipElementsDisplay _leftStart() {
    return ToolTipElementsDisplay(
      arrow: ElementBox(
        w: overlayBox.w,
        h: overlayBox.h,
        x: (triggerBox.x - overlayBox.x - distance - arrowBox.h)
            .floorToDouble(),
        y: triggerBox.y + _half(triggerBox.h),
      ),
      bubble: ElementBox(
        w: overlayBox.w,
        h: overlayBox.h,
        x: triggerBox.x - overlayBox.x - overlayBox.w - distance - arrowBox.h,
        y: triggerBox.y + _half(triggerBox.h),
      ),
      position: TooltipPosition.leftStart,
      radius: showArrow ? BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.zero,
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      ) : BorderRadius.all(Radius.circular(radius)),
    );
  }

  ToolTipElementsDisplay _leftCenter() {
    return ToolTipElementsDisplay(
      arrow: ElementBox(
        w: overlayBox.w,
        h: overlayBox.h,
        x: (triggerBox.x - overlayBox.x - distance - arrowBox.h)
            .floorToDouble(),
        y: (triggerBox.y + _half(triggerBox.h) - _half(arrowBox.w))
            .floorToDouble(),
      ),
      bubble: ElementBox(
        w: overlayBox.w,
        h: overlayBox.h,
        x: triggerBox.x - overlayBox.x - overlayBox.w - distance - arrowBox.h,
        y: triggerBox.y + _half(triggerBox.h) - _half(overlayBox.h),
      ),
      position: TooltipPosition.leftCenter,
      radius: BorderRadius.all(Radius.circular(radius)),
    );
  }

  ToolTipElementsDisplay _leftEnd() {
    return ToolTipElementsDisplay(
      arrow: ElementBox(
        w: overlayBox.w,
        h: overlayBox.h,
        x: (triggerBox.x - overlayBox.x - distance - arrowBox.h)
            .floorToDouble(),
        y: (triggerBox.y + _half(triggerBox.h) - arrowBox.w).floorToDouble(),
      ),
      bubble: ElementBox(
        w: overlayBox.w,
        h: overlayBox.h,
        x: triggerBox.x - overlayBox.x - overlayBox.w - distance - arrowBox.h,
        y: triggerBox.y + _half(triggerBox.h) - overlayBox.h,
      ),
      position: TooltipPosition.leftEnd,
      radius: showArrow ? BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.zero,
      ) : BorderRadius.all(Radius.circular(radius)),
    );
  }

  ToolTipElementsDisplay _rightStart() {
    return ToolTipElementsDisplay(
      arrow: ElementBox(
        w: overlayBox.w,
        h: overlayBox.h,
        x: (triggerBox.x + triggerBox.w + distance).floorToDouble(),
        y: (triggerBox.y + _half(triggerBox.h)).floorToDouble(),
      ),
      bubble: ElementBox(
        w: overlayBox.w,
        h: overlayBox.h,
        x: (triggerBox.x + triggerBox.w + distance + arrowBox.h)
            .floorToDouble(),
        y: (triggerBox.y + _half(triggerBox.h)).floorToDouble(),
      ),
      position: TooltipPosition.rightStart,
      radius: showArrow ? BorderRadius.only(
        topLeft: Radius.zero,
        topRight: Radius.circular(radius),
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      ) : BorderRadius.all(Radius.circular(radius)),
    );
  }

  ToolTipElementsDisplay _rightCenter() {
    return ToolTipElementsDisplay(
      arrow: ElementBox(
        w: overlayBox.w,
        h: overlayBox.h,
        x: (triggerBox.x + triggerBox.w + distance).floorToDouble(),
        y: (triggerBox.y + _half(triggerBox.h) - _half(arrowBox.w))
            .floorToDouble(),
      ),
      bubble: ElementBox(
        w: overlayBox.w,
        h: overlayBox.h,
        x: triggerBox.x + triggerBox.w + distance + arrowBox.h,
        y: triggerBox.y + _half(triggerBox.h) - _half(overlayBox.h),
      ),
      position: TooltipPosition.rightCenter,
      radius: BorderRadius.all(Radius.circular(radius)),
    );
  }

  ToolTipElementsDisplay _rightEnd() {
    return ToolTipElementsDisplay(
      arrow: ElementBox(
        w: overlayBox.w,
        h: overlayBox.h,
        x: (triggerBox.x + triggerBox.w + distance).floorToDouble(),
        y: triggerBox.y + _half(triggerBox.h) - arrowBox.w,
      ),
      bubble: ElementBox(
        w: overlayBox.w,
        h: overlayBox.h,
        x: triggerBox.x + triggerBox.w + distance + arrowBox.h,
        y: triggerBox.y + _half(triggerBox.h) - overlayBox.h,
      ),
      position: TooltipPosition.rightEnd,
      radius: showArrow ? BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
        bottomLeft: Radius.zero,
        bottomRight: Radius.circular(radius),
      ) : BorderRadius.all(Radius.circular(radius)),
    );
  }

  double _half(double size) {
    return size * 0.5;
  }

  bool _fitsScreen(ToolTipElementsDisplay el) {
    if (el.bubble.x > 0 &&
        el.bubble.x + el.bubble.w < screenSize.w &&
        el.bubble.y > 0 &&
        el.bubble.y + el.bubble.h < screenSize.h) {
      return true;
    }
    return false;
  }

  /// Tests each possible position until it finds one that fits.
  ToolTipElementsDisplay _firstAvailablePosition() {
    List<ToolTipElementsDisplay Function()> positions = [
      _topCenter,
      _bottomCenter,
      _leftCenter,
      _rightCenter,
      _topStart,
      _topEnd,
      _leftStart,
      _rightStart,
      _leftEnd,
      _rightEnd,
      _bottomStart,
      _bottomEnd,
    ];
    for (var position in positions) {
      if (_fitsScreen(position())) return position();
    }
    return _topCenter();
  }

  /// Load the calculated tooltip position
  ToolTipElementsDisplay load({TooltipPosition? preferredPosition}) {
    ToolTipElementsDisplay elementPosition;

    switch (preferredPosition) {
      case TooltipPosition.topStart:
        elementPosition = _topStart();
        break;
      case TooltipPosition.topCenter:
        elementPosition = _topCenter();
        break;
      case TooltipPosition.topEnd:
        elementPosition = _topEnd();
        break;
      case TooltipPosition.bottomStart:
        elementPosition = _bottomStart();
        break;
      case TooltipPosition.bottomCenter:
        elementPosition = _bottomCenter();
        break;
      case TooltipPosition.bottomEnd:
        elementPosition = _bottomEnd();
        break;
      case TooltipPosition.leftStart:
        elementPosition = _leftStart();
        break;
      case TooltipPosition.leftCenter:
        elementPosition = _leftCenter();
        break;
      case TooltipPosition.leftEnd:
        elementPosition = _leftEnd();
        break;
      case TooltipPosition.rightStart:
        elementPosition = _rightStart();
        break;
      case TooltipPosition.rightCenter:
        elementPosition = _rightCenter();
        break;
      case TooltipPosition.rightEnd:
        elementPosition = _rightEnd();
        break;
      default:
        elementPosition = _topCenter();
        break;
    }

    return _fitsScreen(elementPosition)
        ? elementPosition
        : _firstAvailablePosition();
  }
}
