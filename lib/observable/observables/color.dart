// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/observable/observable.dart';
import 'package:fml/observable/scope.dart';

class ColorObservable extends Observable
{
  ColorObservable(String? name, dynamic value, {Scope? scope, OnChangeCallback? listener, Getter? getter, Setter? setter}) : super(name, value, scope: scope, listener: listener, getter: getter, setter: setter);

  @override
  Color? get() => toColor(super.get());

  @override
  dynamic to(dynamic value)
  {
    try
    {
      if (value == null)   return null;
      if (value is Color)  return value;
      if (value is String) return toColor(value);
      return Exception();
    }
    catch(e)
    {
      return e;
    }
  }
}