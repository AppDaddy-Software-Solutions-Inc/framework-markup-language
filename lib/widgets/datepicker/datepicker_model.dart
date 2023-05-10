// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/form/form_field_model.dart';
import 'package:fml/widgets/form/form_field_interface.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/datepicker/datepicker_view.dart';
import 'package:intl/intl.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

enum METHODS { launch }

class DatepickerModel extends FormFieldModel implements IFormField
{
  bool isPicking = false;

  static const timeFormatDefault = "HH:mm";
  static const dateFormatDefault = "yyyy-MM-dd";

  // padding
  DoubleObservable? _padding;
  @override
  set padding(dynamic v)
  {
    if (_padding != null) {
      _padding!.set(v);
    } else if (v != null) {
      _padding = DoubleObservable(Binding.toKey(id, 'padding'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double get padding=> _padding?.get() ?? 4;
  
  // view
  BooleanObservable? _view;

  set view(dynamic v) {
    if (_view != null) {
      _view!.set(v);
    } else if (v != null) {
      _view = BooleanObservable(Binding.toKey(id, 'view'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool? get view {
    if (_view == null) return true;
    return _view?.get();
  }

  /// Mode is the entrymode type of the datepicker. Can be gui, input, bothgui, bothinput.
  StringObservable? _type;

  set type(dynamic v) {
    if (_type != null) {
      _type!.set(v);
    } else if (v != null) {
      _type = StringObservable(Binding.toKey(id, 'type'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String get type => _type?.get() ?? "date";

  /// Mode is the entrymode type of the datepicker. Can be gui, input, bothgui, bothinput.
  StringObservable? _mode;

  set mode(dynamic v) {
    if (_mode != null) {
      _mode!.set(v);
    } else if (v != null) {
      _mode = StringObservable(Binding.toKey(id, 'mode'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String get mode => _mode?.get() ?? "bothgui";

  /// Newest date available for selection. DATE___ only.
  StringObservable? _newest;
  set newest(dynamic v) {
    if (_newest != null) {
      _newest!.set(v);
    } else if (v != null) {
      _newest = StringObservable(Binding.toKey(id, 'newest'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get newest => _newest?.get();

  // Oldest date available on selection. DATE___ only.
  StringObservable? _oldest;

  set oldest(dynamic v) {
    if (_oldest != null) {
      _oldest!.set(v);
    } else if (v != null) {
      _oldest = StringObservable(Binding.toKey(id, 'oldest'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get oldest => _oldest?.get();

  /// Format string expected from the input and output. See https://api.flutter.dev/flutter/intl/DateFormat-class.html.
  StringObservable? _format;

  set format(dynamic v) {
    if (_format != null) {
      _format!.set(v);
    } else if (v != null) {
      _format = StringObservable(Binding.toKey(id, 'format'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get format => _format?.get() ?? "yMd";

  // Value
  StringObservable? _value;

  @override
  set value(dynamic v) {
    if (_value != null) {
      _value!.set(v);
    } else {
      if ((v != null) ||
          (WidgetModel.isBound(this, Binding.toKey(id, 'value')))) {
        _value = StringObservable(Binding.toKey(id, 'value'), v,
            scope: scope, listener: onPropertyChange);
      }
    }
  }
  @override
  dynamic get value
  {
    if (_value == null) return defaultValue;
    if ((!dirty) &&
        (S.isNullOrEmpty(_value?.get())) &&
        (!S.isNullOrEmpty(defaultValue))) _value!.set(defaultValue);
    return _value?.get();
  }

  // hint
  StringObservable? _hint;
  set hint(dynamic v) {
    if (_hint != null) {
      _hint!.set(v);
    } else if (v != null) {
      _hint = StringObservable(Binding.toKey(id, 'hint'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get hint => _hint?.get();

  // Radius
  StringObservable? _radius;
  set radius(dynamic v) {
    if (_radius != null) {
      _radius!.set(v);
    } else if (v != null) {
      _radius = StringObservable(Binding.toKey(id, 'radius'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get radius => _radius?.get()?.toLowerCase();

  /// The color of the border for box, defaults to black54
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
  String? get bordercolor => _bordercolor?.get();

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
  double get borderwidth => _borderwidth?.get() ?? 1;

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
  String get border => _border?.get()?.toLowerCase() ?? 'all';

  StringObservable? _textcolor;
  set textcolor(dynamic v) {
    if (_textcolor != null) {
      _textcolor!.set(v);
    } else if (v != null) {
      _textcolor = StringObservable(Binding.toKey(id, 'textcolor'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get textcolor => _textcolor?.get();

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
  String? get weight => _weight?.get();

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
  String? get style => _style?.get();

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
  bool get dense => _dense?.get() ?? false;

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
  double? get size => _size?.get();
  
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
  IconData? get icon => _icon?.get();

  DatepickerModel(
    WidgetModel parent,
    String? id, {
    String? type,
    dynamic width,
    dynamic hint,
    dynamic format,
    dynamic radius,
    dynamic bordercolor,
    dynamic borderwidth,
    dynamic border,
    dynamic textcolor,
    dynamic color,
    dynamic weight,
    dynamic style,
    dynamic dense,
    dynamic clear,
    dynamic size,
    dynamic padding,
    dynamic icon,
  }) : super(parent, id)
  {
    if (type         != null) this.type = type;
    if (width        != null) this.width = width;
    if (hint         != null) this.hint = hint;
    if (format       != null) this.format = format;
    if (radius       != null) this.radius = radius;
    if (bordercolor  != null) this.bordercolor = bordercolor;
    if (borderwidth  != null) this.borderwidth = borderwidth;
    if (border       != null) this.border = border;
    if (textcolor    != null) this.textcolor = textcolor;
    if (color        != null) this.color = color;
    if (weight       != null) this.weight = weight;
    if (style        != null) this.style = style;
    if (dense        != null) this.dense = dense;
    if (clear        != null) this.clear = clear;
    if (size         != null) this.size = size;
    if (padding      != null) this.padding = padding;
    if (icon         != null) this.icon = icon;
  }

  static DatepickerModel? fromXml(WidgetModel parent, XmlElement xml, {String? type})
  {
    DatepickerModel? model;
    try 
    {
      model = DatepickerModel(parent, Xml.get(node: xml, tag: 'id'), type: type);
      model.deserialize(xml);
    } 
    catch(e) 
    {
      Log().exception(e,  caller: 'datepicker.Model');
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
    value   = Xml.get(node: xml, tag: 'value') ?? defaultValue ?? "";
    type    = Xml.get(node: xml, tag: 'type') ?? type;
    hint    = Xml.get(node: xml, tag: 'hint');
    view    = Xml.get(node: xml, tag: 'view');
    oldest  = Xml.get(node: xml, tag: 'oldest');
    newest  = Xml.get(node: xml, tag: 'newest');
    format  = Xml.get(node: xml, tag: 'format');
    mode    = Xml.get(node: xml, tag: 'mode');
    bordercolor = Xml.get(node: xml, tag: 'bordercolor');
    borderwidth = Xml.get(node: xml, tag: 'borderwidth');
    radius = Xml.get(node: xml, tag: 'radius');
    border = Xml.get(node: xml, tag: 'border');
    textcolor = Xml.get(node: xml, tag: 'textcolor');
    weight = Xml.get(node: xml, tag: 'weight');
    style = Xml.get(node: xml, tag: 'style');
    dense = Xml.get(node: xml, tag: 'dense');
    clear = Xml.get(node: xml, tag: 'clear');
    error = Xml.get(node: xml, tag: 'error');
    errortext = Xml.get(node: xml, tag: 'errortext');
    size = Xml.get(node: xml, tag: 'size');
    icon = Xml.get(node: xml, tag: 'icon');
    padding = Xml.get(node: xml, tag: 'padding');
  }


  @override
  dispose() {
// Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  @override
  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async
  {
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    switch (function)
    {
      case "start": return await show(context, mode, type, oldest, newest, format);
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  Future show(BuildContext? buildContext, String? mode, String pick,
      String? oldest, String? newest, String? format) async {
    TimePickerEntryMode tmode = TimePickerEntryMode.dial;
    DatePickerEntryMode dmode = DatePickerEntryMode.calendar;
    switch (mode) {
      case "gui":
        {
          tmode = TimePickerEntryMode.dial;
          dmode = DatePickerEntryMode.calendarOnly;
        }
        break;
      case "input":
        {
          tmode = TimePickerEntryMode.input;
          dmode = DatePickerEntryMode.inputOnly;
        }
        break;
      case "bothinput":
        {
          tmode = TimePickerEntryMode.input;
          dmode = DatePickerEntryMode.input;
        }
        break;
      case "bothgui":
        {
          tmode = TimePickerEntryMode.dial;
          dmode = DatePickerEntryMode.calendar;
        }
        break;
      default:
        {
          tmode = TimePickerEntryMode.dial;
          dmode = DatePickerEntryMode.calendar;
        }
        break;
    }

    DateTime? result = DateTime.now();
    DateTimeRange? range;
    TimeOfDay? timeResult = TimeOfDay.now();

    if (type == "range") {
      range = await showDateRangePicker(
        context: buildContext!,
        initialEntryMode: dmode,
        firstDate: S.toDate(oldest, format: format) ??
            DateTime(DateTime.now().year - 100),
        currentDate: DateTime.now(),
        lastDate: S.toDate(newest, format: format) ??
            DateTime(DateTime.now().year + 10),
      );
      if (range == null) return;
      return setValue(range.start, timeResult, format, secondResult: range.end);
    } else if (type != "time") {
      result = await (showDatePicker(
        context: buildContext!,
        initialDatePickerMode: type == "year" || type == "yeartime"
            ? DatePickerMode.year
            : DatePickerMode.day,
        // selectableDayPredicate: ,
        initialEntryMode: dmode,
        firstDate: S.toDate(oldest, format: format) ??
            DateTime(DateTime.now().year - 100),
        initialDate: S.toDate(value, format: format) ?? DateTime.now(),
        lastDate: S.toDate(newest, format: format) ?? DateTime(DateTime.now().year + 10)));


      if(type == 'datetime' || type == 'yeartime' || type == 'rangetime') {
       TimeOfDay time = TimeOfDay.now();
       timeResult = await showTimePicker(
           context: buildContext,
           initialTime: time,
           initialEntryMode: tmode);
     }

      setValue(result, timeResult, format);
      return;
    } else {
      TimeOfDay time = TimeOfDay.now();
      try {
        time = (TimeOfDay.fromDateTime(S.toDate(value, format: format)!));
      } catch(e) {
        Log().exception(e, caller: 'Datepicker');
        value = '';
      }
      timeResult = await showTimePicker(
        context: buildContext!,
        initialTime: time,
        initialEntryMode: tmode);
    }

    setValue(result, timeResult, format);
    return;
  }




  void setValue(DateTime? result, TimeOfDay? timeResult, String? format,
      {DateTime? secondResult}) {
    DateTime now = DateTime.now();

    //return result based on type and format

    if (type == "date" || type == "year" || type == "range") {
      try {
        if (secondResult != null) {
          value = "${DateFormat(format).format(result!)} - ${DateFormat(format).format(secondResult)}";
        } else {
          value = DateFormat(format, 'en_US').format(result!);
        }
      } on FormatException catch(e) {
        Log().debug('${e}FORMATTING ERROR!!!!!');
      }
    } else if (type == "time") {
      if (format == 'yMd') format= 'H:m';
      try {
        value = DateFormat(format).format(DateTime(now.year, now.month,
                now.day, timeResult!.hour, timeResult.minute));
      } on FormatException catch(e) {
        Log().debug('${e}FORMATTING ERROR!!!!!');
        value = '';
      }
    } else {
      if (format == 'yMd') {format= 'y/M/d H:mm'; this.format = "y/M/d H:mm";}
      try {
        value = DateFormat(format).format(DateTime(result!.year, result.month,
                result.day, timeResult!.hour, timeResult.minute));
      } on FormatException catch(e) {
        Log().debug('${e}FORMATTING ERROR!!!!!');
        value = '';
      }
    }
    onChange(context);
  }

  @override
  Widget getView({Key? key}) => getReactiveView(DatepickerView(this));

}
