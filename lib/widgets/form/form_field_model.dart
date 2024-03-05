// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fml/datasources/gps/payload.dart';
import 'package:fml/phrase.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/alarm/alarm_model.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class FormFieldModel extends DecoratedWidgetModel
{
  // override this getter and setter in your base class
  set value(dynamic v) {}
  dynamic get value => null;

  // default value
  StringObservable? _defaultValue;
  set defaultValue(dynamic v)
  {
    if (_defaultValue != null)
    {
      _defaultValue!.set(v);
    }
    else
    {
      if (v != null)
      {
        _defaultValue = StringObservable(null, v, scope: scope);
      }
    }
  }
  dynamic get defaultValue => _defaultValue?.get();

  /// metadata to save with the post
  StringObservable? _metaData;
  set metaData(dynamic v)
  {
    if (_metaData != null)
    {
      _metaData!.set(v);
    }
    else if (v != null)
    {
      _metaData = StringObservable(Binding.toKey(id, 'meta'), v, scope: scope);
    }
  }
  String? get metaData => _metaData?.get();

  /// If the input has been focused at least once
  BooleanObservable? _touched;
  set touched(dynamic v)
  {
    if (_touched != null)
    {
      _touched!.set(v);
    }
    else if (v != null)
    {
      _touched = BooleanObservable(Binding.toKey(id, 'touched'), v, scope: scope);
    }
  }
  bool get touched => _touched?.get() ?? false;

  // form field name override
  String? field;

  /// The bindable and settable property if the field has been touched or not from its initial state.
  BooleanObservable? get dirtyObservable => _dirty;
  BooleanObservable? _dirty;
  set dirty(dynamic v)
  {
    if (_dirty != null)
    {
      _dirty!.set(v);
    }
    else if (v != null)
    {
      _dirty = BooleanObservable(Binding.toKey(id, 'dirty'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get dirty => _dirty?.get() ?? false;

  /// mandatory will dictate if the field will stop the form from `complete()`ing if not filled out.
  BooleanObservable? _mandatory;
  set mandatory(dynamic v)
  {
    if (_mandatory != null)
    {
      _mandatory!.set(v);
    }
    else if (v != null)
    {
      _mandatory = BooleanObservable(Binding.toKey(id, 'mandatory'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool? get mandatory => _mandatory?.get();

  /// Post tells the form whether or not to include the field in the posting body. If post is null, visible determines post.
  BooleanObservable? _post;
  set post(dynamic v)
  {
    if (_post != null)
    {
      _post!.set(v);
    }
    else if (v != null)
    {
      _post = BooleanObservable(Binding.toKey(id, 'post'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool? get post => _post?.get();

  /// GeoCode for each [iFormField] which is set on answer
  Payload? geocode;

  //field is editable
  BooleanObservable? _editable;
  set editable(dynamic v)
  {
    if (_editable != null)
    {
      _editable!.set(v);
    }
    else if (v != null)
    {
      _editable = BooleanObservable(Binding.toKey(id, 'editable'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get editable => _editable?.get() ?? true;

  // onchange event
  StringObservable? _onchange;
  set onchange(dynamic v)
  {
    if (_onchange != null)
    {
      _onchange!.set(v);
    }
    else if (v != null)
    {
      _onchange = StringObservable(Binding.toKey(id, 'onchange'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }
  String? get onchange => _onchange?.get();

  /// [Alarm]s based on validation checks
  final List<AlarmModel> _alarms = [];

  /// true if there is an alarm sounding on a [iFormField]
  BooleanObservable? _alarming;
  set alarming(dynamic v)
  {
    if (_alarming != null)
    {
      _alarming!.set(v);
    }
    else if (v != null)
    {
      _alarming = BooleanObservable(Binding.toKey(id, 'alarming'), v, scope: scope);
    }
  }
  bool get alarming => _alarming?.get() ?? false;

  /// returns active alarm
  AlarmModel? get alarm
  {
    for (var alarm in _alarms)
    {
      if (alarm.alarming) return alarm;
    }
    return null;
  }

  /// alarm text
  String? get alarmText
  {
    if (isNullOrEmpty(value) && !touched) return null;
    return alarm?.text;
  }

  /// The string of events that will be executed when focus is lost.
  StringObservable? _onfocuslost;
  set onfocuslost(dynamic v)
  {
    if (_onfocuslost != null)
    {
      _onfocuslost!.set(v);
    }
    else if (v != null)
    {
      _onfocuslost = StringObservable(Binding.toKey(id, 'onfocuslost'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }
  String? get onfocuslost => _onfocuslost?.get();

  // field offset
  Offset? offset;

  FormFieldModel(super.parent, super.id,
  {
    dynamic editable,
    dynamic enabled,
    dynamic post,
    dynamic mandatory,
    dynamic onchange,
    dynamic onfocuslost
  })
  {
    if (editable != null) this.editable = editable;
    if (enabled != null) this.enabled = enabled;
    if (post != null) this.post = post;
    if (mandatory != null) this.mandatory = mandatory;
    if (onchange      != null)  this.onchange      = onchange;
    if (onfocuslost != null) this.onfocuslost = onfocuslost;

    alarming = false;
    dirty = false;
  }

  @override
  void deserialize(XmlElement xml)
  {
    super.deserialize(xml);

    // properties
    defaultValue = Xml.get(node: xml, tag: 'default');
    metaData = Xml.get(node: xml, tag: 'meta');
    field = Xml.get(node: xml, tag: 'field');
    mandatory = Xml.get(node: xml, tag: 'mandatory');
    editable = Xml.get(node: xml, tag: 'editable');
    post = Xml.get(node: xml, tag: 'post');
    onchange = Xml.get(node: xml, tag: 'onchange');

    // add alarms
    List<AlarmModel> alarmModels = findChildrenOfExactType(AlarmModel).cast<AlarmModel>();
    for (var alarm in alarmModels)
    {
      addAlarm(alarm);
    }

    // add mandatory alarm
    if (mandatory == true)
    {
      addAlarm(AlarmModel(this, null, type: AlarmType.mandatory, text: Phrases().fieldMandatory, alarm: "=noe({this.value}) && {$id.touched}"));
    }
  }

  void addAlarm(AlarmModel alarm, {int? position})
  {
    // there can only be one mandatory alarm
    // this allows the user to override the alarm wordage with their own
    if (alarm.type == AlarmType.mandatory && (_alarms.firstWhereOrNull((a) => a.type == AlarmType.mandatory) != null)) return;

    // there can only be one validation alarm
    // this allows the user to override the alarm wordage with their own
    if (alarm.type == AlarmType.validation && (_alarms.firstWhereOrNull((a) => a.type == AlarmType.validation) != null)) return;

    // add the alarm
    if (!_alarms.contains(alarm))
    {
      if (position != null)
      {
        if (position < 0) position = 0;
        if (position > _alarms.length) position = _alarms.length;
        _alarms.insert(position, alarm);
      }
      else
      {
        _alarms.add(alarm);
      }

      // register a listener to the alarm
      alarm.alarmingObservable?.registerListener(_onAlarmChange);

      children ??= [];
      if (!children!.contains(alarm)) children!.add(alarm);
    }
  }

  void _onAlarmChange(_)
  {
    alarming = (alarm != null);
    notifyListeners("alarming", alarming);
  }

  // values
  List<String>? get values
  {
    if (!isNullOrEmpty(value?.toString())) return [value.toString()];
    return null;
  }

  // question was answered
  bool get answered => !isNullOrEmpty(value);

  // on change
  Future<bool> onChange(BuildContext? context) async => await EventHandler(this).execute(_onchange);

  // set answer default implementation
  Future<bool> answer(dynamic v) async
  {
    bool ok = true;
    touched = true;
    dirty = true;

    if (value != v)
    {
      // remember old value
      var oldValue = value;
      value = v;

      // remember old geoCode
      var oldGeocode = geocode;

      // set geocode
      geocode = Payload(
          latitude: System().currentLocation?.latitude,
          longitude: System().currentLocation?.longitude,
          altitude: System().currentLocation?.altitude,
          epoch: DateTime.now().millisecondsSinceEpoch,
          user: System.app?.user.claim('key'),
          username: System.app?.user.claim('name'));

      // save the value
      //ok = await save();

      // save failed?
      if (ok == false)
      {
        value = oldValue;
        geocode = oldGeocode;
        dirty = false;
      }

      // save succeeded. set dirty
      else
      {
        dirty = true;
      }
    }
    return ok;
  }

  @override
  dispose()
  {
    super.dispose();
    removeAllListeners();
  }

  //this stays here as it is used by checkbox and radio
  Color setErrorBorderColor(BuildContext context, Color? borderColor)
  {
    if (enabled != false)
    {
      if (alarming)
      {
        return Theme.of(context).colorScheme.error;
      }
      else
      {
        return borderColor ?? Theme.of(context).colorScheme.surfaceVariant;
      }
    } else {
      return color ?? Theme.of(context).colorScheme.primary.withOpacity(0.5);
    }
  }

  Future<bool> onFocusLost(BuildContext context) async => await EventHandler(this).execute(_onfocuslost);
}
