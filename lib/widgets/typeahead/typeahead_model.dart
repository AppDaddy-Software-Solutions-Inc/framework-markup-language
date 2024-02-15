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

  // options
  final List<OptionModel> options = [];

  // selected option
  OptionModel? selectedOption;

  // value
  BooleanObservable? _caseSensitive;
  set caseSensitive(dynamic v)
  {
    if (_caseSensitive != null)
    {
      _caseSensitive!.set(v);
    }
    else if (v != null)
    {
      _caseSensitive = BooleanObservable(Binding.toKey(id, 'casesensitive'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get caseSensitive => _caseSensitive?.get() ?? false;
  
  // value
  StringObservable? _value;
  @override
  set value(dynamic v)
  {
    if (_value != null)
    {
      _value!.set(v);
    }
    else if (v != null)
    {
      _value = StringObservable(Binding.toKey(id, 'value'), v, scope: scope, );
    }
  }

  @override
  dynamic get value => dirty ? _value?.get() : _value?.get() ?? defaultValue;

  //  maximum number of match results to show
  IntegerObservable? _matchRows;
  set matchRows(dynamic v)
  {
    if (_matchRows != null)
    {
      _matchRows!.set(v);
    }
    else
    {
      if (v != null)
      {
        _matchRows = IntegerObservable(Binding.toKey(id, 'matchrows'), v, scope: scope, listener: onPropertyChange);
      }
    }
  }
  int get matchRows => _matchRows?.get() ?? 5;
  
  //  match type
  StringObservable? _matchType;
  set matchType(dynamic v)
  {
    if (_matchType != null)
    {
      _matchType!.set(v);
    }
    else
    {
      if (v != null)
      {
        _matchType = StringObservable(Binding.toKey(id, 'matchtype'), v, scope: scope, listener: onPropertyChange);
      }
    }
  }
  String get matchType => _matchType?.get() ?? 'contains';

  /// if the input will obscure its characters.
  BooleanObservable? _obscure;
  set obscure(dynamic v)
  {
    if (_obscure != null)
    {
      _obscure!.set(v);
    }
    else if (v != null)
    {
      _obscure = BooleanObservable(Binding.toKey(id, 'obscure'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get obscure => _obscure?.get() ?? false;

  TypeaheadModel(WidgetModel parent, String? id) : super(parent, id);

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
    borderColor = Xml.get(node: xml, tag: 'bordercolor');
    borderWidth = Xml.get(node: xml, tag: 'borderwidth');
    radius = Xml.get(node: xml, tag: 'radius');
    matchType = Xml.get(node: xml, tag: 'matchtype') ?? Xml.get(node: xml, tag: 'searchtype');
    matchRows = Xml.get(node: xml, tag: 'matchrows');
    caseSensitive = Xml.get(node: xml, tag: 'casesensitive');
    addempty  = toBool(Xml.get(node: xml, tag: 'addempty')) ?? true;
    obscure = toBool(Xml.get(node: xml, tag: 'obscure'));

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
    _clearOptions;

    // Build options
    List<OptionModel> options = findChildrenOfExactType(OptionModel).cast<OptionModel>();

    // set prototype
    if (!isNullOrEmpty(this.datasource) && options.isNotEmpty)
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

  Future<List<OptionModel>> getMatchingOptions(String pattern) async
  {
    // trim
    pattern.trim();

    // case insensitive pattern
    if (!caseSensitive) pattern = pattern.toLowerCase();

    // empty pattern returns all
    if (isNullOrEmpty(pattern)) return options.toList();

    // matching options at top of list
    return options.where((option) => compare(option, pattern)).take(matchRows).toList();
  }

  bool compare(OptionModel option, String pattern)
  {
    // not text matches all
    if (isNullOrEmpty(pattern)) return true;

    // get option search tags
    for (var tag in option.tags)
    {
      if (isNullOrEmpty(tag)) return false;
      tag = tag.trim();
      if (!caseSensitive) tag = tag.toLowerCase();

      var type = matchType.trim();
      if (!caseSensitive) type = type.toLowerCase();

      switch (type)
      {
        case 'contains':
          if (tag.contains(pattern)) return true;
          break;
        case 'startswith':
          if (tag.startsWith(pattern)) return true;
          break;
        case 'endswith':
          if (tag.endsWith(pattern)) return true;
          break;
      }
    }
    return false;
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
        options.add(OptionModel(this, "$id-$i", value: ''));
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
