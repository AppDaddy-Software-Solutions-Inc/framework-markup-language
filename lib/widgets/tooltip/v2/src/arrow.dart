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
import 'paint/corner.dart';
import 'paint/triangle.dart';
import 'position_manager.dart';

/// Loads the arrow from the paint code and applies the correct transformations
/// color, rotation and mirroring
class Arrow extends StatelessWidget {
  final Color color;
  final TooltipPosition position;
  final double width;
  final double height;
  const Arrow({
    required this.color,
    required this.position,
    this.width = 16.0,
    this.height = 10.0,
    super.key,
  });

  /// Returns either the center triangle or the corner triangle
  CustomPainter? _getElement(bool isArrow) {
    return isArrow ? Triangle(color: color) : Corner(color: color);
  }

  /// Applies the transformation to the triangle
  Widget _getTriangle() {
    double scaleX = 1;
    double scaleY = 1;
    bool isArrow = false;
    int quarterTurns = 0;

    switch (position) {
      case TooltipPosition.topStart:
        break;
      case TooltipPosition.topCenter:
        quarterTurns = 0;
        isArrow = true;
        break;
      case TooltipPosition.topEnd:
        scaleX = -1;
        break;
      case TooltipPosition.bottomStart:
        scaleY = -1;
        break;
      case TooltipPosition.bottomCenter:
        quarterTurns = 2;
        isArrow = true;
        break;
      case TooltipPosition.bottomEnd:
        scaleX = -1;
        scaleY = -1;
        break;
      case TooltipPosition.leftStart:
        scaleY = -1;
        quarterTurns = 3;
        break;
      case TooltipPosition.leftCenter:
        quarterTurns = 3;
        isArrow = true;
        break;
      case TooltipPosition.leftEnd:
        quarterTurns = 3;
        break;
      case TooltipPosition.rightStart:
        quarterTurns = 1;
        break;
      case TooltipPosition.rightCenter:
        quarterTurns = 1;
        isArrow = true;
        break;
      case TooltipPosition.rightEnd:
        quarterTurns = 1;
        scaleY = -1;
        break;
    }

    return Transform.scale(
      scaleX: scaleX,
      scaleY: scaleY,
      child: RotatedBox(
        quarterTurns: quarterTurns,
        child: CustomPaint(
          size: Size(width, height),
          painter: _getElement(isArrow),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getTriangle();
  }
}
