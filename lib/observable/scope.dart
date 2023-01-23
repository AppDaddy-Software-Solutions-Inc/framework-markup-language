// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/observable.dart';
import 'package:fml/observable/observables/string.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/datasources/file/file.dart' as FILE;
import 'package:uuid/uuid.dart';
import 'package:fml/helper/common_helpers.dart';

import 'binding.dart';

class ScopeManager
{
  static final ScopeManager _singleton = ScopeManager._init();

  HashMap<String?, List<Scope>>  directory  = HashMap<String?,List<Scope>>();
  HashMap<String?, List<Observable>>? unresolved;

  factory ScopeManager()
  {
    return _singleton;
  }
  ScopeManager._init();

  add(Scope scope)
  {
    if (!directory.containsKey(scope.id)) directory[scope.id] = [];
    if (!directory[scope.id]!.contains(scope)) directory[scope.id]!.add(scope);
  }

  remove(Scope scope)
  {
    if ((directory.containsKey(scope.id)) && (directory[scope.id]!.contains(scope))) directory[scope.id]!.remove(scope);
    if (unresolved != null)
    {
      unresolved!.removeWhere((scopeId, observable) => scopeId == scope.id);
      if (unresolved!.isEmpty) unresolved = null;
    }
  }

  Scope? of(String? id)
  {
    if (id == null) return null;
    if (directory.containsKey(id)) return directory[id]!.last;
    return null;
  }

  register(Observable observable)
  {
    if ((S.isNullOrEmpty(observable.key)) || (observable.scope == null)) return null;

    ////////////
    /* Notify */
    ////////////
    _notifyDescendants(observable.scope!, observable);

    ////////////////////////////
    /* Unresolved Named Scope */
    ////////////////////////////
    if (unresolved != null) _notifyUnresolved(observable.scope!.id);
  }

  void _notifyUnresolved(String? scopeId)
  {
    if (unresolved!.containsKey(scopeId))
    {
      List<Observable> targets = [];
      unresolved![scopeId]!.forEach((observable) => targets.add(observable));
      unresolved!.remove(scopeId);
      targets.forEach((observable) => observable.scope!.bind(observable));
    }
  }

  void _notifyDescendants(Scope scope, Observable observable)
  {
    /////////////
    /* Resolve */
    /////////////
    if (scope.unresolved.containsKey(observable.key))
    {
      List<Observable> unresolved = scope.unresolved[observable.key]!.toList(growable: false);
      unresolved.forEach((target) => scope.bind(target));
    }

    //////////////////////
    /* Resolve Children */
    //////////////////////
    if (scope.children != null)
      scope.children!.forEach((scope) => _notifyDescendants(scope, observable));
  }

  Observable? named(Observable? target, String? scopeId, String? observableKey)
  {
    ////////////////
    /* Find Scope */
    ////////////////
    Scope? scope = directory.containsKey(scopeId) ? directory[scopeId]!.last : null;

    //////////////////////////////
    /* Find Observable in Scope */
    //////////////////////////////
    Observable? observable;
    if (scope != null) observable = scope.observables.containsKey(observableKey) ? scope.observables[observableKey] : null;

    ///////////////
    /* Not Found */
    ///////////////
    if ((observable == null) && (target != null) && (target.scope != null))
    {
      ///////////////////////////
      /* Create New Unresolved */
      ///////////////////////////
      if (unresolved == null) unresolved = HashMap<String?, List<Observable>>();

      /////////////////////////////////
      /* Create New Unresolved Scope */
      /////////////////////////////////
      if (!unresolved!.containsKey(scopeId)) unresolved![scopeId] = [];

      ////////////////////////////////////////
      /* Create New Unresolved Scope Target */
      ////////////////////////////////////////
      if (!unresolved![scopeId]!.contains(target)) unresolved![scopeId]!.add(target);
    }

    return observable;
  }

