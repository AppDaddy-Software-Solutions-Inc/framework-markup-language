// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/observable/observable.dart';

class ColorObservable extends Observable {
  ColorObservable(super.name, super.value, {
    super.scope,
    super.listener,
    super.getter,
    super.setter,
    super.readonly});

  @override
  Color? get() => toColor(super.get());

  @override
  dynamic to(dynamic value) {
    try {
      if (value == null) return null;
      if (value is Color) return value;
      if (value is String) return toColor(value);
      return Exception();
    } catch (e) {
      return e;
    }
  }
}
