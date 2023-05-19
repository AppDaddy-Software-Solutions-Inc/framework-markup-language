// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/widgets/form/form_field_model.dart';
import 'package:fml/widgets/form/form_field_interface.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/helper/common_helpers.dart';

class FieldModel extends FormFieldModel implements IFormField
{

  /// the value of the input. If not set to "" initially, the value will not be settable through events.
  StringObservable? _value;
  @override
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
    if (_value == null) return defaultValue;
    if ((!dirty) && (S.isNullOrEmpty(_value!.get())) && (!S.isNullOrEmpty(defaultValue))) _value!.set(defaultValue);
    return _value!.get();
  }


  FieldModel(
      WidgetModel parent,
      String? id,{dynamic value,}) : super(parent, id){
    if (value         != null) this.value = value;
  }

  static FieldModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    FieldModel? model;
    try
    {
      model = FieldModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e, caller: 'field.Model');
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
    value = Xml.get(node: xml, tag: S.fromEnum('value'));
  }
}