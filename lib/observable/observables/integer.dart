// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import '../scope.dart';
import '../observable.dart' ;

class IntegerObservable extends Observable
{
  IntegerObservable(String? name, dynamic value, {Scope? scope, OnChangeCallback? listener, Getter? getter, Setter? setter, bool? bindable}) : super(name, value, scope: scope, listener: listener, getter: getter, setter: setter);

  @override
  int? get()
  {
    dynamic value = super.get();
    return (value is int) ? value : null;
  }

  @override
  dynamic to(dynamic value)
  {
    try
    {
      if (value == null)   return null;
      if (value is int)    return value;
      if (value is double) return value.toInt();
      if (value is num)    return value.toInt();
      if (value is String) {
        if (value == '') return null;
        return int.parse(value);
      }
      return Exception();
    }
    catch(e)
    {
      return e;
    }
  }
}