// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/animation/animation_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

/// Transition types
enum Transitions {fade, position, scale, rotate, flip, size, slide}

/// Progression Curve of an Animation or Transition types
enum Curve {
  linear, 
  decelerate, 
  fastLinearToSlowEaseIn, 
  ease, 
  easeIn, 
  easeInToLinear, 
  easeInSine, 
  easeInQuad, 
  easeInCubic, 
  easeInQuart, 
  easeInQuint, 
  easeInExpo,
  easeInCirc,
  easeInBack,
  easeOut,
  linearToEaseOut,
  easeOutSine,
  easeOutQuad,
  easeOutCubic,
  easeOutQuart,
  easeOutQuint,
  easeOutExpo,
  easeOutCirc,
  easeOutBack,
  easeInOut,
  easeInOutSine,
  easeInOutQuad,
  easeInOutCubic,
  easeInOutQuart,
  easeInOutQuint,
  easeInOutExpo,
  easeInOutCirc,
  easeInOutBack,
  fastOutSlowIn,
  slowMiddle,
  bounceIn,
  bounceOut,
  bounceInOut,
  elasticIn,
  elasticOut,
  elasticInOut
}

/// Animation Model
/// Defines the properties of an [ANIMATION.AnimationView]
class AnimationModel extends DecoratedWidgetModel implements IViewableWidget
{
  bool runonce = false;

  
  // animation
  /// Name of Animation to use
  StringObservable? _animation;
  set animation (dynamic v)
  {
    if (_animation != null)
    {
      _animation!.set(v);
    }
    else if (v != null)
    {
      _animation = StringObservable(Binding.toKey(id, 'animation'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get animation => _animation?.get();

  /// Transition Curve
  StringObservable? _transition;
  set transition (dynamic v)
  {
    if (_transition != null)
    {
      _transition!.set(v);
    }
    else if (v != null)
    {
      _transition = StringObservable(Binding.toKey(id, 'transition'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get transition => _transition?.get();

  /// side - used on on flip transition
  StringObservable? _side;
  set side (dynamic v)
  {
    if (_side != null)
    {
      _side!.set(v);
    }
    else if (v != null)
    {
      _side = StringObservable(Binding.toKey(id, 'side'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String get side => _side?.get() ?? "left";

  /// axis - used on on flip transition
  StringObservable? _axis;
  set axis (dynamic v)
  {
    if (_axis != null)
    {
      _axis!.set(v);
    }
    else if (v != null)
    {
      _axis = StringObservable(Binding.toKey(id, 'axis'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String get axis => _axis?.get() ?? "horizontal";

  
  /// Δ x value for transitions such as slide, defaults to 1.5
  DoubleObservable? _dx;
  set dx (dynamic v)
  {
    if (_dx != null)
    {
      _dx!.set(v);
    }
    else if (v != null)
    {
      _dx = DoubleObservable(Binding.toKey(id, 'x'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double get dx => _dx?.get() ?? 1.5;

  /// Δ y value for transitions such as slide
  DoubleObservable? _dy;
  set dy (dynamic v)
  {
    if (_dy != null)
    {
      _dy!.set(v);
    }
    else if (v != null)
    {
      _dy = DoubleObservable(Binding.toKey(id, 'y'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double get dy => _dy?.get() ?? 0.0;
  
  /// bool value to determine how many times the animation repeats
  ///
  /// Can take in an integer or string value
  DoubleObservable? _repeat;
  set repeat (dynamic v)
  {
    if ((v is String) && (v.toLowerCase() == 'forever' || v.toLowerCase() == 'loop' || v.toLowerCase() == 'infinite' )) v = double.maxFinite;
    if (_repeat != null)
    {
      _repeat!.set(v);
    }
    else if (v != null)
    {
      _repeat = DoubleObservable(Binding.toKey(id, 'repeat'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double get repeat => _repeat?.get() ?? 1;

  /// Direction to play the Animation in, if set to true will play in reverse, default: false
  BooleanObservable? _reverse;
  set reverse (dynamic v)
  {
    if (_reverse != null)
    {
      _reverse!.set(v);
    }
    else if (v != null)
    {
      _reverse = BooleanObservable(Binding.toKey(id, 'reverse'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get reverse => _reverse?.get() ?? false;

  /// Duration an animation takes to play once in milliseconds
  IntegerObservable? _duration;
  set duration (dynamic v)
  {
    if (_duration != null)
    {
      _duration!.set(v);
    }
    else if (v != null)
    {
      _duration = IntegerObservable(Binding.toKey(id, 'duration'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int get duration => _duration?.get() ?? 1000;

  /// Curve starting point from 0.0 to 1.0
  DoubleObservable? _from;
  set from (dynamic v)
  {
    if (_from != null)
    {
      _from!.set(v);
    }
    else if (v != null)
    {
      _from = DoubleObservable(Binding.toKey(id, 'from'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double get from
  {
    if (_from == null) return 0.0;
    double f = _from?.get() ?? 0.0;
    if (f < 0.0) f = 0.0;
    if (f > 1.0) f = 1.0;
    return f;
  }

  /// Curve ending point from 1.0 to 0.0
  DoubleObservable? _to;
  set to (dynamic v)
  {
    if (_to != null)
    {
      _to!.set(v);
    }
    else if (v != null)
    {
      _to = DoubleObservable(Binding.toKey(id, 'to'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double get to
  {
    if (_to == null) return 1.0;
    double f = _to?.get() ?? 1.0;
    if (f < 0.0) f = 0.0;
    if (f > 1.0) f = 1.0;
    return f;
  }

  /// Play animation on build, default: false
  BooleanObservable? _autoplay;
  set autoplay(dynamic v) {
    if (_autoplay != null) {
      _autoplay!.set(v);
    } else if (v != null) {
      _autoplay = BooleanObservable(Binding.toKey(id, 'autoplay'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get autoplay => _autoplay?.get() ?? false;

  AnimationModel(WidgetModel parent, String?  id) : super(parent, id); // ; {key: value}

  static AnimationModel? fromXml(WidgetModel parent, XmlElement xml, {String? type})
  {
    AnimationModel? model;
    try
    {
      model = AnimationModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().debug(e.toString());
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) async
  {
    // deserialize
    super.deserialize(xml);

    // properties
    autoplay    = Xml.get(node: xml, tag: 'autoplay');
    animation   = Xml.get(node: xml, tag: 'type');
    transition  = Xml.get(node: xml, tag: 'transition');
    repeat      = Xml.get(node: xml, tag: 'repeat') ?? 1;
    reverse     = Xml.get(node: xml, tag: 'reverse');
    duration    = Xml.get(node: xml, tag: 'duration');
    from        = Xml.get(node: xml, tag: 'from');
    to          = Xml.get(node: xml, tag: 'to');
    dx          = Xml.get(node: xml, tag: 'x');
    dy          = Xml.get(node: xml, tag: 'y');
    side        = Xml.get(node: xml, tag: 'side');
    axis        = Xml.get(node: xml, tag: 'axis');
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  // constrained?
  bool isConstrained(String dimension)
  {
    return true;
  }

  @override
  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async
  {
    /// setter
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    switch (function)
    {
      case "start" :
        var view = findListenerOfExactType(AnimationViewState);
        if (view is AnimationViewState) view.start();
        return true;

      case "stop" :
        var view = findListenerOfExactType(AnimationViewState);
        if (view is AnimationViewState) view.stop();
        return true;

    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  /// Returns the [ANIMATION] View
  Widget getView({Key? key}) => AnimationView(this);
}