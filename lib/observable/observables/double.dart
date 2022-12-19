// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import '../scope.dart';
import '../observable.dart' ;

class DoubleObservable extends Observable
{
  DoubleObservable(String? name, dynamic value, {Scope? scope, OnChangeCallback? listener, Getter? getter, Setter? setter}) : super(name, value, scope: scope, listener: listener, getter: getter, setter: setter);

  @override
  double? get()
  {
    dynamic value = super.get();
    return (value is double) ? value : null;
  }

  @override
  dynamic to(dynamic s)
  {
    try
    {
      if (s == null)    return null;
      if (s is double)  return s;
      if (s is int)     return s.toDouble();
      if (s is num)     return s.toDouble();
      if (s is String) {
        if (s == '') return null;
        return double.parse(s);
      }
      return Exception();
    }
    catch(e)
    {
      return e;
    }
  }
}