  Observable? scoped(Scope? scope, String? key)
  {
    if ((scope == null) || (S.isNullOrEmpty(key))) return null;
    if (scope.observables.containsKey(key)) return scope.observables[key];
    return scoped(scope.parent, key);
  }
}

class Scope
{
  Scope? parent;
  List<Scope>? children;
  LinkedHashMap<String, IDataSource> datasources  = LinkedHashMap<String, IDataSource>();
  LinkedHashMap<String?, WidgetModel> models  = LinkedHashMap<String?, WidgetModel>();
  final Map<String, FILE.File> files = Map<String, FILE.File>();
  HashMap<String?,Observable> observables = HashMap<String?,Observable>();
  HashMap<String?,List<Observable>> unresolved = HashMap<String?,List<Observable>>();

  String? _id;
  set id (String? v)
  {
    if (_id == null)
    {
      _id = S.isNullOrEmpty(v) ? Uuid().v4() : v;
    }
  }
  String? get id
  {
    return _id;
  }

  Scope(String? id)
  {
    this.id = id;
    ScopeManager().add(this);
  }

  static Scope? of(WidgetModel? model)
  {
    if (model == null) return null;
    if (model.scope != null) return model.scope!;
    return Scope.of(model.parent);
  }

  bool register(Observable observable)
  {
    /////////////////////////
    /* Register Observable */
    /////////////////////////
    if (!_register(observable)) return false;

    //////////////////////
    /* Resolve Bindings */
    //////////////////////
    bind(observable);

    //////////////
    /* Register */
    //////////////
    ScopeManager().register(observable);

    return true;
  }

  bool _register(Observable observable)
  {
    if (observable.key != null)
    {
      ///////////////////////
      /* Replace Listeners */
      ///////////////////////
      if (observables.containsKey(observable.key))
      {
        Observable? oldobservable = observables[observable.key];
        if ((oldobservable != null) && (oldobservable != observable) && (observable.listeners != null))
        {
          Log().debug("Duplicate observable ${observable.key} found in scope");
          oldobservable.listeners!.forEach((callback) => observable.registerListener(callback));
          oldobservable.listeners!.clear();
        }
      }

      ///////////////////////
      /* Record Observable */
      ///////////////////////
      observables[observable.key] = observable;
    }
    return true;
  }

  void registerModel(WidgetModel model)
  {
    models[model.id] = model;
  }

  WidgetModel? getModel(String id)
  {
    if (models.containsKey(id)) return models[id];
    if (this.parent != null) return this.parent!.getModel(id);
    return null;
  }

  bool bind(Observable target)
  {
    /////////////////
    /* Bind Target */
    /////////////////
    if ((target.bindings != null))
    {
      bool resolved = true;

      //////////////////////////
      /* Process Each Binding */
      //////////////////////////
      target.bindings!.forEach((binding)
      {
        String? key = binding.key;

        //////////////////////
        /* Find Bind Source */
        //////////////////////
        Observable? source;
        if (binding.scope != null)
             source = ScopeManager().named(target, binding.scope, binding.key);
        else source = ScopeManager().scoped(this, binding.key);

        //////////////
        /* Resolved */
        //////////////
        if (source != null)
        {
          ////////////////////////////
          /* Remove from Unresolved */
          ////////////////////////////
          if ((unresolved.containsKey(key)) && (unresolved[key]!.contains(target)))
          {
            unresolved[key]!.remove(target);
            if (unresolved[key]!.isEmpty) unresolved.remove(key);
          }

          ///////////////////////
          /* Register Listener */
          ///////////////////////
          source.registerListener(target.onObservableChange);

          /////////////////////
          /* Register Source */
          /////////////////////
          target.registerSource(source);

          ///////////////////////
          /* Two Way Listener? */
          ///////////////////////
          if (target.twoway == true)
          {
            ///////////////////////
            /* Register Listener */
            ///////////////////////
            target.registerListener(source.onObservableChange);

            /////////////////////
            /* Register Source */
            /////////////////////
            source.registerSource(target);

            target.twoway = source;
          }
        }

        ////////////////
        /* Unresolved */
        ////////////////
        else
        {
          resolved = false;

          ///////////////////////
          /* Add to Unresolved */
          ///////////////////////
          if (!unresolved.containsKey(key)) unresolved[key] = [];
          if (!unresolved[key]!.contains(target)) unresolved[key]!.add(target);
        }
      });

      ////////////////////////
      /* Trigger Observable */
      ////////////////////////
      if (resolved == true) target.onObservableChange(null);
    }

    return true;
  }

