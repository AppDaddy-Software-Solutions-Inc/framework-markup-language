// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'package:fml/observable/observable.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/widgets/widget/model.dart';

class ScopeManager {
  final directory = HashMap<String, List<Scope>>();
  HashMap<String?, List<Observable>>? unresolved;

  ScopeManager();

  add(Scope scope, {String? alias}) {
    var id = scope.id;
    if (alias != null) id = alias;

    if (!directory.containsKey(id)) directory[id] = [];
    if (!directory[id]!.contains(scope)) directory[id]!.add(scope);
  }

  remove(Scope scope) {
    if ((directory.containsKey(scope.id)) &&
        (directory[scope.id]!.contains(scope))) {
      directory[scope.id]!.remove(scope);
    }
    if (unresolved != null) {
      unresolved!.removeWhere((scopeId, observable) => scopeId == scope.id);
      if (unresolved!.isEmpty) unresolved = null;
    }
  }

  Scope? find(String? id, Model? model) {

    if (id == null) return null;
    if (!directory.containsKey(id)) return null;
    if (directory.isEmpty) return null;
    if (directory.length == 1) return directory[id]!.first;
    if (model == null) return directory[id]!.last;

    // find names scope containing
    for (var scope in directory[id]!) {

      // get highest level scope
      Scope root = scope;
      while (root.parent != null) {
        root = root.parent!;
      }

      // find child scope
      if (root.encapsulates(model)) {
        return scope;
      }
    }

    return directory[id]!.last;
  }

  register(Observable observable) {

    if (isNullOrEmpty(observable.key) || observable.scope == null) {
      return null;
    }

    // Notify
    _notifyDescendants(observable.scope!, observable);

    // Unresolved Named Scope
    if (unresolved != null) _notifyUnresolved(observable.scope!.id);
  }

  void _notifyUnresolved(String? scopeId) {
    if (unresolved!.containsKey(scopeId)) {
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

  void _notifyDescendants(Scope scope, Observable observable) {
    // Resolve
    if (scope.unresolved.containsKey(observable.key)) {
      List<Observable> unresolved =
          scope.unresolved[observable.key]!.toList(growable: false);
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

  Observable? findObservableInScope(
      Observable? target, String? scopeId, String? observableKey) {
    // Find Scope
    Scope? scope =
        directory.containsKey(scopeId) ? directory[scopeId]!.last : null;

    // Find Observable in Scope
    Observable? observable;
    if (scope != null) {
      observable = scope.observables.containsKey(observableKey)
          ? scope.observables[observableKey]
          : null;
    }

    // Not Found
    if ((observable == null) && (target != null) && (target.scope != null)) {
      // Create New Unresolved
      unresolved ??= HashMap<String?, List<Observable>>();

      // Create New Unresolved Scope
      if (!unresolved!.containsKey(scopeId)) unresolved![scopeId] = [];

      // Create New Unresolved Scope Target
      if (!unresolved![scopeId]!.contains(target)) {
        unresolved![scopeId]!.add(target);
      }
    }

    return observable;
  }

  Observable? findObservable(Scope? scope, String? key) {
    if ((scope == null) || (isNullOrEmpty(key))) return null;
    if (scope.observables.containsKey(key)) return scope.observables[key];
    return findObservable(scope.parent, key);
  }

  bool hasScope(String? id) {
    if (id == null) return false;
    return directory.containsKey(id);
  }
}
