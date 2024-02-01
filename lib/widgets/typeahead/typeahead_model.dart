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
import 'package:fml/widgets/typeahead/typeahead_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class TypeaheadModel extends DecoratedInputModel implements IFormField
{
  // data sourced prototype
  XmlElement? prototype;

  @override
  bool get canExpandInfinitelyWide => !hasBoundedWidth;

  bool addempty = true;
  String? emptylabel = "";

  // options
  final List<OptionModel> options = [];

  // inputenabled
  BooleanObservable? _inputenabled;
  set inputenabled(dynamic v)
  {
    if (_inputenabled != null)
    {
      _inputenabled!.set(v);
    }
    else if (v != null)
    {
      _inputenabled = BooleanObservable(Binding.toKey(id, 'inputenabled'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get inputenabled => _inputenabled?.get() ?? false;

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

  //  match type
  StringObservable? _matchtype;
  set matchtype(dynamic v)
  {
    if (_matchtype != null)
    {
      _matchtype!.set(v);
    }
    else
    {
      if (v != null)
      {
        matchtype = StringObservable(Binding.toKey(id, 'matchtype'), v, scope: scope, listener: onPropertyChange);
      }
    }
  }
  String? get matchtype => _matchtype?.get();

  TypeaheadModel(WidgetModel parent, String? id, {dynamic inputenabled,
        dynamic value,
        dynamic defaultValue,
        dynamic emptylabel,
        String? postbroker,
        dynamic matchtype,
      })
      : super(parent, id)
  {
    // instantiate busy observable
    busy = false;

    if (inputenabled  != null) this.inputenabled  = inputenabled;
    if (value         != null) this.value         = value;
    if (defaultValue  != null) this.defaultValue  = defaultValue;
    if (emptylabel     != null) this.emptylabel     = matchtype;
    if (matchtype     != null) this.matchtype     = matchtype;

    alarming = false;
    dirty    = false;
  }

  static TypeaheadModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    TypeaheadModel? model = TypeaheadModel(parent, Xml.get(node: xml, tag: 'id'));
    model.deserialize(xml);
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    // set properties
    value = Xml.get(node: xml, tag: 'value');
    hint = Xml.get(node: xml, tag: 'hint');
    border = Xml.get(node: xml, tag: 'border');
    bordercolor = Xml.get(node: xml, tag: 'bordercolor');
    borderwidth = Xml.get(node: xml, tag: 'borderwidth');
    radius = Xml.get(node: xml, tag: 'radius');
    inputenabled = Xml.get(node: xml, tag: 'inputenabled');
    emptylabel = Xml.get(node: xml, tag: 'emptylabel');
    matchtype = Xml.get(node: xml, tag: 'matchtype') ?? Xml.get(node: xml, tag: 'searchtype');
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
    OptionModel? selectedOption;
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
    label = selectedOption?.labelValue;
  }

  void _buildOptions()
  {
    // clear options
    _clearOptions;

    // Build options
    List<OptionModel> options = findChildrenOfExactType(OptionModel).cast<OptionModel>();

    // set prototype
    if ((!isNullOrEmpty(this.datasource)) && (options.isNotEmpty))
    {
      prototype = prototypeOf(options.first.element);
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

  void _clearOptions()
  {
    for (var option in options)
    {
      option.dispose();
    }
    options.clear();
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource? source, Data? list) async
  {
    try
    {
      if (prototype == null) return true;

      // clear options
      _clearOptions();

      // add empty option to list
      int i = 0;
      if (addempty)
      {
        options.add(OptionModel(this, "$id-$i", value: '', labelValue: emptylabel));
        i = i + 1;
      }

      // build options
      if (list != null && source != null)
      {
        for (var row in list)
        {
          var model = OptionModel.fromXml(this, prototype, data: row);
          if (model != null) options.add(model);
        }
      }

      // set selected option
      _setSelectedOption();
    }
    catch(e)
    {
      Log().error('Error building list. Error is $e');
    }
    return true;
  }

  @override
  onDataSourceException(IDataSource source, Exception exception)
  {
    // Clear the List - Olajos 2021-09-04
    onDataSourceSuccess(null, null);
  }

  @override
  dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  @override
  Widget getView({Key? key}) => getReactiveView(TypeaheadView(this));
}
