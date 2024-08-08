// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import '../observable.dart';

class BooleanObservable extends Observable {
  BooleanObservable(super.name, super.value, {
    super.scope,
    super.listener,
    super.getter,
    super.setter,
    super.readonly});

  @override
  bool? get() {
    dynamic value = super.get();
    return (value is bool) ? value : null;
  }

  @override
  dynamic to(dynamic value) {
    try {
      if (value == null) return null;
      if (value is bool) return value;

      var b = value.toString();
      b = b.trim().toLowerCase();
      if ((b == 'false') || (b == '0') || (b == 'no')) return false;
      if ((b == 'true') || (b == '1') || (b == 'yes')) return true;
      if (b == '') return null;
      return Exception();
    } catch (e) {
      return e;
    }
  }
}
