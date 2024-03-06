// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/animation/animation_child/animation_child_model.dart';
import 'package:fml/widgets/animation/animation_child/slide/slide_transition_view.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

/// Progression Curve of an Animation or Transition types

/// Animation Model
/// Defines the properties of an [ANIMATION.AnimationView]
class SlideTransitionModel extends AnimationChildModel
{
  /// Curve starting point from 0.0 to 1.0
  StringObservable? _from;

  set from(dynamic v) {
    if (_from != null) {
      _from!.set(v);
    } else if (v != null) {
      _from = StringObservable(Binding.toKey(id, 'from'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get from => _from?.get();

  /// Curve ending point from 1.0 to 0.0
  StringObservable? _to;

  set to(dynamic v) {
    if (_to != null) {
      _to!.set(v);
    } else if (v != null) {
      _to = StringObservable(Binding.toKey(id, 'to'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String get to => _to?.get() ?? "0, 0";

  /// Curve ending point from 1.0 to 0.0
  StringObservable? _direction;

  set direction(dynamic v) {
    if (_direction != null) {
      _direction!.set(v);
    } else if (v != null) {
      _direction = StringObservable(Binding.toKey(id, 'direction'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get direction => _direction?.get();

  SlideTransitionModel(super.parent, super.id); // ; {key: value}

  static SlideTransitionModel? fromXml(WidgetModel parent, XmlElement xml) {
    SlideTransitionModel? model;
    try {
      model = SlideTransitionModel(parent, Xml.get(node: xml, tag: 'id'));
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

    from = Xml.get(node: xml, tag: 'from');
    to = Xml.get(node: xml, tag: 'to');
    direction = Xml.get(node: xml, tag: 'direction');
  }

  @override
  dispose() {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  @override
  Future<bool?> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    /// setter
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    switch (function) {
      case "animate":
      case "start":
        var view = findListenerOfExactType(SlideTransitionViewState);
        if (view is SlideTransitionViewState) {
          view.start();
        }
        return true;

      case "stop":
        var view = findListenerOfExactType(SlideTransitionViewState);
        if (view is SlideTransitionViewState) view.stop();
        return true;
      case "reset":
        var view = findListenerOfExactType(SlideTransitionViewState);
        if (view is SlideTransitionViewState) view.reset();
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  @override
  Widget getAnimatedView(Widget child, {AnimationController? controller}) => SlideTransitionView(this, child, controller);
}
