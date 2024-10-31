// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/form/decorated_input_model.dart';
import 'package:fml/widgets/form/form_field_interface.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/reactive/reactive_view.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/widgets/datepicker/datepicker_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

class DatepickerModel extends DecoratedInputModel implements IFormField {
  DatepickerViewState? datepicker;

  bool isPicking = false;

  static const timeFormatDefault = "HH:mm";
  static const dateFormatDefault = "yyyy-MM-dd";

  @override
  bool get canExpandInfinitelyWide => !hasBoundedWidth;

  // readonly
  BooleanObservable? _showicon;
  set showicon(dynamic v) {
    if (_showicon != null) {
      _showicon!.set(v);
    } else if (v != null) {
      _showicon = BooleanObservable(Binding.toKey(id, 'showicon'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get showicon => _showicon?.get() ?? true;
  /// type of the date picker. Can be "datetime", "date", "time", "range" or "year"
  StringObservable? _type;
  set type(dynamic v) {
    if (_type != null) {
      _type!.set(v);
    } else if (v != null) {
      _type = StringObservable(Binding.toKey(id, 'type'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String get type => _type?.get()?.trim().toLowerCase() ?? "date";

  /// Mode is the entry mode type of the date picker dialog. Can be input, inputOnly, year, calendar or calendarOnly
  StringObservable? _cmode;
  set cmode(dynamic tmode) {
    if (_cmode != null) {
      _cmode!.set(tmode);
    } else if (tmode != null) {
      _cmode = StringObservable(Binding.toKey(id, 'cmode'), tmode,
          scope: scope, listener: onPropertyChange);
    }
  }
  String get cmode => _cmode?.get()?.toLowerCase().trim() ?? "calendar";

  /// Mode is the entry mode type of the time picker dialog. Can be input, inputOnly, dial or dialOnly
  StringObservable? _tmode;
  set tmode(dynamic tmode) {
    if (_tmode != null) {
      _tmode!.set(tmode);
    } else if (tmode != null) {
      _tmode = StringObservable(Binding.toKey(id, 'tmode'), tmode,
          scope: scope, listener: onPropertyChange);
    }
  }
  String get tmode => _tmode?.get()?.toLowerCase().trim() ?? "input";
  
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
  String get format {

    var format = _format?.get();
    if (!isNullOrEmpty(format)) {

      // validate the format
      var ok = toDateString(DateTime.now(), format: format) != null;

      // if the format is valid, return it
      if (ok) return format!;
    }

    // set date format according to type
    format = 'y/M/d HH:mm';
    if (type == "date" || type == "year" || type == "range") {
      format = 'y/M/d';
    } else if (type == "time") {
      format = 'HH:mm';
    }
    return format;
  }

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

  /// the date value
  StringObservable? _value;
  @override
  set value(dynamic v) {
    if (_value != null) {
      _value!.set(v);
    }
    else if (v != null) {
      _value = StringObservable(Binding.toKey(id, 'value'), v, scope: scope, listener: onPropertyChange);
    }
  }
  @override
  String? get value => dirty ? _value?.get() : _value?.get() ?? defaultValue;

  /// the date value
  StringObservable? _value2;
  set value2(dynamic v) {
    if (_value2 != null) {
      _value2!.set(v);
    }
    else if (v != null) {
      _value2 = StringObservable(Binding.toKey(id, 'value2'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get value2 => _value2?.get();

  // values
  @override
  List<String>? get values {
    List<String> list = [];
    if (!isNullOrEmpty(value))
    {
      list.add(value!);
      if (!isNullOrEmpty(value2)) list.add(value2!);
    }
    return list.isEmpty ? null : list;
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
  bool get clear => _clear?.get() ?? true;

  DatepickerModel(
    Model super.parent,
    super.id, {
    String? type,
    dynamic format,
    dynamic clear,
    dynamic showicon,
  }) {
    if (type != null) this.type = type;
    if (format != null) this.format = format;
    if (clear != null) this.clear = clear;
    if (showicon != null) this.showicon = showicon;
  }

  static DatepickerModel? fromXml(Model parent, XmlElement xml,
      {String? type}) {
    DatepickerModel? model;
    try {
      model =
          DatepickerModel(parent, Xml.get(node: xml, tag: 'id'), type: type);
      model.deserialize(xml);
    } catch (e) {
      Log().exception(e, caller: 'datepicker.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {

    // deserialize
    super.deserialize(xml);

    type   = Xml.get(node: xml, tag: 'type');
    format = Xml.get(node: xml, tag: 'format');

    // set properties
    value  = Xml.get(node: xml, tag: 'value') ?? defaultValue;
    value2 = Xml.get(node: xml, tag: 'value2');

    oldest = Xml.get(node: xml, tag: 'oldest');
    newest = Xml.get(node: xml, tag: 'newest');
    clear  = Xml.get(node: xml, tag: 'clear');

    cmode   = Xml.get(node: xml, tag: 'cmode') ?? Xml.get(node: xml, tag: 'mode');
    tmode  = Xml.get(node: xml, tag: 'tmode');
    showicon  = Xml.get(node: xml, tag: 'showicon');
  }

  @override
  Future<dynamic> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    switch (function) {
      case "show":
      case "open":
      case "start":
        await datepicker?.show();
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  void setAnswer({DateTime? date, TimeOfDay? time, DateTime? date2})
  {
    switch (type) {

      // date range
      case "range":

        var v1 = toDateString(date,  format: format);
        var v2 = toDateString(date2, format: format);
        if (v1 == null) v2 = null;
        if (v2 == null) v1 = null;

        answer(v1);
        value2 = v2;

        break;

      // time
      case "time":

        var value = toDateString(time, format: format);
        answer(value);
        value2 = null;

        break;

      // date and time
      case "datetime":

        // combine date and time
        if (date != null && time != null) {
          date = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        }

        var value = toDateString(date, format: format);
        answer(value);
        value2 = null;

        break;

      default:

        var value = toDateString(date, format: format);
        answer(value);
        value2 = null;

        break;
    }

    // fire the on change event
    onChange(context);
  }

  @override
  Widget getView({Key? key}) {
    var view = DatepickerView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}
