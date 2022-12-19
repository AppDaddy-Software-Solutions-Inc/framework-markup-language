// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import '../scope.dart';
import '../observable.dart' ;

class NumericObservable extends Observable
{
  NumericObservable(String name, dynamic value, {Scope? scope, OnChangeCallback? listener, Getter? getter, Setter? setter}) : super(name, value, scope: scope, listener: listener, getter: getter, setter: setter);

  @override
  num? get()
  {
    dynamic value = super.get();
    return (value is num) ? value : null;
  }

  @override
  dynamic to(dynamic s)
  {
    try
    {
      if (s == null)   return null;
      if (s is num)    return s;
      if (s is String) {
        if (s == '') return null;
        return num.parse(s);
      }
      return Exception();
    }
    catch(e)
    {
      return e;
    }
  }
}