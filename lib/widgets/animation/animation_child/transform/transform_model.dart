// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/animation/animation_child/animation_child_model.dart';
import 'package:fml/widgets/animation/animation_child/transform/transform_view.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

/// Progression Curve of an Animation or Transition types

/// Animation Model
/// Defines the properties of an [ANIMATION.AnimationView]
class TransformModel extends AnimationChildModel
{
  /// Curve starting point from 0.0 to 1.0
  StringObservable? _rotateFrom;

  set rotateFrom(dynamic v) {
    if (_rotateFrom != null) {
      _rotateFrom!.set(v);
    } else if (v != null) {
      _rotateFrom = StringObservable(Binding.toKey(id, 'rotatefrom'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get rotateFrom => _rotateFrom?.get();

  /// Curve ending point from 1.0 to 0.0
  StringObservable? _rotateTo;

  set rotateTo(dynamic v) {
    if (_rotateTo != null) {
      _rotateTo!.set(v);
    } else if (v != null) {
      _rotateTo = StringObservable(Binding.toKey(id, 'rotateto'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String get rotateTo => _rotateTo?.get() ?? "0, 0";


  StringObservable? _translateFrom;

  set translateFrom(dynamic v) {
    if (_translateFrom != null) {
      _translateFrom!.set(v);
    } else if (v != null) {
      _translateFrom = StringObservable(Binding.toKey(id, 'translatefrom'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get translateFrom => _translateFrom?.get();

  /// Curve ending point from 1.0 to 0.0
  StringObservable? _translateTo;

  set translateTo(dynamic v) {
    if (_translateTo != null) {
      _translateTo!.set(v);
    } else if (v != null) {
      _translateTo = StringObservable(Binding.toKey(id, 'translateto'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String get translateTo => _translateTo?.get() ?? "0, 0, 0";

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

  /// Curve ending point from 1.0 to 0.0
  DoubleObservable? _warp;

  set warp(dynamic v) {
    if (_warp != null) {
      _warp!.set(v);
    } else if (v != null) {
      _warp = DoubleObservable(Binding.toKey(id, 'warp'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get warp => _warp?.get();


  TransformModel(WidgetModel parent, String? id)
      : super(parent, id); // ; {key: value}

  static TransformModel? fromXml(WidgetModel parent, XmlElement xml) {
    TransformModel? model;
    try {
      model = TransformModel(parent, Xml.get(node: xml, tag: 'id'));
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

    rotateFrom = Xml.get(node: xml, tag: 'rotateFrom');
    rotateTo = Xml.get(node: xml, tag: 'rotateTo');
    translateFrom = Xml.get(node: xml, tag: 'translateFrom');
    translateTo = Xml.get(node: xml, tag: 'translateTo');
    align = Xml.get(node: xml, tag: 'align');
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
        var view = findListenerOfExactType(TransformViewState);
        if (view is TransformViewState) {
          view.start();
        }
        return true;

      case "stop":
        var view = findListenerOfExactType(TransformViewState);
        if (view is TransformViewState) view.stop();
        return true;
      case "reset":
        var view = findListenerOfExactType(TransformViewState);
        if (view is TransformViewState) view.reset();
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  Widget getAnimatedView(Widget child, {AnimationController? controller}) => TransformView(this, child, controller);
}
