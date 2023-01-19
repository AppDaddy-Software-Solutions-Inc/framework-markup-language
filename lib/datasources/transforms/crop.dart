// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/transforms/image_transform_model.dart';
import 'package:fml/datasources/transforms/transform_model.dart';
import 'package:xml/xml.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class Crop extends ImageTransformModel implements IDataTransform
{
  /// x-coordinate offset
  IntegerObservable? _x;
  set x (dynamic v)
  {
    if (_x != null)
    {
      _x!.set(v);
    }
    else if (v != null)
    {
      _x = IntegerObservable(Binding.toKey(id, 'x'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int get x => _x?.get() ?? 0;

  /// y-coordinate offset
  IntegerObservable? _y;
  set y (dynamic v)
  {
    if (_y != null)
    {
      _y!.set(v);
    }
    else if (v != null)
    {
      _y = IntegerObservable(Binding.toKey(id, 'y'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int get y => _y?.get() ?? 0;

  /// width
  IntegerObservable? _width;
  set width (dynamic v)
  {
    if (_width != null)
    {
      _width!.set(v);
    }
    else if (v != null)
    {
      _width = IntegerObservable(Binding.toKey(id, 'width'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int get width => _width?.get() ?? 0;

  /// height
  IntegerObservable? _height;
  set height (dynamic v)
  {
    if (_height != null)
    {
      _height!.set(v);
    }
    else if (v != null)
    {
      _height = IntegerObservable(Binding.toKey(id, 'height'), v, scope: scope, listener: onPropertyChange);
    }
  }
  int get height => _height?.get() ?? 0;

  /// source
  StringObservable? _source;
  set source (dynamic v)
  {
    if (_source != null)
    {
      _source!.set(v);
    }
    else if (v != null)
    {
      _source = StringObservable(Binding.toKey(id, 'source'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get source => _source?.get();
  
  Crop(WidgetModel parent, {String? id}) : super(parent, id);

  static Crop? fromXml(WidgetModel parent, XmlElement xml)
  {
    Crop model = Crop
      (
        parent,
        id : Xml.get(node: xml, tag: 'id'),
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
    x      = Xml.get(node: xml, tag: 'x');
    y      = Xml.get(node: xml, tag: 'y');
    width  = Xml.get(node: xml, tag: 'width');
    height = Xml.get(node: xml, tag: 'height');
  }

  apply(List? data) async
  {
    if (enabled == false) return;
    if (data is Data) await cropImage(data, x, y, width, height);
  }
}