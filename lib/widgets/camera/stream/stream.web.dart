// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/helpers/mime.dart';
import 'package:universal_html/html.dart';
import 'dart:typed_data';
import 'package:fml/data/data.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'dart:ui' as ui;
import 'package:fml/datasources/file/file.dart';
import 'package:fml/widgets/camera/camera_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/widgets/camera/stream/stream.dart';
import 'package:fml/helpers/helpers.dart';

import 'package:fml/datasources/detectors/image/detectable_image.stub.dart'
    if (dart.library.io) 'package:fml/datasources/detectors/image/detectable_image.mobile.dart'
    if (dart.library.html) 'package:fml/datasources/detectors/image/detectable_image.web.dart';

// platform
import 'package:fml/platform/platform.vm.dart'
    if (dart.library.io) 'package:fml/platform/platform.vm.dart'
    if (dart.library.html) 'package:fml/platform/platform.web.dart';

View getView(model) => View(model);

class View extends StatefulWidget implements ViewableWidgetView, StreamView {
  @override
  final CameraModel model;

  View(this.model) : super(key: ObjectKey(model));

  @override
  ViewState createState() => ViewState();
}

class ViewState extends ViewableWidgetState<View> {
  List<dynamic> cameras = [];
  int selectedCamera = 0;

  bool abort = false;
  Timer? detectionTimer;
  bool detectInImage = false;
  num detectedFrame = 0;

  final String id = newId();
  num lastFrame = 0;

  Widget? videoWidget;
  late VideoElement video;
  late CanvasElement canvas;
  late CanvasElement canvas2;
  MediaStream? stream;

  Map<String, String> devices = <String, String>{};

  @override
  void initState() {
    Log().debug('web view');
    super.initState();
    
    // Create video widget 
    videoWidget = HtmlElementView(key: UniqueKey(), viewType: id);

    // Create Video Element 
    video = VideoElement();
    video.muted = true;
    video.autoplay = false;
    video.setAttribute('playsinline', 'true');

    // Create Canvas Element 
    canvas = CanvasElement();
    canvas2 = CanvasElement();

    // Register a webcam 
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(id, (int viewId) => video);

    // Start Camera 
    start();
  }

  /// Callback to fire the [_ViewState.build] when the [CameraModel] changes
  @override
  onModelChange(Model model, {String? property, dynamic value}) {
    var b = Binding.fromString(property);
    if ((mounted) && (b?.property == 'enabled')) {
      Log().debug('enabled changed value');
      if (widget.model.enabled) {
        start();
      } else {
        stop();
      }
    }
  }

  @override
  void dispose() {
    Log().debug('disposing of camera ...');
    abort = true;

    stop();

    stream = null;

    // Cancel Detection Timer 
    if (detectionTimer != null) detectionTimer!.cancel();

    super.dispose();
  }

  int tolerance = 0;
  void performDetection() async {
    if (abort) return;

    // Cancel Detection Timer 
    if (detectionTimer != null) detectionTimer!.cancel();

    // No New Frames to Detect? 
    if (lastFrame != detectedFrame) {
      detectedFrame = lastFrame;
      try {
        if (widget.model.detectors != null) {
          int left = 0;
          int top = 0;
          int width = canvas.width!;
          int height = canvas.height!;
          if ((width + left) > canvas.width!) width = canvas.width! - left;
          if ((height + top) > canvas.height!) height = canvas.height! - top;
          
          // Get Image RGBA Bitmap 
          ImageData image =
              canvas.context2D.getImageData(left, top, width, height);
          List<int> rgba = image.data.toList();

          // Convert to Grayscale 
          //rgba = ImageHelper.toGrayScale(rgba);

          //var list8 = Uint8List.fromList(rgba);

          //UriData uri = UriData.parse(canvas.toDataUrl('image/png',1.0));
          //Uint8List bytz = uri.contentAsBytes();

          //IMAGE.Image original = IMAGE.decodePng(bytz);
          //img = IMAGE.grayscale(img);
          //img = IMAGE.gaussianBlur(img, 2);
          //img = IMAGE.contrast(img, 125);
          //img = IMAGE.invert(img);

          if (widget.model.debug == true) {
            var bytes = Uint8List.fromList(rgba);
            for (int i = 0; i < bytes.length; i++) {
              image.data[i] = bytes[i];
            }
            canvas2.width = width;
            canvas2.height = height;
            canvas2.context2D.putImageData(image, 0, 0);
            Blob blob = await canvas2.toBlob('image/png', 1.0);
            await Platform.fileSaveAsFromBlob(blob, "${newId()}-.png");
          }

          // process stream image
          onStream(rgba, width, height);
        }
      } catch (e) {
        //DialogService().show(type: DialogType.error, title: 'detecting error2');
      }
    }

    // Schedule Next Detection 
    detectionTimer = Timer(const Duration(milliseconds: 50), performDetection);
  }

