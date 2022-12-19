// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:xml/xml.dart';
import 'package:image/image.dart' as IMAGE;
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'model.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';

class Crop extends TransformModel implements IImageTransform
{
  String? width;
  String? height;

  /// Δ x value for transitions such as slide, defaults to 1.5
  DoubleObservable? _dx;
  set dx (dynamic v)
  {
    if (_dx != null)
    {
      _dx!.set(v);
    }
    else if (v != null)
    {
      _dx = DoubleObservable(Binding.toKey(id, 'x'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double get dx => _dx?.get() ?? 0.0;

  /// Δ y value for transitions such as slide
  DoubleObservable? _dy;
  set dy (dynamic v)
  {
    if (_dy != null)
    {
      _dy!.set(v);
    }
    else if (v != null)
    {
      _dy = DoubleObservable(Binding.toKey(id, 'y'), v, scope: scope, listener: onPropertyChange);
    }
  }
  double get dy => _dy?.get() ?? 0.0;


  Crop(WidgetModel parent, {String? id}) : super(parent, id);

  static Crop? fromXml(WidgetModel parent, XmlElement xml)
  {
    Crop model = Crop
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
    dx      = Xml.get(node: xml, tag: 'x');
    dy      = Xml.get(node: xml, tag: 'y');
  }

  IMAGE.Image? apply(IMAGE.Image? image)
  {
    if (image == null) return null;
    if (enabled == false) return image;
    return IMAGE.copyCrop(image, S.toInt(dx)!, S.toInt(dy)!, S.toInt(width)!, S.toInt(height)!);
  }
}