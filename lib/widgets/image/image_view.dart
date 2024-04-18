// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fml/fml.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/widgets/widget/viewable_widget_view.dart';
import 'package:fml/widgets/image/image_model.dart';
import 'package:fml/widgets/widget/viewable_widget_state.dart';
import 'package:fml/helpers/helpers.dart';

// platform
import 'package:fml/platform/platform.vm.dart'
    if (dart.library.io) 'package:fml/platform/platform.vm.dart'
    if (dart.library.html) 'package:fml/platform/platform.web.dart';

/// [IMAGE] view
class ImageView extends StatefulWidget implements ViewableWidgetView {
  @override
  final ImageModel model;

  // this is just an empty pixel
  static Uint8List placeholder = const Base64Codec().decode(
      "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGP6LwkAAiABG+faPgsAAAAASUVORK5CYII=");

  ImageView(this.model) : super(key: ObjectKey(model));

  @override
  State<ImageView> createState() => _ImageViewState();

  /// Get an image widget from any image type
  static dynamic getImage(String? url, bool animate,
      {Scope? scope,
      Color? color,
      String? defaultImage,
      double? width,
      double? height,
      String? fit,
      String? filter,
      bool fade = true,
      int? fadeDuration}) {
    Widget? image;

    try {
      // parse the url
      Uri? uri = URI.parse(url);

      // bad url?
      if (uri == null) {
        if (defaultImage != null) {
          if (defaultImage.toLowerCase().trim() == 'none') {
            return Container();
          } else {
            return getImage(defaultImage, animate,
                defaultImage: null,
                fit: fit,
                width: width,
                height: height,
                filter: filter,
                fade: fade,
                fadeDuration: fadeDuration);
          }
        }
        return const Icon(Icons.broken_image_outlined,
            size: 36, color: Colors.grey);
      }

      // error handler
      Widget errorHandler(
          BuildContext content, Object object, StackTrace? stacktrace) {
        Log().debug(
            "Bad image url (${url?.substring(0, min(100, url.length))}. Error is $object",
            caller: "errorHandler");
        if (defaultImage == null) {
          return const Icon(Icons.broken_image_outlined,
              size: 36, color: Colors.grey);
        }
        if (defaultImage.toLowerCase().trim() == 'none') return Container();
        return getImage(defaultImage, animate,
            defaultImage: null,
            fit: fit,
            width: width,
            height: height,
            filter: filter,
            fade: fade,
            fadeDuration: fadeDuration);
      }

      // get image type
      switch (uri.scheme) {
        /// data uri
        case "data":
          if (uri.data != null) {
            image = FadeInImage(
                placeholder: MemoryImage(placeholder),
                image: MemoryImage(uri.data!.contentAsBytes()),
                fit: getFit(fit),
                width: width,
                height: height,
                fadeInDuration: Duration(milliseconds: fadeDuration ?? 300),
                imageErrorBuilder: errorHandler);
          }
          break;

        /// blob image from camera or file picker
        case "blob":
          image = FmlEngine.isWeb
              ? Image.network(url!, fit: getFit(fit))
              : Image.file(File(url!), fit: getFit(fit));
          break;

        /// file image
        case "file":

          // file picker and camera return uri references as file:C:/...?
          dynamic file = Platform.getFile(url!.replaceFirst("file:", ""));

          // user defined local files?
          file ??= Platform.getFile(uri.asFilePath());

          // no file found
          if (file == null) break;

          // svg image?
          if (uri.pageExtension == "svg") {
            image = SvgPicture.file(file!,
                fit: getFit(fit),
                width: width,
                height: height,
                colorFilter: color != null
                    ? ColorFilter.mode(color, BlendMode.srcIn)
                    : null);
          } else {
            image = Image.file(file, fit: getFit(fit));
          }
          break;

        /// asset image
        case "assets":
          var assetpath = "${uri.scheme}/${uri.host}${uri.path}";

          // svg image?
          if (uri.pageExtension == "svg") {
            image = SvgPicture.asset(assetpath,
                fit: getFit(fit),
                width: width,
                height: height,
                colorFilter: color != null
                    ? ColorFilter.mode(color, BlendMode.srcIn)
                    : null);
          } else {
            image = Image.asset(assetpath,
                fit: getFit(fit),
                width: width,
                height: height,
                errorBuilder: errorHandler);
          }
          break;

        /// web image
        default:
          if (uri.pageExtension == "svg") {
            image = SvgPicture.network(uri.url,
                fit: getFit(fit),
                width: width,
                height: height,
                colorFilter: color != null
                    ? ColorFilter.mode(color, BlendMode.srcIn)
                    : null);
          } else {
            if (animate) {
              image = FadeInImage.memoryNetwork(
                placeholder: placeholder,
                image: uri.url,
                fit: getFit(fit),
                width: width,
                height: height,
                fadeInDuration: Duration(milliseconds: fadeDuration ?? 300),
                imageErrorBuilder: errorHandler,
              );
            } else {
              image = Image.network(uri.url,
                  fit: getFit(fit), width: width, height: height);
            }
          }
          break;
      }
    } catch (e) {
      Log().error("Error decoding image from $url. Error is $e");
    }

    // return widget
    return image ??
        Image.memory(placeholder,
            fit: getFit(fit), width: width, height: height);
  }

  /// how the image will fit within the space it is given
  static BoxFit getFit(String? fit) {
    var boxFit = BoxFit.cover;

    if (isNullOrEmpty(fit)) return boxFit;
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
}

class _ImageViewState extends ViewableWidgetState<ImageView> {
  @override
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // get the image
    Widget view = ImageView.getImage(widget.model.url, widget.model.animations == null,
            color: widget.model.color,
            scope: Scope.of(widget.model),
            defaultImage: widget.model.defaultvalue,
            width: widget.model.width,
            height: widget.model.height,
            fit: widget.model.fit,
            filter: widget.model.filter) ??
        Container();

    // interactive image??
    if (widget.model.interactive) view = InteractiveViewer(child: view);

    // add margins
    view = addMargins(view);

    // apply visual transforms
    view = applyTransforms(view);

    // apply constraints
    view = applyConstraints(view, widget.model.constraints);

    // apply user defined constraints
    return view;
  }
}
