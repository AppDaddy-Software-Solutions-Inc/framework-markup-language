// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/form/decorated_input_model.dart';
import 'package:fml/widgets/form/form_field_interface.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/datepicker/datepicker_view.dart';
import 'package:intl/intl.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

enum METHODS { launch }

class DatepickerModel extends DecoratedInputModel implements IFormField
{
  bool isPicking = false;

  static const timeFormatDefault = "HH:mm";
  static const dateFormatDefault = "yyyy-MM-dd";

  @override
  bool get canExpandInfinitelyWide => !hasBoundedWidth;

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
  String? get format => _format?.get();

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
    if (!dirty && S.isNullOrEmpty(_value?.get()) && !S.isNullOrEmpty(defaultValue)) _value!.set(defaultValue);
    return _value?.get();
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
  bool get clear => _clear?.get() ?? false;

  DatepickerModel(
    WidgetModel parent,
    String? id, {
    String? type,
    dynamic format,
    dynamic clear,
  }) : super(parent, id)
  {
    if (type         != null) this.type = type;
    if (format       != null) this.format = format;
    if (clear        != null) this.clear = clear;
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

    setFormat();

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
      //if (format == 'yMd') format= 'H:m';
      try {
        value = DateFormat(format).format(DateTime(now.year, now.month,
                now.day, timeResult!.hour, timeResult.minute));
      } on FormatException catch(e) {
        Log().debug('${e}FORMATTING ERROR!!!!!');
        value = '';
      }
    } else {
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

  void setFormat(){
    if (format != null) return;
    if (type == "date" || type == "year" || type == "range") {
      format ='y/M/d';
    } else if (type == "time") {
      format= 'H:m';
    } else {
      format = 'y/M/d H:mm';
    }

  }

  @override
  Widget getView({Key? key}) => getReactiveView(DatepickerView(this));

}
