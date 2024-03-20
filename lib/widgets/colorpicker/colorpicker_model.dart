// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/observable/observables/color.dart';
import 'package:fml/widgets/colorpicker/colorpicker_view.dart';
import 'package:fml/widgets/form/decorated_input_model.dart';
import 'package:fml/widgets/form/form_field_interface.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/helpers/helpers.dart';

enum METHODS { launch }

class ColorpickerModel extends DecoratedInputModel implements IFormField
{
  bool isPicking = false;

  // value
  ColorObservable? _value;
  @override
  set value(dynamic v)
  {
    if (_value != null)
    {
      _value!.set(v);
    }
    else
    {
      if (v != null) {
        _value = ColorObservable(Binding.toKey(id, 'value'), v, scope: scope, listener: onPropertyChange);
      }
    }
  }
  @override
  Color? get value => _value?.get();

  @override
  bool get canExpandInfinitelyWide => !hasBoundedWidth;

  ColorpickerModel(WidgetModel super.parent,super.id);

  static ColorpickerModel? fromXml(WidgetModel parent, XmlElement xml, {String? type})
  {
    ColorpickerModel? model;
    try 
    {
      model = ColorpickerModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    } 
    catch(e) 
    {
      Log().exception(e,  caller: 'datepicker.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    // set properties
    value = Xml.get(node: xml, tag: fromEnum('value'));
  }

  Future<bool> setSelectedColor(dynamic color) async
  {
    // save the answer
    bool ok = await answer(color);
    if (ok)
    {
      // fire the onchange event
      await onChange(context);
    }
    return ok;
  }

  @override
  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async
  {
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();
    switch (function)
    {
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
