// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/animation/animation_child/tween_view.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

/// Progression Curve of an Animation or Transition types

/// Animation Model
/// Defines the properties of an [ANIMATION.AnimationView]
class TweenModel extends WidgetModel {
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

  /// Curve
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


  /// Curve
  StringObservable? _value;

  set value(dynamic v) {
    if (_value != null) {
      _value!.set(v);
    } else if (v != null) {
      _value = StringObservable(Binding.toKey(id, 'value'), v,
          scope: scope);
    }
  }
  String? get value => _value?.get();

  /// Point at which the animation begins in the controllers value range of 0-1
  DoubleObservable? _begin;

  set begin(dynamic v) {
    if (_begin != null) {
      _begin!.set(v);
    } else if (v != null) {
      _begin = DoubleObservable(Binding.toKey(id, 'begin'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double get begin {
    if (_begin == null) return 0.0;
    double f = _begin?.get() ?? 0.0;
    if (f < 0.0) f = 0.0;
    if (f > 1.0) f = 1.0;
    return f;
  }

  DoubleObservable? _end;

  set end(dynamic v) {
    if (_end != null) {
      _end!.set(v);
    } else if (v != null) {
      _end = DoubleObservable(Binding.toKey(id, 'end'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double get end {
    if (_end == null) return 1.0;
    double f = _end?.get() ?? 1.0;
    if (f < 0.0) f = 0.0;
    if (f > 1.0) f = 1.0;
    return f;
  }

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

    from = Xml.get(node: xml, tag: 'from');
    to = Xml.get(node: xml, tag: 'to');
    curve = Xml.get(node: xml, tag: 'curve');
    begin = Xml.get(node: xml, tag: 'begin');
    end = Xml.get(node: xml, tag: 'end');
    type = Xml.get(node: xml, tag: 'type');
  }

  @override
  dispose() {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  @override
  void onPropertyChange(Observable observable) {

  }

  Widget getTransitionView(Widget child, AnimationController controller) {
    return TweenView(this, child, controller);
  }
}
