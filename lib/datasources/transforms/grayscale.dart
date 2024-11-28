// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/transforms/transform_interface.dart';
import 'package:fml/datasources/transforms/image_transform_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/helpers/helpers.dart';

class Grayscale extends ImageTransformModel implements IDataTransform {

  Grayscale(Model parent, {String? id}) : super(parent, id);

  static Grayscale? fromXml(Model parent, XmlElement xml) {
    Grayscale model = Grayscale(parent, id: Xml.get(node: xml, tag: 'id'));
    model.deserialize(xml);
    return model;
  }

  @override
  apply(Data? data) async {
    if (enabled == false) return;
    if (data != null) await grayImage(data);
  }
}
