// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/event/handler.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/animation/animation_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

/// Animation Model
/// Defines the properties of an [ANIMATION.AnimationView]
class AnimationModel extends ViewableModel {
  bool hasrun = false;

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
  int get duration => _duration?.get() ?? 300;

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
      _gesture =
          StringObservable(Binding.toKey(id, 'gesture'), v, scope: scope);
    }
  }

  String? get gesture => _gesture?.get();

  StringObservable? _oncomplete;
  set oncomplete(dynamic v) {
    if (_oncomplete != null) {
      _oncomplete!.set(v);
    } else if (v != null) {
      _oncomplete = StringObservable(Binding.toKey(id, 'oncomplete'), v,
          scope: scope, listener: onPropertyChange, lazyEvaluation: true);
    }
  }

  String? get oncomplete => _oncomplete?.get();

  StringObservable? _ondismiss;
  set ondismiss(dynamic v) {
    if (_ondismiss != null) {
      _ondismiss!.set(v);
    } else if (v != null) {
      _ondismiss = StringObservable(Binding.toKey(id, 'ondismiss'), v,
          scope: scope, listener: onPropertyChange, lazyEvaluation: true);
    }
  }

  String? get ondismiss => _ondismiss?.get();

  StringObservable? _onstart;
  set onstart(dynamic v) {
    if (_onstart != null) {
      _onstart!.set(v);
    } else if (v != null) {
      _onstart = StringObservable(Binding.toKey(id, 'onstart'), v,
          scope: scope, listener: onPropertyChange, lazyEvaluation: true);
    }
  }

  String? get onstart => _onstart?.get();

  BooleanObservable? _runonce;
  set runonce(dynamic v) {
    if (_runonce != null) {
      _runonce!.set(v);
    } else if (v != null) {
      _runonce = BooleanObservable(Binding.toKey(id, 'runonce'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get runonce => _runonce?.get() ?? false;

  double controllerValue = 0;

  AnimationModel(Model super.parent, super.id); // ; {key: value}

  static AnimationModel? fromXml(Model parent, XmlElement xml) {
    AnimationModel? model;
    try {
      model = AnimationModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().debug(e.toString());
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) async {
    // deserialize
    super.deserialize(xml);

    // properties
    curve = Xml.get(node: xml, tag: 'curve');
    duration = Xml.get(node: xml, tag: 'duration');
    autoplay = Xml.get(node: xml, tag: 'autoplay');
    runonce = Xml.get(node: xml, tag: 'runonce');

    onstart = Xml.get(node: xml, tag: 'onstart');
    oncomplete = Xml.get(node: xml, tag: 'oncomplete');
    ondismiss = Xml.get(node: xml, tag: 'ondismiss');
  }

  //we need a reset function to set the controller back to 0 without ticking.
  @override
  Future<dynamic> execute(
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

  Future<bool> onStart(BuildContext context) async {
    return await EventHandler(this).execute(_onstart);
  }

  Future<bool> onDismiss(BuildContext context) async {
    return await EventHandler(this).execute(_ondismiss);
  }

  Future<bool> onComplete(BuildContext context) async {
    return await EventHandler(this).execute(_oncomplete);
  }

  @override
  Widget getView({Key? key}) => AnimationView(this, null);

  Widget getAnimatedView(Widget child, {AnimationController? controller}) =>
      AnimationView(this, child);
}
