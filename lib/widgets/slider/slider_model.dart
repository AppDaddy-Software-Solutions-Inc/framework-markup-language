// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/iDataSource.dart';
import 'package:fml/dialog/service.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/phrase.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/form/form_field_model.dart';
import 'package:fml/widgets/form/iFormField.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/datasources/gps/payload.dart' as GPS;
import 'package:fml/widgets/slider/slider_view.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

enum InputTypes { numeric, integer, text, boolean}

class SliderModel extends FormFieldModel implements IFormField, IViewableWidget
{
  ///////////
  /* Width */
  ///////////
  @override
  double get width
  {
    return super.width ?? 200;
  }

  ////////////////////
  /* capitalization */
  ////////////////////
  InputTypes? _inputtype;
  set inputtype(dynamic v) {
    if (v is InputTypes) _inputtype = v;
    _inputtype = S.toEnum(v, InputTypes.values);
  }

  InputTypes? get inputtype {
    return _inputtype;
  }

  /////////////
  /* Minimum */
  /////////////
  DoubleObservable? _minimum;
  set minimum(dynamic v) {
    if (_minimum != null) {
      _minimum!.set(v);
    } else if (v != null) {
      _minimum = DoubleObservable(Binding.toKey(id, 'minimum'), v,
          scope: scope, listener: onPropertyChange);
    }
  }

  double? get minimum => _minimum?.get() ?? 0;

  /////////////
  /* Maximum */
  /////////////
  DoubleObservable? _maximum;
  set maximum(dynamic v) {
    if (_maximum != null) {
      _maximum!.set(v);
    } else if (v != null) {
      _maximum = DoubleObservable(Binding.toKey(id, 'maximum'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  double? get maximum => _maximum?.get() ?? 0;

  ///////////////
  /* Divisions */
  ///////////////
  IntegerObservable? _divisions;
  set divisions(dynamic v) {
    if (_divisions != null) {
      _divisions!.set(v);
    } else if (v != null) {
      _divisions = IntegerObservable(
          Binding.toKey(id, 'divisions'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  int? get divisions => _divisions?.get();


  ///////////
  /* Value */
  ///////////
  StringObservable? _value;
  set value(dynamic v)
  {
    if (_value != null)
    {
      _value!.set(v);
    }
    else
    {
      if ((v != null) || (WidgetModel.isBound(this, Binding.toKey(id, 'value')))) _value = StringObservable(Binding.toKey(id, 'value'), v, scope: scope, listener: onPropertyChange);
    }
  }

  @override
  dynamic get value
  {
    // if (_range?.get() == true && _startvalue != null && _endvalue != null) return '${_startvalue?.get()},${_endvalue?.get()}';
    if (_value == null) return defaultValue;
    if ((!dirty) && (S.isNullOrEmpty(_value?.get())) && (!S.isNullOrEmpty(defaultValue))) _value!.set(defaultValue);
    return _value?.get();
  }

  ////////////
  /* Answer */
  ////////////
  Future<bool> answer(dynamic v, {bool range = false}) async
  {
    bool ok = true;
    touched = true;
    if (value != v) {
      ///////////////
      /* Old Value */
      ///////////////
      var oldValue = value;
      if (range != true) {
          value = v.round();
      }
      else if (range == true && v != null) {
        List answerValues = v?.split(',') ?? [minimum, maximum];
        double value1 = S.toDouble(answerValues[0]) ??  minimum ?? 0;
        double value2 = (answerValues.length > 1 ?  S.toDouble(answerValues[1]) : value1) ??  maximum ?? 0;
        value = '${value1.round()},${value2.round()}';
      }

      /////////////////
      /* Old GeoCode */
      /////////////////
      var oldGeocode = geocode;
      geocode = GPS.Payload(
          latitude: System().currentLocation?.latitude,
          longitude: System().currentLocation?.longitude,
          altitude: System().currentLocation?.altitude,
          epoch: DateTime.now().millisecondsSinceEpoch,
          user: System.app?.claim('key'),
          username: System.app?.claim('name'));

      //////////
      /* Save */
      //////////
      //ok = await save();

      /////////////////
      /* Save Failed */
      /////////////////
      if (ok == false) {
        value = oldValue;
        geocode = oldGeocode;
      }

      //////////////////
      /* Save Success */
      //////////////////
      else
        dirty = true;
    }

    return ok;
  }

  ///////////
  /* Range */
  ///////////
  BooleanObservable? _range;
  set range(dynamic v) {
    if (_range != null) {
      _range!.set(v);
    } else if (v != null) {
      _range = BooleanObservable(Binding.toKey(id, 'range'), v,
          scope: scope, listener: onPropertyChange);
    }
  }
  bool get range => _range?.get() ?? false;

  SliderModel(
    WidgetModel parent,
    String? id, {
    String? type,
    dynamic visible,
    dynamic mandatory,
    dynamic editable,
    dynamic enabled,
    dynamic value,
    dynamic defaultValue,
    dynamic minimum,
    dynamic maximum,
    dynamic divisions,
    dynamic width,
    dynamic color,
    dynamic onchange,
    dynamic post,
    dynamic inputtype,
    dynamic range,
    dynamic startvalue,
    dynamic endvalue,
  }) : super(parent, id)
  {
    if (mandatory    != null) this.mandatory  = mandatory;
    if (editable     != null) this.editable   = editable;
    if (enabled      != null) this.enabled    = enabled;
    if (value        != null) this.value      = value;
    if (minimum      != null) this.minimum    = minimum;
    if (maximum      != null) this.maximum    = maximum;
    if (divisions    != null) this.divisions  = divisions;
    if (defaultValue != null) this.defaultValue = defaultValue;
    if (width        != null) this.width      = width;
    if (color        != null) this.color      = color;
    if (onchange     != null) this.onchange   = onchange;
    if (post         != null) this.post       = post;
    if (inputtype    != null) this.inputtype  = inputtype;
    if (range        != null) this.range      = range;

    this.alarming     = false;
    this.dirty        = false;
  }

  static SliderModel? fromXml(WidgetModel parent, XmlElement xml, {String? type}) {
    SliderModel? model;
    try
    {
      model = SliderModel(parent, Xml.get(node: xml, tag: 'id'), type: type);
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'slider.Model');
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
    value   = Xml.get(node: xml, tag: 'value');
    minimum = Xml.get(node: xml, tag: 'minimum');
    maximum = Xml.get(node: xml, tag: 'maximum');
    divisions = Xml.get(node: xml, tag: 'divisions');
    inputtype = Xml.get(node: xml, tag: 'type');
    range = Xml.get(node: xml, tag: 'range');
  }

  bool onException(IDataSource source, Exception e)
  {
    DialogService().show(type: DialogType.error, title: phrase.error, description: e.toString());
    return super.onDataSourceException(source, e);
  }

  @override
  dispose()
  {
    Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Widget getView({Key? key}) => SliderView(this);
}

class Suggestion {
  final dynamic text;

  Suggestion({this.text});
}