  bool doneonce = false;
  void renderFrame(num epoch) {
    try {
      //const int HAVE_NOTHING      = 0; // no information whether or not the video is ready
      //const int HAVE_METADATA     = 1; // metadata for the video is ready
      //const int HAVE_CURRENT_DATA = 2; // data for the current playback position is available, but not enough data to play next frame/millisecond
      //const int HAVE_FUTURE_DATA  = 3; // data for the current and at least the next frame is available
      const int haveEnoughData = 4; // enough data available to start playing

      if (video.readyState == haveEnoughData) {
        // scale and horizontally center the camera image 
        var videoStreamSize = {
          'width': video.videoWidth,
          'height': video.videoHeight
        };
        var videoDisplaySize = {
          'width': video.scrollWidth,
          'height': video.scrollHeight
        };
        var videoRenderSize = calculateSize(videoStreamSize, videoDisplaySize);
        var xOffset =
            (videoDisplaySize['width']! - videoRenderSize['width']) / 2;

        widget.model.streamwidth = videoStreamSize["width"];
        widget.model.streamheight = videoStreamSize["height"];
        widget.model.displaywidth = videoDisplaySize["width"];
        widget.model.displayheight = videoDisplaySize["height"];
        widget.model.renderwidth = videoRenderSize["width"];
        widget.model.renderheight = videoRenderSize["height"];

        if (widget.model.scale) {
          canvas.width = toInt(videoRenderSize["width"]);
          canvas.height = toInt(videoRenderSize["height"]);
          canvas.context2D.drawImageScaled(video, xOffset, 0,
              videoRenderSize["width"], videoRenderSize["height"]);
        } else {
          canvas.width = videoStreamSize["width"];
          canvas.height = videoStreamSize["height"];
          canvas.context2D.drawImage(video, 0, 0);
        }

        lastFrame = epoch;
      }
    } catch (e) {
      // System.toast("Error in video");
    }

    // Request another frame
    if (abort != true) window.requestAnimationFrame(renderFrame);
  }

  Map<String, dynamic> calculateSize(
      Map<String, int> srcSize, Map<String, int> dstSize) {
    var srcRatio = srcSize['width']! / srcSize['height']!;
    var dstRatio = dstSize['width']! / dstSize['height']!;
    if (dstRatio > srcRatio) {
      return {
        'width': dstSize['height']! * srcRatio,
        'height': dstSize['height']
      };
    } else {
      return {
        'width': dstSize['height'],
        'height': dstSize['width']! / srcRatio
      };
    }
  }

  Future start() async {
    try {
      if (stream != null) return;
      Log().debug("Starting Camera");
      var mediaConstraints = <String, dynamic>{
        'audio': false,
        'video': {
          'facingMode': 'environment',
          'width': {'ideal': 1920},
          'height': {'ideal': 1080}
        }
      };
      dynamic cameras;
      cameras ??=
          await window.navigator.mediaDevices!.getUserMedia(mediaConstraints);
      window.navigator.mediaDevices!
          .getUserMedia(mediaConstraints)
          .then((MediaStream stream) {
        this.stream = stream;
        video.srcObject = stream;
        if (widget.model.enabled) video.play();
        window.requestAnimationFrame(renderFrame);
      }).catchError(onError);
      Log().debug("Camera Started");
    } catch (e) {
      Log().debug('$e');
    }
  }

