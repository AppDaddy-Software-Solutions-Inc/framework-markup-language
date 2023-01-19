// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:typed_data';
import 'package:flutter_image_transform/flutter_image_transform.dart';
import 'package:fml/data/data.dart';
import 'package:fml/datasources/transforms/transform_model.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class ImageTransformModel extends TransformModel
{
  final isolate = ImageTransformIsolate();

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
      Log().exception(e,  caller: 'iframe.Model');
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
    source  = Xml.get(node: xml, tag: 'source');
  }

  // reads the image and applies the transform
  Future<Uint8List?> _toBytes(Map row) async
  {
    if (source == null) return null;

    String url = source!;

    // source is a map field?
    if (row.containsKey(source) && row[source] is String) url = row[source];

    // get bytes from file
    if (scope != null && scope!.files.containsKey(url))
    {
      var file = scope!.files[url];
      if (file != null) return await file.read();
    }

    // get bytes from datauri
    if (url.toLowerCase().startsWith("data:"))
    {
      var uri = Uri.tryParse(url);
      if (uri != null && uri.data != null) return uri.data!.contentAsBytes();
    }

    return null;
  }

  void _saveData(Map row, String uri)
  {
      var type = "jpg";
      var size = uri.length;
      var name = row.containsKey("name") ? row["name"] : "${Uuid().v4()}.$type";

      // modify the data
      row['file'] = uri;
      row['name'] = name;
      row['size'] = size;
      row['extension'] = type;
  }

  // grayscale transform
  Future<void> grayImage(Data data) async
  {
    if (data.isNotEmpty || data.first is Map)
    {
      Map row = data.first;
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
