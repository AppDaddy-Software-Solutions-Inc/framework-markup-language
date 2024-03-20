// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import '../binding.dart';
import '../observable.dart';

class ListObservable extends Observable with ListMixin<dynamic> {
  List<dynamic> _value = [];

  @override
  void operator []=(int index, dynamic value) {
    _value[index] = value;
    notifyListeners();
  }

  @override
  dynamic operator [](int index) {
    return _value[index];
  }

  @override
  set length(int newLength) {
    _value.length = newLength;
  }

  @override
  int get length {
    return _value.length;
  }

  @override
  clear() {
    super.clear();
    notifyListeners();
  }

  @override
  add(dynamic element) {
    _value.add(element);
    notifyListeners();
  }

  @override
  bool remove(dynamic element) {
    if (_value.contains(element)) _value.remove(element);
    notifyListeners();
    return true;
  }

  ListObservable(super.name, super.value,
      {super.scope, super.listener, super.getter, super.setter});

  @override
  List get() => _value;

  @override
  dynamic to(dynamic value) {
    if (value is List) {
      _value = value;
      return _value;
    } else {
      _value = [];
      if (value != null) _value.add(value);
    }
  }

  @override
  set(dynamic value, {bool notify = true, Observable? setter}) {
    if (this.setter != null) {
      value = this.setter!(value, setter: setter);
    }

    // null value
    if (value == null) {
      _value.clear();
      if (notify != false) notifyListeners();
      return;
    }

    // map
    if (value is Map) {
      _value = [];
      _value.add(value);
      if (notify != false) notifyListeners();
      return;
    }

    // list of values
    if (value is List) {
      _value = value;
      if (notify != false) notifyListeners();
      return;
    }

    // list of values
    if (_value is List<Map>) {
      Binding? binding = Binding.fromString(key);
      for (var map in _value) {
        map[binding?.property] = value.toString();
      }
      if (notify != false) notifyListeners();
      return;
    }

    // single value
    if (value is String) {
      _value.clear();
      var options = value.split(",");
      for (String v in options) {
        if (v.trim() != '') _value.add(v.trim());
      }
      if (notify != false) notifyListeners();
    }
  }
}
