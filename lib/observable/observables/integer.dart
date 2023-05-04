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
  dynamic to(dynamic s)
  {
    try
    {
      if (s == null)   return null;
      if (s is int)    return s;
      if (s is double) return s.toInt();
      if (s is num)    return s.toInt();
      if (s is String) {
        if (s == '') return null;
        return int.parse(s);
      }
      return Exception();
    }
    catch(e)
    {
      return e;
    }
  }
}