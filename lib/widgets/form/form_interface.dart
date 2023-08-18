import 'package:flutter/material.dart';
import 'package:fml/observable/observables/boolean.dart';

abstract class IForm
{
  // Dirty
  bool? get dirty;
  set dirty(bool? b);
  BooleanObservable? get dirtyObservable;

  // Clean
  set clean(bool b);

  // Routines
  Future<bool> save();
  Future<bool> complete();
  Future<bool> onComplete(BuildContext context);
}