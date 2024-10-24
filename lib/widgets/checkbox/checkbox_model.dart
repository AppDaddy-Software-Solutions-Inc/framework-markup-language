// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/form/form_field_model.dart';
import 'package:fml/widgets/form/form_field_interface.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/option/option_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/widgets/checkbox/checkbox_view.dart';
import 'package:fml/datasources/gps/payload.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

/// Button [CheckboxModel]
///
/// Defines the properties used to build a [CHECKBOX.CheckboxView]
class CheckboxModel extends FormFieldModel implements IFormField {
  // options
  final List<OptionModel> options = [];

  // selected option
  final List<OptionModel> selectedOptions = [];

  // data sourced prototype
  XmlElement? prototype;

  /// The value of the widget. The label becomes the value if not specified. Returns an array if multiple checked. Can also set the initial options
  ListObservable? _value;
  @override
  set value(dynamic v) {
    if (_value != null) {
      _value!.set(v);
    } else {
      if (v != null) {
        _value = ListObservable(Binding.toKey(id, 'value'), v,
            scope: scope, listener: onValueChange);
      }
    }
  }

  @override
  dynamic get value => _value?.get() ?? defaultValue;

  /// Center attribute allows a simple boolean override for halign and valign both being center. halign and valign will override center if given.
  BooleanObservable? _center;
  set center(dynamic v) {
    if (_center != null) {
      _center!.set(v);
    } else if (v != null) {
      _center = BooleanObservable(Binding.toKey(id, 'center'), v, scope: scope);
    }
  }

  bool get center => _center?.get() ?? false;

  /// If option should be selcted on start
  BooleanObservable? _startSelected;
  set startSelected(dynamic v) {
    if (_startSelected != null) {
      _startSelected!.set(v);
    } else if (v != null) {
      _startSelected = BooleanObservable(Binding.toKey(id, 'startselected'), v, scope: scope);
    }
  }

  bool get startSelected => _startSelected?.get() ?? false;

