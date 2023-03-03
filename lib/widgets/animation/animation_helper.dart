import 'package:flutter/animation.dart';
import 'package:fml/helper/string.dart';

class AnimationHelper {

  static Curve getCurve(curve){
  CurveEnum? transitionCurve = S.toEnum(curve, CurveEnum.values);
  switch (transitionCurve)
  {
  case CurveEnum.linear : return Curves.linear;
  case CurveEnum.decelerate : return Curves.decelerate;
  case CurveEnum.fastLinearToSlowEaseIn : return Curves.fastLinearToSlowEaseIn;
  case CurveEnum.ease : return Curves.ease;
  case CurveEnum.easeIn : return Curves.easeIn;
  case CurveEnum.easeInToLinear : return Curves.easeInToLinear;
  case CurveEnum.easeInSine : return Curves.easeInSine;
  case CurveEnum.easeInQuad : return Curves.easeInQuad;
  case CurveEnum.easeInCubic : return Curves.easeInCubic;
  case CurveEnum.easeInQuart : return Curves.easeInQuart;
  case CurveEnum.easeInQuint : return Curves.easeInQuint;
  case CurveEnum.easeInExpo : return Curves.easeInExpo;
  case CurveEnum.easeInCirc : return Curves.easeInCirc;
  case CurveEnum.easeInBack : return Curves.easeInBack;
  case CurveEnum.easeOut : return Curves.easeOut;
  case CurveEnum.linearToEaseOut : return Curves.linearToEaseOut;
  case CurveEnum.easeOutSine : return Curves.easeOutSine;
  case CurveEnum.easeOutQuad : return Curves.easeOutQuad;
  case CurveEnum.easeOutCubic : return Curves.easeOutCubic;
  case CurveEnum.easeOutQuart : return Curves.easeOutQuart;
  case CurveEnum.easeOutQuint : return Curves.easeOutQuint;
  case CurveEnum.easeOutCirc : return Curves.easeOutCirc;
  case CurveEnum.easeOutBack : return Curves.easeOutBack;
  case CurveEnum.easeInOut : return Curves.easeInOut;
  case CurveEnum.easeInOutSine : return Curves.easeInOutSine;
  case CurveEnum.easeInOutQuad : return Curves.easeInOutQuad;
  case CurveEnum.easeInOutCubic : return Curves.easeInOutCubic;
  case CurveEnum.easeInOutQuart : return Curves.easeInOutQuart;
  case CurveEnum.easeInOutQuint : return Curves.easeInOutQuint;
  case CurveEnum.easeInOutExpo : return Curves.easeInOutExpo;
  case CurveEnum.easeInOutCirc : return Curves.easeInOutCirc;
  case CurveEnum.easeInOutBack : return Curves.easeInOutBack;
  case CurveEnum.fastOutSlowIn : return Curves.fastOutSlowIn;
  case CurveEnum.slowMiddle : return Curves.slowMiddle;
  case CurveEnum.bounceIn : return Curves.bounceIn;
  case CurveEnum.bounceOut : return Curves.bounceOut;
  case CurveEnum.bounceInOut : return Curves.bounceInOut;
  case CurveEnum.elasticIn : return Curves.elasticIn;
  case CurveEnum.elasticOut : return Curves.elasticOut;
  case CurveEnum.elasticInOut : return Curves.elasticInOut;
  default : return Curves.linear;
  }
  }
}

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