// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/graphics.dart';
import 'package:flutter/material.dart';

import '../scope.dart';
import '../observable.dart' ;

class IconObservable extends Observable
{
  IconObservable(String? name, dynamic value, {Scope? scope, OnChangeCallback? listener, Getter? getter, Setter? setter}) : super(name, value, scope: scope, listener: listener, getter: getter, setter: setter);

  @override
  IconData? get({String? dotnotation})
  {
    dynamic value = super.get();
    return (value is IconData) ? value : null;
  }

  @override
  dynamic to(dynamic s)
  {
    try
    {
      if (s == null)      return null;
      if (s is IconData)  return s;
      if (s is String)    return toIcon(s);
      return Exception();
    }
    catch(e)
    {
      return e;
    }
  }

  static IconData? toIcon(String name)
  {
    name = name.toLowerCase();
    if (Graphics.icons.containsKey(name)) return Graphics.icons[name];
    return null;
  }
}