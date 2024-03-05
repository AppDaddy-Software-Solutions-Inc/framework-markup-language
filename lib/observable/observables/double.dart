// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import '../observable.dart' ;

class DoubleObservable extends Observable
{
  DoubleObservable(super.name, super.value, {super.scope, super.listener, super.getter, super.setter});

  @override
  double? get()
  {
    dynamic value = super.get();
    return (value is double) ? value : null;
  }

  @override
  dynamic to(dynamic value)
  {
    try
    {
      if (value == null)    return null;
      if (value is double)  return value;
      if (value is int)     return value.toDouble();
      if (value is num)     return value.toDouble();
      if (value is String) {
        if (value == '') return null;
        return double.parse(value);
      }
      return Exception();
    }
    catch(e)
    {
      return e;
    }
  }
}