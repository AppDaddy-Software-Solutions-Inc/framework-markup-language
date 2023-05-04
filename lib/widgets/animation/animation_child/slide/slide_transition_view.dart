// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/event/event.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/helper/string.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/animation/animation_helper.dart';
import 'package:fml/widgets/animation/animation_child/slide/slide_transition_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';

/// Animation View
///
/// Builds the View from model properties
class SlideTransitionView extends StatefulWidget {
  final SlideTransitionModel model;
  final List<Widget> children = [];
  final Widget? child;
  final AnimationController? controller;

  SlideTransitionView(this.model, this.child, this.controller)
      : super(key: ObjectKey(model));

  @override
  SlideTransitionViewState createState() => SlideTransitionViewState();
}

class SlideTransitionViewState extends State<SlideTransitionView>
    with TickerProviderStateMixin
    implements IModelListener {
  late AnimationController _controller;
  List<double> _defaultFrom = [-1, 0];
  late Animation<Offset> _animation;
  bool soloRequestBuild = false;
  String? _direction;
  TextDirection? _align;

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      _controller = AnimationController(vsync: this, duration: Duration(milliseconds: widget.model.duration), reverseDuration: Duration(milliseconds: widget.model.reverseduration ?? widget.model.duration,));
      if(widget.model.controllerValue == 1 && widget.model.runonce == true) {
        _controller.animateTo(widget.model.controllerValue, duration: Duration());

        if (widget.model.autoplay == true && _controller.isAnimating != true) start();
      }
      _controller.addStatusListener((status) {
        _animationListener(status);
      });
      soloRequestBuild = true;
    } else {
      _controller = widget.controller!;
    }
  }

  @override
  didChangeDependencies() {
    // register model listener
    widget.model.registerListener(this);

    // register event listeners
    EventManager.of(widget.model)?.registerEventListener(EventTypes.animate, onAnimate);
    EventManager.of(widget.model)?.registerEventListener(EventTypes.reset, onReset);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(SlideTransitionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.model != widget.model)) {
      // re-register model listeners
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);

      if(soloRequestBuild) {
        // de-register event listeners
        EventManager.of(oldWidget.model)?.removeEventListener(
            EventTypes.animate, onAnimate);
        EventManager.of(widget.model)?.removeEventListener(
            EventTypes.reset, onReset);

        // register event listeners
        EventManager.of(widget.model)?.registerEventListener(
            EventTypes.animate, onAnimate);
        EventManager.of(widget.model)?.registerEventListener(
            EventTypes.reset, onReset);

        _controller.duration = Duration(milliseconds: widget.model.duration);
        _controller.reverseDuration = Duration(
            milliseconds: widget.model.reverseduration ??
                widget.model.duration);
      }
      }
  }

  @override
  void dispose() {

    if(soloRequestBuild) {
      stop();
      // remove controller
      _controller.dispose();
      // de-register event listeners
      EventManager.of(widget.model)?.removeEventListener(
          EventTypes.animate, onAnimate);
      EventManager.of(widget.model)?.removeEventListener(
          EventTypes.reset, onReset);
    }

    // remove model listener
    widget.model.removeListener(this);
    super.dispose();
  }

  /// Callback to fire the [_AnimationViewState.build] when the [AnimationModel] changes
  @override
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    if (mounted) setState(() {});
  }

  @override
Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints) {
    _direction = widget.model.direction?.toLowerCase();

    if (_direction == "right") {
      _align = TextDirection.ltr;
      _defaultFrom = [-1, 0];
    } else if (_direction == "left") {
      _align = TextDirection.rtl;
      _defaultFrom = [-1, 0];
    } else if (_direction == "up") {
      _defaultFrom = [0, 1];
    } else if (_direction == "down") {
      _defaultFrom = [0, -1];
    }

    // Tween
    List<String>? from = widget.model.from?.split(",");
    Offset fromOffset = Offset(
        S.toDouble(from?.elementAt(0)) ?? _defaultFrom[0],
        S.toDouble(from?.elementAt(1)) ?? _defaultFrom[1]);
    List<String>? to = widget.model.to.split(",");
    Offset toOffset = Offset(
        S.toDouble(to.elementAt(0)) ?? 0, S.toDouble(to.elementAt(1)) ?? 0);
    double begin = widget.model.begin;
    double end = widget.model.end;
    Curve curve = AnimationHelper.getCurve(widget.model.curve);
    Tween<Offset> newTween = Tween<Offset>(
      begin: fromOffset,
      end: toOffset,
    );

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

    // Build View
    Widget? view;

    view = SlideTransition(
      position: _animation,
      textDirection: _align,
      child: widget.child,
    );

    // Return View
    return view;
  }

  void onAnimate(Event event) {
    if (event.parameters == null) return;

    String? id = (event.parameters != null) ? event.parameters!['id'] : null;
    if ((S.isNullOrEmpty(id)) || (id == widget.model.id)) {
      bool? enabled = (event.parameters != null)
          ? S.toBool(event.parameters!['enabled'])
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
    if ((S.isNullOrEmpty(id)) || (id == widget.model.id)) {
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
      if(widget.model.hasrun) return;
      if (_controller.isCompleted) {
        if(widget.model.runonce) widget.model.hasrun = true;
        _controller.reverse();
        widget.model.controllerValue = 0;
        widget.model.onStart(context);
      } else if (_controller.isDismissed) {
        _controller.forward();
        widget.model.controllerValue = 1;
        if(widget.model.runonce) widget.model.hasrun = true;
        widget.model.onStart(context);
      } else {
        _controller.forward();
        widget.model.controllerValue = 1;
        if(widget.model.runonce) widget.model.hasrun = true;
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
    } else if  (status == AnimationStatus.dismissed) {
      widget.model.controllerValue = 0;
      widget.model.onDismiss(context);
    }
  }
}