  Future stop() async {
    try {
      if (stream == null) return;
      Log().debug("Stopping Camera");
      video.pause();
      if (stream != null) {
        stream!.getTracks().forEach((track) => track.stop());
      }
      stream = null;
      Log().debug("Camera Stopped");
    } catch (e) {
      Log().debug('$e');
    }
  }

  Future pause() async {
    try {
      if ((stream == null) || (video.paused)) return;
      Log().debug("Pausing Camera");
      video.pause();
      Log().debug("Camera Paused");
    } catch (e) {
      Log().debug('$e');
    }
  }

  Future play() async {
    try {
      try {
        if ((stream == null) || (!video.paused)) return;
        Log().debug("Playing Camera");
        video.play();
        Log().debug("Camera Playing");
      } catch (e) {
        Log().debug('$e');
      }
    } catch (e) {
      Log().debug('$e');
    }
  }

  Future snapshot() async {
    try {
      try {
        if (stream == null) return;
        Log().debug("Taking Snapshot");

        int left = 0;
        int top = 0;
        int width = canvas.width!;
        int height = canvas.height!;
        if ((width + left) > canvas.width!) width = canvas.width! - left;
        if ((height + top) > canvas.height!) height = canvas.height! - top;

        // Get Image RGBA Bitmap 
        ImageData image =
            canvas.context2D.getImageData(left, top, width, height);

        var rgba = image.data.toList();
        var bytes = Uint8List.fromList(rgba);
        for (int i = 0; i < bytes.length; i++) {
          image.data[i] = bytes[i];
        }

        canvas2.width = width;
        canvas2.height = height;
        canvas2.context2D.putImageData(image, 0, 0);

        if (widget.model.debug == true) {
          Blob blob = await canvas2.toBlob('image/png', 1.0);
          await Platform.fileSaveAsFromBlob(blob, "${newId()}-.png");
        }

        ImageData image2 = canvas2.context2D.getImageData(0, 0, width, height);
        var rgba2 = image2.data.toList();

        // save snapshot
        String uri = canvas2.toDataUrl('image/png', 1.0);
        await onSnapshot(rgba2, width, height, UriData.fromString(uri));
      } catch (e) {
        Log().debug('$e');
      }
    } catch (e) {
      Log().debug('$e');
    }
  }

  onError(error) {
    // Camera Launch Failed
    widget.model.onFail(Data(), message: error);
  }

  @override
  Widget build(BuildContext context) {
    // start stream
    if (widget.model.stream) performDetection();
    return Offstage(child: videoWidget);
  }

  toggleCamera() async {
    selectedCamera++;
    if (selectedCamera >= cameras.length) selectedCamera = 0;
    await stop();
    start();
  }

  void onStream(List<int> bytes, int width, int height) {
    // detect in stream
    if (widget.model.detectors != null) {
      DetectableImage? detectable =
          DetectableImage.fromRgba(bytes, width, height);
      widget.model.detectInStream(detectable);
    }
  }

  Future<void> onSnapshot(
      List<int> bytes, int width, int height, UriData uri) async {
    // detect in stream
    if (widget.model.detectors != null) {
      DetectableImage? detectable =
          DetectableImage.fromRgba(bytes, width, height);
      widget.model.detectInImage(detectable);
    }

    // save file
    Blob blob = Blob(bytes);
    final url = Url.createObjectUrlFromBlob(blob);

    String name = "${newId()}.pdf";

    var file = File(blob, url, name, await Mime.type(name), bytes.length);
    widget.model.onFile(file);
  }
}
