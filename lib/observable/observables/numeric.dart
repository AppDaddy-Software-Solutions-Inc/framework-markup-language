// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import '../observable.dart';

class NumericObservable extends Observable {
  NumericObservable(String super.name, super.value,
      {super.scope, super.listener, super.getter, super.setter});

  @override
  num? get() {
    dynamic value = super.get();
    return (value is num) ? value : null;
  }

  @override
  dynamic to(dynamic value) {
    try {
      if (value == null) return null;
      if (value is num) return value;
      if (value is String) {
        if (value == '') return null;
        return num.parse(value);
      }
      return Exception();
    } catch (e) {
      return e;
    }
  }
}
