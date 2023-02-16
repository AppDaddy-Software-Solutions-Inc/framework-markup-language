// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:html' as HTML;
import 'dart:typed_data';
import 'package:fml/data/data.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/system.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui' as ui;
import 'package:fml/datasources/file/file.dart' as FILE;
import 'package:fml/widgets/camera/camera_model.dart' as CAMERA;
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/camera/stream/stream.dart' as STREAM;
import 'package:fml/helper/common_helpers.dart';

import 'package:fml/datasources/detectors/image/detectable_image.stub.dart'
if (dart.library.io)   'package:fml/datasources/detectors/image/detectable_image.mobile.dart'
if (dart.library.html) 'package:fml/datasources/detectors/image/detectable_image.web.dart';

View getView(model) => View(model);

class View extends StatefulWidget implements STREAM.StreamView {
  final CAMERA.CameraModel model;

  View(this.model) : super(key: ObjectKey(model));

  @override
  ViewState createState() => ViewState();
}

class ViewState extends State<View> implements IModelListener
{
  List<dynamic> cameras = [];
  int selectedCamera = 0;

  bool abort = false;
  Timer? detectionTimer;
  bool detectInImage = false;
  num detectedFrame = 0;

  final String id = Uuid().v1().toString().substring(0, 5);
  num lastFrame = 0;

  Widget? videoWidget;
  late HTML.VideoElement video;
  late HTML.CanvasElement canvas;
  late HTML.CanvasElement canvas2;
  HTML.MediaStream? stream;

  Map<String, String> devices = Map<String, String>();

  @override
  void initState() {
    Log().debug('web view');
    super.initState();

    /***********************/
    /* Create video widget */
    /***********************/
    videoWidget = HtmlElementView(key: UniqueKey(), viewType: id);

    /************************/
    /* Create Video Element */
    /************************/
    video = HTML.VideoElement();
    video.muted = true;
    video.autoplay = false;
    video.setAttribute('playsinline', 'true');

    /*************************/
    /* Create Canvas Element */
    /*************************/
    canvas = HTML.CanvasElement();
    canvas2 = HTML.CanvasElement();

    /*********************/
    /* Register a webcam */
    /*********************/
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(id, (int viewId) => video);

    /*********************/
    /* Register Listener */
    /*********************/
    widget.model.registerListener(this);

    /****************/
    /* Start Camera */
    /****************/
    start();
  }

  /// Callback to fire the [_ViewState.build] when the [CameraModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    var b = Binding.fromString(property);
    if ((this.mounted) && (b?.property == 'enabled')) {
      Log().debug('enabled changed value');
      if (widget.model.enabled)
        start();
      else
        stop();
    }
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(View oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    Log().debug('disposing of camera ...');
    abort = true;

    stop();

    stream = null;

    /**************************/
    /* Cancel Detection Timer */
    /**************************/
    if (detectionTimer != null) detectionTimer!.cancel();

    super.dispose();
  }

  int tolerance = 0;
  void performDetection() async {
    if (abort) return;

    /**************************/
    /* Cancel Detection Timer */
    /**************************/
    if (detectionTimer != null) detectionTimer!.cancel();

    /****************************/
    /* No New Frames to Detect? */
    /****************************/
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

          /*************************/
          /* Get Image RGBA Bitmap */
          /*************************/
          HTML.ImageData image =
              canvas.context2D.getImageData(left, top, width, height);
          List<int> rgba = image.data.toList();

          /************************/
          /* Convert to Grayscale */
          /************************/
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
            for (int i = 0; i < bytes.length; i++) image.data[i] = bytes[i];
            canvas2.width = width;
            canvas2.height = height;
            canvas2.context2D.putImageData(image, 0, 0);
            HTML.Blob blob = await canvas2.toBlob('image/png', 1.0);
            await Platform.fileSaveAsFromBlob(blob, System().uuid() + '-' + '.png');
          }

