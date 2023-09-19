import 'dart:math';

import 'package:flutter/material.dart';

class ZoomableChart extends StatefulWidget {
  ZoomableChart({
    super.key,
    required this.maxX,
    required this.builder,
  });

  double maxX;
  Widget Function(double, double) builder;

  @override
  State<ZoomableChart> createState() => _ZoomableChartState();
}

class _ZoomableChartState extends State<ZoomableChart> {
  late double minX;
  late double maxX;

  late double lastMaxXValue;
  late double lastMinXValue;

  @override
  void initState() {
    super.initState();
    minX = 0;
    maxX = widget.maxX;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          minX = 0;
          maxX = widget.maxX;
        });
      },
      onHorizontalDragStart: (details) {
        lastMinXValue = minX;
        lastMaxXValue = maxX;
      },
      onHorizontalDragUpdate: (details) {
        var horizontalDistance = details.primaryDelta ?? 0;
        if (horizontalDistance == 0) return;
        print(horizontalDistance);
        var lastMinMaxDistance = max(lastMaxXValue - lastMinXValue, 0.0);

        setState(() {
          minX -= lastMinMaxDistance * 0.005 * horizontalDistance;
          maxX -= lastMinMaxDistance * 0.005 * horizontalDistance;

          if (minX < 0) {
            minX = 0;
            maxX = lastMinMaxDistance;
          }
          if (maxX > widget.maxX) {
            maxX = widget.maxX;
            minX = maxX - lastMinMaxDistance;
          }
          print("$minX, $maxX");
        });
      },
      onScaleStart: (details) {
        lastMinXValue = minX;
        lastMaxXValue = maxX;
      },
      onScaleUpdate: (details) {
        var horizontalScale = details.horizontalScale;
        if (horizontalScale == 0) return;
        print(horizontalScale);
        var lastMinMaxDistance = max(lastMaxXValue - lastMinXValue, 0);
        var newMinMaxDistance = max(lastMinMaxDistance / horizontalScale, 10);
        var distanceDifference = newMinMaxDistance - lastMinMaxDistance;
        print("$lastMinMaxDistance, $newMinMaxDistance, $distanceDifference");
        setState(() {
          final newMinX = max(
            lastMinXValue - distanceDifference,
            0.0,
          );
          final newMaxX = min(
            lastMaxXValue + distanceDifference,
            widget.maxX,
          );

          if (newMaxX - newMinX > 2) {
            minX = newMinX;
            maxX = newMaxX;
          }
          print("$minX, $maxX");
        });
      },
      child: widget.builder(minX, maxX),
    );
  }
}