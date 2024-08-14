// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/foundation.dart';
import 'package:fml/widgets/plugin/plugin_mixin.dart';
import 'package:fml/widgets/variable/variable_model.dart';
import 'package:fml/widgets/widget/model_interface.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

enum ReturnTypes { string, int, integer, double, bool, boolean, blob, list }

class FunctionModel extends Model with PluginMixin implements IModelListener {

  final ReturnTypes returns;
  bool readonly = false;
  int? precision;
  String? encoding;

  // value
  dynamic _value;

  @override
  set value(dynamic v) {

    if (_value != null) {
      _value!.set(v);
      return;
    }

    switch (returns) {

      case ReturnTypes.string:
        _value = StringObservable(Binding.toKey(id, 'value'), v,
            scope: scope,
            listener: onPropertyChange,
            setter: readonly ? (dynamic value, {Observable? setter}) => v : null,
            formatter: encoding != null ? _encode : null);
        break;

      case ReturnTypes.int:
      case ReturnTypes.integer:
        _value = IntegerObservable(Binding.toKey(id, 'value'), v,
            scope: scope,
            listener: onPropertyChange,
            readonly: readonly);
        break;

      case ReturnTypes.double:
        _value = DoubleObservable(Binding.toKey(id, 'value'), v,
            scope: scope,
            listener: onPropertyChange,
            setter: precision != null ? (dynamic value, {Observable? setter}) => toDouble(value, precision: precision) : null,
            readonly: readonly);
        break;

      case ReturnTypes.bool:
      case ReturnTypes.boolean:
        _value = BooleanObservable(Binding.toKey(id, 'value'), v,
            scope: scope,
            listener: onPropertyChange,
            readonly: readonly);
        break;

      case ReturnTypes.list:
        _value = ListObservable(Binding.toKey(id, 'value'), v,
            scope: scope,
            listener: onPropertyChange,
            readonly: readonly);
        break;

      case ReturnTypes.blob:
        _value = StringObservable(Binding.toKey(id, 'value'), v,
            scope: scope,
            listener: onPropertyChange,
            readonly: readonly,
            formatter: encoding != null ? _encode : null);
        break;
    }
  }

  @override
  dynamic get value => _value?.get();

  // onchange
  StringObservable? _onchange;
  set onchange(dynamic v) {
    if (_onchange != null) {
      _onchange!.set(v);
    } else if (v != null) {
      _onchange = StringObservable(Binding.toKey(id, 'onchange'), v,
          scope: scope, lazyEvaluation: true);
    }
  }
  String? get onchange => _onchange?.get();

  // autoexecute
  BooleanObservable? _autoexecute;
  set autoexecute(dynamic v) {
    if (_autoexecute != null) {
      _autoexecute!.set(v);
    } else if (v != null) {
      _autoexecute =
          BooleanObservable(Binding.toKey(id, 'autoexecute'), v, scope: scope);
    }
  }
  bool get autoexecute => _autoexecute?.get() ?? true;

  FunctionModel(this.returns, super.parent, super.id) {
    value = null;
  }

  static FunctionModel? fromXml(Model parent, XmlElement xml) {

    // get return type
    var returns = toEnum(Xml.get(node: xml, tag: 'returns')?.trim().toLowerCase(), ReturnTypes.values) ?? ReturnTypes.string;
    var model = FunctionModel(returns, parent, Xml.get(node: xml, tag: 'id'));
    model.deserialize(xml);

    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {

    // deserialize
    super.deserialize(xml);

    // properties
    autoexecute = Xml.get(node: xml, tag: 'autoexecute');
    encoding = Xml.get(node: xml, tag: 'encoding')?.trim().toLowerCase();
    readonly = toBool(Xml.get(node: xml, tag: 'readonly')?.trim().toLowerCase()) ?? false;
    onchange = Xml.get(node: xml, tag: 'onchange');
    precision = toInt(Xml.get(node: xml, tag: 'precision'));

    // listen for child changes
    var parameters = children?.whereType<VariableModel>() ?? [];
    for (var variable in parameters) {
      variable.registerListener(this);
    }

    // fire the function
    if (autoexecute) _execute();
  }

  @override
  onModelChange(Model model, {String? property, dynamic value}) {
    if (!autoexecute) return;
    _execute();
  }

  Future<bool> onChange() async {
    bool ok = true;

    if (!isNullOrEmpty(onchange)) {
      // This is Hack in Case Onchange Is Bound to Its own Value
      if (_onchange!.bindings != null) _onchange!.onObservableChange(null);

      // fire onchange event
      ok = await EventHandler(this).execute(_onchange);
    }

    return ok;
  }

  void _execute() async {

    // wait for runtime to load
    await initialized?.future;

    // runtime loaded?
    if (runtime == null) return;

    // runtime loaded?
    if (!isPlugin) return;

    try {

      // execute the dart code
      var result = runtime?.executeLib(library, method, arguments);

      // set value
      value = toStr(result);
    }
    catch(e) {
      if (kDebugMode) print(e);
    }
  }

  @override
  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async {

    if (scope == null) return null;

    var function = propertyOrFunction.toLowerCase().trim();

    switch (function) {

    // fire event handler
      case 'execute':
        _execute();
        return true;
    }

    return super.execute(caller, propertyOrFunction, arguments);
  }

  // encode value
  String? _encode(dynamic value) => encode(value, encoding);
  static String? encode(dynamic value, String? type) {

    if (value == null || value is! String || type == null) return value;

    switch (type) {
      case "json":
        value = Json.escape(value);
        break;

      case "xml":
        value = Xml.encodeIllegalCharacters(value);
        break;
      default:
        break;
    }
    return value;
  }

  @override
  void dispose() {
    //if (global && !persistent) System().scope.removeDataSource(this);
    super.dispose();
  }

  @override
  void onPropertyChange(Observable observable) {
    onChange();
  }
}
