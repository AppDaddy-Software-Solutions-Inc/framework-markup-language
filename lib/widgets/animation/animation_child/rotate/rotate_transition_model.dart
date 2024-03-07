// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/animation/animation_child/animation_child_model.dart';
import 'package:fml/widgets/animation/animation_child/rotate/rotate_transition_view.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

/// Animation Model
/// Defines the properties of an [ANIMATION.AnimationView]
class RotateTransitionModel extends AnimationChildModel
{
  /// Curve starting point from
  DoubleObservable? _from;

  set from(dynamic v) {
    if (_from != null) {
      _from!.set(v);
    } else if (v != null) {
      _from = DoubleObservable(Binding.toKey(id, 'from'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double get from => _from?.get() ?? 0.0;

  /// Curve ending point from 1.0 to 0.0
  DoubleObservable? _to;

  set to(dynamic v) {
    if (_to != null) {
      _to!.set(v);
    } else if (v != null) {
      _to = DoubleObservable(Binding.toKey(id, 'to'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double get to => _to?.get() ?? 1.0;

  /// Curve ending point from 1.0 to 0.0
  StringObservable? _align;

  set align(dynamic v) {
    if (_align != null) {
      _align!.set(v);
    } else if (v != null) {
      _align = StringObservable(Binding.toKey(id, 'align'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get align => _align?.get();

  RotateTransitionModel(super.parent, super.id); // ; {key: value}

  static RotateTransitionModel? fromXml(WidgetModel parent, XmlElement xml) {
    RotateTransitionModel? model;
    try {
      model = RotateTransitionModel(parent, Xml.get(node: xml, tag: 'id'));
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
    align = Xml.get(node: xml, tag: 'align');
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
        var view = findListenerOfExactType(RotateTransitionViewState);
        if (view is RotateTransitionViewState) {
          view.start();
        }
        return true;

      case "stop":
        var view = findListenerOfExactType(RotateTransitionViewState);
        if (view is RotateTransitionViewState) view.stop();
        return true;
      case "reset":
        var view = findListenerOfExactType(RotateTransitionViewState);
        if (view is RotateTransitionViewState) view.reset();
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  @override
  Widget getAnimatedView(Widget child, {AnimationController? controller}) => RotateTransitionView(this, child, controller);
}
