// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/helpers/xml.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/navigation/navigation_manager.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/framework/framework_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/observable/observable_barrel.dart';

class ShowLogIntent extends Intent {}

class ShowLogAction extends Action<ShowLogIntent> {
  ShowLogAction();

  @override
  void invoke(covariant ShowLogIntent intent) {
    Log().export();
  }
}

class ShortcutModel extends WidgetModel {
  // key
  StringObservable? _key;

  bool ctrlPressed = false;
  bool altPressed = false;
  bool shiftPressed = false;

  set key(dynamic v) {
    if (_key != null) {
      _key!.set(v);
    } else if (v != null) {
      _key = StringObservable(Binding.toKey(id, 'key'), null,
          scope: scope, listener: onKeySetChange);
      _key!.set(v);
    }
  }

  String? get key => _key?.get();

  // action
  StringObservable? _action;
  set action(dynamic v) {
    if (_action != null) {
      _action!.set(v);
    } else if (v != null) {
      _action = StringObservable(Binding.toKey(id, 'action'), v, scope: scope);
    }
  }

  String? get action => _action?.get();

  // holds the sequence of keys that make up the shortcut
  List<LogicalKeyboardKey> keySequence = [];

  ShortcutModel(WidgetModel super.parent, super.id,
      {String? key, String? action}) {
    this.key = key;
    this.action = action;
  }

  static ShortcutModel? fromXml(WidgetModel parent, XmlElement xml) {
    ShortcutModel? model = ShortcutModel(parent, Xml.get(node: xml, tag: 'id'));
    model.deserialize(xml);
    return model;
  }

  onKeySetChange(_) {
    ctrlPressed = false;
    altPressed = false;
    shiftPressed = false;

    var keys = key?.split("-");

    // lookup logical keys
    if (keys != null) {
      for (var keyLabel in keys) {
        // lookup the logical key
        keyLabel = keyLabel.trim();

        // control key?
        LogicalKeyboardKey? key;
        if (keyLabel.toUpperCase() == "CTRL") {
          key = LogicalKeyboardKey.control;
          ctrlPressed = true;
        } else if (keyLabel.toUpperCase() == "ALT") {
          key = LogicalKeyboardKey.alt;
          altPressed = true;
        } else if (keyLabel.toUpperCase() == "SHIFT") {
          key = LogicalKeyboardKey.shift;
          shiftPressed = true;
        }

        // other key?
        else {
          // lookup key
          key = LogicalKeyboardKey.knownLogicalKeys.firstWhereOrNull((k) {
            if (k.keyLabel == keyLabel) return true;
            if (k.keyLabel.toUpperCase() == keyLabel.toUpperCase()) return true;
            for (var s in k.synonyms) {
              if (s.keyLabel == keyLabel) return true;
              if (s.keyLabel.toUpperCase() == keyLabel.toUpperCase()) {
                return true;
              }
            }
            return false;
          });
        }

        // no corresponding key
        if (key == null) {
          keySequence.clear();
          break;
        }

        // add logical key to the set
        if (!ShortcutHandler.isControlKey(key)) {
          keySequence.add(key);
        }
      }
    }
  }

  // returns true if the shortcut was found and executed, false otherwise
  bool isMatch(
      List<LogicalKeyboardKey> keysPressed, bool ctrl, bool alt, bool shift) {
    // key set sizes don't match
    if (keySequence.isEmpty || keySequence.length != keysPressed.length) {
      return false;
    }

    // control keys don't match
    if ((ctrlPressed && !ctrl) ||
        (altPressed && !alt) ||
        (shiftPressed && !shift)) return false;

    // evaluate keys
    int i = 0;
    bool matchFound = false;
    for (var key in keysPressed) {
      matchFound = (key == keySequence[i] ||
          key.synonyms.contains(keySequence[i]) ||
          keySequence[i].synonyms.contains(key));
      if (matchFound) break;
      i++;
    }

    // return result
    return matchFound;
  }

  // fire event handler
  fire() => EventHandler(this).execute(_action);

  @override
  Future<bool?> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    if (scope == null) return null;

    var function = propertyOrFunction.toLowerCase().trim();

    switch (function) {
      // fire event handler
      case 'execute':
        fire();
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml) {
    // deserialize
    super.deserialize(xml);

    // properties
    key = Xml.get(node: xml, tag: 'key');
    action = Xml.get(node: xml, tag: 'action');
  }
}

