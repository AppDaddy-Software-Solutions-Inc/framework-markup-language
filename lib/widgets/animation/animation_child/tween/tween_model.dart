// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/animation/animation_child/animation_child_model.dart';
import 'package:fml/widgets/animation/animation_child/tween/tween_view.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

/// Progression Curve of an Animation or Transition types

/// Animation Model
/// Defines the properties of an [ANIMATION.AnimationView]
class TweenModel extends AnimationChildModel
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

  String? get from => _from?.get() ?? "0";

  /// Curve ending point
  StringObservable? _to;

  set to(dynamic v) {
    if (_to != null) {
      _to!.set(v);
    } else if (v != null) {
      _to = StringObservable(Binding.toKey(id, 'to'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String get to => _to?.get() ?? "1";

  /// type of tween, color or double
  StringObservable? _type;

  set type(dynamic v) {
    if (_type != null) {
      _type!.set(v);
    } else if (v != null) {
      _type = StringObservable(Binding.toKey(id, 'type'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get type => _type?.get();

  TweenModel(WidgetModel parent, String? id)
      : super(parent, id); // ; {key: value}

  static TweenModel? fromXml(WidgetModel parent, XmlElement xml) {
    TweenModel? model;
    try {
      model = TweenModel(parent, Xml.get(node: xml, tag: 'id'));
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
    type = Xml.get(node: xml, tag: 'type');
    from = Xml.get(node: xml, tag: 'from');
    to = Xml.get(node: xml, tag: 'to');
  }

  @override
  dispose() {
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
        var view = findListenerOfExactType(TweenViewState);
        if (view is TweenViewState) {
          view.start();
        }
        return true;

      case "stop":
        var view = findListenerOfExactType(TweenViewState);
        if (view is TweenViewState) view.stop();
        return true;
      case "reset":
        var view = findListenerOfExactType(TweenViewState);
        if (view is TweenViewState) view.reset();
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  Widget getAnimatedView(Widget child, {AnimationController? controller}) => TweenView(this, child, controller);
}
