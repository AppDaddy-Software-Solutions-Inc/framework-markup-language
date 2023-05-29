// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/datasources/gps/payload.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/alarm/alarm_model.dart';
import 'package:fml/widgets/decorated/decorated_widget_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

class FormFieldModel extends DecoratedWidgetModel {
  // override this getter and setter in your base class
  set value(dynamic v) {}
  dynamic get value => null;

  String didSetAlarm = '';

  // default value
  StringObservable? _defaultValue;
  set defaultValue(dynamic v) {
    if (_defaultValue != null) {
      _defaultValue!.set(v);
    } else {
      if (v != null) {
        _defaultValue = StringObservable(null, v, scope: scope);
      }
    }
  }

  dynamic get defaultValue => _defaultValue?.get();

  /// metadata to save with the post
  StringObservable? _meta;
  set meta(dynamic v) {
    if (_meta != null) {
      _meta!.set(v);
    } else if (v != null) {
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
  set dirty(dynamic v) {
    if (_dirty != null) {
      _dirty!.set(v);
    } else if (v != null) {
      _dirty = BooleanObservable(Binding.toKey(id, 'dirty'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get dirty {
    if (_dirty == null) return false;
    return _dirty?.get() ?? false;
  }

  /// Mandatory will dictate if the field will stop the form from `complete()`ing if not filled out.
  BooleanObservable? _mandatory;
  set mandatory(dynamic v) {
    if (_mandatory != null) {
      _mandatory!.set(v);
    } else if (v != null) {
      _mandatory = BooleanObservable(Binding.toKey(id, 'mandatory'), v,
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
  bool get postable {
    if (S.isNullOrEmpty(id)) return false;
    if (post != null) return post!;
    if ((value == null) || value is List && value.isEmpty) return false;
    WidgetModel model = this;
    while (model.parent != null) {
      model = model.parent!;
    }
    return true;
  }

  /// GeoCode for each [iFormField] which is set on answer
  Payload? geocode;

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
      _onchange = StringObservable(Binding.toKey(id, 'onchange'), v,
          scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }

  String? get onchange => _onchange?.get();

  /// [Alarm]s based on validation checks
  final Map<String?, AlarmModel> _alarms = {};

  StringObservable? _alarm;
  set alarm(dynamic v) {
    if (_alarm != null) {
      _alarm!.set(v);
    } else {
      _alarm = StringObservable(Binding.toKey(id, 'alarm'), v, scope: scope);
    }
  }

  String? get alarm => _alarm?.get();

  /// If the field will display its error state.
  BooleanObservable? _error;
  set error(dynamic v) {
    if (_error != null) {
      _error!.set(v);
    } else if (v != null) {
      _error = BooleanObservable(Binding.toKey(id, 'error'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool get error => _error?.get() ?? false;

  /// If an alarm is going off, seperate from the error field as to not override it.
  bool alarmerror = false;

  /// The error message value of a form field.
  StringObservable? _errortext;
  set errortext(dynamic v) {
    if (_errortext != null) {
      _errortext!.set(v);
    } else if (v != null) {
      _errortext = StringObservable(Binding.toKey(id, 'errortext'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get errortext => _errortext?.get();



  /// The error message value of a form field.
  StringObservable? _alarmerrortext;
  set alarmerrortext(dynamic v) {
    if (_alarmerrortext != null) {
      _alarmerrortext!.set(v);
    } else if (v != null) {
      _alarmerrortext = StringObservable(Binding.toKey(id, 'alarmerrortext'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get alarmerrortext => _alarmerrortext?.get();

  /// True if there is an alarm sounding on a [iFormField]
  BooleanObservable? _alarming;
  set alarming(dynamic v) {
    if (_alarming != null) {
      _alarming!.set(v);
    } else if (v != null) {
      _alarming =
          BooleanObservable(Binding.toKey(id, 'alarming'), v, scope: scope);
    }
  }

  bool get alarming => _alarming?.get() ?? false;

  /// True if there is an alarm sounding on a [iFormField]
  BooleanObservable? _validationHasHit;
  set validationHasHit(dynamic v) {
    if (_validationHasHit != null) {
      _validationHasHit!.set(v);
    } else if (v != null) {
      _validationHasHit = BooleanObservable(
          Binding.toKey(id, 'validationHasHit'), v,
          scope: scope);
    }
  }

  bool get validationHasHit => _validationHasHit?.get() ?? false;

  /// True if there is an alarm sounding on a [iFormField]
  BooleanObservable? _hasDefaulted;
  set hasDefaulted(dynamic v) {
    if (_hasDefaulted != null) {
      _hasDefaulted!.set(v);
    } else if (v != null) {
      _hasDefaulted =
          BooleanObservable(Binding.toKey(id, 'hasDefaulted'), v, scope: scope);
    }
  }

  bool get hasDefaulted => _hasDefaulted?.get() ?? false;


  /// The string of events that will be executed when focus is lost.
  StringObservable? _onfocuslost;
  set onfocuslost(dynamic v) {
    if (_onfocuslost != null) {
      _onfocuslost!.set(v);
    } else if (v != null) {
      _onfocuslost = StringObservable(Binding.toKey(id, 'onfocuslost'), v,
          scope: scope, listener: onPropertyChange, lazyEval: true);
    }
  }

  String? get onfocuslost {
    return _onfocuslost?.get();
  }

  // field offset
  Offset? offset;

  FormFieldModel(WidgetModel? parent, String? id,
      {
      dynamic error,
      dynamic errortext,
      dynamic validationHasHit,
      dynamic hasDefaulted,
      dynamic editable,
        dynamic enabled,
        dynamic post,
        dynamic mandatory,
        dynamic onchange,
        dynamic onfocuslost,
        dynamic touched,
        dynamic alarmerrortext,
      })
      : super(parent, id) {
    if (error != null) this.error = error;
    if (errortext != null) this.errortext = errortext;
    if (alarmerrortext != null) this.alarmerrortext = alarmerrortext;
    if (editable != null) this.editable = editable;
    if (enabled != null) this.enabled = enabled;
    if (post != null) this.post = post;
    if (mandatory != null) this.mandatory = mandatory;
    if (onchange      != null)  this.onchange      = onchange;
    if (touched != null) this.touched = touched;
    if (onfocuslost != null) this.onfocuslost = onfocuslost;


    this.validationHasHit = false;
    this.hasDefaulted = false;

    alarming = false;
    dirty = false;
  }

  @override
  void deserialize(XmlElement xml) {
    super.deserialize(xml);

    // properties
    defaultValue = Xml.get(node: xml, tag: 'default');
    meta = Xml.get(node: xml, tag: 'meta');
    error = Xml.get(node: xml, tag: 'error');
    errortext = Xml.get(node: xml, tag: 'errortext');
    field = Xml.get(node: xml, tag: 'field');
    mandatory = Xml.get(node: xml, tag: 'mandatory');
    editable = Xml.get(node: xml, tag: 'editable');
    post = Xml.get(node: xml, tag: 'post');
    onchange = Xml.get(node: xml, tag: 'onchange');

    // Build alarms
    List<AlarmModel> alarms =
        findChildrenOfExactType(AlarmModel).cast<AlarmModel>();
    _alarms.clear();
    for (var alarm in alarms) {
      _alarms[alarm.id] = alarm;
      //register a listener to always throw the alarm state when the value of the alarm changes if the alarm type is 'all'
      alarm.seterror?.registerListener(onAlarmChange);
    }
  }

  void onAlarmChange(Observable errorObservable) {
    // get the error state of the alarm and set it to that of the form field.
    String? sourceid = errorObservable.key?.split('.')[0];
    // The errorobservable from the alarm is the value of the alarms error atrribute.
    bool alarmSounding = errorObservable.get();
    AlarmModel? currentAlarm = _alarms[sourceid];
    String? triggerType = currentAlarm?.alarmtrigger;

    // set the error if the trigger type is not validation based, or if validation has already been hit
    if (triggerType != "validate" || validationHasHit == true)
    {
      alarmerror = alarmSounding;
    }
    // turn off the validation state if the alarm has been dismissed to require a validation per alarm sounding
    if (validationHasHit == true && !error) validationHasHit = false;

    // check to see if an alarm is already sounding and ensure the field is not alarming already
    if (alarmSounding && !alarming) {
      alarmerrortext = currentAlarm?.errortext;
      alarming = true;
      // execute the onalarm event string if the error state is active, this will not activate if validate is the type until validation happens.
      if (error) currentAlarm?.executeAlarmString(true);
      // tell the field which alarm has set its alarm state, this prevents multiple alarms
      didSetAlarm = sourceid ?? '';
    }
    // check that the changed alarm has set the alarming state, and that the alarm is not sounding
    else if (!alarmSounding && didSetAlarm == sourceid) {
      // set the alarming state to false
      alarming = false;
      // execute the ondismiss event string
      currentAlarm?.executeAlarmString(false);
    }
  }

  // values
  List<String>? get values {
    if (!S.isNullOrEmpty(value?.toString())) return [value.toString()];
    return null;
  }

  // question was answered
  bool get answered {
    return (!S.isNullOrEmpty(value));
  }

  Future<bool> onChange(BuildContext? context) async {
    return await EventHandler(this).execute(_onchange);
  }

  // set answer default implementation
  Future<bool> answer(dynamic v) async {
    bool ok = true;
    touched = true;

    if (value != v) {
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
      if (ok == false) {
        value = oldValue;
        geocode = oldGeocode;
      }

      // save succeeded. set dirty
      else {
        dirty = true;
      }
    }
    return ok;
  }

  @override
  dispose() {
    super.dispose();
    removeAllListeners();
  }

  //Return the error state between the alarm and the error set on the model
  bool returnErrorState() {
    if (alarmerror == true) return true;
    if (error == true) return true;
    return false;
  }


  // return the correct combination of error and errotext based on the alarm vs the error.
  String? returnErrorText() {
    if (!S.isNullOrEmpty(alarmerrortext) && alarmerror == true) {
       return alarmerrortext;
    }
    if (!S.isNullOrEmpty(errortext) && error == true) return errortext!;
    if (error == true || alarmerror == true) {
      return errortext ?? alarmerrortext;
    }
    return null;
  }

  //this stays here as it is used by checkbox and radio
  Color setErrorBorderColor(BuildContext context, Color? borderColor) {
    if (enabled != false) {
      if(returnErrorState()) {
        return Theme.of(context).colorScheme.error;
      } else {
        return borderColor ?? Theme
            .of(context)
            .colorScheme
            .surfaceVariant;
      }
    } else {
      return color ?? Theme.of(context).colorScheme.primary.withOpacity(0.5);
    }
  }


  Future<bool> onFocusLost(BuildContext context) async {
    return await EventHandler(this).execute(_onfocuslost);
  }
}
