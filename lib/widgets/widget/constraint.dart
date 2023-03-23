import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observable.dart';
import 'package:fml/observable/observables/double.dart';
import 'package:fml/observable/scope.dart';

abstract class IConstraint
{
  double? get minWidth;
  double? get maxWidth;
  double? get minHeight;
  double? get maxHeight;
}

class Constraint implements IConstraint
{
  double? minWidth;
  double? maxWidth;
  double? minHeight;
  double? maxHeight;
}

class ObservableConstraint implements IConstraint
{
  String? id;
  Scope? scope;
  OnChangeCallback? listener;

  ObservableConstraint(this.id, this.scope, this.listener);

  DoubleObservable? _minWidth;
  set minWidth(dynamic v)
  {
    if (_minWidth != null)
    {
      _minWidth!.set(v);
    }
    else if (v != null)
    {
      _minWidth = DoubleObservable(Binding.toKey(id, 'minwidth'), v, scope: scope, listener: listener);
    }
  }
  double? get minWidth => _minWidth?.get();

  DoubleObservable? _maxWidth;
  set maxWidth(dynamic v)
  {
    if (_maxWidth != null)
    {
      _maxWidth!.set(v);
    }
    else if (v != null)
    {
      _maxWidth = DoubleObservable(Binding.toKey(id, 'maxwidth'), v, scope: scope, listener: listener);
    }
  }
  double? get maxWidth => _maxWidth?.get();

  DoubleObservable? _minHeight;
  set minHeight(dynamic v)
  {
    if (_minHeight != null)
    {
      _minHeight!.set(v);
    }
    else if (v != null)
    {
      _minHeight = DoubleObservable(Binding.toKey(id, 'minheight'), v, scope: scope, listener: listener);
    }
  }
  double? get minHeight => _minHeight?.get();

  DoubleObservable? _maxHeight;
  set maxHeight(dynamic v)
  {
    if (_maxHeight != null)
    {
      _maxHeight!.set(v);
    }
    else if (v != null)
    {
      _maxHeight = DoubleObservable(Binding.toKey(id, 'maxheight'), v, scope: scope, listener: listener);
    }
  }
  double? get maxHeight => _maxHeight?.get();
}