  void dispose()
  {
    Log().debug('dispose called on => <$runtimeType id="$id">');

    // dispose of data sources
    final list = datasources.values.toList();
    list.forEach((source) => source.dispose());
    datasources.clear();

    // clear models
    models.clear();

    /////////////
    /* Cleanup */
    /////////////
    observables.forEach((key, observable) => observable.dispose());

    ///////////////////////
    /* Clear Observables */
    ///////////////////////
    observables.clear();

    ///////////////////////
    /* Clear Unresolved */
    //////////////////////
    unresolved.clear();

    ////////////////////
    /* Clear Children */
    ////////////////////
    if (children != null) children!.clear();

    //////////////////
    /* Clear Parent */
    //////////////////
    if (parent != null) parent!.remove(child: this);

    ///////////////////////////////////
    /* Unregister with Scope Manager */
    ///////////////////////////////////
    ScopeManager().remove(this);
  }

  void add({Scope? child})
  {
    if (child == null) return;
    if (children == null) children = [];
    if (!children!.contains(child)) children!.add(child);
  }

  void remove({Scope? child})
  {
    if (child == null) return;
    if ((children != null) && (children!.contains(child)))
    {
      children!.remove(child);
      if (children!.isEmpty) children = null;
    }
  }

  void setObservable(String? key, dynamic value)
  {
    Binding? binding = Binding.fromString(key);

    if(binding == null) return;
    /////////////////////
    /* Find Observable */
    /////////////////////
    Observable? observable = getObservable(binding);

    ///////////////
    /* Set Value */
    ///////////////
    if (value is String && Observable.isEvalSignature(value))
    {
      value = Observable.getEvalSignature(value);
      value = Observable.doEvaluation(value);
    }

    // Create the Observable
    if (observable == null)
    {
      Scope? scope = this;
      if (binding.scope != null) scope = ScopeManager().of(binding.scope);
      if (scope != null)
      {
        var observable = StringObservable(binding.key, value, scope: this);
        scope.register(observable);
      }
    }

    // Set the Value
    else observable.set(value);
  }

  Observable? getObservable(Binding binding, {Observable? requestor})
  {
    if (binding.scope == null)
    {
      return ScopeManager().scoped(this, binding.key);
    }
    else return ScopeManager().named(requestor, binding.scope, binding.key);
  }

  Future<String?> replaceFileReferences(String? body) async
  {
    if (S.isNullOrEmpty(body) || (files.isEmpty)) return body;
    for (String key in files.keys)
    {
      var file = files[key];
      if (file != null && body!.contains(key))
      {
        if (file.uri == null) await file.read();
        body = body.replaceAll(key, (file.uri ?? ''));
      }
    }
    return body;
  }

  void registerDataSource(IDataSource source)
  {
    datasources[source.id] = source;
  }

  void removeDataSource(IDataSource source)
  {
    if (datasources.containsKey(source.id)) datasources.remove(source.id);
  }

  IDataSource? getDataSource(String? id)
  {
    if (id == null) return null;

    // datasource exists in this scope
    if (datasources.containsKey(id)) return datasources[id];

    // walk up the scope tree
    if (this.parent != null) return parent!.getDataSource(id);

    // not found
    return null;
  }
}