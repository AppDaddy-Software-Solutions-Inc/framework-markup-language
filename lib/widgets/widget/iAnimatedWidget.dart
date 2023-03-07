// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
abstract class IAnimatedWidget
{
  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments);
  getTransitionView(Widget child, {AnimationController? controller});
}