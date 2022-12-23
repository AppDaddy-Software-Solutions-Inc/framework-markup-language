import 'dart:async';
import 'dart:typed_data';
import 'package:image/image.dart';
import 'package:mime/mime.dart';
import 'package:squadron/squadron.dart';
import 'package:squadron/squadron_service.dart';

abstract class ImageService
{
  FutureOr<String?> gray(Uint8List imageData);
  FutureOr<String?> crop(Uint8List imageData, int x, int y, int width, int height);
  FutureOr<String?> flip(Uint8List imageData, String axis);
  FutureOr<String?> resize(Uint8List imageData, int width, int height);

  // this constant is used to identify the method to call when communicating with isolates / web workers
  static const Gray = 1;
  static const Crop = 2;
  static const Flip = 3;
  static const Resize = 4;
}

// this class is the actual implementation of the service defined above
class ImageServiceImpl implements ImageService, WorkerService
{
  String? _encode(Image image, Decoder decoder)
  {
    String? mimetype;
    Uint8List? bytes;

    switch (decoder.runtimeType)
    {
      case JpegDecoder: bytes = Uint8List.fromList(encodeJpg(image));
                        mimetype = lookupMimeType("jpg");
                        break;
      case TgaDecoder:
      case ExrDecoder:
      case TiffDecoder:
      case WebPDecoder:
      case PsdDecoder:
      case PngDecoder:  bytes = Uint8List.fromList(encodePng(image));
                        mimetype = lookupMimeType("png");
                        break;
      case GifDecoder:  bytes = Uint8List.fromList(encodeGif(image));
                        mimetype = lookupMimeType("gif");
                        break;
      case BmpDecoder:  bytes = Uint8List.fromList(encodeBmp(image));
                        mimetype = lookupMimeType("bmp");
                        break;
      case TgaDecoder:  bytes = Uint8List.fromList(encodeTga(image));
                        mimetype = lookupMimeType("tga");
                        break;
      case IcoDecoder:  bytes = Uint8List.fromList(encodeIco(image));
                        mimetype = lookupMimeType("ico");
                        break;
    }

    if (bytes != null)
    {
      UriData uri = UriData.fromBytes(bytes,mimeType: mimetype ?? "", parameters: {"size":"${bytes.length}", "c":"d"});
      return uri.toString();
    }
    return null;
  }

  @override
  FutureOr<String?> gray(Uint8List imageData)
  {
    // get decoder
    final decoder = findDecoderForData(imageData);
    if (decoder == null) return null;

    // decode image
    Image? image = decoder.decodeImage(imageData);
    if (image != null)
    {
      image = grayscale(image);
      return _encode(image, decoder);
    }
    return null;
  }

  @override
  FutureOr<String?> crop(Uint8List imageData, int x, int y, int width, int height)
  {
    // get decoder
    final decoder = findDecoderForData(imageData);
    if (decoder == null) return null;

    // decode image
    Image? image = decoder.decodeImage(imageData);
    if (image != null)
    {
      image = copyCrop(image,x,y,width,height);
      return _encode(image, decoder);
    }
    return null;
  }

  @override
  FutureOr<String?> flip(Uint8List imageData, String axis)
  {
    // get decoder
    final decoder = findDecoderForData(imageData);
    if (decoder == null) return null;

    // decode image
    Image? image = decoder.decodeImage(imageData);
    if (image != null)
    {
      image = (axis.toLowerCase() == "vertical") ? flipVertical(image) : flipHorizontal(image);
      return _encode(image, decoder);
    }
    return null;
  }

  @override
  FutureOr<String?> resize(Uint8List imageData, int width, int height)
  {
    // get decoder
    final decoder = findDecoderForData(imageData);
    if (decoder == null) return null;

    // decode image
    Image? image = decoder.decodeImage(imageData);
    if (image != null)
    {
      image = copyResize(image, width: width, height: height);
      return _encode(image, decoder);
    }
    return null;
  }

  // this map creates the correspondance between the service constants from ThumbnailService
  // and the method implementations in ThumbnailServiceImpl
  @override
  late final Map<int, CommandHandler> operations =
  {
    ImageService.Gray: (WorkerRequest r)
    {
      return gray(r.args[0]);
    },
    ImageService.Crop: (WorkerRequest r)
    {
      return crop(r.args[0],r.args[1],r.args[2],r.args[3],r.args[4]);
    },
    ImageService.Flip: (WorkerRequest r)
    {
      return flip(r.args[0],r.args[1]);
    },
    ImageService.Resize: (WorkerRequest r)
    {
      return resize(r.args[0],r.args[1],r.args[2]);
    },
  };
}