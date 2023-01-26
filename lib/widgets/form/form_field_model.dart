// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/datasources/gps/payload.dart' as GPS;
import 'package:fml/system.dart';
import 'package:fml/widgets/alarm/alarm_model.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/event/handler.dart' ;
import 'package:fml/observable/observable_barrel.dart';
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

class FormFieldModel extends DecoratedWidgetModel
{
  // override this getter and setter in your base class
  set value(dynamic v){}
  dynamic get value => null;

  // default value
  StringObservable? _defaultValue;
  set defaultValue(dynamic v)
  {
    if (_defaultValue != null) {
      _defaultValue!.set(v);
    } else {
      if (v != null)
        _defaultValue = StringObservable(null, v, scope: scope);
    }
  }
  dynamic get defaultValue => _defaultValue?.get();

  /// metadata to save with the post
  StringObservable? _meta;
  set meta (dynamic v)
  {
    if (_meta != null)
    {
      _meta!.set(v);
    }
    else if (v != null)
    {
      _meta = StringObservable(Binding.toKey(id, 'meta'), v, scope: scope);
    }
  }
  String? get meta => _meta?.get();

  // field manually updated
  bool? touched = false;

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
  bool get dirty
  {
    if (_dirty == null) return false;
    return _dirty?.get() ?? false;
  }

  /// Mandatory will dictate if the field will stop the form from `complete()`ing if not filled out.
  BooleanObservable? _mandatory;
  set mandatory(dynamic v) {
    if (_mandatory != null) {
      _mandatory!.set(v);
    } else if (v != null) {
      _mandatory = BooleanObservable(
          Binding.toKey(id, 'mandatory'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool? get mandatory => _mandatory?.get();

  /// Post tells the form whether or not to include the field in the posting body. If post is null, visible determines post.
  BooleanObservable? _post;
  set post(dynamic v) {
    if (_post != null) {
      _post!.set(v);
    } else if (v != null) {
      _post = BooleanObservable(Binding.toKey(id, 'post'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool? get post => _post?.get();

  /// visible determining if postable. This is not a settable attribute but part of post.
  bool get postable
  {
    if (S.isNullOrEmpty(id)) return false;
    if (post != null) return post!;
    if ((value == null) || value is List && value.isEmpty) return false;
    WidgetModel model = this;
    while (model.parent != null) model = model.parent!;
    return true;
  }

  /// GeoCode for each [iFormField] which is set on answer
  GPS.Payload? geocode;

  //field is editable
  BooleanObservable? _editable;
  set editable(dynamic v) {
    if (_editable != null) {
      _editable!.set(v);
    } else if (v != null) {
      _editable = BooleanObservable(Binding.toKey(id, 'editable'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool? get editable => _editable?.get();

  // onchange event
  StringObservable? _onchange;
  set onchange(dynamic v) {
    if (_onchange != null) {
      _onchange!.set(v);
    } else if (v != null) {
      _onchange = StringObservable(Binding.toKey(id, 'onchange'), v, scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }
  String? get onchange => _onchange?.get();

  /// [Alarm]s based on validation checks
  Map<String?, BooleanObservable>? _alarms;

  StringObservable? _alarm;
  set alarm(dynamic v) {
    if (_alarm != null) {
      _alarm!.set(v);
    } else {
      _alarm = StringObservable(Binding.toKey(id, 'alarm'), v,
          scope: scope);
    }
  }
  String? get alarm => _alarm?.get();

  /// True if there is an alarm sounding on a [iFormField]
  BooleanObservable? _alarming;
  set alarming(dynamic v) {
    if (_alarming != null) {
      _alarming!.set(v);
    } else if (v != null) {
      _alarming = BooleanObservable(Binding.toKey(id, 'alarming'), v,
          scope: scope);
    }
  }
  bool? get alarming => _alarming?.get();

  // field offset
  Offset? offset;

  FormFieldModel(WidgetModel? parent, String? id) : super(parent, id);

  @override
  void deserialize(XmlElement xml)
  {
    super.deserialize(xml);

    // properties
    defaultValue = Xml.get(node: xml, tag: 'default');
    meta         = Xml.get(node: xml, tag: 'meta');
    field        = Xml.get(node: xml, tag: 'field');
    mandatory    = Xml.get(node: xml, tag: 'mandatory');
    editable     = Xml.get(node: xml, tag: 'editable');
    post         = Xml.get(node: xml, tag: 'post');
    onchange     = Xml.get(node: xml, tag: 'onchange');

    // Build alarms
    List<AlarmModel> alarms = findChildrenOfExactType(AlarmModel).cast<AlarmModel>();
    alarms.forEach((alarm)
    {
      if (_alarms == null) _alarms = Map<String?, BooleanObservable>();
      this._alarms!.clear();
      String id = alarm.id;
      if (!S.isNullOrEmpty(alarm.value)) _alarms![id] = BooleanObservable(null, value, scope: scope, setter: (value) => touched! ? value : false, listener: _onAlarm);
    });
  }

  void _onAlarm(Observable alarm)
  {
    if (_alarms == null) return;

    String? id;
    bool alarming = false;
    _alarms!.forEach((key, value)
    {
      if ((value.get() == true))
      {
        alarming = true;
        if (id == null) id = key;
      }
    });

    this.alarming = alarming;
    this.alarm = id;
  }

  // values
  List<String>? get values
  {
    if (!S.isNullOrEmpty(value?.toString())) return [value.toString()];
    return null;
  }

  // question was answered
  bool get answered
  {
    return (!S.isNullOrEmpty(value));
  }

  Future<bool> onChange(BuildContext? context) async
  {
    return await EventHandler(this).execute(_onchange);
  }

  // set answer default implementation
  Future<bool> answer(dynamic v) async
  {
    bool ok = true;
    touched = true;

    if (value != v)
    {
      // remember old value
      var oldValue = value;
      value = v;

      // remember old geoCode
      var oldGeocode = geocode;

      // set geocode
      geocode = GPS.Payload(
          latitude: System().currentLocation?.latitude,
          longitude: System().currentLocation?.longitude,
          altitude: System().currentLocation?.altitude,
          epoch: DateTime.now().millisecondsSinceEpoch,
          user: System().userProperty('key'),
          username: System().userProperty('name'));

      // save the value
      //ok = await save();

      // save failed?
      if (ok == false)
      {
        value = oldValue;
        geocode = oldGeocode;
      }

      // save succeeded. set dirty
      else dirty = true;
    }
    return ok;
  }
}