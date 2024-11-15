// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/event/event.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/animation/animation_helper.dart';
import 'package:fml/widgets/animation/tween/tween_model.dart';
import 'package:fml/widgets/widget/model_interface.dart';
import 'package:fml/widgets/widget/model.dart';

/// Animation View
///
/// Builds the View from model properties
class TweenView extends StatefulWidget {
  final TweenModel model;
  final List<Widget> children = [];
  final Widget? child;
  final AnimationController? controller;

  TweenView(this.model, this.child, this.controller)
      : super(key: ObjectKey(model));

  @override
  TweenViewState createState() => TweenViewState();
}

class TweenViewState extends State<TweenView>
    with TickerProviderStateMixin
    implements IModelListener {
  late AnimationController _controller;
  late Animation<dynamic> _animation;
  bool hasLocalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: widget.model.duration),
          reverseDuration: Duration(
            milliseconds: widget.model.reverseduration ?? widget.model.duration,
          ));
      if (widget.model.controllerValue == 1 && widget.model.runonce) {
        _controller.animateTo(widget.model.controllerValue,
            duration: const Duration());

        if (widget.model.autoplay && !_controller.isAnimating) {
          start();
        }
      }
      _controller.addStatusListener((status) {
        _animationListener(status);
      });
      hasLocalController = true;
    } else {
      _controller = widget.controller!;
    }

    widget.model.value = widget.model.from;

    _controller.addListener(() {
      setState(() {
        if (widget.model.type == "color") {
          widget.model.value = "#${_animation.value.value.toRadixString(16)}";
        } else {
          widget.model.value = _animation.value.toString();
        }
      });
    });
  }

  @override
  didChangeDependencies() {
    // register model listener
    widget.model.registerListener(this);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(TweenView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model != widget.model) {
      // re-register model listeners
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);

      if (hasLocalController) {
        _controller.duration = Duration(milliseconds: widget.model.duration);
        _controller.reverseDuration = Duration(
            milliseconds:
                widget.model.reverseduration ?? widget.model.duration);
      }
    }
  }

  @override
  void dispose() {
    if (hasLocalController) {
      stop();
      // remove controller
      _controller.dispose();
    }

    // remove model listener
    widget.model.removeListener(this);
    super.dispose();
  }

  /// Callback to fire the [_AnimationViewState.build] when the [AnimationModel] changes
  @override
  onModelChange(Model model, {String? property, dynamic value}) {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Tween
    double begin = widget.model.begin;
    double end = widget.model.end;
    Curve curve = AnimationHelper.getCurve(widget.model.curve);
    dynamic from;
    dynamic to;
    Tween<dynamic> newTween;

    // we must check from != to and begin !< end

    if (widget.model.type == "color") {
      from = toColor(widget.model.from) ?? Colors.white;
      to = toColor(widget.model.to) ?? Colors.black;
      newTween = ColorTween(
        begin: from,
        end: to,
      );
    } else {
      from = toDouble(widget.model.from) ?? 0;
      to = toDouble(widget.model.to) ?? 1;
      newTween = Tween<double>(
        begin: from,
        end: to,
      );
    }

    if (begin != 0.0 || end != 1.0) {
      curve = Interval(
        begin,
        end,
        // the style curve to pass.
        curve: curve,
      );
    }

    _animation = newTween.animate(CurvedAnimation(
      curve: curve,
      parent: _controller,
    ));

    // Return View
    return Container(child: widget.child);
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
      _controller.reset();
      widget.model.controllerValue = 0;
    } catch (e) {
      Log().debug('$e');
    }
  }

  void start() {
    try {
      if (widget.model.hasrun) return;
      if (_controller.isCompleted) {
        if (widget.model.runonce) widget.model.hasrun = true;
        _controller.reverse();
        widget.model.controllerValue = 0;
        widget.model.onStart(context);
      } else if (_controller.isDismissed) {
        _controller.forward();
        widget.model.controllerValue = 1;
        if (widget.model.runonce) widget.model.hasrun = true;
        widget.model.onStart(context);
      } else {
        _controller.forward();
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
      _controller.reset();
      widget.model.controllerValue = 0;
      _controller.stop();
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
