// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import '../binding.dart';
import '../scope.dart';
import '../observable.dart' ;

class ListObservable extends Observable with ListMixin<dynamic>
{
  List<dynamic> _value = [];

  @override
  void operator []=(int index, dynamic value)
  {
    _value[index] = value;
    notifyListeners();
  }

  @override
  dynamic operator [](int index)
  {
    return _value[index];
  }

  @override
  set length(int newLength)
  {
    _value.length = newLength;
  }

  @override
  int get length
  {
    return _value.length;
  }

  @override
  clear()
  {
    super.clear();
    notifyListeners();
  }

  @override
  add(dynamic value)
  {
    _value.add(value);
    notifyListeners();
  }

  @override
  bool remove(dynamic value)
  {
    if (_value.contains(value)) _value.remove(value);
    notifyListeners();
    return true;
  }

  ListObservable(String? name, dynamic value, {Scope? scope, OnChangeCallback? listener, Getter? getter, Setter? setter}) : super(name, value, scope: scope, listener: listener, getter: getter, setter: setter);

  @override
  List? get()
  {
    return (_value.isNotEmpty) ? _value : null;
  }

  @override
  dynamic to(dynamic value)
  {
    if (value is List)
    {
      _value = value;
      return _value;
    }
    else
    {
      _value.clear();
      if (value != null) _value.add(value);
    }
  }

  @override
  set(dynamic value, {bool notify = true})
  {
    // null value
    if (value == null)
    {
      _value.clear();
      if (notify != false) notifyListeners();
      return;
    }

    // map
    if (value is Map)
    {
      _value = [];
      _value.add(value);
      notifyListeners();
      return;
    }

    // list of values
    if (value is List)
    {
      _value = value;
      notifyListeners();
      return;
    }

    // list of values
    if (_value is List<Map>)
    {
      Binding? binding = Binding.fromString(this.key);
      _value.forEach((map) => map[binding?.property] = value.toString());
      notifyListeners();
      return;
    }

    // single value
    if (value is String)
    {
      _value.clear();
      var options = value.split(",");
      for (String v in options) if (v.trim() != '') _value.add(v.trim());
      notifyListeners();
    }
  }
}