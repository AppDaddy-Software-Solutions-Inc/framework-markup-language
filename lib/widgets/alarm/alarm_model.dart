// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/event/handler.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

enum AlarmType { generic, mandatory, validation }

class AlarmModel extends Model {
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
      _text = StringObservable(Binding.toKey(id, 'text'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String? get text => _text?.get();

  /// The eval to determine if the error state of the parent is displayed.
  BooleanObservable? _alarm;
  set alarm(dynamic v) {
    if (_alarm != null) {
      _alarm?.set(v);
    } else if (v != null) {
      _alarm =
          BooleanObservable(Binding.toKey(id, 'alarm'), v, scope: scope);
    }
  }
  bool get alarm => _alarm?.get() ?? false;
  bool get isAlarming => _alarm?.get() ?? false;

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

  AlarmModel(Model parent, String? id,
      {dynamic type, dynamic text, dynamic alarm})
      : super(parent, id) {
    // set type
    this.type = AlarmType.generic;
    if (type is String) {
      this.type = toEnum(type.trim().toLowerCase(), AlarmType.values) ??
          AlarmType.generic;
    }
    if (type is AlarmType) this.type = type;

    if (text != null) this.text = text;
    if (alarm != null) this.alarm = alarm;

    // Build a binding to the parent value
    var binding = "{${parent.id}.value}";
    _value ??= StringObservable(Binding.toKey(this.id, 'value'), binding,
        scope: scope);
  }

  static AlarmModel? fromXml(Model parent, XmlElement xml) {
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
    alarm =
        Xml.get(node: xml, tag: 'alarm') ?? Xml.get(node: xml, tag: 'error') ?? Xml.get(node: xml, tag: 'value');
    text =
        Xml.get(node: xml, tag: 'text') ?? Xml.get(node: xml, tag: 'errortext');
    onalarm = Xml.get(node: xml, tag: 'onalarm');
  }

  // listen for changed
  void onChange(OnChangeCallback callback) => _alarm?.registerListener(callback);

  Future<bool> onAlarm() async {
    if (_onalarm == null) return true;
    return await EventHandler(this).execute(_onalarm);
  }
}
