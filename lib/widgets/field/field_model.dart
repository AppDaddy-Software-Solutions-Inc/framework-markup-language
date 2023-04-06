// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/form/form_field_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/helper/common_helpers.dart';

class FieldModel extends FormFieldModel
{


  FieldModel(
      WidgetModel parent,
      String? id,) : super(parent, id);

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
  }


  @override
  void dispose()
  {
    super.dispose();
  }

}