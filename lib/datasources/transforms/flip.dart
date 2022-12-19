// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:xml/xml.dart';
import 'package:image/image.dart' as IMAGE;
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'model.dart';
import 'package:fml/helper/helper_barrel.dart';

class Flip extends TransformModel implements IImageTransform
{
  final String? axis;

  Flip(WidgetModel parent, {String? id, this.axis}) : super(parent, id);

  static Flip? fromXml(WidgetModel parent, XmlElement xml)
  {
    Flip model = Flip
      (
      parent,
      id     : Xml.get(node: xml, tag: 'id'),
      axis   : Xml.get(node: xml, tag: 'axis'),
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
    return (this.axis?.toLowerCase() == "vertical") ? IMAGE.flipVertical(image) : IMAGE.flipHorizontal(image);
  }
}