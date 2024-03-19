// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'dart:ui';

import 'package:fml/log/manager.dart';

class ImageHelper
{
  static Uint8List color2Uint(int color)
  {
    return Uint8List.fromList([
      color >> 16 & 0xff,
      color >> 8 & 0xff,
      color & 0xff,
      color >> 16 & 0xff
    ]);
  }

  static int getLuminanceRgb(int red, int green, int blue) => (0.299 * red + 0.587 * green + 0.114 * blue).round();

  static int getColorRgb(int red, int green, int blue, [int a = 255]) => (red << 16) + (green << 8) + blue + (a << 24);

  static List<int> toGrayScale(List<int> rgba)
  {
    for (int i = 0, len = rgba.length; i < len; i += 4)
    {
      final luminance  = getLuminanceRgb(rgba[i], rgba[i + 1], rgba[i + 2]);
      rgba[i]     = luminance;
      rgba[i + 1] = luminance;
      rgba[i + 2] = luminance;
    }
    return rgba;
  }

  static int getWhitest(List<int> grayscaleRgba)
  {
    int value = 0;
    for (int i = 0, len = grayscaleRgba.length; i < len; i += 4)
    {
      if (grayscaleRgba[i] > value) value = grayscaleRgba[i];
    }
    return value;
  }

  static int getBlackest(List<int> grayscaleRgba)
  {
    int value = 255;
    for (int i = 0, len = grayscaleRgba.length; i < len; i += 4)
    {
      if (grayscaleRgba[i] < value) value = grayscaleRgba[i];
    }
    return value;
  }

  static List<int> toBlackAndWhite(List<int> rgba, {int tolerance = 75})
  {
    int white = 255;
    int black = 0;
    rgba = toGrayScale(rgba);
    int whitest = getWhitest(rgba);
    for (int i = 0, len = rgba.length; i < len; i += 4)
    {
      int value = (rgba[i] < (whitest - tolerance)) ? black : white;
      rgba[i]     = value;
      rgba[i + 1] = value;
      rgba[i + 2] = value;
    }
    return rgba;
  }

  static List<int> toPixelsFromRgba(List<int> rgba, {bool greyscale = false})
  {
    return List<int>.generate(rgba.length ~/ 4, (index) => (greyscale == true) ? getColorFromByte(rgba, index * 4) : getColorFromByte(rgba, index * 4));
  }

  static List<int> toGrayscalePixelsFromRgba(List<int> rgba)
  {
    return List<int>.generate(rgba.length ~/ 4, (index) => ImageHelper.getColorFromByte(rgba, index * 4));
  }

  static int getColorFromByte(List<int> byte, int index, {bool isLog = false})
  {
    return getColorRgb(byte[index], byte[index + 1], byte[index + 2], byte[index + 3]);
  }

  static int byte2Pixel(Uint8List byteData, int firstIndex)
  {
    return byteData[firstIndex + 3] << 24 + byteData[firstIndex] << 16  + byteData[firstIndex+1] << 8 + byteData[firstIndex+2] ;
  }

  static Future<Uint8List?> toRawRgba(Uint8List bytes) async
  {
    try
    {
      var codec = await instantiateImageCodec(bytes);
      var frame = await codec.getNextFrame();
      var data  = await frame.image.toByteData(format: ImageByteFormat.rawRgba);
      return data?.buffer.asUint8List();
    }
    catch(e)
    {
      Log().exception(e);
      return null;
    }
  }

  static Future<Uint8List?> uriToUint8List(UriData uri, {ui.ImageByteFormat format = ui.ImageByteFormat.png}) async
  {
    try
    {

      ///////////////////////
      /* Convert Uri Image */
      ///////////////////////
      Uint8List bytesBase64 = uri.isBase64 ? uri.contentAsBytes() : const Base64Codec().decode(uri.contentText);

      ui.Codec codec = await ui.instantiateImageCodec(bytesBase64);
      ui.FrameInfo frame = await codec.getNextFrame();

      ByteData? data = await frame.image.toByteData(format: format );
      return data?.buffer.asUint8List();
    }
    catch(e)
    {
      Log().exception(e);
    }
    return null;
  }
}
