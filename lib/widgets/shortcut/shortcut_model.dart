// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/helpers/xml.dart';
import 'package:fml/log/manager.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/observable/observable_barrel.dart';

class ShowLogIntent extends Intent {}
class ShowLogAction extends Action<ShowLogIntent>
{
  ShowLogAction();

  @override
  void invoke(covariant ShowLogIntent intent)
  {
    Log().export();
  }
}

class ShortcutModel extends WidgetModel
{
  // key
  StringObservable? _key;

  set key(dynamic v)
  {
    if (_key != null)
    {
      _key!.set(v);
    }
    else if (v != null)
    {
      _key = StringObservable(Binding.toKey(id, 'key'), null, scope: scope, listener: onKeySetChange);
      _key!.set(v);
    }
  }
  String? get key => _key?.get();

  // action
  StringObservable? _action;
  set action(dynamic v)
  {
    if (_action != null)
    {
      _action!.set(v);
    }
    else if (v != null)
    {
      _action = StringObservable(Binding.toKey(id, 'action'), v, scope: scope);
    }
  }

  static final shiftKeys = [
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.shiftRight
  ];

  static final altKeys = [
    LogicalKeyboardKey.alt,
    LogicalKeyboardKey.altLeft,
    LogicalKeyboardKey.altRight
  ];

  static final ctrlKeys = [
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.controlLeft,
    LogicalKeyboardKey.controlRight
  ];

  static final metaKeys = [
    LogicalKeyboardKey.meta,
    LogicalKeyboardKey.metaLeft,
    LogicalKeyboardKey.metaRight
  ];

  static bool get isShiftPressed => RawKeyboard.instance.keysPressed
      .where((key) => shiftKeys.contains(key))
      .isNotEmpty;

  static bool get isAltPressed => RawKeyboard.instance.keysPressed
      .where((key) => altKeys.contains(key))
      .isNotEmpty;

  static bool get isCtrlPressed => RawKeyboard.instance.keysPressed
      .where((key) => ctrlKeys.contains(key))
      .isNotEmpty;

  static bool get isMetaPressed => RawKeyboard.instance.keysPressed
      .where((key) => metaKeys.contains(key))
      .isNotEmpty;

  String? get action => _action?.get();

  LogicalKeySet? keyset;

  ShortcutModel(WidgetModel parent, String? id, {dynamic key, dynamic action, this.keyset}) : super(parent, id)
  {
    this.key = key;
    this.action = action;
  }

  onKeySetChange(_) {
    var keys = key?.split("-");
    var keyset = <LogicalKeyboardKey>{};

    // lookup logical keys
    if (keys != null) {
      for (var key in keys) {
        // lookup the logical key
        key = key.trim();
        var match = LogicalKeyboardKey.knownLogicalKeys.firstWhereOrNull((k) {
          if (k.keyLabel == key) return true;
          if (k.keyLabel.toUpperCase() == key.toUpperCase()) return true;
          for (var s in k.synonyms) {
            if (s.keyLabel == key) return true;
            if (s.keyLabel.toUpperCase() == key.toUpperCase()) return true;
          }
          return false;
        });

        // no corresponding key
        if (match == null) {
          keyset.clear();
          break;
        }

        // add logical key to the set
        keyset.add(match);
      }
    }

    // build the key set
    this.keyset = keyset.isNotEmpty ? LogicalKeySet.fromSet(keyset) : null;
  }

  static ShortcutModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    ShortcutModel? model = ShortcutModel(parent, Xml.get(node: xml, tag: 'id'));
    model.deserialize(xml);
    return model;
  }

  @override
  Future<bool> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async
  {
    bool ok = await EventHandler(this).execute(_action);
    return ok;
  }

  bool matches(List<LogicalKeyboardKey> keys)
  {
    if (keyset?.keys.isEmpty ?? true) return false;

    int i = 0;
    for (var key in keys) {
      if (!sameAs(key, keyset!.keys.elementAt(i))) return false;
      i++;
    }
    return true;
  }

  bool startsWith(List<LogicalKeyboardKey> keys)
  {
    if (keyset == null || keyset!.keys.isEmpty || keys.isEmpty || keyset!.keys.length > keys.length) return false;

    int i = 0;
    for (var key in keyset!.keys)
    {
      if (!sameAs(key, keys[i])) return false;
      i++;
    }
    return true;
  }

  bool sameAs(LogicalKeyboardKey k1, LogicalKeyboardKey k2)
  {
    if (k1 == k2) return true;
    if (k1.synonyms.contains(k2) || k2.synonyms.contains(k1)) return true;
    return false;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    // properties
    key = Xml.get(node: xml, tag: 'key');
    action = Xml.get(node: xml, tag: 'action');
  }
}
