// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/event/handler.dart' ;
import 'package:fml/widgets/form/form_field_model.dart';
import 'package:fml/widgets/form/iFormField.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/input/input_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

enum InputFormats {numeric, integer, text, boolean, xml}
enum CapitalizationTypes {mixed, camel, upper, lower, sentences, words}

class InputModel extends FormFieldModel implements IFormField
{
  List<Suggestion> suggestions = [];

  // override
  double? get padding => super.padding == null ? 4 : super.padding;

  /// Capitilization sets the input to uppercase or lowercase with `upper` and `lower`
  // TODO: maybe change this to caps or uppercase = t/f?
  CapitalizationTypes? _capitalization;
  set capitalization(dynamic v) {
    if (v is CapitalizationTypes) _capitalization = v;
    _capitalization = S.toEnum(v, CapitalizationTypes.values);
  }

  CapitalizationTypes? get capitalization {
    return _capitalization;
  }

  // controller is maintained in the model so its state is maintained across rebuilds.
  TextEditingController? controller;

  /// The regex of characters to allow, will exclude everything else.
  StringObservable? _allow;
  set allow(dynamic v) {
    if (_allow != null) {
      _allow!.set(v);
    } else if (v != null) {
      _allow = StringObservable(Binding.toKey(id, 'allow'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get allow {
    if (_allow == null) return null;
    return _allow!.get();
  }

  /// The regex of characters to deny, will allow everything else.
  StringObservable? _deny;
  set deny(dynamic v) {
    if (_deny != null) {
      _deny!.set(v);
    } else if (v != null) {
      _deny = StringObservable(Binding.toKey(id, 'deny'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get deny {
    if (_deny == null) return null;
    return _deny!.get();
  }


  /// If the input will display its error state.
  BooleanObservable? _error;
  set error(dynamic v) {
    if (_error != null) {
      _error!.set(v);
    } else if (v != null) {
      _error = BooleanObservable(Binding.toKey(id, 'error'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool? get error {
    if (_error == null) return false;
    return _error!.get();
  }


  /// The error value of an input.
  StringObservable? _errortext;
  set errortext(dynamic v) {
    if (_errortext != null) {
      _errortext!.set(v);
    } else if (v != null) {
      _errortext = StringObservable(Binding.toKey(id, 'errortext'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get errortext {
    if (_errortext == null) return null;
    return _errortext!.get();
  }

  Suggestion? suggestion;

  /// If the input excludes the label above, and minimises the vertical space it takes up.
  BooleanObservable? _dense;
  set dense(dynamic v) {
    if (_dense != null) {
      _dense!.set(v);
    } else if (v != null) {
      _dense = BooleanObservable(Binding.toKey(id, 'dense'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool? get dense {
    if (_dense == null) return false;
    return _dense!.get();
  }

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

  bool? get clear {
    if (_clear == null) return false;
    return _clear!.get();
  }

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
  bool? get obscure
  {
    if (_obscure == null) return null;
    return _obscure!.get();
  }

  /// True if there is an alarm sounding on a [IFormField]
  BooleanObservable? _alarming;
  set alarming(dynamic v)
  {
    if (_alarming != null)
    {
      _alarming!.set(v);
    }
    else if (v != null)
    {
      _alarming = BooleanObservable(Binding.toKey(id, 'alarming'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool? get alarming
  {
    if (_alarming == null) return null;
    return _alarming!.get();
  }

  /// the value of the input. If not set to "" initially, the value will not be settable through events.
  StringObservable? _value;
  set value(dynamic v)
  {
    if (_value != null)
    {
      _value!.set(v);
    }
    else
    {
      if ((v != null) || (WidgetModel.isBound(this, Binding.toKey(id, 'value')))) _value = StringObservable(Binding.toKey(id, 'value'), v, scope: scope, listener: onPropertyChange);
    }
  }

  dynamic get value
  {
    if (_value == null) return defaultValue;
    if ((!dirty) && (S.isNullOrEmpty(_value!.get())) && (!S.isNullOrEmpty(defaultValue))) _value!.set(defaultValue);
    return _value!.get();
  }

  set valueNoModelChange(dynamic v)
  {
    if (_value != null) _value!.set(v, notify: false);
  }

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
  dynamic get mask
  {
    if (_mask == null) return null;
    return _mask!.get();
  }

  ///The format of the input for quick formatting. Currently boolean, integer, numeric, phone, currency, card, expiry, password, email .
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
  dynamic get format
  {
    if (_format == null) return null;
    return _format!.get();
  }

  /// The hint that sits inside of the input, and floats above if not dense and filled.
  StringObservable? _hint;
  set hint(dynamic v) {
    if (_hint != null) {
      _hint!.set(v);
    } else if (v != null) {
      _hint = StringObservable(Binding.toKey(id, 'hint'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get hint {
    if (_hint == null) return null;
    return _hint!.get();
  }

  /// The size of the font and height of the input.
  DoubleObservable? _size;
  set size(dynamic v) {
    if (_size != null) {
      _size!.set(v);
    } else if (v != null) {
      _size = DoubleObservable(Binding.toKey(id, 'size'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get size {
    if (_size == null) return null;
    return _size!.get();
  }


  /// The color of the text. Can be an array of 3 colors seperated by commas for enabled, disabled, and error.
  StringObservable? _textcolor;
  set textcolor(dynamic v) {
    if (_textcolor != null) {
      _textcolor!.set(v);
    } else if (v != null) {
      _textcolor = StringObservable(Binding.toKey(id, 'textcolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get textcolor {
    if (_textcolor == null) return null;
    return _textcolor!.get();
  }

  /// The weight of the font
  StringObservable? _weight;
  set weight(dynamic v) {
    if (_weight != null) {
      _weight!.set(v);
    } else if (v != null) {
      _weight = StringObservable(Binding.toKey(id, 'weight'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get weight {
    if (_weight == null) return null;
    return _weight!.get();
  }

  /// The style of the font. Will override weight and size.
  StringObservable? _style;
  set style(dynamic v) {
    if (_style != null) {
      _style!.set(v);
    } else if (v != null) {
      _style = StringObservable(Binding.toKey(id, 'style'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get style {
    if (_style == null) return null;
    return _style!.get();
  }

  /// The number of lines of text the input will display (vertical height).
  IntegerObservable? _lines;
  set lines(dynamic v) {
    if (_lines != null) {
      _lines!.set(v);
    } else if (v != null) {
      _lines = IntegerObservable(Binding.toKey(id, 'lines'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  int? get lines {
    if (_lines == null) return null;
    return _lines!.get();
  }

  IntegerObservable? _maxlines;
  set maxlines(dynamic v) {
    if (_maxlines != null) {
      _maxlines!.set(v);
    } else if (v != null) {
      _maxlines = IntegerObservable(Binding.toKey(id, 'maxlines'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  int? get maxlines {
    if (_maxlines == null) return null;
    return _maxlines!.get();
  }

  /// The maximum allowable length of the input in number of characters.
  IntegerObservable? _length;
  set length(dynamic v) {
    if (_length != null) {
      _length!.set(v);
    } else if (v != null) {
      _length = IntegerObservable(Binding.toKey(id, 'length'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  int? get length {
    if (_length == null) return null;
    return _length!.get();
  }

  /// The string of events that will be executed when focus is lost. 
  StringObservable? _onfocuslost;
  set onfocuslost(dynamic v) {
    if (_onfocuslost != null) {
      _onfocuslost!.set(v);
    } else if (v != null) {
      _onfocuslost = StringObservable(Binding.toKey(id, 'onfocuslost'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }

  String? get onfocuslost {
    return _onfocuslost?.get();
  }

  /// The prefix icon within the input
  IconObservable? _icon;
  set icon(dynamic v) {
    if (_icon != null) {
      _icon!.set(v);
    } else if (v != null) {
      _icon = IconObservable(Binding.toKey(id, 'icon'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  IconData? get icon {
    if (_icon == null) return null;
    return _icon!.get();
  }

  /// The keyoard type the input uses.
  StringObservable? _keyboardtype;

  set keyboardtype(dynamic v) {
    if (_keyboardtype != null) {
      _keyboardtype!.set(v);
    } else if (v != null) {
      _keyboardtype = StringObservable(
          Binding.toKey(id, 'keyboardtype'), v,
          scope: scope);
    }
  }

  String? get keyboardtype {
    if (_keyboardtype == null) return null;
    return _keyboardtype!.get();
  }

  ///////////////////
  /* keyboardinput */
  ///////////////////
  StringObservable? _keyboardinput;

  set keyboardinput(dynamic v) {
    if (_keyboardinput != null) {
      _keyboardinput!.set(v);
    } else if (v != null) {
      _keyboardinput = StringObservable(
          Binding.toKey(id, 'keyboardinput'), v,
          scope: scope);
    }
  }

  String? get keyboardinput {
    if (_keyboardinput == null) return null;
    return _keyboardinput!.get();
  }

  /// The radius of the border if all.
  DoubleObservable? _radius;
  set radius(dynamic v) {
    if (_radius != null) {
      _radius!.set(v);
    } else if (v != null) {
      _radius = DoubleObservable(Binding.toKey(id, 'radius'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get radius {
    if (_radius == null) return 5;
    return _radius!.get();
  }

  /// The color of the border for input, defaults to black54. Accepts 4 colors positionally. Enabled, disabled, focused, and error colors.
  StringObservable? _bordercolor;
  set bordercolor(dynamic v) {
    if (_bordercolor != null) {
      _bordercolor!.set(v);
    } else if (v != null) {
      _bordercolor = StringObservable(
          Binding.toKey(id, 'bordercolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get bordercolor {
    if (_bordercolor == null) return null;
    return _bordercolor!.get();
  }

  /// The width of the containers border, defaults to 2
  DoubleObservable? _borderwidth;
  set borderwidth(dynamic v) {
    if (_borderwidth != null) {
      _borderwidth!.set(v);
    } else if (v != null) {
      _borderwidth = DoubleObservable(
          Binding.toKey(id, 'borderwidth'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get borderwidth {
    if (_borderwidth == null) return 1;
    return _borderwidth!.get();
  }

  /// The border choice, can be `all`, `none`, `top`, `left`, `right`, `bottom`, `vertical`, or `horizontal`
  StringObservable? _border;
  set border(dynamic v) {
    if (_border != null) {
      _border!.set(v);
    } else if (v != null) {
      _border = StringObservable(Binding.toKey(id, 'border'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get border {
    if (_border == null) return 'all';
    return _border!.get()?.toLowerCase();
  }

  /// If the input has been focused at least once
  BooleanObservable? _touched;
  set touched(dynamic v) {
    if (_touched != null) {
      _touched!.set(v);
    } else if (v != null) {
      _touched = BooleanObservable(Binding.toKey(id, 'touched'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool? get touched {
    if (_touched == null) return false;
    return _touched!.get();
  }

  BooleanObservable? _wrap;
  set wrap(dynamic v) {
    if (_wrap != null) {
      _wrap!.set(v);
    } else if (v != null) {
      _wrap = BooleanObservable(Binding.toKey(id, 'wrap'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool? get wrap {
    if (_wrap == null) return false;
    return _wrap!.get();
  }

  BooleanObservable? _expand;
  set expand(dynamic v) {
    if (_expand != null) {
      _expand!.set(v);
    } else if (v != null) {
      _expand = BooleanObservable(Binding.toKey(id, 'expand'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool? get expand {
    if (_expand == null) return false;
    return _expand!.get();
  }

  InputModel(
    WidgetModel? parent,
    String? id, {
    String? type,
    dynamic visible,
    dynamic mandatory,
    dynamic wrap,
    dynamic editable,
    dynamic enabled,
    dynamic value,
    dynamic defaultValue,
    dynamic width,
    dynamic hint,
    dynamic size,
    dynamic color,
    dynamic weight,
    dynamic expand,
    dynamic style,
    dynamic lines,
    dynamic length,
    dynamic error,
    dynamic errortext,
    dynamic obscure,
    dynamic mask,
    dynamic clear,
    dynamic onchange,
    dynamic onfocuslost,
    dynamic halign,
    dynamic post,
    dynamic icon,
    dynamic allow,
    dynamic deny,
    dynamic dense,
    dynamic padding,
    dynamic keyboardtype,
    dynamic keyboardinput,
    dynamic format,
    dynamic border,
    dynamic maxlines,
    dynamic radius,
    dynamic bordercolor,
    dynamic borderwidth,
    dynamic textcolor,
    dynamic touched,
  }) : super(parent, id)
  {
    if (mandatory     != null) this.mandatory = mandatory;
    if (maxlines      != null) this.maxlines = maxlines;
    if (wrap          != null) this.wrap = wrap;
    if (expand        != null) this.expand = expand;
    if (editable      != null) this.editable = editable;
    if (enabled       != null) this.enabled = enabled;
    if (value         != null) this.value = value;
    if (mask          != null) this.mask = mask;
    if (color         != null) this.color = color;
    if (defaultValue  != null) this.defaultValue = defaultValue;
    if (width         != null) this.width = width;
    if (hint          != null) this.hint = hint;
    if (size          != null) this.size = size;
    if (weight        != null) this.weight = weight;
    if (style         != null) this.style = style;
    if (error         != null) this.error = error;
    if (errortext     != null) this.errortext = errortext;
    if (lines         != null) this.lines = lines;
    if (length        != null) this.length = length;
    if (padding       != null) this.padding = padding;
    if (obscure       != null) this.obscure = obscure;
    if (clear         != null) this.clear = clear;
    if (onchange      != null) this.onchange = onchange;
    if (onfocuslost   != null) this.onfocuslost = onfocuslost;
    if (halign        != null) this.halign = halign;
    if (post          != null) this.post = post;
    if (icon          != null) this.icon = icon;
    if (dense         != null) this.dense = dense;
    if (allow         != null) this.allow = allow;
    if (deny          != null) this.deny = deny;
    if (keyboardtype  != null) this.keyboardtype = keyboardtype;
    if (keyboardinput != null) this.keyboardinput = keyboardinput;
    if (format        != null) this.format = format;
    if (border        != null) this.border = border;
    if (radius        != null) this.radius = radius;
    if (bordercolor   != null) this.bordercolor = bordercolor;
    if (borderwidth   != null) this.borderwidth = borderwidth;
    if (textcolor     != null) this.textcolor = textcolor;
    if (touched       != null) this.touched = touched;

    this.alarming = false;
    this.dirty = false;
  }

  static InputModel? fromXml(WidgetModel parent, XmlElement xml, {String? type}) {
    InputModel? model;
    try
    {
      model = InputModel(parent, Xml.get(node: xml, tag: 'id'), type: type);
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'input.Model');
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
    padding = Xml.get(node: xml, tag: 'padding');
    format = Xml.get(node: xml, tag: S.fromEnum('type'));
    if (format == InputFormats.xml)
    {
      String? xml;
      XmlElement? child;
      if (child == null) child = Xml.getChildElement(node: element!, tag: S.fromEnum('value')!.toUpperCase());
      if (child == null) child = Xml.getChildElement(node: element!, tag: S.fromEnum('value')!.toLowerCase());
      if (child == null) child = Xml.getChildElement(node: element!, tag: S.fromEnum('value')!);
      if (child != null) xml = child.innerXml;
      if (xml != null)
      {
        //////////////////////////
        /* This Defeats Binding */
        //////////////////////////
        XmlDocument? document = Xml.tryParse(xml, silent: true);
        if (document != null) value = "";

        ///////////////////
        /* Set the Value */
        ///////////////////
        value = xml;
      }
    }
    else value = Xml.get(node: xml, tag: S.fromEnum('value'));
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
    error = Xml.get(node: xml, tag: 'error');
    errortext = Xml.get(node: xml, tag: 'errortext');
    onfocuslost = Xml.get(node: xml, tag: 'onfocuslost');
    icon = Xml.get(node: xml, tag: 'icon');
    keyboardtype = Xml.get(node: xml, tag: 'keyboardtype');
    keyboardinput = Xml.get(node: xml, tag: 'keyboardinput');
    allow = Xml.get(node: xml, tag: 'allow');
    deny = Xml.get(node: xml, tag: 'deny');
    capitalization = Xml.get(node: xml, tag: 'case');
    dense = Xml.get(node: xml, tag: 'dense');
    border = Xml.get(node: xml, tag: 'border');
    radius = Xml.get(node: xml, tag: 'radius');
    bordercolor = Xml.get(node: xml, tag: 'bordercolor');
    borderwidth = Xml.get(node: xml, tag: 'borderwidth');
    textcolor = Xml.get(node: xml, tag: 'textcolor');
    mask = Xml.get(node: xml, tag: 'mask');
    touched = Xml.get(node: xml, tag: 'touched');
  }

  @override
  dispose() {
// Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Future<bool> onFocusLost(BuildContext context) async {
    return await EventHandler(this).execute(_onfocuslost);
  }

  Widget getView({Key? key}) => getReactiveView(InputView(this));
}

class Suggestion {
  final dynamic text;

  Suggestion({this.text});
}
