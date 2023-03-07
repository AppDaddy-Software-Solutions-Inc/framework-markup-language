// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/animation/animation_child/animation_child_model.dart';
import 'package:fml/widgets/animation/animation_child/fade/fade_transition_view.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

/// Animation Model
/// Defines the properties of an [ANIMATION.AnimationView]
class AnimationModel extends AnimationChildModel {
  /// Curve starting point from 0.0 to 1.0
  DoubleObservable? _from;

  set from(dynamic v) {
    if (_from != null) {
      _from!.set(v);
    } else if (v != null) {
      _from = DoubleObservable(Binding.toKey(id, 'from'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double get from {
    if (_from == null) return 0.0;
    double f = _from?.get() ?? 0.0;
    if (f < 0.0) f = 0.0;
    if (f > 1.0) f = 1.0;
    return f;
  }

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

  double get to {
    if (_to == null) return 1.0;
    double f = _to?.get() ?? 1.0;
    if (f < 0.0) f = 0.0;
    if (f > 1.0) f = 1.0;
    return f;
  }

  AnimationModel(WidgetModel parent, String? id)
      : super(parent, id); // ; {key: value}

  static AnimationModel? fromXml(WidgetModel parent, XmlElement xml) {
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

    from = Xml.get(node: xml, tag: 'from');
    to = Xml.get(node: xml, tag: 'to');
  }

  @override
  dispose() {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Widget getTransitionView(Widget child, AnimationController controller) {
    return FadeTransitionView(this, child, controller);
  }
}
