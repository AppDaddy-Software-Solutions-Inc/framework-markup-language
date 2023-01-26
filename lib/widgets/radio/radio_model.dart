// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/dialog/service.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/phrase.dart';
import 'package:fml/widgets/form/form_field_model.dart';
import 'package:fml/widgets/form/iFormField.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/option/option_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/radio/radio_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class RadioModel extends FormFieldModel implements IFormField, IViewableWidget
{
  // prototype
  String? prototype;

  // options
  List<OptionModel> options = [];

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

  /// True if there is an alarm sounding on a [IFormField]
  BooleanObservable? _alarming;
  set alarming(dynamic v) {
    if (_alarming != null) {
      _alarming!.set(v);
    } else if (v != null) {
      _alarming = BooleanObservable(Binding.toKey(id, 'alarming'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool? get alarming => _alarming?.get();

  /// the value of the widget. The label becomes the value if not specified. If specified, the options will reflect the value.
  StringObservable? _value;
  set value(dynamic v) {
    if (_value != null) {

      _value!.set(v);

        if (v != null) v = v.toString();
        dynamic data;
        options.forEach((option)
        {
          if (option.value == v) data = option.data;
        });
        this.data = data;
      }
    else
    {
      if ((v != null) || (WidgetModel.isBound(this, Binding.toKey(id, 'value')))) _value = StringObservable(Binding.toKey(id, 'value'), v, scope: scope, listener: onPropertyChange);
    }
  }

  dynamic get value {
    if (_value == null) return defaultValue;
    if ((!dirty) && (S.isNullOrEmpty(_value?.get())) && (!S.isNullOrEmpty(defaultValue))) _value!.set(defaultValue);
    return _value?.get();
  }

  /// the size of the options radio button
  DoubleObservable? _size;
  set size(dynamic v) {
    if (_size != null) {
      _size!.set(v);
    } else {
      if (v != null)
        _size = DoubleObservable(Binding.toKey(id, 'size'), v,
            scope: scope, listener: onPropertyChange);
    }
  }
  double get size
  {
    double? s = _size?.get();
    if ((s == null) || (s < 0)) s = 24.0;
    return s;
  }

  // bindable data
  ListObservable? _data;
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
  dynamic get data => _data?.get();

  RadioModel(
    WidgetModel parent,
    String? id, {
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
  }) : super(parent, id)
  {
    if (mandatory    != null) this.mandatory    = mandatory;
    if (editable     != null) this.editable     = editable;
    if (enabled      != null) this.enabled      = enabled;
    if (value        != null) this.value        = value;
    if (defaultValue != null) this.defaultValue = defaultValue;
    if (width        != null) this.width        = width;
    if (size         != null) this.size         = size;
    if (color        != null) this.color        = color;
    if (post         != null) this.post         = post;
    if (onchange     != null) this.onchange     = onchange;
    if (layout       != null) this.layout       = layout;
    if (center       != null) this.center       = center;
    if (halign       != null) this.halign       = halign;
    if (valign       != null) this.valign       = valign;
    if (wrap         != null) this.wrap         = wrap;

    this.alarming = false;
    this.dirty    = false;
  }

  static RadioModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    RadioModel? model;
    try
    {
      model = RadioModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'radio.Model');
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
    value  = Xml.get(node: xml, tag: 'value');
    layout = Xml.get(node: xml, tag: 'layout');
    center = Xml.get(node: xml, tag: 'center');
    wrap = Xml.get(node: xml, tag: 'wrap');
    size = Xml.get(node: xml, tag: 'size');

    // Build options
    this.options.clear();
    List<OptionModel> options = findChildrenOfExactType(OptionModel).cast<OptionModel>();

      // set prototype
      if ((!S.isNullOrEmpty(datasource)) && (options.isNotEmpty))
      {
        prototype = S.toPrototype(options[0].element.toString());
        options.removeAt(0);
      }
      // build options
      options.forEach((option) => this.options.add(option));

  }

  Future<bool> onDataSourceSuccess(IDataSource source, Data? list) async
  {
    try
    {
      if (prototype == null) return true;

      options.clear();

      // build options
      int i = 0;
      if ((list != null))
      {
        // build options
        list.forEach((row)
        {
          XmlElement? prototype = S.fromPrototype(this.prototype, "${this.id}-$i");
          i = i + 1;
          var model = OptionModel.fromXml(this, prototype, data: row);
          if (model != null) options.add(model);
        });
      }

      // Set value to first option or null if the current value is not in option list
      if (!containsOption()) value = options.isNotEmpty ? options[0].value : null;

      // set the data
      setData();

      // notify listeners
      notifyListeners('options', options);
    }
    catch(e)
    {
      DialogService().show(
          type: DialogType.error,
          title: phrase.error,
          description: e.toString());
    }
    return true;
  }

  @override
  dispose() {
Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Future<bool> onCheck(OptionModel option) async
  {
    // set answer
    bool ok = await answer(option.value);

    // set data
    if (ok == true) ok = await setData();

    // fire onchange
    if (ok == true) ok = await onChange(context);

    return ok;
  }

  bool containsOption()
  {
    bool contains = false;
      options.forEach((option)
      {
        if (option.value == value) contains = true;
      });
    return contains;
  }

  Future<bool> setData() async
  {
    // set the data
    List<dynamic> data = [];
    options.forEach((option)
    {
      bool contains = (value == option.value);
      if ((contains) && (option.data != null)) data.add(option.data);
    });
    this.data = data;
    return true;
  }

  Widget getView({Key? key}) => RadioView(this);
}
