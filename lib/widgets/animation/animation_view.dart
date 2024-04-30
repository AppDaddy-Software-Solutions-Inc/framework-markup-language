// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED
import 'package:flutter/material.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'package:fml/widgets/widget/model_interface.dart';
import 'package:fml/widgets/animation/animation_model.dart'
    as base_animation_model;
import 'package:fml/event/event.dart';
import 'package:fml/helpers/helpers.dart';

/// Animation View
///
/// Builds the View from [ANIMATION.AnimationModel] properties
class AnimationView extends StatefulWidget implements ViewableWidgetView {
  @override
  final base_animation_model.AnimationModel model;
  final List<Widget> children = [];
  final Widget? child;

  AnimationView(this.model, this.child) : super(key: ObjectKey(model));

  @override
  AnimationViewState createState() => AnimationViewState();
}

class AnimationViewState extends ViewableWidgetState<AnimationView>
    with TickerProviderStateMixin
    implements IModelListener {
  AnimationController? _controller;
  Widget? transitionChild;

  @override
  void initState() {
    super.initState();

    // build the controller
    _controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.model.duration),
        reverseDuration: Duration(
          milliseconds: widget.model.reverseduration ?? widget.model.duration,
        ));

    if (widget.model.controllerValue == 1 && widget.model.runonce) {
      _controller?.animateTo(widget.model.controllerValue,
          duration: const Duration());
    }

    _controller?.addStatusListener((status) {
      _animationListener(status);
    });

    if (widget.model.autoplay && !_controller!.isAnimating) {
      start();
    }
  }

  @override
  didChangeDependencies() {
    // register event listeners
    EventManager.of(widget.model)
        ?.registerEventListener(EventTypes.animate, onAnimate);
    EventManager.of(widget.model)
        ?.registerEventListener(EventTypes.reset, onReset);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(AnimationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.model != widget.model)) {
      // de-register event listeners
      EventManager.of(oldWidget.model)
          ?.removeEventListener(EventTypes.animate, onAnimate);
      EventManager.of(widget.model)
          ?.removeEventListener(EventTypes.reset, onReset);

      // register event listeners
      EventManager.of(widget.model)
          ?.registerEventListener(EventTypes.animate, onAnimate);
      EventManager.of(widget.model)
          ?.registerEventListener(EventTypes.reset, onReset);

      _controller!.duration = Duration(milliseconds: widget.model.duration);
      _controller!.reverseDuration = Duration(
          milliseconds: widget.model.reverseduration ?? widget.model.duration);
    }
  }

  @override
  void dispose() {
    // remove controller
    _controller?.dispose();

    // de-register event listeners
    EventManager.of(widget.model)
        ?.removeEventListener(EventTypes.animate, onAnimate);
    EventManager.of(widget.model)
        ?.removeEventListener(EventTypes.reset, onReset);

    model?.removeListener(this);

    super.dispose();
  }

  _buildTransitionChildren() {
    Widget? newChild = widget.child;

    if (widget.model.animations != null) {
      for (var transition in widget.model.animations!) {
        newChild =
            transition.getAnimatedView(newChild!, controller: _controller);
      }
    }
    return newChild;
  }

  @override
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (((widget.model.children?.isEmpty ?? true) && widget.child == null)) {
      return const Offstage();
    }

    if (widget.model.animations != null &&
        widget.model.animations!.isNotEmpty &&
        widget.child != null) {
      Widget view = _buildTransitionChildren();

      // Start the Controller

      return view;
    }

    var child = widget.children.length == 1
        ? widget.children[0]
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.children);

    return child;
  }

  void onAnimate(Event event) {
    if (event.parameters == null) return;

    String? id = (event.parameters != null) ? event.parameters!['id'] : null;
    if ((isNullOrEmpty(id)) || (id == widget.model.id)) {
      bool? enabled = (event.parameters != null)
          ? toBool(event.parameters!['enabled'])
          : true;
      if (enabled != false) {
        start();
      } else {
        stop();
      }
      event.handled = true;
    }
  }

  void onReset(Event event) {
    String? id = (event.parameters != null) ? event.parameters!['id'] : null;
    if ((isNullOrEmpty(id)) || (id == widget.model.id)) {
      reset();
    }
  }

  void reset() {
    try {
      _controller!.reset();
      widget.model.controllerValue = 0;
    } catch (e) {
      Log().debug('$e');
    }
  }

  void start() {
    try {
      if (widget.model.hasrun) return;
      if (_controller!.isCompleted) {
        if (widget.model.runonce) widget.model.hasrun = true;
        _controller!.reverse();
        widget.model.controllerValue = 0;
        widget.model.onStart(context);
      } else if (_controller!.isDismissed) {
        _controller!.forward();
        widget.model.controllerValue = 1;
        if (widget.model.runonce) widget.model.hasrun = true;
        widget.model.onStart(context);
      } else {
        _controller!.forward();
        widget.model.controllerValue = 1;
        if (widget.model.runonce) widget.model.hasrun = true;
        widget.model.onStart(context);
      }
    } catch (e) {
      Log().debug('$e');
    }
  }

  void stop() {
    try {
      _controller!.reset();
      widget.model.controllerValue = 0;
      _controller!.stop();
    } catch (e) {
      Log().debug('$e');
    }
  }

  void _animationListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.model.controllerValue = 1;
      widget.model.onComplete(context);
    } else if (status == AnimationStatus.dismissed) {
      widget.model.controllerValue = 0;
      widget.model.onDismiss(context);
    }
  }
}
