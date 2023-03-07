// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/event/event.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/helper/string.dart';
import 'package:fml/widgets/animation/animation_helper.dart';
import 'package:fml/widgets/animation/animation_child/tween/tween_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';

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
  bool soloRequestBuild = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = AnimationController(vsync: this, duration: Duration(milliseconds: widget.model.duration), reverseDuration: Duration(milliseconds: widget.model.reverseduration ?? widget.model.duration,))
    ..addStatusListener((status) {
    _animationListener(status);
    });
      widget.model.controller = _controller;
      soloRequestBuild = true;
    } else {
      _controller = widget.controller!;
      widget.model.controller = _controller;
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

    if(soloRequestBuild) {
      // register event listeners
      EventManager.of(widget.model)?.registerEventListener(
          EventTypes.animate, onAnimate);
      EventManager.of(widget.model)?.registerEventListener(
          EventTypes.reset, onReset);
    }

    super.didChangeDependencies();
  }


  @override
  void didUpdateWidget(TweenView oldWidget) {
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
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    if (this.mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints) {
    // Tween

    double _begin = widget.model.begin;
    double _end = widget.model.end;
    Curve _curve = AnimationHelper.getCurve(widget.model.curve);
    dynamic _from;
    dynamic _to;
    Tween<dynamic> _newTween;


    // we must check from != to and begin !< end

    if (widget.model.type == "color") {
      _from = S.toColor(widget.model.from) ?? Colors.white;
      _to = S.toColor(widget.model.to) ?? Colors.black;
      _newTween = ColorTween(
        begin: _from,
        end: _to,
      );
    } else {
      _from = S.toDouble(widget.model.from) ?? 0;
      _to = S.toDouble(widget.model.to) ?? 1;
      _newTween = Tween<double>(
        begin: _from,
        end: _to,
      );
    }

    if (_begin != 0.0 || _end != 1.0) {
      _curve = Interval(
        _begin,
        _end,
        // the style curve to pass.
        curve: _curve,
      );
    }

    _animation = _newTween.animate(CurvedAnimation(
      curve: _curve,
      parent: _controller,
    ));

    // Return View
    return Container(child: widget.child);
  }


  void onAnimate(Event event) {
    if (event.parameters == null) return;

    String? id = (event.parameters != null) ? event.parameters!['id'] : null;
    if ((S.isNullOrEmpty(id)) || (id == widget.model.id)) {
      bool? enabled = (event.parameters != null)
          ? S.toBool(event.parameters!['enabled'])
          : true;
      if (enabled != false)
        start();
      else
        stop();
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

    } catch (e) {}
  }

  void start() {
    try {
      if (_controller.isCompleted) {
        _controller.reverse();
        widget.model.onstart;
      } else if (_controller.isDismissed) {
        _controller.forward();
        widget.model.onstart;
      } else {
        _controller.forward();
        widget.model.onstart;
      }

    } catch (e) {}
  }

  void stop() {
    try {
      _controller.reset();
      _controller.stop();
    } catch (e) {}
  }

  void _animationListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.model.oncomplete;
    } else if  (status == AnimationStatus.dismissed) {
      widget.model.ondismiss;
    }
  }
}
