// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import '../scope.dart';
import '../observable.dart' ;

class StringObservable extends Observable
{
  StringObservable(String? name, dynamic value, {Scope? scope, OnChangeCallback? listener, Getter? getter, Setter? setter, Formatter? formatter, bool lazyEval = false})
      : super(name, value, scope: scope, listener: listener, getter: getter, setter: setter, formatter: formatter, lazyEvaluation: lazyEval);

  @override
  String? get()
  {
    dynamic value = super.get();
    return (value is String) ? value : null;
  }

  @override
  dynamic to(dynamic value)
  {
    try
    {
      if (value == null)   return null;
      if (value is String) return value;
      return value.toString();
    }
    catch(e)
    {
      return e;
    }
  }
}