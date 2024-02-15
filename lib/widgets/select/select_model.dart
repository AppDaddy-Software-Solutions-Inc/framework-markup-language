// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/form/decorated_input_model.dart';
import 'package:fml/widgets/form/form_field_interface.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/option/option_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/select/select_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class SelectModel extends DecoratedInputModel implements IFormField
{
  @override
  bool get canExpandInfinitelyWide => !hasBoundedWidth;

  // add empty value
  bool addempty = true;

  // options
  final List<OptionModel> options = [];

  // selected option
  OptionModel? selectedOption;

  // data sourced prototype
  XmlElement? prototype;

  // value
  StringObservable? _value;
  @override
  set value(dynamic v)
  {
    if (_value != null)
    {
      _value!.set(v);
    }
    else if (v != null || WidgetModel.isBound(this, Binding.toKey(id, 'value')))
    {
        _value = StringObservable(Binding.toKey(id, 'value'), v, scope: scope, listener: onValueChange);
    }
  }

  @override
  dynamic get value => dirty ? _value?.get() : _value?.get() ?? defaultValue;

  SelectModel(WidgetModel parent, String? id,
      { dynamic value,
        dynamic defaultValue,
        String? postbroker,
        dynamic borderColor,
        dynamic matchtype,
        })
      : super(parent, id)
  {
    // instantiate busy observable
    busy = false;

    if (borderColor   != null)  this.borderColor = borderColor;
    if (value         != null)  this.value = value;
    if (defaultValue  != null)  this.defaultValue = defaultValue;
  }

  static SelectModel? fromXml(WidgetModel parent, XmlElement xml) {
    SelectModel? model;
    try
    {
      model = SelectModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'select.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    // set properties
    value     = Xml.get(node: xml, tag: 'value');
    addempty  = toBool(Xml.get(node: xml, tag: 'addempty')) ?? true;

    // build select options
    _buildOptions();

    // set the default selected option
    if (datasource == null) _setSelectedOption();
  }

  void onValueChange(Observable observable)
  {
    // set the selected option
    _setSelectedOption(setValue: false);

    // notify listeners
    onPropertyChange(observable);
  }

  void _setSelectedOption({bool setValue = true})
  {
    selectedOption = null;
    if (options.isNotEmpty)
    {
      for (var option in options)
      {
        if (option.value == value)
        {
          selectedOption = option;
          break;
        }
      }

      // not found? default to the first option
      selectedOption ??= options[0];
    }

    // set values
    if (setValue) value = selectedOption?.value;
    data  = selectedOption?.data;
    label = selectedOption?.value;
  }

  void _buildOptions()
  {
    // clear options
    _clearOptions();

    // build options
    List<OptionModel> options = findChildrenOfExactType(OptionModel).cast<OptionModel>();

    // set prototype
    if (!isNullOrEmpty(this.datasource) && options.isNotEmpty)
    {
      prototype = prototypeOf(options.first.element);
      options.first.dispose();
      options.removeAt(0);
    }

    // build options
    this.options.addAll(options);

    // announce data for late binding
    var datasource = scope?.getDataSource(this.datasource);
    if (datasource?.data?.isNotEmpty ?? false)
    {
      onDataSourceSuccess(datasource!, datasource.data);
    }
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async
  {
    try
    {
      if (prototype == null) return true;

      // clear options
      _clearOptions();

      // add empty option to list
      if (addempty) options.add(OptionModel(this, "$id-0", value: ''));

      // build options
      list?.forEach((row)
      {
        OptionModel? model = OptionModel.fromXml(this, prototype, data: row);
        if (model != null) options.add(model);
      });

      // set selected option
      _setSelectedOption();
    }
    catch(e)
    {
      Log().error('Error building list. Error is $e', caller: 'SELECT');
    }
    return true;
  }

  void _clearOptions()
  {
    for (var option in options) {
      option.dispose();
    }
    options.clear();
    selectedOption = null;
    data = null;
  }

  Future<bool> setSelectedOption(OptionModel? option) async
  {
    // save the answer
    bool ok = await answer(option?.value);
    if (ok)
    {
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
  onDataSourceException(IDataSource source, Exception exception)
  {
    // Clear the List - Olajos 2021-09-04
    onDataSourceSuccess(source, null);
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  @override
  Widget getView({Key? key}) => getReactiveView(SelectView(this));
}
