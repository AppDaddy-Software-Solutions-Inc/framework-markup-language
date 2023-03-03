// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/log/manager.dart';
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
  dynamic _controller;
  Widget? transitionChild;

  int  _loop    = 0;
  bool _stopped = false;

  @override
  void initState() 
  {
    super.initState();
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
    if (_controller is AnimationController) (_controller as AnimationController).dispose();

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
      _controller = AnimationController(duration: Duration(milliseconds: widget.model.duration), vsync: this);
       Widget view = _buildTransitionChildren();
      // Start the Controller
      if ((widget.model.autoplay == true) && (!_stopped)) start();
      return view;
    }

    // Animation Type
    ANIMATION.Transitions? type = S.toEnum(widget.model.animation, ANIMATION.Transitions.values);
    if (type == null) type = ANIMATION.Transitions.fade;

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

    // Animation Curve
    Curve curve;
    ANIMATION.Curve? transitionCurve = S.toEnum(widget.model.curve, ANIMATION.Curve.values);
    switch (transitionCurve)
    {
      case ANIMATION.Curve.linear                 : curve = Curves.linear; break;
      case ANIMATION.Curve.decelerate             : curve = Curves.decelerate; break;
      case ANIMATION.Curve.fastLinearToSlowEaseIn : curve = Curves.fastLinearToSlowEaseIn; break;
      case ANIMATION.Curve.ease                   : curve = Curves.ease; break;
      case ANIMATION.Curve.easeIn                 : curve = Curves.easeIn; break;
      case ANIMATION.Curve.easeInToLinear         : curve = Curves.easeInToLinear; break;
      case ANIMATION.Curve.easeInSine             : curve = Curves.easeInSine; break;
      case ANIMATION.Curve.easeInQuad             : curve = Curves.easeInQuad; break;
      case ANIMATION.Curve.easeInCubic            : curve = Curves.easeInCubic; break;
      case ANIMATION.Curve.easeInQuart            : curve = Curves.easeInQuart; break;
      case ANIMATION.Curve.easeInQuint            : curve = Curves.easeInQuint; break;
      case ANIMATION.Curve.easeInExpo             : curve = Curves.easeInExpo; break;
      case ANIMATION.Curve.easeInCirc             : curve = Curves.easeInCirc; break;
      case ANIMATION.Curve.easeInBack             : curve = Curves.easeInBack; break;
      case ANIMATION.Curve.easeOut                : curve = Curves.easeOut; break;
      case ANIMATION.Curve.linearToEaseOut        : curve = Curves.linearToEaseOut; break;
      case ANIMATION.Curve.easeOutSine            : curve = Curves.easeOutSine; break;
      case ANIMATION.Curve.easeOutQuad            : curve = Curves.easeOutQuad; break;
      case ANIMATION.Curve.easeOutCubic           : curve = Curves.easeOutCubic; break;
      case ANIMATION.Curve.easeOutQuart           : curve = Curves.easeOutQuart; break;
      case ANIMATION.Curve.easeOutQuint           : curve = Curves.easeOutQuint; break;
      case ANIMATION.Curve.easeOutExpo            : curve = Curves.easeOutExpo; break;
      case ANIMATION.Curve.easeOutCirc            : curve = Curves.easeOutCirc; break;
      case ANIMATION.Curve.easeOutBack            : curve = Curves.easeOutBack; break;
      case ANIMATION.Curve.easeInOut              : curve = Curves.easeInOut; break;
      case ANIMATION.Curve.easeInOutSine          : curve = Curves.easeInOutSine; break;
      case ANIMATION.Curve.easeInOutQuad          : curve = Curves.easeInOutQuad; break;
      case ANIMATION.Curve.easeInOutCubic         : curve = Curves.easeInOutCubic; break;
      case ANIMATION.Curve.easeInOutQuart         : curve = Curves.easeInOutQuart; break;
      case ANIMATION.Curve.easeInOutQuint         : curve = Curves.easeInOutQuint; break;
      case ANIMATION.Curve.easeInOutExpo          : curve = Curves.easeInOutExpo; break;
      case ANIMATION.Curve.easeInOutCirc          : curve = Curves.easeInOutCirc; break;
      case ANIMATION.Curve.easeInOutBack          : curve = Curves.easeInOutBack; break;
      case ANIMATION.Curve.fastOutSlowIn          : curve = Curves.fastOutSlowIn; break;
      case ANIMATION.Curve.slowMiddle             : curve = Curves.slowMiddle; break;
      case ANIMATION.Curve.bounceIn               : curve = Curves.bounceIn; break;
      case ANIMATION.Curve.bounceOut              : curve = Curves.bounceOut; break;
      case ANIMATION.Curve.bounceInOut            : curve = Curves.bounceInOut; break;
      case ANIMATION.Curve.elasticIn              : curve = Curves.elasticIn; break;
      case ANIMATION.Curve.elasticOut             : curve = Curves.elasticOut; break;
      case ANIMATION.Curve.elasticInOut           : curve = Curves.elasticInOut; break;
      default                                     : curve = Curves.linear; break;
    }
    
    // Duration
    int _duration = widget.model.duration;
    int? _reverseDuration = widget.model.reverseduration;

    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: _duration,),  reverseDuration: Duration(milliseconds: _reverseDuration ?? _duration,),);


    switch (type)
    {
      case ANIMATION.Transitions.flip :

        // anchor
        Alignment anchor = Alignment.center;
        switch (widget.model.anchor.toLowerCase())
        {
          case "topleft" :
            anchor = Alignment.topLeft;
            break;
          case "centerleft" :
            anchor = Alignment.centerLeft;
            break;
          case "bottomleft" :
            anchor = Alignment.bottomLeft;
            break;
          case "topcenter" :
            anchor = Alignment.topCenter;
            break;
          case "center" :
            anchor = Alignment.center;
            break;
          case "bottomcenter" :
            anchor = Alignment.bottomCenter;
            break;
          case "topright" :
            anchor = Alignment.topRight;
            break;
          case "centerright" :
            anchor = Alignment.centerRight;
            break;
          case "bottomright" :
            anchor = Alignment.bottomRight;
            break;
        }

        // axis
        FlipDirection? axis = S.toEnum(widget.model.axis.toUpperCase(), FlipDirection.values);
        if (axis == null) axis = FlipDirection.HORIZONTAL;

        // build the animation
        _controller = FlipCardController();
        view = FlipCard(speed: _duration, direction: axis, alignment: anchor, controller: _controller, front: front ?? Container(), back: back ?? Container(), flipOnTouch: false,);
        break;

      case ANIMATION.Transitions.fade :
        break;

      case ANIMATION.Transitions.scale :
        break;

      case ANIMATION.Transitions.size:
        break;

      case ANIMATION.Transitions.rotate :
        break;

      case ANIMATION.Transitions.slide:
        break;

      case ANIMATION.Transitions.position:
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
        if (_controller is AnimationController) {
            _controller.reset();
          } else if (_controller is FlipCardController) {
          (_controller as FlipCardController).toggleCardWithoutAnimation();
          bool front = (_controller as FlipCardController).state?.isFront ?? true;
          widget.model.side = front ? "front" : "back";
        }
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
        if (_controller is AnimationController)
        {
          if(_controller.isCompleted) {
            _controller.reverse();
          } else if (_controller.isDismissed){
            _controller.forward();
          } else {
            _controller.forward();
          }
        }
        else if (_controller is FlipCardController)
        {
          (_controller as FlipCardController).toggleCard();
          bool front = (_controller as FlipCardController).state?.isFront ?? true;
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
      if (_controller is AnimationController)
      {
        (_controller as AnimationController).reset();
        (_controller as AnimationController).stop();
        widget.model.side = (_controller as FlipCardController).state?.isFront ?? true ? "front" : "back";
      }
    }
    catch(e){}
  }

  void _animationListener(AnimationStatus status)
  {
    if (_controller is FlipCardController) return;

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
