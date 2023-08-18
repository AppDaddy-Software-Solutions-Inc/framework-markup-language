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
import 'package:fml/helper/common_helpers.dart';

class TypeaheadModel extends DecoratedInputModel implements IFormField
{
  @override
  bool get canExpandInfinitelyWide => !hasBoundedWidth;

  bool? addempty = true;

  // bindable data
  ListObservable? _data;
  @override
  set data(dynamic v)
  {
    if (_data != null)
    {
      _data!.set(v);
    }
    else if (v != null)
    {
      _data = ListObservable(Binding.toKey(id, 'data'), null, scope: scope, listener: onPropertyChange);
      _data!.set(v);
    }
  }
  @override
  get data => _data?.get();

  // prototype
  XmlElement? prototype;

  // options
  final List<OptionModel> options = [];

  //////////////////
  /* inputenabled */
  //////////////////
  BooleanObservable? _inputenabled;
  set inputenabled(dynamic v) {
    if (_inputenabled != null) {
      _inputenabled!.set(v);
    } else if (v != null) {
      _inputenabled = BooleanObservable(
          Binding.toKey(id, 'inputenabled'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get inputenabled => _inputenabled?.get() ?? false;

  ///////////
  /* Value */
  ///////////
  StringObservable? _value;
  @override
  set value(dynamic v) {
    if (_value != null)
    {
      _value!.set(v);
    }
    else
    {
      if ((v != null) || (WidgetModel.isBound(this, Binding.toKey(id, 'value')))) _value = StringObservable(Binding.toKey(id, 'value'), v, scope: scope, listener: onPropertyChange);
    }
    setData();
  }
  @override
  dynamic get value
  {
    if (_value == null) return defaultValue;
    if (!dirty && S.isNullOrEmpty(_value?.get()) && !S.isNullOrEmpty(defaultValue)) _value!.set(defaultValue);
    return _value?.get();
  }

  ////////////
  /* length */
  ////////////
  IntegerObservable? _length;
  set length(dynamic v) {
    if (_length != null) {
      _length!.set(v);
    } else {
      if (v != null) {
        _length = IntegerObservable(Binding.toKey(id, 'length'), v,
            scope: scope, listener: onPropertyChange);
      }
    }
  }
  int? get length => _length?.get();


  //
  //  Match Type
  //
  StringObservable? _matchtype;
  set matchtype(dynamic v) {
    if (_matchtype != null) {
      _matchtype!.set(v);
    } else {
      if (v != null) {
        matchtype = StringObservable(Binding.toKey(id, 'matchtype'), v,
            scope: scope, listener: onPropertyChange);
      }
    }
  }
  String? get matchtype => _matchtype?.get();


  TypeaheadModel(WidgetModel parent, String? id,
      {
        dynamic inputenabled,
        dynamic value,
        dynamic defaultValue,
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

    if (matchtype     != null) this.matchtype     = matchtype;

    alarming = false;
    dirty    = false;
  }

  static TypeaheadModel? fromXml(WidgetModel parent, XmlElement xml) {
    TypeaheadModel? model;
    try
    {
      model = TypeaheadModel(parent, Xml.get(node: xml, tag: 'id'));
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
    value = Xml.get(node: xml, tag: 'value');
    hint = Xml.get(node: xml, tag: 'hint');
    border = Xml.get(node: xml, tag: 'border');
    bordercolor = Xml.get(node: xml, tag: 'bordercolor');
    borderwidth = Xml.get(node: xml, tag: 'borderwidth');
    radius = Xml.get(node: xml, tag: 'radius');
    inputenabled = Xml.get(node: xml, tag: 'inputenabled');
    matchtype = Xml.get(node: xml, tag: 'matchtype') ?? Xml.get(node: xml, tag: 'searchtype');

    String? empty = Xml.get(node: xml, tag: 'addempty');
    if (S.isBool(empty)) addempty = S.toBool(empty);

    // clear options
    for (var option in this.options)
    {
      option.dispose();
    }
    this.options.clear();

    // Build options
    List<OptionModel> options = findChildrenOfExactType(OptionModel).cast<OptionModel>();

    // set prototype
    if ((!S.isNullOrEmpty(datasource)) && (options.isNotEmpty))
    {
      prototype = WidgetModel.prototypeOf(options[0].element);
      options.removeAt(0);
    }

    // build options
    for (var option in options) {
      this.options.add(option);
    }

    // Set selected option
    setData();
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource? source, Data? list) async
  {
    try
    {
      if (prototype == null) return true;

      // clear options
      for (var option in options) {
        option.dispose();
      }
      options.clear();

      int i = 0;
      if (addempty == true)
      {
        options.add(OptionModel(this, "$id-$i", value: ''));
        i = i + 1;
      }

      // build options
      if ((list != null) && (source != null))
      {
        // build options
        for (var row in list)
        {
          var model = OptionModel.fromXml(this, prototype, data: row);
          if (model != null) options.add(model);
        }
      }

      // sets the data
      setData();

      // notify listeners
      notifyListeners('options', options);
    }
    catch(e)
    {
      Log().error('Error building list. Error is $e');
    }
    return true;
  }


  @override
  onDataSourceException(IDataSource source, Exception exception) {
    // Clear the List - Olajos 2021-09-04
    onDataSourceSuccess(null, null);
  }

  void setData()
  {
    // value is not in data?
    if (!_containsOption())
    {
      var value = options.isNotEmpty ? options[0].value : null;

      // set to first entry if no datasource
      if (datasource == null)
      {
        // if we set value to itself it will cause an infinite loop
        if (this.value != value) this.value = value;
      }

      // set to first entry after data has been returned
      else if (options.isNotEmpty)
      {
        // if we set value to itself it will cause an infinite loop
        if (this.value != value) this.value = value;
      }
    }

    dynamic data;
    for (var option in options) {
      if (option.value == value)
      {
        data = option.data;
        label = option.labelValue;
      }
    }
    this.data = data;
  }

  bool _containsOption()
  {
    bool contains = false;
    for (var option in options) {
      if (option.value == value) contains = true;
    }
    return contains;
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
