// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/dragdrop/draggable_view.dart';
import 'package:fml/widgets/dragdrop/droppable_view.dart';
import 'package:fml/widgets/tooltip/v2/tooltip_view.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ReactiveView extends StatefulWidget implements ViewableWidgetView {

  @override
  final ViewableMixin model;

  final ViewableWidgetView child;

  ReactiveView(this.model, this.child) : super(key: ObjectKey(model));

  @override
  State<ReactiveView> createState() => ReactiveViewState();
}

class ReactiveViewState extends ViewableWidgetState<ReactiveView> {

  // set visibility
  double visibility = 0;
  bool hasGoneOffscreen = false;
  bool hasGoneOnscreen = false;

  // fires on visibility change
  void _onVisibilityChange(VisibilityInfo info) {

    var model = widget.model;

    if (visibility == (info.visibleFraction * 100)) return;

    model.visibleHeight = info.size.height > 0
        ? ((info.visibleBounds.height / info.size.height) * 100)
        : 0.0;

    model.visibleWidth = info.size.width > 0
        ? ((info.visibleBounds.width / info.size.width) * 100)
        : 0.0;

    model.visibleArea = info.visibleFraction * 100;

    visibility = model.visibleArea ?? 0.0;

    // on screen
    if (model.visibleArea! > 1 && !hasGoneOnscreen) {
      model.onScreen();
      hasGoneOnscreen = true;
    }

    // off screen
    else if (model.visibleArea! == 0 && hasGoneOnscreen) {
      model.offScreen();
      hasGoneOnscreen = false;
    }
  }

  @override
  Widget build(BuildContext context) {

    var view = (widget.child as Widget);
    var model = widget.model;

    // wrap in visibility detector?
    if (model.needsVisibilityDetector) {
      view = VisibilityDetector(
          key: ObjectKey(this),
          onVisibilityChanged: _onVisibilityChange,
          child: view);
    }

    // wrap in tooltip?
    if (model.tipModel != null) {
      view = TooltipView(model.tipModel!, view);
    }

    // droppable?
    if (model.droppable && view is! DroppableView) {
      view = DroppableView(model, view);
    }

    // draggable?
    if (model.draggable && view is! DraggableView) {
      view = DraggableView(model, view);
    }

    // wrap animations.
    if (model.animations != null) {
      var animations = model.animations!.reversed;
      for (var model in animations) {
        view = model.getAnimatedView(view);
      }
    }
    return view;
  }
}