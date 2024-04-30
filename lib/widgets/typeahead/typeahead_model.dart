// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/datasource_interface.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/form/decorated_input_model.dart';
import 'package:fml/widgets/form/form_field_interface.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/option/tag_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/option/option_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/widgets/typeahead/typeahead_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class TypeaheadModel extends DecoratedInputModel implements IFormField {
  // data sourced prototype
  XmlElement? prototype;

  @override
  bool get canExpandInfinitelyWide => !hasBoundedWidth;

  // options
  final List<OptionModel> options = [];

  // add an empty option if no data
  bool addempty = true;

  // holds no data option model
  OptionModel? noDataOption;

  // holds no match option model
  OptionModel? noMatchOption;

  // holds the empty option model
  OptionModel? emptyOption;

  // selected option
  OptionModel? selectedOption;

  // readonly
  BooleanObservable? _readonly;
  set readonly(dynamic v) {
    if (_readonly != null) {
      _readonly!.set(v);
    } else if (v != null) {
      _readonly = BooleanObservable(Binding.toKey(id, 'readonly'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get readonly => _readonly?.get() ?? false;

  // value
  StringObservable? _value;
  @override
  set value(dynamic v) {
    if (_value != null) {
      _value!.set(v);
    } else if (v != null) {
      _value = StringObservable(
        Binding.toKey(id, 'value'),
        v,
        scope: scope, listener: onValueChange
      );
    }
  }

  @override
  dynamic get value => dirty ? _value?.get() : _value?.get() ?? defaultValue;

  /// If the input shows the clear icon on its right.
  BooleanObservable? _clear;
  set clear(dynamic v) {
    if (_clear != null) {
      _clear!.set(v);
    } else if (v != null) {
      _clear = BooleanObservable(Binding.toKey(id, 'clear'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get clear => _clear?.get() ?? false;
  
  //  maximum number of match results to show
  IntegerObservable? _rows;
  set rows(dynamic v) {
    if (_rows != null) {
      _rows!.set(v);
    } else {
      if (v != null) {
        _rows = IntegerObservable(Binding.toKey(id, 'rows'), v,
            scope: scope, listener: onPropertyChange);
      }
    }
  }
  int get rows => _rows?.get() ?? 5;

  /// if the input will obscure its characters.
  BooleanObservable? _obscure;
  set obscure(dynamic v) {
    if (_obscure != null) {
      _obscure!.set(v);
    } else if (v != null) {
      _obscure = BooleanObservable(Binding.toKey(id, 'obscure'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get obscure => _obscure?.get() ?? false;

  TypeaheadModel(Model super.parent, super.id);

  static TypeaheadModel? fromXml(Model parent, XmlElement xml) {
    TypeaheadModel? model =
        TypeaheadModel(parent, Xml.get(node: xml, tag: 'id'));
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
    rows = Xml.get(node: xml, tag: 'rows');
    obscure = Xml.get(node: xml, tag: 'obscure');
    readonly = Xml.get(node: xml, tag: 'readonly');
    clear = Xml.get(node: xml, tag: 'clear');

    // automatically add an empty widget to the list?
    var addempty = toBool(Xml.get(node: xml, tag: 'addempty'));
      if (addempty == null && emptyOption != null) addempty = true;
    this.addempty = addempty ?? true;

    // build select options
    _buildOptions();

    // set the default selected option
    if (datasource == null) _setSelectedOption();
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
  }

  void _buildOptions() {
    // clear options
    _clearOptions;

    // Build options
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

  void onValueChange(Observable observable) {

    // set the selected option
    _setSelectedOption(setValue: false);

    // notify listeners
    onPropertyChange(observable);
  }

  Future<List<OptionModel>> getMatchingOptions(String pattern) async {
    // trim
    pattern.trim();

    // return visible options
    if (isNullOrEmpty(pattern)) {
      return options.where((option) => option.visible).toList();
    }

    // matching options at top of list
    return options
        .where((option) => compare(option, pattern))
        .take(rows)
        .toList();
  }

  bool compare(OptionModel option, String pattern) {

    // not text matches all
    if (isNullOrEmpty(pattern.trim())) return true;

    // get option search tags
    for (var tag in option.tags) {

      // set search values
      var v1 = (tag.ignoreCase ? pattern.toLowerCase() : pattern).trim();
      var v2 = (tag.ignoreCase ? tag.value?.toLowerCase() : tag.value)?.trim();

      // specify search
      if (v2 != null) {
        switch (tag.type) {

          // contains
          case TagType.contains:
            if (v2.contains(v1)) return true;
            break;

          // starts with
          case TagType.startswith:
            if (v2.startsWith(v1)) return true;
            break;

          // ends with
          case TagType.endwith:
            if (v2.endsWith(v1)) return true;
            break;

          // exact match
          case TagType.equal:
            if (v2 == v1) return true;
            break;

          // compares space separated keywords
          case TagType.keyword:
            var keywords = v1.split(" ");
            var values = v2.split(" ");
            bool ok = true;
            for (var keyword in keywords) {
              var match = values.firstWhereOrNull((value) => value.trim() == keyword.trim());
              if (match == null) {
                ok = false;
                break;
              }
            }
            if (ok) return true;
        }
      }
    }

    return false;
  }

  @override
  Future<bool> onDataSourceSuccess(IDataSource? source, Data? list) async {
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
      Log().error('Error building list. Error is $e', caller: 'TYPEAHEAD');
    }
    return true;
  }

  @override
  onDataSourceException(IDataSource source, Exception exception) {
    // Clear the List - Olajos 2021-09-04
    onDataSourceSuccess(null, null);
  }

  @override
  Widget getView({Key? key}) => getReactiveView(TypeaheadView(this));
}