  // wrap
  BooleanObservable? _wrap;
  set wrap(dynamic v) {
    if (_wrap != null) {
      _wrap!.set(v);
    } else if (v != null) {
      _wrap = BooleanObservable(Binding.toKey(id, 'wrap'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get wrap => _wrap?.get() ?? false;

  /// Layout determines the widgets childrens layout. Can be `row`, `column`, `col`, or `stack`. Defaulted to `column`. If set to `stack` it can take `POSITIONED` as a child.
  StringObservable? _layout;
  set layout(dynamic v) {
    if (_layout != null) {
      _layout!.set(v);
    } else if (v != null) {
      _layout = StringObservable(Binding.toKey(id, 'layout'), v, scope: scope);
    }
  }

  /// By default we stack the [Check]s vertically, if set to row we display them horizontal
  LayoutType get layoutType =>
      BoxModel.getLayoutType(layout, defaultLayout: LayoutType.column);
  String get layout => _layout?.get()?.toLowerCase() ?? 'column';

  // set answer
  @override
  Future<bool> answer(dynamic v, {bool delete = false}) async {
    touched = true;
    bool ok = delete ? await _removeAnswer(v) : await _insertAnswer(v);
    return ok;
  }

  void onValueChange(Observable observable) {
    _setSelectedOptions(observable.get());
    return super.onPropertyChange(observable);
  }

  Future<bool> _insertAnswer(dynamic v) async {
    bool ok = true;
    if (value is List) {
      if ((v != null) && (!(value as List).contains(v))) {
        // add value to list
        (value as List).add(v);

        // remember old geoCode
        var oldGeocode = geocode;

        // set geocode
        geocode = Payload(
            latitude: System().currentLocation?.latitude,
            longitude: System().currentLocation?.longitude,
            altitude: System().currentLocation?.altitude,
            epoch: DateTime.now().millisecondsSinceEpoch,
            user: System.currentApp?.user.claim('key'),
            username: System.currentApp?.user.claim('name'));

        // save the value
        //ok = await save();

        // save failed?
        if (ok == false) {
          value.remove(v);
          geocode = oldGeocode;
        }

        // save succeeded. set dirty
        else {
          dirty = true;
          _value!.notifyListeners();
        }
      }
    } else {
      var oldValue = value;
      value = v;

      // remember old geoCode
      var oldGeocode = geocode;

      // set geocode
      geocode = Payload(
          latitude: System().currentLocation?.latitude,
          longitude: System().currentLocation?.longitude,
          altitude: System().currentLocation?.altitude,
          epoch: DateTime.now().millisecondsSinceEpoch,
          user: System.currentApp?.user.claim('key'),
          username: System.currentApp?.user.claim('name'));

      // save the value
      // ok = await save();

      // save failed?
      if (ok == false) {
        value = oldValue;
        geocode = oldGeocode;
      }

      // save succeeded. set dirty
      else {
        dirty = true;
        _value!.notifyListeners();
      }
    }
    return ok;
  }

  Future<bool> _removeAnswer(dynamic v) async {
    bool ok = true;
    if ((v != null) && (value is List) && (value as List).contains(v)) {
      // Old GeoCode
      var oldGeocode = geocode;
      geocode = Payload(
          latitude: System().currentLocation?.latitude,
          longitude: System().currentLocation?.longitude,
          altitude: System().currentLocation?.altitude,
          epoch: DateTime.now().millisecondsSinceEpoch,
          user: System.currentApp?.user.claim('key'),
          username: System.currentApp?.user.claim('name'));

      // Remove Value
      value.remove(v);

      // Save
      //ok = await save();

      // Save Failed
      if (ok == false) {
        value.add(v);
        geocode = oldGeocode;
      }

      // Save Success
      else {
        dirty = true;
        _value!.notifyListeners();
      }
    }
    return ok;
  }

  // Values
  @override
  List<String>? get values {
    List<String>? list;
    if (value != null) {
      value.forEach((v) {
        if (!isNullOrEmpty(v?.toString())) {
          list ??= [];
          list!.add(v.toString());
        }
      });
    }
    return list;
  }

  // question was answered
  @override
  bool get answered {
    if (value == null) return false;
    return (value.isNotEmpty) && (!isNullOrEmpty(value[0]));
  }

  /// the size of the options checks
  DoubleObservable? _size;
  set size(dynamic v) {
    if (_size != null) {
      _size!.set(v);
    } else {
      if (v != null) {
        _size = DoubleObservable(Binding.toKey(id, 'size'), v,
            scope: scope, listener: onPropertyChange);
      }
    }
  }

  double get size {
    double? s = _size?.get();
    if ((s == null) || (s < 0)) s = 24.0;
    return s;
  }

  // label
  ListObservable? _label;
  set label(dynamic v) {
    if (_label != null) {
      _label!.set(v);
    } else {
      if (v != null) {
        _label = ListObservable(Binding.toKey(id, 'label'), v,
            scope: scope, listener: onPropertyChange);
      }
    }
  }

  List? get label => _label?.get();

  CheckboxModel(
    Model super.parent,
    super.id, {
    dynamic visible,
    dynamic mandatory,
    dynamic editable,
    dynamic enabled,
    dynamic value,
    String? defaultValue,
    dynamic width,
    dynamic size,
    dynamic layout,
    dynamic halign,
    dynamic valign,
    dynamic center,
    dynamic color,
    dynamic label,
    dynamic post,
    dynamic onchange,
    dynamic wrap,
        dynamic startSelected,
  }) {
    if (mandatory != null) this.mandatory = mandatory;
    if (editable != null) this.editable = editable;
    if (enabled != null) this.enabled = enabled;
    if (value != null) this.value = value;
    if (defaultValue != null) this.defaultValue = defaultValue;
    if (width != null) this.width = width;
    if (layout != null) this.layout = layout;
    if (center != null) this.center = center;
    if (valign != null) this.valign = valign;
    if (halign != null) this.halign = halign;
    if (size != null) this.size = size;
    if (color != null) this.color = color;
    if (label != null) this.label = label;
    if (post != null) this.post = post;
    if (onchange != null) this.onchange = onchange;
    if (wrap != null) this.wrap = wrap;
    if (startSelected != null) this.startSelected = startSelected;

    alarming = false;
    dirty = false;
  }

  static CheckboxModel? fromXml(Model parent, XmlElement xml) {
    CheckboxModel? model;
    try {
      model = CheckboxModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'checkbox.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {

    // deserialize
    super.deserialize(xml);

    // checkboxes can have multiple values

    // value is an attribute?
    var v = Xml.attribute(node: xml, tag: 'value');
    if (!isNullOrEmpty(v)) value = v?.split(",");

    // add individual element values. this allows setting multiple values that may have commas in them and
    // cannot be set by an attribute style comma separated list
    var values = Xml.getChildElements(node: xml, tag: 'value');
    values?.forEach((element) {
      String? v = Xml.getText(element);
      if (!isNullOrEmpty(v)) {
        if (_value == null) value = v;
        if (_value is List && !_value!.contains(v)) _value!.add(v);
      }
    });

    // properties
    layout = Xml.get(node: xml, tag: 'layout');
    center = Xml.get(node: xml, tag: 'center');
    wrap = Xml.get(node: xml, tag: 'wrap');
    size = Xml.get(node: xml, tag: 'size');
    startSelected = Xml.get(node: xml, tag: 'startselected');

    // build checkbox options
    _buildOptions();

    // set the default selected options
    if (datasource == null) _setSelectedOptions(value);
  }

  void _buildOptions() {
    // clear options
    _clearOptions();

    // Build options
    List<OptionModel> options =
        findChildrenOfExactType(OptionModel).cast<OptionModel>();

    // set prototype
    if (!isNullOrEmpty(datasource) && options.isNotEmpty) {
      prototype = prototypeOf(options.first.element);
      options.removeAt(0);
    }

    // build options
    this.options.addAll(options);
  }

  void _clearOptions() {
    for (var option in options) {
      option.dispose();
    }
    options.clear();
    selectedOptions.clear();
  }

  void _setSelectedOptions(dynamic value) {

    // clear all options
    selectedOptions.clear();

    // insert new option
    for (var option in options) {
      bool contains = false;
      if (value is String && option.value == value) contains = true;
      if (value is List && value.contains(option.value)) contains = true;
      if (contains) selectedOptions.add(option);
    }

    // set data
    List<dynamic> data = [];
    for (var option in selectedOptions) {
      if (option.data != null) data.add(option.data);
    }
    this.data = data;
  }

  Future<bool> setSelectedOption(OptionModel? option) async {

    if (option == null) return true;

    // add/remove option on toggle
    var checked = !selectedOptions.contains(option);

    // set answer
    bool ok = await answer(option.value, delete: !checked);

    if (ok) {

      // remove option
      if (!checked && selectedOptions.contains(option)) selectedOptions.remove(option);

      // insert option
      if ( checked && !selectedOptions.contains(option)) selectedOptions.add(option);

      // set data
      List<dynamic> data = [];
      for (var option in selectedOptions) {
        if (option.data != null) data.add(option.data);
      }
      this.data = data;

      // fire onchange
      await onChange(context);
    }


    return ok;
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async {
    try {
      if (prototype == null) return true;

      // clear options
      _clearOptions();

      // build options
      list?.forEach((row) {
        OptionModel? model = OptionModel.fromXml(this, prototype, data: row);
        if (model != null) options.add(model);
       if(startSelected || model!.startSelected) _insertAnswer(model?.value);
      });

      // set selected option
      _setSelectedOptions(value);
    } catch (e) {
      Log().error('Error building list. Error is $e', caller: 'CHECKBOX');
    }
    return true;
  }

  @override
  Future<dynamic> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    switch (function) {
      case "check":
        selectedOptions.clear();
        for (var option in options) {
          await setSelectedOption(option);
        }
        return true;

      case "uncheck":
        selectedOptions.clear();
        selectedOptions.addAll(options);
        for (var option in options) {
          await setSelectedOption(option);
        }
        return true;

      case "toggle":
        for (var option in options) {
          await setSelectedOption(option);
        }
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  @override
  Widget getView({Key? key}) {
    var view = CheckboxView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}
