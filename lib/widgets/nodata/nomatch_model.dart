// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:xml/xml.dart';
import 'package:fml/helpers/helpers.dart';

class NoMatchModel extends BoxModel
{
  NoMatchModel(WidgetModel super.parent, super.id);

  static NoMatchModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    NoMatchModel? model;
    try
    {
      model = NoMatchModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'NOMATCH');
      model = null;
    }
    return model;
  }
}
