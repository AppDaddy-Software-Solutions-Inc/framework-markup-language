// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED
import 'package:flutter/material.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:fml/widgets/animation/animation_model.dart' as BaseAnimationModel;
import 'package:fml/event/event.dart';
import 'package:fml/helper/common_helpers.dart';

/// Animation View
///
/// Builds the View from [ANIMATION.AnimationModel] properties
class AnimationView extends StatefulWidget implements IWidgetView
{
  final BaseAnimationModel.AnimationModel model;
  final List<Widget> children = [];
  final Widget? child;

  AnimationView(this.model, this.child) : super(key: ObjectKey(model));

  @override
  AnimationViewState createState() => AnimationViewState();
}

class AnimationViewState extends WidgetState<AnimationView> with TickerProviderStateMixin implements IModelListener
{
  AnimationController? _controller;
  Widget? transitionChild;

  bool _stopped = false;

  @override
  void initState()
  {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: widget.model.duration), reverseDuration: Duration(milliseconds: widget.model.reverseduration ?? widget.model.duration,));
    if(widget.model.controllerValue == 1 && widget.model.runonce == true) {
      _controller?.animateTo(widget.model.controllerValue, duration: Duration());
    }
    _controller?.addStatusListener((status) {
      _animationListener(status);
    });

    if (widget.model.autoplay == true && _controller?.isAnimating != true) start();
  }

  @override
  didChangeDependencies()
  {
    // register event listeners
    EventManager.of(widget.model)?.registerEventListener(EventTypes.animate, onAnimate);
    EventManager.of(widget.model)?.registerEventListener(EventTypes.reset, onReset);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(AnimationView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.model != widget.model))
    {
      // de-register event listeners
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.animate, onAnimate);
      EventManager.of(widget.model)?.removeEventListener(EventTypes.reset, onReset);

      // register event listeners
      EventManager.of(widget.model)?.registerEventListener(EventTypes.animate, onAnimate);
      EventManager.of(widget.model)?.registerEventListener(EventTypes.reset, onReset);

      _controller!.duration = Duration(milliseconds: widget.model.duration);
      _controller!.reverseDuration = Duration(milliseconds: widget.model.reverseduration ?? widget.model.duration);
    }
  }

  @override
  void dispose()
  {
    // remove controller
    _controller?.dispose();

    // de-register event listeners
    EventManager.of(widget.model)?.removeEventListener(EventTypes.animate, onAnimate);
    EventManager.of(widget.model)?.removeEventListener(EventTypes.reset, onReset);

    model?.removeListener(this);

    super.dispose();
  }

  _buildTransitionChildren()
  {
    Widget? newChild = widget.child;

    if (widget.model.animations != null)
    widget.model.animations!.forEach((transition)
    {
      newChild = transition.getAnimatedView(newChild!, controller: _controller);
    });
    return newChild;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Check if widget is visible before wasting resources on building it
    if (((widget.model.children?.isEmpty ?? true) && widget.child == null)) return Offstage();

    if (widget.model.animations != null && widget.model.animations!.isNotEmpty && widget.child != null)
    {
      Widget view = _buildTransitionChildren();

      // Start the Controller

      return view;
    }

    // Build Children
    widget.children.clear();
    if (widget.child != null) widget.children.add(widget.child!);
    if (widget.model.children != null)
      widget.model.children!.forEach((model) {
        if (model is IViewableWidget) {
          var view = (model as IViewableWidget).getView();
          widget.children.add(view);
      }});
    if (widget.children.isEmpty) widget.children.add(Container());
    var child = widget.children.length == 1
        ? widget.children[0]
        : Column(
            children: widget.children,
            crossAxisAlignment: CrossAxisAlignment.start);

    // Build View
    Widget? view;

    // Start the Controller
    if ((widget.model.autoplay == true) && (!_stopped)) start();

    // Return View
    return view ?? child;
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
        _controller!.reset();
        widget.model.controllerValue = 0;
    } catch (e) {}
  }

  void start() {
    try {
        _stopped = false;
        if(widget.model.hasrun) return;
          if (_controller!.isCompleted) {
            if(widget.model.runonce) widget.model.hasrun = true;
            _controller!.reverse();
            widget.model.controllerValue = 0;
            widget.model.onStart(context);
          } else if (_controller!.isDismissed) {
            _controller!.forward();
            widget.model.controllerValue = 1;
            if(widget.model.runonce) widget.model.hasrun = true;
            widget.model.onStart(context);
          } else {
            _controller!.forward();
            widget.model.controllerValue = 1;
            if(widget.model.runonce) widget.model.hasrun = true;
            widget.model.onStart(context);
          }

    } catch (e) {}
  }

  void stop() {
    try {
      _stopped = true;
        _controller!.reset();
        widget.model.controllerValue = 0;
        _controller!.stop();
    } catch (e) {}
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
