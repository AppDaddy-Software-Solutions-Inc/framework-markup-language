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
import 'package:intl/intl.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

enum METHODS { launch }

class DatepickerModel extends DecoratedInputModel implements IFormField {
  DatepickerViewState? datepicker;

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
  bool? get view => _view?.get();

  /// type of the datepicker. Can be "datetime", "date", "time", "range"
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

  // Value
  StringObservable? _value;

  @override
  set value(dynamic v) {
    if (_value != null) {
      _value!.set(v);
    } else if (v != null ||
        Model.isBound(this, Binding.toKey(id, 'value'))) {
      _value = StringObservable(Binding.toKey(id, 'value'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  @override
  String? get value => dirty ? _value?.get() : _value?.get() ?? defaultValue;

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
  }) {
    if (type != null) this.type = type;
    if (format != null) this.format = format;
    if (clear != null) this.clear = clear;
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

    // set properties
    value = Xml.get(node: xml, tag: 'value') ?? defaultValue ?? "";
    type = Xml.get(node: xml, tag: 'type') ?? type;
    view = Xml.get(node: xml, tag: 'view');
    oldest = Xml.get(node: xml, tag: 'oldest');
    newest = Xml.get(node: xml, tag: 'newest');
    format = Xml.get(node: xml, tag: 'format');
    mode = Xml.get(node: xml, tag: 'mode');
    clear = Xml.get(node: xml, tag: 'clear');
  }

  @override
  Future<bool?> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    switch (function) {
      case "start":
        await datepicker?.show();
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  void setValue(DateTime? result, TimeOfDay? timeResult, {DateTime? secondResult})
  {
    switch (type) {
      case "date":
      case "year":
      case "range":
        try {
          value = (secondResult != null) ?
                "${DateFormat(format).format(result!)} - ${DateFormat(format).format(secondResult)}" :
                DateFormat(format, 'en_US').format(result!);
        } catch (e) {
          value = '';
        }
      break;

      case "time":
        try {
          DateTime now = DateTime.now();
          value = DateFormat(format).format(DateTime(
              now.year, now.month, now.day, timeResult!.hour, timeResult.minute));
        } catch (e) {
          value = '';
        }
        break;

      case "datetime":
      default:
        try {
          value = DateFormat(format).format(DateTime(result!.year, result.month,
              result.day, timeResult!.hour, timeResult.minute));
        } catch (e) {
          value = '';
        }
    }

    onChange(context);
  }

  void setFormat() {
    if (format != null) return;

    // set date format according to type
    format = 'y/M/d HH:mm';
    if (type == "date" || type == "year" || type == "range") {
      format = 'y/M/d';
    } else if (type == "time") {
      format = 'HH:mm';
    }
  }

  @override
  Widget getView({Key? key}) {
    var view = DatepickerView(this);
    return isReactive ? ReactiveView(this, view) : view;
  }
}
