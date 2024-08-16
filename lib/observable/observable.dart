// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:fml/observable/observables/string.dart';
import 'binding.dart';
import 'scope.dart';
import 'package:fml/eval/eval.dart';
import 'package:fml/helpers/helpers.dart';

typedef Getter = dynamic Function();
typedef Setter = dynamic Function(dynamic value, {Observable? setter});
typedef Formatter = dynamic Function(dynamic value);
typedef OnChangeCallback = void Function(Observable value);
typedef OnGetVariables = Map<String, dynamic> Function();

class ObservableDefault {
  dynamic value;
  dynamic defaultValue;
}

class Observable {
  final Scope? scope;

  Getter? getter;
  Setter? setter;
  Formatter? formatter;

  final String? key;
  String? signature;

  final bool lazyEvaluation;
  final bool readonly;

  List<Binding>? bindings;
  List<OnChangeCallback>? listeners;
  List<Observable>? sources;

  bool _isEval = false;
  bool get isEval => _isEval && lazyEvaluation == false;
  set isEval(bool value) {
    _isEval = value;
  }

  dynamic twoway;

  dynamic _defaultValue;
  dynamic get defaultValue {
    return to(_defaultValue);
  }

  dynamic _value;
  dynamic get value => to(_value);

  /// Observable set function
  set(dynamic value, {bool notify = true, Observable? setter}) {

    // if a customer setter is declared, use it
    if (this.setter != null) {
      value = this.setter!(value, setter: setter);
    }

    // convert the value to the specified type
    value = to(value);

    // quit on exception of to()
    if (value is Exception) return;

    // for readonly variables, we only set the value once
    if (readonly && _value != null) return;

    // if value has changed, set it and notify of changes
    if (value != _value) {

      // set the value
      _value = value;

      // notify listeners
      if (notify != false) notifyListeners();
    }
  }

  /// Observable get function
  dynamic get() {

    // custom getter function defined?
    if (getter != null) return getter!();

    // return value
    return _value;
  }

  Observable(this.key, dynamic value,
      {this.scope,
      OnChangeCallback? listener,
      this.getter,
      this.setter,
      this.formatter,
      this.readonly = false,
      this.lazyEvaluation = false}) {

    if (value is String) {

      // get bindings?
      bindings = Binding.getBindings(value, scope: scope);

      if (bindings != null) {

        // replace the "this" and "parent" operators
        value = replaceReferences(this, scope, value);

        // save the signature
        signature = value;
      }

      // eval?
      isEval = isEvalSignature(value);
      if (_isEval == true) {
        value = getEvalSignature(value);
        signature = value;
      }

      // 2-way
      String t = '@{';
      if ((bindings != null) &&
          (bindings!.length == 1) &&
          (value.trim().toLowerCase().startsWith(t)) &&
          (value.trim().toLowerCase().endsWith('}'))) {
        twoway = true;
        value = (value as String).substring(1);
        signature = value;
      }
    }

    // set the value
    if (bindings == null) set(value, notify: false);

    // perform evaluation
    if (isEval || bindings != null) onObservableChange(null);

    // add listener
    if (listener != null) registerListener(listener);

    // register the observable in the scope
    if (scope != null) scope!.register(this);

    // notify any listeners
    notifyListeners();
  }

  static String replaceReferences(
      Observable observable, Scope? scope, String value) {
    if (scope == null || observable.key == null || observable.bindings == null) {
      return value;
    }

    bool requery = false;
    for (Binding binding in observable.bindings!) {
      // replace "this" with the id in the signature
      if (binding.source == "this" || binding.source == "parent") {
        requery = true;

        // get source id
        String sourceId = observable.key!.split(".").first;
        if (binding.source == "parent") sourceId = parentId(scope, sourceId);
        if (binding.property == "parent") {
          sourceId = parentId(scope, sourceId);
          for (var segment in binding.dotnotation ?? []) {
            if (segment.name != "parent") break;
            sourceId = parentId(scope, sourceId);
          }
        }

        // build signature
        var signature = sourceId;
        if (binding.property != "parent") {
          signature = "$sourceId.${binding.property}";
        }
        if (binding.dotnotation != null) {
          int i = 0;

          // skip parent dotnotation
          while (i < binding.dotnotation!.length &&
              binding.dotnotation![i].name == "parent") {
            i++;
          }

          // append non-parent dotnotation
          while (i < binding.dotnotation!.length) {
            signature = "$signature.${binding.dotnotation![i++].name}";
          }
        }

        // replace signature
        value = value.replaceAll(binding.signature, "{$signature}");
      }
    }

    // requery the bindings
    if (requery) observable.bindings = Binding.getBindings(value, scope: scope);

    return value;
  }

