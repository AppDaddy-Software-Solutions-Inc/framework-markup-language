// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'package:fml/observable/observable.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/helper/common_helpers.dart';

class ScopeManager
{
  final HashMap<String?, List<Scope>>  _directory  = HashMap<String?,List<Scope>>();
  HashMap<String?, List<Observable>>? unresolved;

  ScopeManager();

  add(Scope scope, {String? alias})
  {
    var id = scope.id;
    if (alias != null) id = alias;
    
    if (!_directory.containsKey(id)) _directory[id] = [];
    if (!_directory[id]!.contains(scope)) _directory[id]!.add(scope);
  }

  remove(Scope scope)
  {
    if ((_directory.containsKey(scope.id)) && (_directory[scope.id]!.contains(scope))) _directory[scope.id]!.remove(scope);
    if (unresolved != null)
    {
      unresolved!.removeWhere((scopeId, observable) => scopeId == scope.id);
      if (unresolved!.isEmpty) unresolved = null;
    }
  }

  Scope? of(String? id)
  {
    if (id == null) return null;
    if (_directory.containsKey(id)) return _directory[id]!.last;
    return null;
  }

  register(Observable observable)
  {
    if ((S.isNullOrEmpty(observable.key)) || (observable.scope == null)) return null;

    // Notify 
    _notifyDescendants(observable.scope!, observable);

    // Unresolved Named Scope 
    if (unresolved != null) _notifyUnresolved(observable.scope!.id);
  }

  void _notifyUnresolved(String? scopeId)
  {
    if (unresolved!.containsKey(scopeId))
    {
      List<Observable> targets = [];
      for (var observable in unresolved![scopeId]!) {
        targets.add(observable);
      }
      unresolved!.remove(scopeId);
      for (var observable in targets) {
        observable.scope!.bind(observable);
      }
    }
  }

  void _notifyDescendants(Scope scope, Observable observable)
  {
    // Resolve 
    if (scope.unresolved.containsKey(observable.key))
    {
      List<Observable> unresolved = scope.unresolved[observable.key]!.toList(growable: false);
      for (var target in unresolved) {
        scope.bind(target);
      }
    }

    // Resolve Children 
    if (scope.children != null) {
      for (var scope in scope.children!) {
        _notifyDescendants(scope, observable);
      }
    }
  }

  Observable? findObservableInScope(Observable? target, String? scopeId, String? observableKey)
  {
    // Find Scope 
    Scope? scope = _directory.containsKey(scopeId) ? _directory[scopeId]!.last : null;

    // Find Observable in Scope 
    Observable? observable;
    if (scope != null) observable = scope.observables.containsKey(observableKey) ? scope.observables[observableKey] : null;

    // Not Found 
    if ((observable == null) && (target != null) && (target.scope != null))
    {
      // Create New Unresolved 
      unresolved ??= HashMap<String?, List<Observable>>();

      // Create New Unresolved Scope 
      if (!unresolved!.containsKey(scopeId)) unresolved![scopeId] = [];

      // Create New Unresolved Scope Target 
      if (!unresolved![scopeId]!.contains(target)) unresolved![scopeId]!.add(target);
    }

    return observable;
  }

  Observable? findObservable(Scope? scope, String? key)
  {
    if ((scope == null) || (S.isNullOrEmpty(key))) return null;
    if (scope.observables.containsKey(key)) return scope.observables[key];
    return findObservable(scope.parent, key);
  }

  bool hasScope(String? id)
  {
    if (id == null) return false;
    return _directory.containsKey(id);
  }
}