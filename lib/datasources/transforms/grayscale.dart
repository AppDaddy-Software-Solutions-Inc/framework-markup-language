// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/transforms/image_transform_model.dart';
import 'package:fml/datasources/transforms/transform_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/helper/helper_barrel.dart';

class Grayscale extends ImageTransformModel implements IDataTransform
{
  Grayscale(WidgetModel parent, {String? id}) : super(parent, id);

  static Grayscale? fromXml(WidgetModel parent, XmlElement xml)
  {
    Grayscale model = Grayscale
      (
      parent,
      id : Xml.get(node: xml, tag: 'id')
    );
    model.deserialize(xml);
    return model;
  }

  @override
  void deserialize(XmlElement xml)
  {
    // Deserialize
    super.deserialize(xml);
  }

  apply(List? data) async
  {
    if (enabled == false) return;
    if (data is Data) await grayImage(data, runAsIsolate: background);
  }
}