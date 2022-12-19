// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:xml/xml.dart';
import 'package:fml/helper/helper_barrel.dart';

class AlarmModel extends WidgetModel
{
  final String? value;

  AlarmModel(WidgetModel parent, String?  id, {this.value}) : super(parent, id); // ; {key: value}

  static AlarmModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    AlarmModel? model;
    try
    {
      model = AlarmModel(parent, Xml.get(node: xml, tag: 'id'), value: Xml.getText(xml));
    }
    catch(e)
    {
      Log().debug(e.toString());
      model = null;
    }
    return model;
  }
}