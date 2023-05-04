// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import '../scope.dart';
import '../observable.dart' ;

class BooleanObservable extends Observable
{
  BooleanObservable(String? name, dynamic value, {Scope? scope, OnChangeCallback? listener, Getter? getter, Setter? setter}) : super(name, value, scope: scope, listener: listener, getter: getter, setter: setter);

  @override
  bool? get()
  {
    dynamic value = super.get();
    return (value is bool) ? value : null;
  }

  @override
  dynamic to(dynamic value)
  {
    try
    {
      if (value == null) return null;
      if (value is bool) return value;

      var b = value.toString();
      b = b.trim().toLowerCase();
      if ((b == 'false') || (b == '0') || (b == 'no'))  return false;
      if ((b == 'true')  || (b == '1') || (b == 'yes')) return true;
      if (b == '') return null;
      return Exception();
    }
    catch(e)
    {
      return e;
    }
  }
}