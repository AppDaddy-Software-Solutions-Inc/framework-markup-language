// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED
import 'package:flutter/material.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/observable/scope.dart';
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

  int _loop = 0;
  bool _stopped = false;

  @override
  void initState()
  {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: widget.model.duration), reverseDuration: Duration(milliseconds: widget.model.reverseduration ?? widget.model.duration,));
    widget.model.controller = _controller;
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
    stop();

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
    widget.model.transitionChildren.forEach((child)
    {
      newChild = child.getTransitionView(newChild, _controller);
    });
    return newChild;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Check if widget is visible before wasting resources on building it
    if (((widget.model.children?.isEmpty ?? true) && widget.child == null)) return Offstage();

    //link animations to sync from a single controller
    if(widget.model.linked != null){
      WidgetModel? linkedAnimation = Scope.findWidgetModel(widget.model.linked, widget.model.scope);
      if(linkedAnimation != null && linkedAnimation is BaseAnimationModel.AnimationModel){
         if (linkedAnimation.controller != null) {
           _controller = linkedAnimation.controller;
           widget.model.controller = _controller;
         } else {
           widget.model.controller = null;
         }
      }
    }

    if (widget.model.transitionChildren.isNotEmpty && widget.child != null) {
      Widget view = _buildTransitionChildren();
      // Start the Controller
      if ((widget.model.autoplay == true) && (!_stopped)) start();
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

    } catch (e) {}
  }

  void start() {
    try {

        _loop = 0;
        _stopped = false;

          if (_controller!.isCompleted) {
            _controller!.reverse();
          } else if (_controller!.isDismissed) {
            _controller!.forward();
          } else {
            _controller!.forward();
          }

    } catch (e) {}
  }

  void stop() {
    try {
      _stopped = true;
        _controller!.reset();
        _controller!.stop();
    } catch (e) {}
  }

  void _animationListener(AnimationStatus status) {
    if (_controller == null) return;

    // Animation Complete?
    if (status == AnimationStatus.completed) {
      _loop++;
      if (_loop < widget.model.repeat || widget.model.repeat == 0) {
        // Rewind
        if (widget.model.reverse == true) {
          // Reverse
          if (_loop.isOdd) {
            _controller!.reverse().whenComplete(() {
              _loop++;
              (_loop < widget.model.repeat || widget.model.repeat == 0)
                  ? _controller!.forward()
                  : _controller!.stop();
            });
          }

          // Forward
          else
            _controller!.forward();
        }

        // Reset
        else {
          if (_loop < widget.model.repeat || widget.model.repeat == 0) {
            _controller!.reset();
            _controller!.forward();
          } else
            _controller!.stop();
        }
      }

      // Stop
      else
        _controller!.stop();
    }
  }
}
