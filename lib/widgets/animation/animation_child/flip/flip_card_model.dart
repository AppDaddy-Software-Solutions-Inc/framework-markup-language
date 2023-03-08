// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/animation/animation_child/animation_child_model.dart';
import 'package:fml/widgets/animation/animation_child/flip/flip_card_view.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

/// Animation Model
/// Defines the properties of an [ANIMATION.AnimationView]
class FlipCardModel extends AnimationChildModel
{
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


  StringObservable? _side;

  set side(dynamic v) {
    if (_side != null) {
      _side!.set(v);
    } else if (v != null) {
      // no listener since this is only set by the view
      // and we don't want to trigger a rebuild
      _side = StringObservable(Binding.toKey(id, 'side'), v, scope: scope);
    }
  }

  String get side => _side?.get() ?? "front";

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


  FlipCardModel(WidgetModel parent, String? id)
      : super(parent, id); // ; {key: value}

  static FlipCardModel? fromXml(WidgetModel parent, XmlElement xml) {
    FlipCardModel? model;
    try {
      model = FlipCardModel(parent, Xml.get(node: xml, tag: 'id'));
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

    align = Xml.get(node: xml, tag: 'align');
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
        var view = findListenerOfExactType(FlipCardViewState);
        if (view is FlipCardViewState) {
          view.start();
        }
        return true;

      case "stop":
        var view = findListenerOfExactType(FlipCardViewState);
        if (view is FlipCardViewState) view.stop();
        return true;
      case "reset":
        var view = findListenerOfExactType(FlipCardViewState);
        if (view is FlipCardViewState) view.reset();
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  Widget getAnimatedView(Widget child, {AnimationController? controller}) =>  FlipCardView(this, child, controller);
}
