// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/data/data.dart';
import 'package:fml/datasources/transforms/transform_model.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/widget_model.dart'  ;
import 'package:image/image.dart' as IMAGE;
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/helper_barrel.dart';

class ImageTransformModel extends TransformModel
{
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
  Future<void> transform(Data data, TransformCallback transform) async
  {
    if (source == null) return;

    IMAGE.Image? image;
    for (var row in data)
    {
      String url = source!;
      var mimetype;
      var type;
      var bytes;

      // source is a map field?
      if (row is Map && row.containsKey(source) && row[source] is String) url = row[source];

      // get bytes from file
      if (scope != null && scope!.files.containsKey(url))
      {
         var file = scope!.files[url];
         if (file != null)
         {
           bytes = await file.read() as List<int>;
           mimetype = file.mimeType ?? "";
           type  = extensionFromMime(mimetype).toLowerCase();
         }
      }

      // get bytes from datauri
      else if (url is String && url.toLowerCase().startsWith("data:"))
      {
        var uri = Uri.tryParse(url);
        if (uri != null && uri.data != null)
        {
          bytes    = uri.data!.contentAsBytes();
          mimetype = uri.data!.mimeType;
          type     = extensionFromMime(mimetype).toLowerCase();
        }
      }

      // transform from file
      if (bytes != null)
      {
          IMAGE.Decoder? decoder;
               if (type == "jpg")  decoder = IMAGE.JpegDecoder();
          else if (type == "jpeg") decoder = IMAGE.JpegDecoder();
          else if (type == "jpe")  decoder = IMAGE.JpegDecoder();
          else if (type == "png")  decoder = IMAGE.PngDecoder();
          else if (type == "gif")  decoder = IMAGE.GifDecoder();
          if (decoder != null)
          {
            try
            {
              image = decoder.decodeImage(bytes);
              if (image != null)
              {
                image = await transform(image);
                if (image != null)
                {
                  // encode transformed image
                  bytes = [];
                       if (decoder is IMAGE.PngDecoder)   bytes = IMAGE.encodePng(image);
                  else if (decoder is IMAGE.JpegDecoder)  bytes = IMAGE.encodeJpg(image);
                  else if (decoder is IMAGE.GifDecoder)   bytes = IMAGE.encodeGif(image);

                  var uri  = UriData.fromBytes(bytes, mimeType: mimetype);
                  var url  = uri.toString();
                  var size = bytes.length;
                  var name = row.containsKey("name") ? row["name"] : "${Uuid().v4()}.$type";

                  // modify the data
                  row['file'] = url;
                  row['name'] = name;
                  row['size'] = size;
                  row['extension'] = type;
                }
              }
            }
            catch(e)
            {
              Log().error("Error converting to image. error is $e");
              image = null;
            }
          }
        }
      }
  }
}
