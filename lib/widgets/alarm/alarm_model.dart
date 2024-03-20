// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

enum AlarmType { generic, mandatory, validation, server }

class AlarmModel extends WidgetModel {
  // indicates the type of alarm
  AlarmType type = AlarmType.generic;

  // value of the parent
  StringObservable? _value;

  /// The alarm text to display when alarm is active
  StringObservable? _text;
  set text(dynamic v) {
    if (_text != null) {
      _text!.set(v);
    } else if (v != null) {
      _text = StringObservable(Binding.toKey(id, 'errortext'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  String? get text => _text?.get();

  /// The eval to determine if the error state of the parent is displayed.
  BooleanObservable? get alarmingObservable => _alarming;
  BooleanObservable? _alarming;
  set alarming(dynamic v) {
    if (_alarming != null) {
      _alarming?.set(v);
    } else if (v != null) {
      _alarming =
          BooleanObservable(Binding.toKey(id, 'alarming'), v, scope: scope);
    }
  }

  bool get alarming => _alarming?.get() ?? false;

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

  AlarmModel(WidgetModel parent, String? id,
      {dynamic type, dynamic text, dynamic alarm})
      : super(parent, id) {
    // set type
    this.type = AlarmType.generic;
    if (type is String)
      this.type = toEnum(type.trim().toLowerCase(), AlarmType.values) ??
          AlarmType.generic;
    if (type is AlarmType) this.type = type;

    if (text != null) this.text = text;
    if (alarm != null) alarming = alarm;

    // Build a binding to the parent value
    var binding = "{${parent.id}.value}";
    _value ??= StringObservable(Binding.toKey(this.id, 'value'), binding,
        scope: scope);
  }

  static AlarmModel? fromXml(WidgetModel parent, XmlElement xml) {
    AlarmModel? model;
    try {
      model = AlarmModel(parent, Xml.get(node: xml, tag: 'id'),
          type: Xml.get(node: xml, tag: 'type'));
      model.deserialize(xml);
    } catch (e) {
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
    alarming =
        Xml.get(node: xml, tag: 'alarm') ?? Xml.get(node: xml, tag: 'error');
    text =
        Xml.get(node: xml, tag: 'text') ?? Xml.get(node: xml, tag: 'errortext');
    onalarm = Xml.get(node: xml, tag: 'onalarm');
    ondismissed = Xml.get(node: xml, tag: 'ondismissed');
  }
}