  static String parentId(Scope scope, String id) {
    if (!scope.models.containsKey(id)) return id;
    return scope.models[id]!.parent?.id ?? id;
  }

  notifyListeners() {
    if (listeners == null) return;
    for (OnChangeCallback callback in listeners!) {
      callback(this);
    }
  }

  registerListener(OnChangeCallback callback) {
    listeners ??= [];
    if (!listeners!.contains(callback)) listeners!.add(callback);
  }

  removeListener(OnChangeCallback callback) {
    if (listeners != null) {
      if (listeners!.contains(callback)) listeners!.remove(callback);
      if (listeners!.isEmpty) listeners = null;
    }
  }

  registerSource(Observable source) {
    sources ??= [];
    if (!sources!.contains(source)) sources!.add(source);
  }

  removeSource(Observable source) {
    if (sources == null) return;
    if (sources!.contains(source)) sources!.remove(source);
  }

  dispose() {
    // Clear Listeners
    if (listeners != null) {
      listeners!.clear();
      listeners = null;
    }

    // Clear Sources
    if (sources != null) {
      for (var source in sources!) {
        source.removeListener(onObservableChange);
      }
      sources = null;
    }
  }

  dynamic to(dynamic value) {
    return value;
  }

  onObservableChange(Observable? observable) {

    dynamic value = signature;

    bool hasMissingBindings = false;

    // resolve all bindings
    Map<String?, dynamic>? variables;
    if (bindings != null && scope != null) {

      for (Binding binding in bindings!) {

        dynamic replacementValue;

        // get binding source
        Observable? source = scope!.getObservable(binding, requestor: observable);
        if (source != null) {
          replacementValue = binding.translate(source.get());
          if (formatter != null) {
            replacementValue = formatter!(replacementValue);
          }
        }
        else {
          hasMissingBindings = true;
        }

        // is this an eval?
        if (isEval) {
          variables ??= <String?, dynamic>{};
          variables[binding.signature] = replacementValue;
        }

        else if (this is! StringObservable &&
            bindings!.length == 1 &&
            signature != null &&
            signature!.replaceFirst(binding.signature, "").trim().isEmpty) {
          value = replacementValue ?? source?.get();
          break;
        }

        // simple replacement of string values
        else {
          replacementValue = toStr(replacementValue) ?? "";
          value = value!.replaceAll(binding.signature, replacementValue);
        }
      }
    }

    // perform the evaluation
    if (isEval) {
      variables ??= <String?, dynamic>{};
      variables["scope"] = scope;
      value = doEvaluation(signature, variables: variables);
    }

    // 2-way binding?
    if (observable?.twoway == this) {
      set(observable!.value, setter: observable);
    }

    // set the value
    if (!readonly) return set(value);

    // if all bindings are satisfied, clear the eval flag, signature,
    // bindings remove all source listeners
    if (!hasMissingBindings) {

      // clear eval flag
      _isEval = false;

      // clear signature
      signature = null;

      // clear bindings
      bindings?.clear();

      // clear binding sources
      if (sources != null) {
        for (var source in sources!) {
          source.removeListener(onObservableChange);
        }
        sources = null;
      }
      sources?.clear();

      // set the value
      set(value);
    }
  }

  static bool isEvalSignature(String? value) {
    if ((value != null) &&
        (value.trim().toLowerCase().startsWith('eval(')) &&
        (value.trim().toLowerCase().endsWith(')'))) return true;
    if ((value != null) && (value.startsWith('='))) {
      return true;
    } else {
      return false;
    }
  }

  static String? getEvalSignature(String? value) {
    if (isEvalSignature(value)) {
      String f = 'eval(';
      if (value!.trim().toLowerCase().startsWith(f)) {
        int i = value.toLowerCase().indexOf(f) + f.length;
        int j = value.toLowerCase().lastIndexOf(')');
        value = (i < j) ? value.substring(i, j) : null;
        return value;
      }
      f = '=';
      if (value.trim().toLowerCase().startsWith(f)) {
        int i = value.toLowerCase().indexOf(f) + f.length;
        value = value.substring(i);
        return value;
      }
    }
    return null;
  }

  static dynamic doEvaluation(String? expression, {
    Map<String?, dynamic>? variables,
    Scope? scope}) => Eval.evaluate(expression, variables: variables) ?? "";

  Map<String, dynamic> getVariables() {
    Map<String, dynamic> variables = <String, dynamic>{};
    if (bindings != null) {
      for (var binding in bindings!) {
        Observable? source;
        if (sources != null) {
          source = sources!
              .firstWhereOrNull((observable) => observable.key == binding.key);
        }
        variables[binding.signature] = binding.translate(source?.get());
      }
    }
    return variables;
  }
}
