// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:fml/log/manager.dart';
import 'binding.dart';
import 'scope.dart';
import 'package:fml/eval/eval.dart'       as fml_eval;
import 'package:fml/observable/blob.dart';
import 'package:fml/helper/common_helpers.dart';

typedef Getter = dynamic Function();
typedef Setter = dynamic Function(dynamic value);
typedef OnChangeCallback = void Function (Observable value);

class ObservableDefault
{
  dynamic value;
  dynamic defaultValue;
}

class Observable
{
  final Scope? scope;

  Getter? getter;
  Setter? setter;

  final String? key;
  String? signature;

  List<Binding>? bindings;
  List<OnChangeCallback>? listeners;
  List<Observable>? sources;

  final bool lazyEvaluation;
  bool _isEval = false;
  bool get isEval => _isEval && lazyEvaluation == false;
  set isEval(bool v)
  {
      _isEval = v;
  }

  dynamic twoway;

  dynamic _defaultValue;
  dynamic get defaultValue
  {
    return to(_defaultValue);
  }

  dynamic _value;
  dynamic get value
  {
    return to(_value);
  }

  set(dynamic v, {bool notify = true})
  {
    if (setter != null)
    {
      v = setter!(v);
    }
    v = to(v);
    if (v is Exception) return;
    if (v != _value)
    {
      _value = v;
      if (notify != false) notifyListeners();
    }
  }

  dynamic get()
  {
    if (getter == null) {
      return _value;
    } else {
      return getter!();
    }
  }

  Observable(this.key, dynamic value, {this.scope, OnChangeCallback? listener, this.getter, this.setter, this.lazyEvaluation = false})
  {
    if (value is String)
    {
      // bindings?
      if (this is! BlobObservable) bindings = Binding.getBindings(value, scope: scope);
      if (bindings != null)
      {
        // replace the "this" operator
        if (value.contains("this") && key != null)
        {
          String id = key!.split(".").first;

          // replace "this" with the id in the signature
          for(Binding binding in bindings!) {
            if (binding.source == "this")
          {
            var signature = binding.signature.replaceFirst("this",id);
            value = (value as String).replaceAll(binding.signature, signature);
          }
          }

          // requery the bindings
          bindings = Binding.getBindings(value, scope: scope);
        }

        // save the signature
        signature = value;
      }

      // eval?
      isEval = isEvalSignature(value);
      if (_isEval == true)
      {
        value = getEvalSignature(value);
        signature = value;
      }

      ///////////
      /* 2-way */
      ///////////
      String t = '@{';
      if ((bindings != null) && (bindings!.length == 1) && (value.trim().toLowerCase().startsWith(t)) && (value.trim().toLowerCase().endsWith('}')))
      {
        twoway = true;
        value = (value as String).substring(1);
        signature = value;
      }
    }

    ///////////////////
    /* Set the Value */
    ///////////////////
    if (bindings == null) _value = to(value);

    ////////////////////////
    /* Perform Evaluation */
    ////////////////////////
    if ((isEval) || bindings != null) onObservableChange(null);

    //////////////////
    /* Add Listener */
    //////////////////
    if (listener != null) registerListener(listener);

    //////////////
    /* Register */
    //////////////
    if (scope != null) scope!.register(this);

    ////////////
    /* Notify */
    ////////////
    notifyListeners();
  }

  notifyListeners()
  {
    if (listeners != null){
    for (OnChangeCallback callback in listeners!)
    {
      callback(this);
    }
  }
  }

  registerListener(OnChangeCallback callback)
  {
    listeners ??= [];
    if (!listeners!.contains(callback)) listeners!.add(callback);
  }

  removeListener(OnChangeCallback callback)
  {
    if (listeners != null)
    {
      if (listeners!.contains(callback)) listeners!.remove(callback);
      if (listeners!.isEmpty) listeners = null;
    }
  }

  registerSource(Observable source)
  {
    sources ??= [];
    if (!sources!.contains(source)) sources!.add(source);
  }

  removeSource(Observable source)
  {
    if (sources == null) return;
    if (sources!.contains(source)) sources!.remove(source);
  }

  dispose()
  {
    // Clear Listeners
    if (listeners != null)
    {
      listeners!.clear();
      listeners = null;
    }

    // Clear Sources
    if (sources != null)
    {
      for (var source in sources!) {
        source.removeListener(onObservableChange);
      }
      sources = null;
    }
  }

  dynamic to(dynamic value)
  {
    return value;
  }

  onObservableChange(Observable? observable) {
    String? template = signature;

    // resolve all bindings
    Map<String?, dynamic>? variables;
    if ((bindings != null) && (scope != null)){
      for (Binding binding in bindings!) {
        dynamic v;

        // get binding source
        Observable? source = scope!.getObservable(
            binding, requestor: observable);
        if (source != null) {
          dynamic value0 = source.get();
          v = binding.translate(value0);
        }

        // is this an eval?
        if (isEval) {
          variables ??= <String?, dynamic>{};
          if ((source is BlobObservable) && (!S.isNullOrEmpty(v))) {
            variables[binding.signature] = 'blob';
          } else {
            variables[binding.signature] = v;
          }
        }

        // simple replacement of string values
        else {
          v = S.toStr(v) ?? "";
          template = template!.replaceAll(binding.signature, v.toString());
        }
      }
  }
    // set the value
    dynamic value = (isEval) ? doEvaluation(signature, variables: variables) : template;

    // 2-way binding?
    if (observable?.twoway == this) value = observable!.value;

    // set the target value
    set(value);
  }

  static bool isEvalSignature(String? value)
  {
    if ((value != null) && (value.trim().toLowerCase().startsWith('eval(')) && (value.trim().toLowerCase().endsWith(')'))) return true;
    if ((value != null) && (value.startsWith('='))) {
      return true;
    } else {
      return false;
    }
  }

  static String? getEvalSignature(String? value)
  {
    if (isEvalSignature(value))
    {
      String f = 'eval(';
      if (value!.trim().toLowerCase().startsWith(f)) {
        int i = value.toLowerCase().indexOf(f) + f.length;
        int j = value.toLowerCase().lastIndexOf(')');
        value = (i < j) ? value.substring(i,j) : null;
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

  static dynamic doEvaluation(dynamic expression, {Map<String?, dynamic>? variables})
  {
    dynamic result;
    try
    {
      result = fml_eval.Eval.evaluate(expression, variables: variables);
      result ??= "";
    }
    catch(e)
    {
      Log().error('Error in Eval() -> $expression. Error is $e');
      result = null;
    }
    return result;
  }

  Map<String?, dynamic> getVariables()
  {
    Map<String?, dynamic> variables =  <String?, dynamic>{};
    if (bindings != null) {
      for (var binding in bindings!) {
      Observable? source;
      if (sources != null) source = sources!.firstWhereOrNull((observable) => observable.key == binding.key);
      variables[binding.signature] = (source != null)  ? binding.translate(source.get()) : null;
    }
    }
    return variables;
  }
}