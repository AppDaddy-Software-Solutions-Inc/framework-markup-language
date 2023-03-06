// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

/// Progression Curve of an Animation or Transition types

/// Animation Model
/// Defines the properties;
class AnimationChildModel extends WidgetModel {
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
      _value = StringObservable(Binding.toKey(id, 'value'), v, scope: scope);
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


  AnimationChildModel(WidgetModel parent, String? id)
      : super(parent, id); // ; {key: value}

  static AnimationChildModel? fromXml(WidgetModel parent, XmlElement xml) {
    AnimationChildModel? model;
    try {
      model = AnimationChildModel(parent, Xml.get(node: xml, tag: 'id'));
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
    curve = Xml.get(node: xml, tag: 'curve');
    begin = Xml.get(node: xml, tag: 'begin');
    end = Xml.get(node: xml, tag: 'end');
  }

  @override
  dispose() {
    super.dispose();
  }
}
