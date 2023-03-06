// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/animation/animation_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

/// Animation Model
/// Defines the properties of an [ANIMATION.AnimationView]
class AnimationModel extends WidgetModel implements IViewableWidget {
  bool runonce = false;


  /// Transition Curve
  StringObservable? _curve;

  set curve(dynamic v) {
    if (_curve != null) {
      _curve!.set(v);
    } else if (v != null) {
      _curve = StringObservable(Binding.toKey(id, 'curve'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get curve => _curve?.get();


  /// bool value to determine how many times the animation repeats
  ///
  /// Can take in an integer or string value
  DoubleObservable? _repeat;

  set repeat(dynamic v) {
    if ((v is String) &&
        (v.toLowerCase() == 'forever' ||
            v.toLowerCase() == 'loop' ||
            v.toLowerCase() == 'infinite')) v = double.maxFinite;
    if (_repeat != null) {
      _repeat!.set(v);
    } else if (v != null) {
      _repeat = DoubleObservable(Binding.toKey(id, 'repeat'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double get repeat => _repeat?.get() ?? 1;


  /// Direction to play the Animation in, if set to true will play in reverse, default: false
  BooleanObservable? _reverse;

  set reverse(dynamic v) {
    if (_reverse != null) {
      _reverse!.set(v);
    } else if (v != null) {
      _reverse = BooleanObservable(Binding.toKey(id, 'reverse'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get reverse => _reverse?.get() ?? false;

  /// Duration an animation takes to play once in milliseconds
  IntegerObservable? _duration;

  set duration(dynamic v) {
    if (_duration != null) {
      _duration!.set(v);
    } else if (v != null) {
      _duration = IntegerObservable(Binding.toKey(id, 'duration'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  int get duration => _duration?.get() ?? 1000;

  /// Duration an animation takes to play once in milliseconds
  IntegerObservable? _reverseduration;

  set reverseduration(dynamic v) {
    if (_reverseduration != null) {
      _reverseduration!.set(v);
    } else if (v != null) {
      _reverseduration = IntegerObservable(
          Binding.toKey(id, 'reverseduration'), v,
          scope: scope, listener: onPropertyChange);
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

  /// Linked allows for passing the animation controller on a single animation. This will allow for the animation to sync to that controller.
  StringObservable? _linked;

  set linked(dynamic v) {
    if (_linked != null) {
      _linked!.set(v);
    } else if (v != null) {
      _linked = StringObservable(Binding.toKey(id, 'linked'), v, scope: scope);
    }
  }

  String? get linked => _linked?.get();

  /// scroll allows for passing the scrollcontroller on a single animation. This will allow for the animation to sync to that controller.
  StringObservable? _scroll;

  set scroll(dynamic v) {
    if (_scroll != null) {
      _scroll!.set(v);
    } else if (v != null) {
      _scroll = StringObservable(Binding.toKey(id, 'scroll'), v, scope: scope);
    }
  }

  String? get scroll => _scroll?.get();

  /// gesture allows for passing the gesturedetector on a single animation. This will allow for the animation to sync to that controller.
  StringObservable? _gesture;

  set gesture(dynamic v) {
    if (_gesture != null) {
      _gesture!.set(v);
    } else if (v != null) {
      _gesture = StringObservable(Binding.toKey(id, 'gesture'), v, scope: scope);
    }
  }

  String? get gesture => _gesture?.get();

  final List transitionChildren = [];
  AnimationController? controller;

  AnimationModel(WidgetModel parent, String? id)
      : super(parent, id); // ; {key: value}

  static AnimationModel? fromXml(WidgetModel parent, XmlElement xml, bool requestedStandalone)
  {
    AnimationModel? model;
    try
    {
      model = AnimationModel(parent, Xml.get(node: xml, tag: 'id'));
      if (requestedStandalone)
      {
        var xmlCopy = xml.copy();
        xmlCopy.setAttribute('id', null);
        xml.children.add(xmlCopy);
      }
      model.deserialize(xml);
    }
    catch (e)
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
    autoplay = Xml.get(node: xml, tag: 'autoplay');
    curve = Xml.get(node: xml, tag: 'curve');
    repeat = Xml.get(node: xml, tag: 'repeat') ?? 1;
    reverse = Xml.get(node: xml, tag: 'reverse');
    duration = Xml.get(node: xml, tag: 'duration');
    linked = Xml.get(node: xml, tag: 'linked');

    // clear options
    this.transitionChildren.clear();

    // Build options
    List? transitionChildren = children;

    transitionChildren?.forEach((child) => this.transitionChildren.add(child));
  }

  @override
  dispose() {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  // constrained?
  bool isConstrained(String dimension) {
    return true;
  }

  //we need a reset function to set the controller back to 0 without ticking.

  @override
  Future<bool?> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    /// setter
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    switch (function) {
      case "animate":
      case "start":
        var view = findListenerOfExactType(AnimationViewState);
        if (view is AnimationViewState) {
          view.start();
        }
        return true;

      case "stop":
        var view = findListenerOfExactType(AnimationViewState);
        if (view is AnimationViewState) view.stop();
        return true;
      case "reset":
        var view = findListenerOfExactType(AnimationViewState);
        if (view is AnimationViewState) view.reset();
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  /// Returns the [ANIMATION] View

  Widget getView({Key? key}) {
    return AnimationView(this, null, null);
  }
}
