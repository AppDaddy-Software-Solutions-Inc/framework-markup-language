// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

enum VariableTypes { string, integer, double, boolean, blob, list, constant }

class VariableModel extends Model {

  VariableTypes type = VariableTypes.string;
  bool readonly = false;
  int? precision;
  String? encoding;

  // value
  dynamic _value;
  set value(dynamic v) {

    if (_value != null) {
      _value!.set(v);
    }
    else if (v != null || Model.isBound(this, Binding.toKey(id, 'value'))) {

      switch (type) {

        case VariableTypes.string:
            _value = StringObservable(Binding.toKey(id, 'value'), v,
            scope: scope,
            listener: onPropertyChange,
            setter: readonly ? (dynamic value, {Observable? setter}) => v : null,
            formatter: encoding != null ? _encodeBody : null);
          break;

        case VariableTypes.integer:
          _value = IntegerObservable(Binding.toKey(id, 'value'), v,
              scope: scope,
              listener: onPropertyChange,
              readonly: readonly);
          break;

        case VariableTypes.double:
          _value = DoubleObservable(Binding.toKey(id, 'value'), v,
              scope: scope,
              listener: onPropertyChange,
              setter: precision != null ? (dynamic value, {Observable? setter}) => toDouble(value, precision: precision) : null,
              readonly: readonly);
          break;

        case VariableTypes.boolean:
          _value = BooleanObservable(Binding.toKey(id, 'value'), v,
              scope: scope,
              listener: onPropertyChange,
              readonly: readonly);
          break;

        case VariableTypes.list:
          _value = ListObservable(Binding.toKey(id, 'value'), v,
              scope: scope,
              listener: onPropertyChange,
              readonly: readonly);
          break;

        case VariableTypes.blob:
          // setting the value to null before the actual value defeats any bindings
          _value = StringObservable(Binding.toKey(id, 'value'), null,
              scope: scope,
              listener: onPropertyChange,
              readonly: readonly,
              formatter: encoding != null ? _encodeBody : null);
          _value.set(v);
          break;

        case VariableTypes.constant:
          _value = StringObservable(Binding.toKey(id, 'value'), v,
              scope: scope,
              listener: onPropertyChange,
              readonly: true,
              formatter: encoding != null ? _encodeBody : null);
          break;
      }
    }
  }
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

  // return parameter
  String? _returnas;
  set returnas(dynamic v) {
    if ((v != null) && (v is String)) _returnas = v.trim().toLowerCase();
  }
  String? get returnas => _returnas;

  VariableModel(this.type, super.parent, super.id, {dynamic value, dynamic onchange}) {
    if (value != null) this.value = value;
    if (onchange != null) this.onchange = onchange;
  }

  static VariableModel? fromXml(VariableTypes type, Model parent, XmlElement xml) {
    var model = VariableModel(type, parent, Xml.get(node: xml, tag: 'id'));
    model.deserialize(xml);
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {

    // deserialize
    super.deserialize(xml);

    // properties
    encoding = Xml.get(node: xml, tag: 'type')?.trim().toLowerCase();
    readonly = toBool(Xml.get(node: xml, tag: 'readonly')?.trim().toLowerCase()) ?? false;
    value = Xml.get(node: xml, tag: 'value', innerXmlAsText: true);
    onchange = Xml.get(node: xml, tag: 'onchange');
    returnas = Xml.get(node: xml, tag: 'return');
    precision = toInt(Xml.get(node: xml, tag: 'precision'));
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

  // encode segments
  String? _encodeBody(dynamic value) => encode(value, encoding);
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
    if (observable == _value) {
      notifyListeners('value', value);
    }
  }
}
