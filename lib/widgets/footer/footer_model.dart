// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:xml/xml.dart';
import 'package:fml/helper/common_helpers.dart';

class FooterModel extends BoxModel 
{
  @override
  String? get layout => super.layout ?? "stack";

  @override
  double get height => super.height ?? maxHeight ?? minHeight ?? 50;

  FooterModel(WidgetModel parent, String? id) : super(parent, id);

  static FooterModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    FooterModel? model;
    try
    {
      // Build Model
      model = FooterModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'footer.Model');
      model = null;
    }
    return model;
  }
}