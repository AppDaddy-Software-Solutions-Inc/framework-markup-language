// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/form/decorated_input_model.dart';
import 'package:fml/widgets/form/form_field_interface.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/option/option_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/select/select_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class SelectModel extends DecoratedInputModel implements IFormField {
  @override
  bool get canExpandInfinitelyWide => !hasBoundedWidth;

  // options
  final List<OptionModel> options = [];

  // add empty value
  bool addempty = true;

  // holds no data option model
  OptionModel? noDataOption;

  // holds no match option model
  OptionModel? noMatchOption;

  // holds the empty option model
  OptionModel? emptyOption;

  // selected option
  OptionModel? selectedOption;

  // data sourced prototype
  XmlElement? prototype;

  // value
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

  SelectModel(
    WidgetModel super.parent,
    super.id, {
    dynamic value,
    dynamic defaultValue,
    String? postbroker,
    dynamic borderColor,
    dynamic matchtype,
  }) {
    // instantiate busy observable
    busy = false;

    if (borderColor != null) this.borderColor = borderColor;
    if (value != null) this.value = value;
    if (defaultValue != null) this.defaultValue = defaultValue;
  }

  static SelectModel? fromXml(WidgetModel parent, XmlElement xml) {
    SelectModel? model;
    try {
      model = SelectModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'select.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);

    // set properties
    value = Xml.get(node: xml, tag: 'value');

    // automatically add an empty widget to the list?
    var addempty = toBool(Xml.get(node: xml, tag: 'addempty'));
    if (addempty == null && emptyOption != null) addempty = true;
    this.addempty = addempty ?? true;

    // build select options
    _buildOptions();

    // set the default selected option
    if (datasource == null) _setSelectedOption();
  }

  void onValueChange(Observable observable) {
    // set the selected option
    _setSelectedOption(setValue: false);

    // notify listeners
    onPropertyChange(observable);
  }

  void _setSelectedOption({bool setValue = true}) {
    selectedOption = null;
    if (options.isNotEmpty) {
      for (var option in options) {
        if (option.value == value) {
          selectedOption = option;
          break;
        }
      }

      // not found? default to the first option
      selectedOption ??= options[0];
    }

    // set values
    if (setValue) value = selectedOption?.value;
    data = selectedOption?.data;
    label = selectedOption?.value;
  }

  void _buildOptions() {
    // clear options
    _clearOptions();

    // build options
    List<OptionModel> options =
        findChildrenOfExactType(OptionModel).cast<OptionModel>();

    // strip out special options
    for (var option in options.toList()) {
      switch (option.type) {

      // no data
        case OptionType.nodata:
          noDataOption?.dispose();
          noDataOption = option;
          children?.remove(option);
          options.remove(option);
          break;

      // empty
        case OptionType.empty:
          emptyOption?.dispose();
          emptyOption = option;
          children?.remove(option);
          options.remove(option);
          break;

      // no match
        case OptionType.nomatch:
          noMatchOption?.dispose();
          noMatchOption = option;
          children?.remove(option);
          options.remove(option);
          break;

      // no match
        case OptionType.prototype:
          if (!isNullOrEmpty(this.datasource))
          {
            prototype = prototypeOf(option.element);
            option.dispose();
            children?.remove(option);
            options.remove(option);
          }
          break;

        default:
          break;
      }
    }

    // set prototype if not already defined
    // prototype is the first element in the options list
    if (!isNullOrEmpty(this.datasource) && options.isNotEmpty && prototype == null) {
      var option = options.first;
      prototype = prototypeOf(option.element);
      option.dispose();
      children?.remove(option);
      options.remove(option);
    }

    // add empty option to list
    if (addempty && options.isEmpty) {
      OptionModel model = emptyOption ?? OptionModel(this, "$id-0", value: '');
      options.insert(0, model);
    }

    // build options
    this.options.addAll(options);

    // announce data for late binding
    var datasource = scope?.getDataSource(this.datasource);
    if (datasource != null && datasource.initialized) onDataSourceSuccess(datasource, datasource.data);
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async {
    try {
      // clear options
      _clearOptions();

      // build options
      if (prototype != null) {
        list?.forEach((row) {
          OptionModel? model = OptionModel.fromXml(this, prototype, data: row);
          if (model != null) options.add(model);
        });
      }

      // add empty option to list only if nodata isn't displayed
      if (addempty && (noDataOption == null || options.isNotEmpty)) {
        OptionModel model =
            emptyOption ?? OptionModel(this, "$id-0", value: '');
        options.insert(0, model);
      }

      // add nodata option
      if (noDataOption != null && options.isEmpty) {
        options.add(noDataOption!);
      }

      // set selected option
      _setSelectedOption();
    } catch (e) {
      Log().error('Error building list. Error is $e', caller: 'SELECT');
    }
    return true;
  }

  void _clearOptions() {
    for (var option in options) {
      if (option != emptyOption && option != noDataOption && option != noMatchOption) {
        option.dispose();
      }
    }
    options.clear();
    selectedOption = null;
    data = null;
  }

  @override
  dispose() {
    noDataOption?.dispose();
    noMatchOption?.dispose();
    emptyOption?.dispose();
    super.dispose();
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
  onDataSourceException(IDataSource source, Exception exception) {
    // Clear the List - Olajos 2021-09-04
    onDataSourceSuccess(source, null);
  }

  @override
  Widget getView({Key? key}) => getReactiveView(SelectView(this));
}
