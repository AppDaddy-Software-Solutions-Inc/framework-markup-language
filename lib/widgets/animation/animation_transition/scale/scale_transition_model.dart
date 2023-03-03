// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/animation/animation_transition/scale/scale_transition_view.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

/// Progression Curve of an Animation or Transition types
enum CurveEnum {
  linear,
  decelerate,
  fastLinearToSlowEaseIn,
  ease,
  easeIn,
  easeInToLinear,
  easeInSine,
  easeInQuad,
  easeInCubic,
  easeInQuart,
  easeInQuint,
  easeInExpo,
  easeInCirc,
  easeInBack,
  easeOut,
  linearToEaseOut,
  easeOutSine,
  easeOutQuad,
  easeOutCubic,
  easeOutQuart,
  easeOutQuint,
  easeOutExpo,
  easeOutCirc,
  easeOutBack,
  easeInOut,
  easeInOutSine,
  easeInOutQuad,
  easeInOutCubic,
  easeInOutQuart,
  easeInOutQuint,
  easeInOutExpo,
  easeInOutCirc,
  easeInOutBack,
  fastOutSlowIn,
  slowMiddle,
  bounceIn,
  bounceOut,
  bounceInOut,
  elasticIn,
  elasticOut,
  elasticInOut
}

/// Animation Model
/// Defines the properties of an [ANIMATION.AnimationView]
class ScaleTransitionModel extends WidgetModel
{
  /// Curve starting point from 0.0 to 1.0
  DoubleObservable? _from;
  set from (dynamic v)
  {
    if (_from != null)
    {
      _from!.set(v);
    }
    else if (v != null)
    {
      _from = DoubleObservable(Binding.toKey(id, 'from'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double get from
  {
    if (_from == null) return 0.0;
    double f = _from?.get() ?? 0.0;
    if (f < 0.0) f = 0.0;
    return f;
  }

  /// Curve ending point from 1.0 to 0.0
  DoubleObservable? _to;
  set to (dynamic v)
  {
    if (_to != null)
    {
      _to!.set(v);
    }
    else if (v != null)
    {
      _to = DoubleObservable(Binding.toKey(id, 'to'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double get to => _to?.get() ?? 1.0;

  /// Curve
  StringObservable? _curve;
  set curve (dynamic v)
  {
    if (_curve != null)
    {
      _curve!.set(v);
    }
    else if (v != null)
    {
      _curve = StringObservable(Binding.toKey(id, 'curve'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get curve => _curve?.get();


  /// Point at which the animation begins in the controllers value range of 0-1
  DoubleObservable? _begin;
  set begin (dynamic v)
  {
    if (_begin != null)
    {
      _begin!.set(v);
    }
    else if (v != null)
    {
      _begin = DoubleObservable(Binding.toKey(id, 'begin'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double get begin
  {
    if (_begin == null) return 0.0;
    double f = _begin?.get() ?? 0.0;
    if (f < 0.0) f = 0.0;
    if (f > 1.0) f = 1.0;
    return f;
  }


  DoubleObservable? _end;
  set end (dynamic v)
  {
    if (_end != null)
    {
      _end!.set(v);
    }
    else if (v != null)
    {
      _end = DoubleObservable(Binding.toKey(id, 'end'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double get end
  {
    if (_end == null) return 1.0;
    double f = _end?.get() ?? 1.0;
    if (f < 0.0) f = 0.0;
    if (f > 1.0) f = 1.0;
    return f;
  }

  /// Curve ending point from 1.0 to 0.0
  StringObservable? _align;
  set align (dynamic v)
  {
    if (_align != null)
    {
      _align!.set(v);
    }
    else if (v != null)
    {
      _align = StringObservable(Binding.toKey(id, 'align'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get align =>  _align?.get();


  ScaleTransitionModel(WidgetModel parent, String?  id) : super(parent, id); // ; {key: value}

  static ScaleTransitionModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    ScaleTransitionModel? model;
    try
    {
      model = ScaleTransitionModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().debug(e.toString());
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) async
  {
    // deserialize
    super.deserialize(xml);

    from        = Xml.get(node: xml, tag: 'from');
    to          = Xml.get(node: xml, tag: 'to');
    curve       = Xml.get(node: xml, tag: 'curve');
    begin       = Xml.get(node: xml, tag: 'begin');
    end         = Xml.get(node: xml, tag: 'end');
    align       = Xml.get(node: xml, tag: 'align');
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Widget getTransitionView(Widget child, AnimationController controller) {
    return ScaleTransitionView(this, child, controller);
  }


  Curve getCurve(){
    CurveEnum? transitionCurve = S.toEnum(curve, CurveEnum.values);
    switch (transitionCurve)
    {
      case CurveEnum.linear                 : return Curves.linear;
      case CurveEnum.decelerate             : return Curves.decelerate;
      case CurveEnum.fastLinearToSlowEaseIn : return Curves.fastLinearToSlowEaseIn;
      case CurveEnum.ease                   : return Curves.ease;
      case CurveEnum.easeIn                 : return Curves.easeIn;
      case CurveEnum.easeInToLinear         : return Curves.easeInToLinear;
      case CurveEnum.easeInSine             : return Curves.easeInSine;
      case CurveEnum.easeInQuad             : return Curves.easeInQuad;
      case CurveEnum.easeInCubic            : return Curves.easeInCubic;
      case CurveEnum.easeInQuart            : return Curves.easeInQuart;
      case CurveEnum.easeInQuint            : return Curves.easeInQuint;
      case CurveEnum.easeInExpo             : return Curves.easeInExpo;
      case CurveEnum.easeInCirc             : return Curves.easeInCirc;
      case CurveEnum.easeInBack             : return Curves.easeInBack;
      case CurveEnum.easeOut                : return Curves.easeOut;
      case CurveEnum.linearToEaseOut        : return Curves.linearToEaseOut;
      case CurveEnum.easeOutSine            : return Curves.easeOutSine;
      case CurveEnum.easeOutQuad            : return Curves.easeOutQuad;
      case CurveEnum.easeOutCubic           : return Curves.easeOutCubic;
      case CurveEnum.easeOutQuart           : return Curves.easeOutQuart;
      case CurveEnum.easeOutQuint           : return Curves.easeOutQuint;
      case CurveEnum.easeOutCirc            : return Curves.easeOutCirc;
      case CurveEnum.easeOutBack            : return Curves.easeOutBack;
      case CurveEnum.easeInOut              : return Curves.easeInOut;
      case CurveEnum.easeInOutSine          : return Curves.easeInOutSine;
      case CurveEnum.easeInOutQuad          : return Curves.easeInOutQuad;
      case CurveEnum.easeInOutCubic         : return Curves.easeInOutCubic;
      case CurveEnum.easeInOutQuart         : return Curves.easeInOutQuart;
      case CurveEnum.easeInOutQuint         : return Curves.easeInOutQuint;
      case CurveEnum.easeInOutExpo          : return Curves.easeInOutExpo;
      case CurveEnum.easeInOutCirc          : return Curves.easeInOutCirc;
      case CurveEnum.easeInOutBack          : return Curves.easeInOutBack;
      case CurveEnum.fastOutSlowIn          : return Curves.fastOutSlowIn;
      case CurveEnum.slowMiddle             : return Curves.slowMiddle;
      case CurveEnum.bounceIn               : return Curves.bounceIn;
      case CurveEnum.bounceOut              : return Curves.bounceOut;
      case CurveEnum.bounceInOut            : return Curves.bounceInOut;
      case CurveEnum.elasticIn              : return Curves.elasticIn;
      case CurveEnum.elasticOut             : return Curves.elasticOut;
      case CurveEnum.elasticInOut           : return Curves.elasticInOut;
      default                               : return Curves.linear;
    }
  }

}