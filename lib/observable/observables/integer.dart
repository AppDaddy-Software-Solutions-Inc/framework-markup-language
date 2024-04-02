// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import '../observable.dart';

class IntegerObservable extends Observable {
  IntegerObservable(super.name, super.value,
      {super.scope,
      super.listener,
      super.getter,
      super.setter,
      bool? bindable});

  @override
  int? get() {
    dynamic value = super.get();
    return (value is int) ? value : null;
  }

  @override
  dynamic to(dynamic value) {
    try {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is num) return value.toInt();
      if (value is String) {
        if (value == '') return null;
        return int.parse(value);
      }
      return Exception();
    } catch (e) {
      return e;
    }
  }
}
