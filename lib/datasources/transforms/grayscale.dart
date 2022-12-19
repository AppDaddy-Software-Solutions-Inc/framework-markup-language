// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:xml/xml.dart';
import 'package:image/image.dart' as IMAGE;
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'model.dart';
import 'package:fml/helper/helper_barrel.dart';

class Grayscale extends TransformModel implements IImageTransform
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

  IMAGE.Image? apply(IMAGE.Image? image)
  {
    if (image == null) return null;
    if (enabled == false) return image;
    return IMAGE.grayscale(image);
  }
}