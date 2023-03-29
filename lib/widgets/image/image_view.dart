// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/image/image_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:image/image.dart' as IMAGE;
import 'package:fml/helper/common_helpers.dart';

/// [IMAGE] view
class ImageView extends StatefulWidget implements IWidgetView
{
  final ImageModel model;

  // this is just an empty pixel
  static Uint8List placeholder = Base64Codec().decode("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGP6LwkAAiABG+faPgsAAAAASUVORK5CYII=");

  ImageView(this.model) : super(key: ObjectKey(model));

  @override
  _ImageViewState createState() => _ImageViewState();

  /// Get an image widget from any image type
  static dynamic getImage(String? url, bool animate, {Scope? scope, String? defaultImage, double? width, double? height, String? fit, String? filter, bool fade = true, int? fadeDuration})
  {
    Widget? image;

    try
    {
      // parse the url
      Uri? uri = URI.parse(url);

      // bad url?
      if (uri == null)
      {
        if (defaultImage != null)
        {
          if (defaultImage.toLowerCase().trim() == 'none')
               return Container();
          else return getImage(defaultImage, animate, defaultImage: null, fit: fit, width: width, height: height, filter: filter, fade: fade, fadeDuration: fadeDuration);
        }
        return Icon(Icons.broken_image_outlined, size: 36, color: Colors.grey);
      }

      // error handler
      Widget errorHandler(BuildContext content, Object object, StackTrace? stacktrace)
      {
        Log().debug("Bad image url (${url?.substring(0,min(100,url.length - 1))}. Error is $object", caller: "errorHandler");
        if (defaultImage == null) return Icon(Icons.broken_image_outlined, size: 36, color: Colors.grey);
        if (defaultImage.toLowerCase().trim() == 'none') return Container();
        return getImage(defaultImage, animate, defaultImage: null, fit: fit, width: width, height: height, filter: filter, fade: fade, fadeDuration: fadeDuration);
      }

      // get image type
      switch (uri.scheme)
      {
        /// data uri
        case "data":
            if (uri.data != null) image = FadeInImage(placeholder: MemoryImage(placeholder), image: MemoryImage(uri.data!.contentAsBytes()), fit: getFit(fit), width: width, height: height, fadeInDuration: Duration(milliseconds: fadeDuration ?? 300), imageErrorBuilder: errorHandler);
            break;

        /// blob image from camera or file picker
        case "blob":
          image = kIsWeb ? Image.network(url!, fit: getFit(fit)) : Image.file(File(url!), fit: getFit(fit));
          break;

        /// file image
        case "file":

          // file picker and camera return uri references as file:C:/...?
          dynamic file = Platform.getFile(url!.replaceFirst("file:", ""));

          // user defined local files?
          if (file == null) file = Platform.getFile(uri.asFilePath());

          // no file found
          if (file == null) break;

          // svg image?
          if (uri.pageExtension == "svg")
               image = SvgPicture.file(file!, fit: getFit(fit), width: width, height: height);
          else image = Image.file(file, fit: getFit(fit));
          break;

        /// asset image
        case "assets":
          var assetpath = "${uri.scheme}/${uri.host}${uri.path}";

          // svg image?
          if (uri.pageExtension == "svg")
               image = SvgPicture.asset(assetpath, fit: getFit(fit), width: width, height: height);
          else image = Image.asset(assetpath, fit: getFit(fit), width: width, height: height, errorBuilder: errorHandler);
          break;

        /// web image
        default:
          if (uri.pageExtension == "svg")
               image = SvgPicture.network(uri.url, fit: getFit(fit), width: width, height: height);
          else
          {
            if (animate)
                 image = FadeInImage.memoryNetwork(placeholder: placeholder, image: uri.url, fit: getFit(fit), width: width, height: height, fadeInDuration: Duration(milliseconds: fadeDuration ?? 300), imageErrorBuilder: errorHandler);
            else image = Image.network(uri.url, fit: getFit(fit), width: width, height: height);
          }
          break;
      }
    }
    catch(e)
    {
      Log().error("Error decoding image from $url. Error is $e");
    }

    // return widget
    return image ?? Image.memory(placeholder, fit: getFit(fit), width: width, height: height);
  }

