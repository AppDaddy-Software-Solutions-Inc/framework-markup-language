// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/animation/animation_helper.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart'     ;
import 'package:fml/widgets/animation/animation_model.dart' as ANIMATION;
import 'package:fml/event/event.dart'      ;
import 'package:fml/helper/common_helpers.dart';

/// Animation View
///
/// Builds the View from [ANIMATION.AnimationModel] properties
class AnimationView extends StatefulWidget
{
  final ANIMATION.AnimationModel model;
  final List<Widget> children = [];
  final Widget? child;

  AnimationView(this.model, this.child) : super(key: ObjectKey(model));

  @override
  AnimationViewState createState() => AnimationViewState();
}

class AnimationViewState extends State<AnimationView> with TickerProviderStateMixin implements IModelListener
{
  AnimationController? _controller;
  FlipCardController? _flipController;
  Widget? transitionChild;
  late ANIMATION.Transitions? type = S.toEnum(widget.model.animation, ANIMATION.Transitions.values);

  int  _loop    = 0;
  bool _stopped = false;

  @override
  void initState() 
  {
    super.initState();
    if(type != ANIMATION.Transitions.flip) {
      _controller = AnimationController(vsync: this,
        duration: Duration(milliseconds: widget.model.duration,),
        reverseDuration: Duration(milliseconds: widget.model.reverseduration ??
            widget.model.duration,),);
    } else {
      _flipController = FlipCardController();
    }
  }

  @override
  didChangeDependencies()
  {
    // register event listeners
    EventManager.of(widget.model)?.registerEventListener(EventTypes.animate, onAnimate);
    EventManager.of(widget.model)?.registerEventListener(EventTypes.reset, onReset);

    // register model listener
    widget.model.registerListener(this);

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

      if(type == ANIMATION.Transitions.flip) {
        _controller!.duration = Duration(milliseconds: widget.model.duration);
        _controller!.reverseDuration = Duration(
            milliseconds: widget.model.reverseduration ??
                widget.model.duration);
      }

      // re-register model listeners
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }
  }

  @override
  void dispose()
  {
    stop();

    // remove model listener
    widget.model.removeListener(this);

    // remove controller
    _controller?.dispose();

    // de-register event listeners
    EventManager.of(widget.model)?.removeEventListener(EventTypes.animate, onAnimate);
    EventManager.of(widget.model)?.removeEventListener(EventTypes.reset, onReset);

    super.dispose();
  }

  /// Callback to fire the [_AnimationViewState.build] when the [AnimationModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    if (this.mounted) setState((){});
  }

  _buildTransitionChildren()
  {
    Widget? newChild = widget.child;
    widget.model.transitionChildren.forEach((child) {
      newChild = child.getTransitionView(newChild, _controller);
    });
    return newChild;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Check if widget is visible before wasting resources on building it
    if (((widget.model.children?.isEmpty ?? true) && widget.child == null)) return Offstage();

    if(widget.model.transitionChildren.isNotEmpty && widget.child != null) {
       Widget view = _buildTransitionChildren();
      // Start the Controller
      if ((widget.model.autoplay == true) && (!_stopped)) start();
      return view;
    }

    // Build Children
    Widget? front;
    Widget? back;
    widget.children.clear();
    if (widget.child != null) widget.children.add(widget.child!);
    if (widget.model.children != null)
      widget.model.children!.forEach((model)
      {
        if (model is IViewableWidget)
        {
          var view = (model as IViewableWidget).getView();
          widget.children.add(view);
          if (front == null) front = view;
          else if (back == null) back = view;
        }
      });
    if (widget.children.isEmpty) widget.children.add(Container());
    var child = widget.children.length == 1 ? widget.children[0] : Column(children: widget.children, crossAxisAlignment: CrossAxisAlignment.start);

    
    // Build View
    Widget? view;

    // Duration
    int _duration = widget.model.duration;

    switch (type)
    {
      case ANIMATION.Transitions.flip :

        // anchor
        Alignment anchor = AnimationHelper.getAlignment(widget.model.anchor.toLowerCase());

        // axis
        FlipDirection? axis = S.toEnum(widget.model.axis.toUpperCase(), FlipDirection.values);
        if (axis == null) axis = FlipDirection.HORIZONTAL;

        // build the animation
        view = FlipCard(speed: _duration, direction: axis, alignment: anchor, controller: _flipController, front: front ?? Container(), back: back ?? Container(), flipOnTouch: false,);
        break;

        default:
          break;

    }

    // Start the Controller
    if ((widget.model.autoplay == true) && (!_stopped)) start();

    // Return View
    return view ?? child;
  }

  void onAnimate(Event event)
  {
    if (event.parameters == null) return;

    String? id = (event.parameters != null) ? event.parameters!['id'] : null;
    if ((S.isNullOrEmpty(id)) || (id == widget.model.id))
    {
      bool? enabled = (event.parameters != null) ? S.toBool(event.parameters!['enabled']) : true;
      if (enabled != false)
           start();
      else stop();
      event.handled = true;
    }
  }

  void onReset(Event event) {
    String? id = (event.parameters != null) ? event.parameters!['id'] : null;
    if ((S.isNullOrEmpty(id)) || (id == widget.model.id)) {
      reset();
    }

  }


  void reset(){
    try
    {
      if (_controller != null)
      {
            _controller!.reset();
      } else if (_flipController != null) {
                    _flipController!.toggleCardWithoutAnimation();
          bool front = _flipController!.state?.isFront ?? true;
          widget.model.side = front ? "front" : "back";
      }
    }
    catch(e){}
  }

  void start()
  {
    try
    {
      if (_controller != null)
      {
        Log().debug('starting animation');
        _loop = 0;
        _stopped = false;
        if (_controller != null)
        {
          if(_controller!.isCompleted) {
            _controller!.reverse();
          } else if (_controller!.isDismissed){
            _controller!.forward();
          } else {
            _controller!.forward();
          }
        }
        else if (_flipController != null)
        {
          _flipController!.toggleCard();
          bool front = _flipController!.state?.isFront ?? true;
          widget.model.side = front ? "front" : "back";
        }
      }
    }
    catch(e){}
  }

  void stop()
  {
    try
    {
      _stopped = true;
      if (_controller != null)
      {
        _controller!.reset();
        _controller!.stop();
      } else if (_flipController != null){
        widget.model.side = _flipController!.state?.isFront ?? true ? "front" : "back";
      }
    }
    catch(e){}
  }

  void _animationListener(AnimationStatus status)
  {
    if (_flipController != null || _controller == null) return;

    // Animation Complete?
    if (status == AnimationStatus.completed)
    {
      _loop++;
      if (_loop < widget.model.repeat || widget.model.repeat == 0)
      {
        // Rewind
        if (widget.model.reverse == true)
        {
          // Reverse
          if (_loop.isOdd)
          {
            _controller!.reverse().whenComplete(()
            {
              _loop++;
              (_loop < widget.model.repeat || widget.model.repeat == 0) ? _controller!.forward() : _controller!.stop();
            });
          }

          // Forward
          else _controller!.forward();
        }

        // Reset
        else
        {
          if (_loop < widget.model.repeat || widget.model.repeat == 0)
          {
            _controller!.reset();
            _controller!.forward();
          }
          else _controller!.stop();
        }
      }

      // Stop
      else _controller!.stop();
    }
  }
}
