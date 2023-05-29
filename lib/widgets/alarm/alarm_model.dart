// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/event/handler.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

class AlarmModel extends WidgetModel
{
  /// The value of the alarms parent.
  StringObservable? _value;
  set value(dynamic v) {
    if (_value != null) {
      _value?.set(v);
    } else if (v != null) {
      _value = StringObservable(Binding.toKey(id, 'value'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get value => _value?.get();

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

  /// The eval to determine if the error state of the parent is displayed.
  BooleanObservable? seterror;
  set error(dynamic v) {
    if (seterror != null) {
      seterror?.set(v);
    } else if (v != null) {
      seterror = BooleanObservable(Binding.toKey(id, 'error'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  bool? get error => seterror?.get();

  // TODO: implement mandatory to allow for forms to pass with alarms

  /// The event string to execute when an alarm is triggered.
  StringObservable? _onalarm;
  set onalarm(dynamic v) {
    if (_onalarm != null) {
      _onalarm?.set(v);
    } else if (v != null) {
      _onalarm = StringObservable(Binding.toKey(id, 'onalarm'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get onalarm => _onalarm?.get();

  /// The event string to execute when an alarm is dismissed.
  StringObservable? _ondismissed;
  set ondismissed(dynamic v) {
    if (_ondismissed != null) {
      _ondismissed?.set(v);
    } else if (v != null) {
      _ondismissed = StringObservable(Binding.toKey(id, 'ondismissed'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get ondismissed => _ondismissed?.get();

  /// 'Type' in FML, The type of alarm trigger state. Can be validate (which will trigger on complete(), save() or validate() of the form or the field, or all.
  StringObservable? _alarmtrigger;
  set alarmtrigger(dynamic v) {
    if (_alarmtrigger != null) {
      _alarmtrigger?.set(v);
    } else if (v != null) {
      _alarmtrigger = StringObservable(Binding.toKey(id, 'alarmtrigger'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get alarmtrigger => _alarmtrigger?.get();



  AlarmModel(
      WidgetModel parent,
      String?  id, {
      dynamic value,
      dynamic error,
      dynamic errortext,
      dynamic onalarm,
      dynamic ondismissed,
      dynamic alarmtrigger,
  })
      : super(parent, id) {
    if (value     != null) this.value = value;
    if (error     != null) this.error = error;
    if (errortext     != null) this.errortext = errortext;
    if (onalarm     != null) this.onalarm = onalarm;
    if (ondismissed     != null) this.ondismissed = ondismissed;
    if (alarmtrigger     != null) this.alarmtrigger = alarmtrigger;
  }

  static AlarmModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    AlarmModel? model;
    try
    {
      model = AlarmModel(parent, Xml.get(node: xml, tag: 'id'), value: Xml.getText(xml));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().debug(e.toString());
      model = null;
    }
    return model;
  }

  @override
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);

    // set properties
    error = Xml.get(node: xml, tag: 'error');
    errortext = Xml.get(node: xml, tag: 'errortext');
    onalarm = Xml.get(node: xml, tag: 'onalarm');
    ondismissed = Xml.get(node: xml, tag: 'ondismissed');
    //override 'alarmtrigger' with 'type' as the xml attribute name;
    alarmtrigger = Xml.get(node: xml, tag: 'type');
  }

  void executeAlarmString(bool isAlarming){
    if(isAlarming) {
      //execute the onalarm
      EventHandler(this).execute(_onalarm);
    } else {
      // execute the ondismissed
      EventHandler(this).execute(_ondismissed);
    }
  }

}