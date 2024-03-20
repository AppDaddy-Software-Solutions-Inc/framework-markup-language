// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/form/form_field_model.dart';
import 'package:fml/widgets/form/form_field_interface.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/option/option_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/radio/radio_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class RadioModel extends FormFieldModel implements IFormField {
  // options
  List<OptionModel> options = [];

  // selected option
  OptionModel? selectedOption;

  // data sourced prototype
  XmlElement? prototype;

  /// Center attribute allows a simple boolean override for halign and valign both being center. halign and valign will override center if given.
  BooleanObservable? _center;
  set center(dynamic v) {
    if (_center != null) {
      _center!.set(v);
    } else if (v != null) {
      _center = BooleanObservable(Binding.toKey(id, 'center'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get center => _center?.get() ?? false;

  /// if the widget will wrap its children rather than clipping the overflow
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
  LayoutType get layoutType =>
      BoxModel.getLayoutType(layout, defaultLayout: LayoutType.column);
  StringObservable? _layout;
  set layout(dynamic v) {
    if (_layout != null) {
      _layout!.set(v);
    } else if (v != null) {
      _layout = StringObservable(Binding.toKey(id, 'layout'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String get layout => _layout?.get()?.toLowerCase() ?? 'column';

  /// the value of the widget. The label becomes the value if not specified. If specified, the options will reflect the value.
  StringObservable? _value;

  @override
  set value(dynamic v) {
    if (_value != null) {
      _value!.set(v);
    } else if (v != null ||
        WidgetModel.isBound(this, Binding.toKey(id, 'value'))) {
      _value = StringObservable(Binding.toKey(id, 'value'), v,
          scope: scope, listener: onValueChange);
    }
  }

  @override
  dynamic get value => dirty ? _value?.get() : _value?.get() ?? defaultValue;

  /// the size of the options radio button
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
    if (s == null || s < 0) s = 24.0;
    return s;
  }

  RadioModel(
    WidgetModel super.parent,
    super.id, {
    dynamic visible,
    dynamic mandatory,
    dynamic editable,
    dynamic enabled,
    dynamic value,
    dynamic defaultValue,
    dynamic width,
    dynamic size,
    dynamic color,
    dynamic direction,
    dynamic post,
    dynamic onchange,
    dynamic center,
    dynamic layout,
    dynamic halign,
    dynamic valign,
    dynamic wrap,
  }) {
    if (mandatory != null) this.mandatory = mandatory;
    if (editable != null) this.editable = editable;
    if (enabled != null) this.enabled = enabled;
    if (value != null) this.value = value;
    if (defaultValue != null) this.defaultValue = defaultValue;
    if (width != null) this.width = width;
    if (size != null) this.size = size;
    if (color != null) this.color = color;
    if (post != null) this.post = post;
    if (onchange != null) this.onchange = onchange;
    if (layout != null) this.layout = layout;
    if (center != null) this.center = center;
    if (halign != null) this.halign = halign;
    if (valign != null) this.valign = valign;
    if (wrap != null) this.wrap = wrap;

    alarming = false;
    dirty = false;
  }

  static RadioModel? fromXml(WidgetModel parent, XmlElement xml) {
    RadioModel? model = RadioModel(parent, Xml.get(node: xml, tag: 'id'));
    model.deserialize(xml);
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);

    // set properties
    value = Xml.get(node: xml, tag: 'value');
    layout = Xml.get(node: xml, tag: 'layout');
    center = Xml.get(node: xml, tag: 'center');
    wrap = Xml.get(node: xml, tag: 'wrap');
    size = Xml.get(node: xml, tag: 'size');

    // build radio options
    _buildOptions();

    // set the default selected option
    if (datasource == null) _setSelectedOption();
  }

  void _buildOptions() {
    // clear options
    _clearOptions();

    // find option models
    List<OptionModel> options =
        findChildrenOfExactType(OptionModel).cast<OptionModel>();

    // set prototype
    if (!isNullOrEmpty(this.datasource) && options.isNotEmpty) {
      prototype = prototypeOf(options.first.element);
      options.first.dispose();
      options.removeAt(0);
    }

    // build options
    this.options.addAll(options);

    // announce data for late binding
    var datasource = scope?.getDataSource(this.datasource);
    if (datasource?.data?.isNotEmpty ?? false) {
      onDataSourceSuccess(datasource!, datasource.data);
    }
  }

  void onValueChange(Observable observable) {
    // set the selected option
    _setSelectedOption(setValue: false);

    // notify listeners
    onPropertyChange(observable);
  }

  void _setSelectedOption({bool setValue = true}) {
    selectedOption = null;
    for (var option in options) {
      if (option.value == value) {
        selectedOption = option;
        break;
      }
    }

    // set values
    if (setValue) value = selectedOption?.value;
    data = selectedOption?.data;
  }

  void _clearOptions() {
    for (var option in options) {
      option.dispose();
    }
    options.clear();

    selectedOption = null;
    data = null;
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
      });

      // set selected option
      _setSelectedOption();
    } catch (e) {
      Log().error('Error building list. Error is $e', caller: 'RADIO');
    }
    return true;
  }

  Future<bool> setSelectedOption(OptionModel? option) async {
    // save the answer
    bool ok = await answer(option?.value);
    if (ok) {
      // set selected
      selectedOption = option;

      // set data
      data = option?.data;

      // fire the onchange event
      await onChange(context);
    }
    return ok;
  }

  @override
  Widget getView({Key? key}) => getReactiveView(RadioView(this));
}
