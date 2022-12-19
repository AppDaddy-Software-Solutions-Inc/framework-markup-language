// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:xml/xml.dart';
import 'package:image/image.dart' as IMAGE;
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'model.dart';
import 'package:fml/helper/helper_barrel.dart';

class Resize extends TransformModel implements IImageTransform
{
  String? width;
  String? height;

  Resize(WidgetModel parent, {String? id}) : super(parent, id);

  static Resize? fromXml(WidgetModel parent, XmlElement xml)
  {
    Resize model = Resize
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

    // Properties
    width   = Xml.get(node: xml, tag: 'width');
    height  = Xml.get(node: xml, tag: 'height');
  }

  IMAGE.Image? apply(IMAGE.Image? image)
  {
    if (image   == null) return null;
    if (enabled == false) return image;
    return IMAGE.copyResize(image, width: S.toInt(width), height: S.toInt(height));
  }
}