          // process stream image
          onStream(rgba, width, height);
        }
      } catch(e) {
        //DialogService().show(type: DialogType.error, title: 'detecting error2');
      }
    }

    /***************************/
    /* Schedule Next Detection */
    /***************************/
    detectionTimer = Timer(Duration(milliseconds: 50), performDetection);
  }

  bool doneonce = false;
  void renderFrame(num epoch) {
    try {
      //const int HAVE_NOTHING      = 0; // no information whether or not the video is ready
      //const int HAVE_METADATA     = 1; // metadata for the video is ready
      //const int HAVE_CURRENT_DATA = 2; // data for the current playback position is available, but not enough data to play next frame/millisecond
      //const int HAVE_FUTURE_DATA  = 3; // data for the current and at least the next frame is available
      const int HAVE_ENOUGH_DATA = 4; // enough data available to start playing

      if (video.readyState == HAVE_ENOUGH_DATA) {
        /**************************************************/
        /* scale and horizontally center the camera image */
        /**************************************************/
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

        if (widget.model.scale)
        {
          canvas.width = S.toInt(videoRenderSize["width"]);
          canvas.height = S.toInt(videoRenderSize["height"]);
          canvas.context2D.drawImageScaled(video, xOffset, 0,
              videoRenderSize["width"], videoRenderSize["height"]);
        } else {
          canvas.width = videoStreamSize["width"];
          canvas.height = videoStreamSize["height"];
          canvas.context2D.drawImage(video, 0, 0);
        }

        lastFrame = epoch;
      }
    } catch(e) {
      // System.toast("Error in video");
    }

    // Request another frame
    if (abort != true) HTML.window.requestAnimationFrame(renderFrame);
  }

  Map<String, dynamic> calculateSize(
      Map<String, int> srcSize, Map<String, int> dstSize) {
    var srcRatio = srcSize['width']! / srcSize['height']!;
    var dstRatio = dstSize['width']! / dstSize['height']!;
    if (dstRatio > srcRatio)
      return {
        'width': dstSize['height']! * srcRatio,
        'height': dstSize['height']
      };
    else
      return {
        'width': dstSize['height'],
        'height': dstSize['width']! / srcRatio
      };
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
      if (cameras == null)
        cameras = await HTML.window.navigator.mediaDevices!
            .getUserMedia(mediaConstraints);
      HTML.window.navigator.mediaDevices!
          .getUserMedia(mediaConstraints)
          .then((HTML.MediaStream stream) {
        this.stream = stream;
        video.srcObject = stream;
        if (widget.model.enabled) video.play();
        HTML.window.requestAnimationFrame(renderFrame);
      }).catchError(onError);
      Log().debug("Camera Started");
    } catch(e) {}
  }

  Future stop() async {
    try {
      if (stream == null) return;
      Log().debug("Stopping Camera");
      video.pause();
      if (this.stream != null)
        this.stream!.getTracks().forEach((track) => track.stop());
      this.stream = null;
      Log().debug("Camera Stopped");
    } catch(e) {}
  }

  Future pause() async {
    try {
      if ((stream == null) || (video.paused)) return;
      Log().debug("Pausing Camera");
      video.pause();
      Log().debug("Camera Paused");
    } catch(e) {}
  }

  Future play() async {
    try {
      try {
        if ((stream == null) || (!video.paused)) return;
        Log().debug("Playing Camera");
        video.play();
        Log().debug("Camera Playing");
      } catch(e) {}
    } catch(e) {}
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

        /*************************/
        /* Get Image RGBA Bitmap */
        /*************************/
        HTML.ImageData image =
            canvas.context2D.getImageData(left, top, width, height);

        var rgba = image.data.toList();
        var bytes = Uint8List.fromList(rgba);
        for (int i = 0; i < bytes.length; i++) image.data[i] = bytes[i];

        canvas2.width = width;
        canvas2.height = height;
        canvas2.context2D.putImageData(image, 0, 0);

        if (widget.model.debug == true) {
          HTML.Blob blob = await canvas2.toBlob('image/png', 1.0);
          await Platform.fileSaveAsFromBlob(blob, System().uuid() + '-' + '.png');
        }

        HTML.ImageData image2 =
            canvas2.context2D.getImageData(0, 0, width, height);
        var rgba2 = image2.data.toList();

        // save snapshot
        String uri = canvas2.toDataUrl('image/png', 1.0);
        await onSnapshot(rgba2, width, height, UriData.fromString(uri));
      } catch(e) {}
    } catch(e) {}
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
      DetectableImage? detectable = DetectableImage.fromRgba(bytes, width, height);
      widget.model.detectInStream(detectable);
    }
  }

  Future<void> onSnapshot(
      List<int> bytes, int width, int height, UriData uri) async {
    // detect in stream
    if (widget.model.detectors != null) {
      DetectableImage? detectable = DetectableImage.fromRgba(bytes, width, height);
      widget.model.detectInImage(detectable);
    }

    // save file
    HTML.Blob blob = HTML.Blob(bytes);
    final url = HTML.Url.createObjectUrlFromBlob(blob);

    String name = "${Uuid().v4().toString()}.pdf";

    var file = FILE.File(blob, url, name, await S.mimetype(name), bytes.length);
    widget.model.onFile(file);
  }
}
