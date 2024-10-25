// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/color.dart';
import 'package:fml/observable/observables/string.dart';
import 'package:fml/widgets/colorpicker/colorpicker_view.dart';
import 'package:fml/widgets/form/decorated_input_model.dart';
import 'package:fml/widgets/form/form_field_interface.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/helpers/helpers.dart';

enum METHODS { launch }

class ColorpickerModel extends DecoratedInputModel implements IFormField {
  bool isPicking = false;

  // value
  ColorObservable? _value;
  @override
  set value(dynamic v) {
    if (_value != null) {
      _value!.set(v);
    } else {
      if (v != null) {
        _value = ColorObservable(Binding.toKey(id, 'value'), v,
            scope: scope, listener: onPropertyChange);
      }
    }
  }
  @override
  Color? get value => _value?.get();

  /// heading of the date picker
  StringObservable? _heading;
  set heading(dynamic v) {
    if (_heading != null) {
      _heading!.set(v);
    } else if (v != null) {
      _heading = StringObservable(Binding.toKey(id, 'heading'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String get heading => _heading?.get() ?? "Color";

  /// shade label of the date picker
  StringObservable? _subheading;
  set subheading(dynamic v) {
    if (_subheading != null) {
      _subheading!.set(v);
    } else if (v != null) {
      _subheading = StringObservable(Binding.toKey(id, 'subheading'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  String get subheading => _subheading?.get() ?? "Shade";
  
  @override
  bool get canExpandInfinitelyWide => !hasBoundedWidth;

  ColorpickerModel(Model super.parent, super.id);

  static ColorpickerModel? fromXml(Model parent, XmlElement xml,
      {String? type}) {
    ColorpickerModel? model;
    try {
      model = ColorpickerModel(parent, Xml.get(node: xml, tag: 'id'));
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
    value  = Xml.get(node: xml, tag: fromEnum('value'));
    heading  = Xml.get(node: xml, tag: fromEnum('heading'));
    subheading = Xml.get(node: xml, tag: fromEnum('subheading'));
  }

  Future<bool> setSelectedColor(dynamic color) async {
    // save the answer
    bool ok = await answer(color);
    if (ok) {
      // fire the onchange event
      await onChange(context);
    }
    return ok;
  }

  @override
  Future<dynamic> execute(
      String caller, String propertyOrFunction, List<dynamic> arguments) async {
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();
    switch (function) {
      case "open":
      case "show":
      case "start":
        ColorPickerView.launchPicker(this, context);
        return true;
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  @override
  Widget getView({Key? key}) => const Offstage();
}
