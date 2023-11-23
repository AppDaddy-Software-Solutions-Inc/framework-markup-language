// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fml/event/event.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/animation/animation_helper.dart';
import 'package:fml/widgets/animation/animation_child/flip/flip_card_model.dart';
import 'package:fml/widgets/widget/widget_model_interface.dart';
import 'package:fml/widgets/widget/widget_model.dart';

/// Animation View
///
/// Builds the View from model properties
class FlipCardView extends StatefulWidget {
  final FlipCardModel model;
  final List<Widget> children = [];
  final Widget? child;
  final AnimationController? controller;
  FlipCardView(this.model, this.child, this.controller)
      : super(key: ObjectKey(model));

  @override
  FlipCardViewState createState() => FlipCardViewState();
}

class FlipCardViewState extends State<FlipCardView>
    with TickerProviderStateMixin
    implements IModelListener {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool soloRequestBuild = false;

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

    _controller.addListener(() {setState(() {

    });});
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
  void didUpdateWidget(FlipCardView oldWidget) {
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
Widget build(BuildContext context)
  {
    double begin = widget.model.begin;
    double end = widget.model.end;
    Curve curve = AnimationHelper.getCurve(widget.model.curve);

    // Build View
    Widget? view;
    dynamic frontWidget;
    double from;
    double to;
    Tween<double> newTween;

    if (begin != 0.0 || end != 1.0) {
      curve = Interval(
        begin,
        end,
        // the style curve to pass.
        curve: curve,
      );
    }

    from = widget.model.from;
    to = widget.model.to;
    newTween = Tween<double>(
      begin: from,
      end: to,
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

    //get front and back widgets.

    //this is done likely wrong. We need to find each element of type, not sure if getting the view here is any good

     frontWidget = widget.child;
    if(_animation.value <= 0.5 && frontWidget.model.children.length >= 2) {
      frontWidget.model.children
          .elementAt(0)
          .visible = false;
      frontWidget.model.children
          .elementAt(1)
          .visible = true;
    } else if (frontWidget.model.children.length >= 2){
    frontWidget.model.children
        .elementAt(0)
        .visible = true;
    frontWidget.model.children
        .elementAt(1)
        .visible = false;
    }


    view = Stack(
      fit: StackFit.passthrough,
      children:[
        _buildContent(
          frontWidget: frontWidget ?? Container(),
      )]);

    return view;
  }

  Widget _buildContent({required dynamic frontWidget}) {
    /// pointer events that would reach the backside of the card should be


      if (widget.model.direction?.toLowerCase() == "vertical") {
        return Transform(
            alignment: FractionalOffset.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateX(pi * _animation.value),
            child: Container(
              child:  Transform(
                alignment: FractionalOffset.center,
                transform:  Matrix4.identity()
                  ..rotateX(_animation.value <= 0.5 ? 0: pi), child: frontWidget,),
            ));

      }
        return Transform(
          alignment: FractionalOffset.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(pi * _animation.value),
          child: Container(
          child:  Transform(
          alignment: FractionalOffset.center,
    transform:  Matrix4.identity()
    ..rotateY(_animation.value <= 0.5 ? 0: pi), child: frontWidget,),
        ));
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
      widget.model.side = "back";
      widget.model.onComplete(context);
    } else if  (status == AnimationStatus.dismissed) {
      widget.model.controllerValue = 0;
      widget.model.side = "front";
      widget.model.onDismiss(context);
    }
  }
}
