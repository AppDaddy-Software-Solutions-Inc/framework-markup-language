// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/animation/animation_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

/// Transition types
enum Transitions {fade, position, scale, rotate, flip, size, slide}

/// Animation Model
/// Defines the properties of an [ANIMATION.AnimationView]
class AnimationModel extends WidgetModel implements IViewableWidget
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
  StringObservable? _curve;
  set curve (dynamic v)
  {
    if (_curve != null)
    {
      _curve!.set(v);
    }
    else if (v != null)
    {
      _curve = StringObservable(Binding.toKey(id, 'curve'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get curve => _curve?.get();

  /// anchor - used on on flip transition
  StringObservable? _anchor;
  set anchor (dynamic v)
  {
    if (_anchor != null)
    {
      _anchor!.set(v);
    }
    else if (v != null)
    {
      _anchor = StringObservable(Binding.toKey(id, 'anchor'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String get anchor => _anchor?.get() ?? "center";

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

  StringObservable? _side;
  set side (dynamic v)
  {
    if (_side != null)
    {
      _side!.set(v);
    }
    else if (v != null)
    {
      // no listener since this is only set by the view
      // and we don't want to trigger a rebuild
      _side = StringObservable(Binding.toKey(id, 'side'), v, scope: scope);
    }
  }
  String get side => _side?.get() ?? "front";

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

  /// Duration an animation takes to play once in milliseconds
  IntegerObservable? _reverseduration;
  set reverseduration (dynamic v)
  {
    if (_reverseduration != null)
    {
      _reverseduration!.set(v);
    }
    else if (v != null)
    {
      _reverseduration = IntegerObservable(Binding.toKey(id, 'reverseduration'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int? get reverseduration => _reverseduration?.get();


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

  final List transitionChildren = [];

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
    curve  = Xml.get(node: xml, tag: 'curve');
    repeat      = Xml.get(node: xml, tag: 'repeat') ?? 1;
    reverse     = Xml.get(node: xml, tag: 'reverse');
    duration    = Xml.get(node: xml, tag: 'duration');
    anchor      = Xml.get(node: xml, tag: 'anchor');
    axis        = Xml.get(node: xml, tag: 'axis');



    // clear options
    this.transitionChildren.clear();

    // Build options
    List? transitionChildren = children;

    transitionChildren?.forEach((child) => this.transitionChildren.add(child));


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

  //we need a reset function to set the controller back to 0 without ticking.

  @override
  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async
  {
    /// setter
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    switch (function)
    {
      case "animate" :
      case "start" :
        var view = findListenerOfExactType(AnimationViewState);
        if (view is AnimationViewState)
        {
          view.start();
        }
          return true;

      case "stop" :
        var view = findListenerOfExactType(AnimationViewState);
        if (view is AnimationViewState) view.stop();
        return true;
      case "reset" :
        var view = findListenerOfExactType(AnimationViewState);
        if (view is AnimationViewState) view.reset();
        return true;

    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  /// Returns the [ANIMATION] View



  Widget getView({Key? key}) {

    return AnimationView(this, null);

  }
}