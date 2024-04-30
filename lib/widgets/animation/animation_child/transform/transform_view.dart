// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fml/event/event.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/animation/animation_helper.dart';
import 'package:fml/widgets/animation/animation_child/transform/transform_model.dart';
import 'package:fml/widgets/widget/model_interface.dart';
import 'package:fml/widgets/widget/model.dart';

/// Animation View
///
/// Builds the View from model properties
class TransformView extends StatefulWidget {
  final TransformModel model;
  final List<Widget> children = [];
  final Widget? child;
  final AnimationController? controller;

  TransformView(this.model, this.child, this.controller)
      : super(key: ObjectKey(model));

  @override
  TransformViewState createState() => TransformViewState();
}

class TransformViewState extends State<TransformView>
    with TickerProviderStateMixin
    implements IModelListener {
  late AnimationController _controller;
  late Animation<double> _xAnimation;
  late Animation<double> _yAnimation;
  late Animation<double> _xTranslateAnimation;
  late Animation<double> _yTranslateAnimation;
  late Animation<double> _zTranslateAnimation;
  bool soloRequestBuild = false;

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
      soloRequestBuild = true;
    } else {
      _controller = widget.controller!;
    }

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  didChangeDependencies() {
    // register model listener
    widget.model.registerListener(this);

    if (soloRequestBuild) {
      // register event listeners
      EventManager.of(widget.model)
          ?.registerEventListener(EventTypes.animate, onAnimate);
      EventManager.of(widget.model)
          ?.registerEventListener(EventTypes.reset, onReset);
    }

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(TransformView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.model != widget.model)) {
      // re-register model listeners
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);

      if (soloRequestBuild) {
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

        _controller.duration = Duration(milliseconds: widget.model.duration);
        _controller.reverseDuration = Duration(
            milliseconds:
                widget.model.reverseduration ?? widget.model.duration);
      }
    }
  }

  @override
  void dispose() {
    if (soloRequestBuild) {
      stop();
      // remove controller
      _controller.dispose();
      // de-register event listeners
      EventManager.of(widget.model)
          ?.removeEventListener(EventTypes.animate, onAnimate);
      EventManager.of(widget.model)
          ?.removeEventListener(EventTypes.reset, onReset);
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
    double begin = widget.model.begin;
    double end = widget.model.end;

    // default warp is 0.0015, 0 is no warping. This could potentially be made smarter
    double warp = (widget.model.warp ?? 15) / 10000;
    Curve curve = AnimationHelper.getCurve(widget.model.curve);

    List<String?> rotateFrom = widget.model.rotateFrom?.split(",") ?? [];

    if (rotateFrom.isEmpty) {
      rotateFrom.add("0");
      rotateFrom.add("0");
    } else if (rotateFrom.length < 2) {
      rotateFrom.add("0");
    }

    List<String?> rotateTo = widget.model.rotateTo.split(",");

    if (rotateTo.isEmpty) {
      rotateTo.add("0");
      rotateTo.add("0");
    } else if (rotateTo.length < 2) {
      rotateTo.add("0");
    }

    List<String?> translateFrom = widget.model.translateFrom?.split(",") ?? [];

    if (translateFrom.isEmpty) {
      translateFrom.add("0");
      translateFrom.add("0");
      translateFrom.add("0");
    } else if (translateFrom.length < 2) {
      translateFrom.add("0");
      translateFrom.add("0");
    } else if (translateFrom.length < 3) {
      translateFrom.add("0");
    }

    List<String?> translateTo = widget.model.translateTo.split(",");

    if (translateTo.isEmpty) {
      translateTo.add("0");
      translateTo.add("0");
      translateTo.add("0");
    } else if (translateTo.length < 2) {
      translateTo.add("0");
      translateTo.add("0");
    } else if (translateTo.length < 3) {
      translateTo.add("0");
    }

    //start, end, center
    Alignment align =
        AnimationHelper.getAlignment(widget.model.align?.toLowerCase());

    if (begin != 0.0 || end != 1.0) {
      curve = Interval(
        begin,
        end,
        // the style curve to pass.
        curve: curve,
      );
    }

    _xAnimation = Tween<double>(
      begin: toDouble(rotateFrom.elementAt(0)) ?? 0,
      end: toDouble(rotateTo.elementAt(0)) ?? 0,
    ).animate(CurvedAnimation(
      curve: curve,
      parent: _controller,
    ));
    _yAnimation = Tween<double>(
      begin: toDouble(rotateFrom.elementAt(1)) ?? 0,
      end: toDouble(rotateTo.elementAt(1)) ?? 0,
    ).animate(CurvedAnimation(
      curve: curve,
      parent: _controller,
    ));
    _xTranslateAnimation = Tween<double>(
      begin: toDouble(translateFrom.elementAt(0)) ?? 0,
      end: toDouble(translateTo.elementAt(0)) ?? 0,
    ).animate(CurvedAnimation(
      curve: curve,
      parent: _controller,
    ));
    _yTranslateAnimation = Tween<double>(
      begin: toDouble(translateFrom.elementAt(1)) ?? 0,
      end: toDouble(translateTo.elementAt(1)) ?? 0,
    ).animate(CurvedAnimation(
      curve: curve,
      parent: _controller,
    ));
    _zTranslateAnimation = Tween<double>(
      begin: toDouble(translateFrom.elementAt(2)) ?? 0,
      end: toDouble(translateTo.elementAt(2)) ?? 0,
    ).animate(CurvedAnimation(
      curve: curve,
      parent: _controller,
    ));

    // Build View
    Widget? view;

    view = Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, warp)
        ..rotateY(pi * _yAnimation.value * 2)
        ..rotateX(pi * _xAnimation.value * 2)
        ..translate(_xTranslateAnimation.value, _yTranslateAnimation.value,
            _zTranslateAnimation.value),
      alignment: align,
      //origin: Offset(0, 0),
      child: widget.child,
    );

    // Return View
    return view;
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
