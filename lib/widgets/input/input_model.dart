// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/alarm/alarm_model.dart';
import 'package:fml/widgets/form/decorated_input_model.dart';
import 'package:fml/widgets/form/form_field_interface.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/input/input_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:xml/xml.dart';

enum CapitalizationTypes { mixed, camel, upper, lower, sentences, words }

class InputModel extends DecoratedInputModel implements IFormField {

  @override
  bool get canExpandInfinitelyWide => !hasBoundedWidth;

  List<Suggestion> suggestions = [];

  /// Capitilization sets the input to uppercase or lowercase with `upper` and `lower`
  // TODO: maybe change this to caps or uppercase = t/f?
  CapitalizationTypes? _capitalization;
  set capitalization(dynamic v)
  {
    if (v is CapitalizationTypes) _capitalization = v;
    _capitalization = toEnum(v, CapitalizationTypes.values);
  }
  CapitalizationTypes? get capitalization => _capitalization;

  // controller is maintained in the model so its state is maintained across rebuilds.
  TextEditingController? controller;

  /// The regex of characters to allow, will exclude everything else.
  StringObservable? _allow;
  set allow(dynamic v)
  {
    if (_allow != null)
    {
      _allow!.set(v);
    }
    else if (v != null)
    {
      _allow = StringObservable(Binding.toKey(id, 'allow'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get allow => _allow?.get();

  /// The regex of characters to deny, will allow everything else.
  StringObservable? _deny;
  set deny(dynamic v)
  {
    if (_deny != null)
    {
      _deny!.set(v);
    }
    else if (v != null)
    {
      _deny = StringObservable(Binding.toKey(id, 'deny'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get deny => _deny?.get();

  Suggestion? suggestion;

  /// If the input shows the clear icon on its right.
  BooleanObservable? _clear;
  set clear(dynamic v)
  {
    if (_clear != null)
    {
      _clear!.set(v);
    }
    else if (v != null)
    {
      _clear = BooleanObservable(Binding.toKey(id, 'clear'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get clear => _clear?.get() ?? false;

  /// If the input will obscure its characters.
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
  bool get obscure => _obscure?.get() ?? formatType == 'password' ? true : false;

  /// the value of the input. If not set to "" initially, the value will not be settable through events.
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
      _value = StringObservable(Binding.toKey(id, 'value'), v, scope: scope, listener: onPropertyChange);
    }
  }

  @override
  dynamic get value => dirty ? _value?.get() : _value?.get() ?? defaultValue;

  // mask
  StringObservable? _mask;
  set mask(dynamic v)
  {
    if (_mask != null)
    {
      _mask!.set(v);
    }
    else if (v != null)
    {
      _mask = StringObservable(Binding.toKey(id, 'mask'), v, scope: scope, listener: onPropertyChange);
    }
  }
  dynamic get mask => _mask?.get();

  // The format of the input for quick formatting. Currently boolean, integer, numeric, phone, currency, card, expiry, password, email .
  StringObservable? _format;
  set format(dynamic v)
  {
    if (_format != null)
    {
      _format!.set(v);
    }
    else if (v != null)
    {
      _format = StringObservable(Binding.toKey(id, 'format'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get format => _format?.get();

  // format type
  String? get formatType => format?.split(',')[0].trim().toLowerCase();

  /// The number of lines of text the input will display (vertical height).
  IntegerObservable? _lines;
  set lines(dynamic v)
  {
    if (_lines != null)
    {
      _lines!.set(v);
    }
    else if (v != null)
    {
      _lines = IntegerObservable(Binding.toKey(id, 'lines'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int? get lines => _lines?.get();

  IntegerObservable? _maxlines;
  set maxlines(dynamic v)
  {
    if (_maxlines != null)
    {
      _maxlines!.set(v);
    }
    else if (v != null)
    {
      _maxlines = IntegerObservable(Binding.toKey(id, 'maxlines'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int? get maxlines => _maxlines?.get();

  /// The maximum allowable length of the input in number of characters.
  IntegerObservable? _length;
  set length(dynamic v)
  {
    if (_length != null)
    {
      _length!.set(v);
    }
    else if (v != null)
    {
      _length = IntegerObservable(Binding.toKey(id, 'length'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int? get length => _length?.get();

  /// The keyoard type the input uses.
  StringObservable? _keyboardType;
  set keyboardType(dynamic v)
  {
    if (_keyboardType != null)
    {
      _keyboardType!.set(v);
    }
    else if (v != null)
    {
      _keyboardType = StringObservable(Binding.toKey(id, 'keyboardtype'), v, scope: scope);
    }
  }
  String? get keyboardType => _keyboardType?.get();

  // keyboardinput
  StringObservable? _keyboardInput;
  set keyboardInput(dynamic v)
  {
    if (_keyboardInput != null)
    {
      _keyboardInput!.set(v);
    }
    else if (v != null)
    {
      _keyboardInput = StringObservable(Binding.toKey(id, 'keyboardinput'), v, scope: scope);
    }
  }
  String? get keyboardInput => _keyboardInput?.get();

  BooleanObservable? _wrap;
  set wrap(dynamic v)
  {
    if (_wrap != null)
    {
      _wrap!.set(v);
    }
    else if (v != null)
    {
      _wrap = BooleanObservable(Binding.toKey(id, 'wrap'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get wrap => _wrap?.get() ?? false;

  InputModel(
    super.parent,
    super.id, {
    String? type,
    dynamic wrap,
    dynamic value,
    dynamic defaultValue,
    dynamic lines,
    dynamic length,
    dynamic obscure,
    dynamic icon,
    dynamic hint,
    dynamic mask,
    dynamic clear,
    dynamic halign,
    dynamic allow,
    dynamic deny,
    dynamic keyboardType,
    dynamic keyboardInput,
    dynamic format,
    dynamic maxlines,
  })
  {
    if (maxlines != null) this.maxlines = maxlines;
    if (wrap != null) this.wrap = wrap;
    if (icon != null) this.icon = icon;
    if (hint != null) this.hint = hint;
    if (value != null) this.value = value;
    if (mask != null) this.mask = mask;
    if (defaultValue != null) this.defaultValue = defaultValue;
    if (lines != null) this.lines = lines;
    if (length != null) this.length = length;
    if (obscure != null) this.obscure = obscure;
    if (clear != null) this.clear = clear;
    if (halign != null) this.halign = halign;
    if (allow != null) this.allow = allow;
    if (deny != null) this.deny = deny;
    if (keyboardType != null) this.keyboardType = keyboardType;
    if (keyboardInput != null) this.keyboardInput = keyboardInput;
    if (format != null) this.format = format;

    alarming = false;
    dirty = false;
  }

  static InputModel? fromXml(WidgetModel parent, XmlElement xml, {String? type})
  {
    InputModel? model;
    try
    {
      model = InputModel(parent, Xml.get(node: xml, tag: 'id'), type: type);
      model.deserialize(xml);
    }
    catch (e)
    {
      Log().exception(e, caller: 'input.Model');
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
    format = Xml.get(node: xml, tag: fromEnum('type'));
    if (formatType == "xml")
    {
      String? xml;
      XmlElement? child;
      child ??= Xml.getChildElement(node: element!, tag: fromEnum('value')!.toUpperCase());
      child ??= Xml.getChildElement(node: element!, tag: fromEnum('value')!.toLowerCase());
      child ??= Xml.getChildElement(node: element!, tag: fromEnum('value')!);
      if (child != null) xml = child.innerXml;
      if (xml != null)
      {
        // This Defeats Binding
        XmlDocument? document = Xml.tryParse(xml, silent: true);
        if (document != null) value = "";
        value = xml;
      }
    }
    else
    {
      value = Xml.get(node: xml, tag: fromEnum('value'));
    }

    // set validator
    setValidator(Xml.get(node: xml, tag: 'errortext'));

    hint = Xml.get(node: xml, tag: 'hint') ?? "";
    size = Xml.get(node: xml, tag: 'size');
    weight = Xml.get(node: xml, tag: 'weight');
    style = Xml.get(node: xml, tag: 'style');
    lines = Xml.get(node: xml, tag: 'lines');
    length = Xml.get(node: xml, tag: 'length');
    obscure = Xml.get(node: xml, tag: 'obscure');
    clear = Xml.get(node: xml, tag: 'clear');
    maxlines = Xml.get(node: xml, tag: 'maxlines');
    expand = Xml.get(node: xml, tag: 'expand');
    onfocuslost = Xml.get(node: xml, tag: 'onfocuslost');
    icon = Xml.get(node: xml, tag: 'icon');
    keyboardType = Xml.get(node: xml, tag: 'keyboardtype');
    keyboardInput = Xml.get(node: xml, tag: 'keyboardinput');
    allow = Xml.get(node: xml, tag: 'allow');
    deny = Xml.get(node: xml, tag: 'deny');
    capitalization = Xml.get(node: xml, tag: 'case');
    dense = Xml.get(node: xml, tag: 'dense');
    border = Xml.get(node: xml, tag: 'border');
    radius = Xml.get(node: xml, tag: 'radius');
    borderColor = Xml.get(node: xml, tag: 'bordercolor');
    borderWidth = Xml.get(node: xml, tag: 'borderwidth');
    textcolor = Xml.get(node: xml, tag: 'textcolor');
    mask = Xml.get(node: xml, tag: 'mask');
  }

  setValidator(String? defaultText)
  {
    // format type
    if (parent != null)
    {
      switch (formatType)
      {
        case 'credit':
          var alarm = AlarmModel(parent!, null,type:AlarmType.validation,text: defaultText ?? "Invalid card number",alarm: "=!isCard({$id.value})");
          addAlarm(alarm, position: 0);
          break;

        case 'expire':
          var alarm = AlarmModel(parent!, null,type:AlarmType.validation,text: defaultText ?? "Invalid expiry date", alarm: "=!isExpiry({$id.value})");
          addAlarm(alarm, position: 0);
          break;

        case 'phone':
          var alarm = AlarmModel(parent!, null,type:AlarmType.validation,text: defaultText ?? "Invalid phone number", alarm: "=!isPhone({$id.value})");
          addAlarm(alarm, position: 0);
          break;

        case 'password':
          var alarm = AlarmModel(parent!, null,type:AlarmType.validation,text: defaultText ?? "The password must be at least 8 characters long, including upper/lowercase and a number", alarm: "=!isPassword({$id.value})");
          addAlarm(alarm, position: 0);
          break;

        case 'email':
          var alarm = AlarmModel(parent!, null,type:AlarmType.validation,text: defaultText ?? "Invalid email", alarm: "=!isEmail({$id.value})");
          addAlarm(alarm, position: 0);
          break;

        default:
          break;
      }
    }
  }

  @override
  dispose()
  {
    controller?.dispose();
    controller = null;

    super.dispose();
  }

  @override
  Widget getView({Key? key}) => getReactiveView(InputView(this));
}

class Suggestion
{
  final dynamic text;
  Suggestion({this.text});
}
