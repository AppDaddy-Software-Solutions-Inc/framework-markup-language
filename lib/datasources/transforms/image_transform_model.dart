// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:typed_data';
import 'package:flutter_image_transform/flutter_image_transform.dart';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/transforms/transform_model.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class ImageTransformModel extends TransformModel
{
  final isolate = ImageTransformIsolate();

  /// target
  StringObservable? _target;
  set target (dynamic v)
  {
    if (_target != null)
    {
      _target!.set(v);
    }
    else if (v != null)
    {
      _target = StringObservable(Binding.toKey(id, 'target'), v, scope: scope, listener: onPropertyChange);
    }
  }
  String? get target => _target?.get();

  ImageTransformModel(WidgetModel? parent, String? id) : super(parent, id);

  static ImageTransformModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    ImageTransformModel? model;
    try
    {
      model = ImageTransformModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'image_transform_model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    // properties
    target  = Xml.get(node: xml, tag: 'target');
  }

  // reads the image and applies the transform
  Future<Uint8List?> _toBytes(dynamic row) async
  {
    var v = Data.readValue(row, source);
    if (v == null) v = source;

    v = v.toString();

    // get bytes from a file
    if (scope != null && scope!.files.containsKey(v))
    {
      var file = scope!.files[v];
      if (file != null) return await file.read();
    }

    // get bytes from data uri
    else if (v.toLowerCase().startsWith("data:"))
    {
      var uri = Uri.tryParse(v);
      if (uri != null && uri.data != null) return uri.data!.contentAsBytes();
    }

    return null;
  }

  void _saveData(Map row, String uri)
  {
    // legacy
    var target = this.target ?? 'file';
    Data.writeValue(row, target, uri);
  }

  // grayscale transform
  Future<void> grayImage(Data data) async
  {
    for (var row in data)
    {
      var bytes = await _toBytes(row);
      if (bytes != null)
      {
        String? uri = await isolate.gray(bytes);
        if (uri != null) _saveData(row, uri);
      }
    }
  }

  // crop transform
  Future<void> cropImage(Data data, int x, int y, int width, int height) async
  {
    for (var row in data)
    {
      var bytes = await _toBytes(row);
      if (bytes != null)
      {
        String? uri = await isolate.crop(bytes,x,y,width,height);
        if (uri != null) _saveData(row, uri);
      }
    }
  }

  // crop transform
  Future<void> flipImage(Data data, String axis) async
  {
    for (var row in data)
    {
      var bytes = await _toBytes(row);
      if (bytes != null)
      {
        String? uri = (axis == "vertical") ? await isolate.flipVerically(bytes) : await isolate.flipHorizontally(bytes);
        if (uri != null) _saveData(row, uri);
      }
    }
  }

  // grayscale transform
  Future<void> resizeImage(Data data, int width, int height) async
  {
    if (data.isNotEmpty || data.first is Map)
    {
      Map row = data.first;
      var bytes = await _toBytes(row);
      if (bytes != null)
      {
        String? uri = await isolate.resize(bytes, width, height);
        if (uri != null) _saveData(row, uri);
      }
    }
  }
}
