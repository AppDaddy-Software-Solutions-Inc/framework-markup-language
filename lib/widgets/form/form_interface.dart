import 'package:fml/observable/observables/boolean.dart';

abstract class IForm {
  // Dirty
  bool? get dirty;
  set dirty(bool? b);
  BooleanObservable? get dirtyObservable;

  // Clean
  set clean(bool b);

  // Default Post
  bool? get post;

  // Routines
  Future<bool> save();
  Future<bool> complete();
  Future<bool> validate();
}
