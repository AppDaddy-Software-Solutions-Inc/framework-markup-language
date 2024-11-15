// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/widgets/animation/animation_model.dart';

/// Progression Curve of an Animation or Transition types

/// Animation Model
/// Defines the properties;
class AnimationBaseModel extends AnimationModel {
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

  AnimationBaseModel(super.parent, super.id); // ; {key: value}

  static AnimationBaseModel? fromXml(Model parent, XmlElement xml) {
    AnimationBaseModel? model;
    try {
      model = AnimationBaseModel(parent, Xml.get(node: xml, tag: 'id'));
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
    begin = Xml.get(node: xml, tag: 'begin');
    end = Xml.get(node: xml, tag: 'end');
  }
}
