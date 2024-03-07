// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/datasources/file/file.dart';
import 'package:fml/helpers/helpers.dart';

class Scope
{
  // scope id
  late String id;

  // parent scope
  Scope? parent;

  // child scopes
  List<Scope>? children;

  // list of datasources
  // in this scope
  LinkedHashMap<String, IDataSource> datasources  = LinkedHashMap<String, IDataSource>();

  // list of widget models in this scope
  LinkedHashMap<String, WidgetModel> models  = LinkedHashMap<String, WidgetModel>();

  // file links
  final Map<String, File> files = <String, File>{};

  // list of observables
  HashMap<String?,Observable> observables = HashMap<String?,Observable>();

  // unresolved observables
  HashMap<String?,List<Observable>> unresolved = HashMap<String?,List<Observable>>();

  Scope({this.parent, String? id})
  {
    this.id = id ?? newId();

    // add me as a child of my parent
    parent?.addChild(this);

    // add me to my applications scope manager
    System.app?.scopeManager.add(this);
  }

  static Scope? of(WidgetModel? model)
  {
    if (model == null) return null;
    if (model.scope != null) return model.scope!;
    return Scope.of(model.parent);
  }

  bool register(Observable observable)
  {
    // Register Observable
    if (!_register(observable)) return false;

    // Resolve Bindings
    bind(observable);

    // Register
    System.app?.scopeManager.register(observable);

    return true;
  }

  bool _register(Observable observable)
  {
    if (observable.key != null)
    {
      // Replace Listeners
      if (observables.containsKey(observable.key))
      {
        Observable? oldobservable = observables[observable.key];
        if ((oldobservable != null) && (oldobservable != observable) && (observable.listeners != null))
        {
          Log().debug("Duplicate observable ${observable.key} found in scope");
          for (var callback in oldobservable.listeners!) {
            observable.registerListener(callback);
          }
          oldobservable.listeners!.clear();
        }
      }

      // Record Observable
      observables[observable.key] = observable;
    }
    return true;
  }

  void registerModel(WidgetModel model)
  {
    models[model.id] = model;
  }

  void unregisterModel(WidgetModel model)
  {
    models.remove(model.id);
    var observables = this.observables.values.where((observable) => observable.key != null && observable.key!.startsWith("${model.id.toLowerCase()}.")).toList();
    for (Observable observable in observables)
    {
      observable.listeners?.clear();
      this.observables.remove(observable.key);
    }
  }

  WidgetModel? _findWidgetModel(String id)
  {
    if (models.containsKey(id)) return models[id];
    if (parent != null) return parent!._findWidgetModel(id);
    return null;
  }

  static WidgetModel? findWidgetModel(String? id, Scope? scope)
  {
    if (id == null) return null;

    // named scope reference?
    if (id.contains("."))
    {
      var parts = id.split(".");
      var myScope = System.app?.scopeManager.of(parts.first.trim());
      if (myScope != null)
      {
        scope = myScope;
        parts.removeAt(0);
      }
      id = parts.first;
    }

    // get the model
    return scope?._findWidgetModel(id);
  }

  bool bind(Observable target)
  {
    // Bind Target
    if ((target.bindings != null))
    {
      bool resolved = true;

      // Process Each Binding
      for (var binding in target.bindings!) {
        String? key = binding.key;

        // Find Bind Source
        Observable? source;
        if (binding.scope != null)
        {
          source = System.app?.scopeManager.findObservableInScope(target, binding.scope, binding.key);
        }
        else
        {
          source = System.app?.scopeManager.findObservable(this, binding.key);
        }

        // resolved
        if (source != null)
        {
          // Remove from Unresolved
          if ((unresolved.containsKey(key)) && (unresolved[key]!.contains(target)))
          {
            unresolved[key]!.remove(target);
            if (unresolved[key]!.isEmpty) unresolved.remove(key);
          }

          // Register Listener
          source.registerListener(target.onObservableChange);

          // Register Source
          target.registerSource(source);

          // Two Way Listener?
          if (target.twoway == true)
          {
            // Register Listener
            target.registerListener(source.onObservableChange);

            // Register Source
            source.registerSource(target);

            target.twoway = source;
          }
        }

        // Unresolved
        else
        {
          resolved = false;

          // Add to Unresolved
          if (!unresolved.containsKey(key)) unresolved[key] = [];
          if (!unresolved[key]!.contains(target)) unresolved[key]!.add(target);
        }
      }

      // Trigger Observable
      if (resolved == true) target.onObservableChange(null);
    }

    return true;
  }

  void dispose()
  {
    // dispose of data sources
    final list = datasources.values.toList();
    for (var source in list) {
      source.dispose();
    }
    datasources.clear();

    // clear models
    models.clear();

    // Cleanup
    observables.forEach((key, observable) => observable.dispose());

    // Clear Observables
    observables.clear();

    // Clear Unresolved
    unresolved.clear();

    // Clear Children
    children?.clear();

    // Clear Parent
    parent?.removeChild(this);

    // Unregister with Scope Manager
    System.app?.scopeManager.remove(this);
  }

  void addChild(Scope child)
  {
    children ??= [];
    if (!children!.contains(child)) children!.add(child);
  }

  void removeChild(Scope child)
  {
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

    // Find Observable
    Observable? observable = getObservable(binding);

    // Set Value
    if (value is String && Observable.isEvalSignature(value))
    {
      value = Observable.getEvalSignature(value);
      value = Observable.doEvaluation(value);
    }

    // Create the Observable
    if (observable == null)
    {
      Scope? scope = this;
      if (binding.scope != null) scope = System.app?.scopeManager.of(binding.scope);
      if (scope != null)
      {
        var observable = StringObservable(binding.key, value, scope: this);
        scope.register(observable);
      }
    }

    // set the Value
    else
    {
      // observable is a data element
      if (observable is ListObservable && observable.isNotEmpty && binding.dotnotation != null)
      {
        // get the data
        var data = observable.first;
        if (binding.offset != null && binding.offset! > 0 && binding.offset! < observable.length) data = observable[binding.offset!];

        // write to the data list
        Data.write(data,binding.dotnotation.toString().replaceFirst(".", ""),value);
        return;
      }

      // set value
      observable.set(value);
    }
  }

  Observable? getObservable(Binding binding, {Observable? requestor})
  {
    // look up the scope tree
    if (binding.scope == null) return System.app?.scopeManager.findObservable(this, binding.key);

    // named scope
    return System.app?.scopeManager.findObservableInScope(requestor, binding.scope, binding.key);
  }

  Future<String?> replaceFileReferences(String? body) async
  {
    if (isNullOrEmpty(body) || (files.isEmpty)) return body;
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
    if (parent != null) return parent!.getDataSource(id);

    // not found
    return null;
  }
}