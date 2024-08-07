// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import '../observable.dart';

class StringObservable extends Observable {
  StringObservable(super.name, super.value,
      {super.scope,
      super.listener,
      super.getter,
      super.setter,
      super.formatter,
      super.lazyEvaluation});

  @override
  String? get() {
    dynamic value = super.get();
    return (value is String) ? value : null;
  }

  @override
  dynamic to(dynamic value) {
    try {
      if (value == null) return null;
      if (value is String) return value;
      return value.toString();
    } catch (e) {
      return e;
    }
  }
}
