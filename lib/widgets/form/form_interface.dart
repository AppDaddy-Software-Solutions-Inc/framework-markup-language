import 'package:fml/observable/observables/boolean.dart';

abstract class IForm {
  bool? get dirty;
  set dirty(bool? b);
  BooleanObservable? get dirtyObservable;

  // Default Post
  bool? get post;

  // Routines
  Future<bool> save();
  Future<bool> complete();
  Future<bool> validate();
  bool clean();
  bool clear();
}