  /// how the image will fit within the space it is given
  static BoxFit getFit(String? fit) {
    var boxFit = BoxFit.cover;

    if (S.isNullOrEmpty(fit)) return boxFit;
    fit = fit!.toLowerCase();

    switch (fit) {
      case 'cover':
        boxFit = BoxFit.cover;
        break;
      case 'fitheight':
      case 'height':
        boxFit = BoxFit.fitHeight;
        break;
      case 'fitwidth':
      case 'width':
        boxFit = BoxFit.fitWidth;
        break;
      case 'fill':
        boxFit = BoxFit.fill;
        break;
      case 'contain':
        boxFit = BoxFit.contain;
        break;
      case 'scaledown':
      case 'scale':
        boxFit = BoxFit.scaleDown;
        break;
      case 'none':
        boxFit = BoxFit.none;
        break;
      default:
        boxFit = BoxFit.cover;
    }
    return boxFit;
  }

  /// Apply a filter to the image
  static void applyFilter(Uint8List img, String filter) {
    IMAGE.Image? filtered = IMAGE.decodePng(img);
    switch (filter) {
      case 'sobel':
        IMAGE.sobel(filtered!, amount: 1.0);
        break;
      case 'quantize':
        IMAGE.quantize(filtered!, numberOfColors: 4);
        break;
      case 'remap':
        IMAGE.remapColors(filtered!,
            red: IMAGE.Channel.luminance,
            green: IMAGE.Channel.luminance,
            blue: IMAGE.Channel.luminance);
        break;
      case 'normalize':
        IMAGE.normalize(filtered!, 85, 170);
        break;
      case 'greyscale':
      case 'grayscale':
        IMAGE.grayscale(filtered!);
        break;
      case 'mirror':
        IMAGE.flipHorizontal(filtered!);
        break;
      case 'contrast':
        IMAGE.contrast(filtered, 200);
        break;
      case 'white':
        IMAGE.adjustColor(filtered!, whites: 130);
        break;
      case 'black':
        IMAGE.adjustColor(filtered!, blacks: 130);
        break;
      case 'mid':
        IMAGE.adjustColor(filtered!, mids: 130);
        break;
      case 'reverse':
        IMAGE.adjustColor(filtered!, blacks: 255, whites: 0);
        break;
      case 'convolution':
        IMAGE.convolution(filtered!, [0, -1, 0, -1, 5, -1, 0, -1, 0]);
        break;
      default:
        break;
    }
  }
}

class _ImageViewState extends WidgetState<ImageView>
{
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // save system constraints
    widget.model.systemConstraints = constraints;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    String? url = widget.model.url;
    double? opacity = widget.model.opacity;
    double? width = widget.model.width;
    double? height = widget.model.height;
    String? fit = widget.model.fit;
    String? filter = widget.model.filter;
    Scope? scope = Scope.of(widget.model);

    // get the image
    Widget view = ImageView.getImage(url, widget.model.animations == null, scope: scope, defaultImage: widget.model.defaultvalue, width: width, height: height, fit: fit, filter: filter) ?? Container();

    // Flip
    if (widget.model.flip != null) {
      if (widget.model.flip!.toLowerCase() == 'vertical')
        // view = Transform(alignment: Alignment.center, transform: Matrix4.rotationX(pi), child: view);
        view = Transform.scale(scaleY: -1, child: view);
      if (widget.model.flip!.toLowerCase() == 'horizontal')
        // view = Transform(alignment: Alignment.center, transform: Matrix4.rotationY(pi), child: view);
        view = Transform.scale(scaleX: -1, child: view);
    }

    // Alpha/Opacity
    if (opacity != null) view = Opacity(opacity: opacity, child: view);

    // Rotation
    if (widget.model.rotation != null)
      view = RotationTransition(
          turns: AlwaysStoppedAnimation(widget.model.rotation! / 360),
          child: view);

    // Stack Children
    if (widget.model.children != null && widget.model.children!.length > 0)
      view = Stack(children: [view]);

    // Interactive
    if (widget.model.interactive == true) view = InteractiveViewer(child: view);

    // apply user defined constraints
    return applyConstraints(view, widget.model.modelConstraints);
  }
}