class ShortcutHandler {
  static final shiftKeys = [
    LogicalKeyboardKey.shift.keyLabel,
    LogicalKeyboardKey.shiftLeft.keyLabel,
    LogicalKeyboardKey.shiftRight.keyLabel
  ];

  static final altKeys = [
    LogicalKeyboardKey.alt.keyLabel,
    LogicalKeyboardKey.altLeft.keyLabel,
    LogicalKeyboardKey.altRight.keyLabel,
  ];

  static final ctrlKeys = [
    LogicalKeyboardKey.control.keyLabel,
    LogicalKeyboardKey.controlLeft.keyLabel,
    LogicalKeyboardKey.controlRight.keyLabel
  ];

  static final metaKeys = [
    LogicalKeyboardKey.meta.keyLabel,
    LogicalKeyboardKey.metaLeft.keyLabel,
    LogicalKeyboardKey.metaRight.keyLabel
  ];

  static bool get isShiftPressed => HardwareKeyboard.instance.logicalKeysPressed
      .where((key) => shiftKeys.contains(key.keyLabel))
      .isNotEmpty;

  static bool get isAltPressed => HardwareKeyboard.instance.logicalKeysPressed
      .where((key) => altKeys.contains(key.keyLabel))
      .isNotEmpty;

  static bool get isCtrlPressed => HardwareKeyboard.instance.logicalKeysPressed
      .where((key) => ctrlKeys.contains(key.keyLabel))
      .isNotEmpty;

  static bool get isMetaPressed => HardwareKeyboard.instance.logicalKeysPressed
      .where((key) => metaKeys.contains(key.keyLabel))
      .isNotEmpty;

  static bool isControlKey(LogicalKeyboardKey key) =>
      shiftKeys.contains(key.keyLabel) ||
      altKeys.contains(key.keyLabel) ||
      ctrlKeys.contains(key.keyLabel);

  static final List<LogicalKeyboardKey> keysPressed = [];
  static final List<ShortcutModel> defaultShortcuts = [];

  // returns true if a shortcut was found and executed,
  // otherwise false
  static bool handleKeyPress(KeyEvent event, FrameworkModel? framework) {
    bool handled = false;

    // repeat key
    if (event is KeyRepeatEvent) return handled;

    // none of the control keys are depressed?
    // clear the keys pressed
    if (!isAltPressed && !isCtrlPressed && !isShiftPressed) {
      keysPressed.clear();
      return handled;
    }

    // key up event?
    if (event is KeyUpEvent) return handled;

    // key is a special key
    if (isControlKey(event.logicalKey)) return handled;

    // add the key to the list
    keysPressed.add(event.logicalKey);

    // fire the frameworks shortcut handler
    var shortcut = findMatching(framework?.shortcuts);
    if (shortcut != null) {
      handled = true;
      shortcut.execute("ShortcutHandler", "execute", []);
    }

    // shortcut was handled?
    if (!handled) handled = handleDefaults(framework);

    // clear the keys buffer
    if (handled) keysPressed.clear();

    return handled;
  }

  static ShortcutModel? findMatching(List<ShortcutModel>? shortcuts) {
    // find the shortcut
    for (ShortcutModel shortcut in shortcuts ?? []) {
      // shortcut found?
      var found = shortcut.isMatch(
          keysPressed, isCtrlPressed, isAltPressed, isShiftPressed);
      if (found) return shortcut;
    }
    return null;
  }

  static bool handleDefaults(FrameworkModel? framework) {
    // initialize default shortcuts
    if (defaultShortcuts.isEmpty) {
      defaultShortcuts.add(ShortcutModel(System(), "1", key: "CTRL-ALT-R"));
      defaultShortcuts.add(ShortcutModel(System(), "2", key: "CTRL-ALT-L"));
      defaultShortcuts.add(ShortcutModel(System(), "3", key: "CTRL-ALT-T"));
    }

    // find shortcut from keysPressed
    var shortcut = findMatching(defaultShortcuts);
    if (shortcut != null) {
      switch (shortcut.id) {
        // refresh
        case "1":
          NavigationManager().refresh();
          break;

        // export log
        case "2":
          Log().export();
          break;

        // show template
        case "3":
          framework?.showTemplate();
          break;
      }
    }
    return shortcut != null;
  }
}
