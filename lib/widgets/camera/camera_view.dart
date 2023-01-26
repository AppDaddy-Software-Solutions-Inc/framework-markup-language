// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:fml/data/data.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/camera/camera_model.dart';
import 'package:fml/widgets/camera/stream/stream.dart' as STREAM;
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/icon/icon_model.dart';
import 'package:fml/widgets/icon/icon_view.dart';
import 'package:fml/datasources/file/file.dart' as FILE;
import 'package:flutter/material.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

import 'package:fml/datasources/detectors/image/detectable_image.stub.dart'
if (dart.library.io)   'package:fml/datasources/detectors/image/detectable_image.mobile.dart'
if (dart.library.html) 'package:fml/datasources/detectors/image/detectable_image.web.dart';

class CameraView extends StatefulWidget
{
  final CameraModel model;

  CameraView(this.model) : super(key: ObjectKey(model));

  @override
  CameraViewState createState() => CameraViewState();
}

class CameraViewState extends State<CameraView>
    implements IModelListener {
  CameraController? controller;

  List<CameraDescription>? cameras;
  CameraPreview? camera;

  STREAM.View? backgroundStream;

  int _pointers = 0;

  double _zoom = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _baseScale = 1.0;

  IconView? shutterbutton;
  IconView? selectorbutton;

  List<OverlayEntry> overlays = [];

  @override
  void initState() {
    super.initState();

    ///////////////////////
    /* Register Listener */
    ///////////////////////
    widget.model.registerListener(this);

    // register camera
    widget.model.camera = this;

    // start camera
    initialize();
  }

  /// Callback to fire the [CameraViewState.build] when the [CameraModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    var b = Binding.fromString(property);
    if (this.mounted) {
      if (b?.property == 'index') {
        initialize();
      } else if (b?.property == 'enabled') {
        if (widget.model.enabled)
          start();
        else
          stop();
      } else if (b?.property == 'visible') {
        if (!widget.model.visible) {
          stop();
          setState(() {});
        } else
          initialize();
      }
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    backgroundStream = null;
    super.dispose();
  }

  toggleCamera() async {
    int index = widget.model.index ?? 0;
    index++;
    if (index >= cameras!.length) index = 0;

    // this will fire onModelChange
    widget.model.index = index;
  }

  initialize() async {
    try {
      // camera is busy
      widget.model.busy = true;

      if (!widget.model.visible) return;

      // get cameras
      if (cameras == null) cameras = await availableCameras();
      if ((cameras != null) && (cameras!.length > 0)) {
        // set specified camera
        int index = widget.model.index ?? -1;
        if (index < 0) {
          // get the camera
          CameraLensDirection direction =
              S.toEnum(widget.model.direction, CameraLensDirection.values) ??
                  CameraLensDirection.back;
          var camera = cameras!
              .firstWhereOrNull((camera) => camera.lensDirection == direction);
          if (camera != null)
            index = cameras!.indexOf(camera);
          else
            index = 0;

          // this will fire onModelChange
          widget.model.index = index;
          return;
        }

        // index exceeds camera length
        if (widget.model.index! >= cameras!.length) {
          // this will fire onModelChange
          widget.model.index = cameras!.length - 1;
          return;
        }

        // set the camera
        final camera = cameras![widget.model.index!];

        // front facing camera
        widget.model.direction =
            (camera.lensDirection == CameraLensDirection.external) ||
                    (camera.lensDirection == CameraLensDirection.front)
                ? S.fromEnum(CameraLensDirection.front)
                : S.fromEnum(CameraLensDirection.back);

        // camera name
        widget.model.name = camera.name;

        // default the format
        var format = ImageFormatGroup.yuv420;
        if (kIsWeb) format = ImageFormatGroup.jpeg;

        // default the resolution
        ResolutionPreset resolution =
            S.toEnum(widget.model.resolution, ResolutionPreset.values) ??
                ResolutionPreset.medium;
        if (widget.model.stream)
          resolution =
              (kIsWeb) ? ResolutionPreset.medium : ResolutionPreset.low;

        // build the controller
        controller = CameraController(camera, resolution,
            imageFormatGroup: format, enableAudio: false);

        // initialize the controller
        await controller!.initialize();
        if (!mounted) return;
        try {
          // min zoom
          _zoom = await controller!.getMinZoomLevel();
          _minAvailableZoom = _zoom;
        } catch (e) {}

        try {
          // max zoom
          _maxAvailableZoom = await controller!.getMaxZoomLevel();
        } catch (e) {}

        // set aspect ratio
        widget.model.scale = controller!.value.aspectRatio;

        // set display size
        widget.model.renderwidth = controller!.value.previewSize!.width;
        widget.model.renderheight = controller!.value.previewSize!.height;

        // set orientation
        widget.model.orientation =
            S.fromEnum(controller!.value.deviceOrientation);

        // start stream
        if (widget.model.stream)
          controller!.startImageStream((stream) => onStream(stream, camera));

        // notify initilizied
        widget.model.onInitialized(this.context);

        // camera is busy
        widget.model.busy = false;

        // refresh
        setState(() {});
      }
    } catch (e) {
      Log().debug(e.toString());
      //DialogService().show(type: DialogType.error, description: e.toString());
    }
  }

  Future<bool> start() async {
    if ((controller != null) &&
        (controller!.value.isInitialized) &&
        (controller!.value.isPreviewPaused)) controller!.resumePreview();
    if (widget.model.togglevisible) widget.model.visible = true;
    return true;
  }

  Future<bool> stop() async {
    if ((controller != null) &&
        (controller!.value.isInitialized) &&
        (!controller!.value.isPreviewPaused)) controller!.pausePreview();
        if (widget.model.togglevisible) widget.model.visible = false;
    return true;
  }

  Future<bool> snapshot() async {
    bool ok = true;

    try {
      if ((controller != null) &&
          (controller!.value.isInitialized) &&
          (widget.model.busy != true)) {
        // set busy
        widget.model.busy = true;

        // disable shutter
        if (shutterbutton != null) {
          shutterbutton!.model.color = Colors.lightGreenAccent;
          shutterbutton!.model.size = 60;
        }

        // stop stream
        if (widget.model.stream) controller?.stopImageStream();

        /// take picture
        XFile image = await controller!.takePicture();

        // start stream
        if (widget.model.stream)
          await controller?.startImageStream(
              (stream) => onStream(stream, cameras![widget.model.index ?? 0]));

        // save the image
        ok = await onSnapshot(image);

        // enable shutter
        if (shutterbutton != null) {
          shutterbutton!.model.color = Colors.white;
          shutterbutton!.model.size = 65;
        }

        widget.model.busy = false;
      } else {
        ok = false;
        widget.model.onException(Data(), message: "Failed to take picture");
      }
    } catch (e) {
      ok = false;
      Log().exception(e);
      widget.model.busy = false;
    }

    return ok;
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controller == null || !controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initialize();
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _zoom;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) return;

    _zoom = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_zoom);
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) return;

    final CameraController cameraController = controller!;

    final offset = Offset(details.localPosition.dx / constraints.maxWidth,
        details.localPosition.dy / constraints.maxHeight);

    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints) {
    // Set Build Constraints in the [WidgetModel]

    widget.model.minwidth = constraints.minWidth;
    widget.model.maxwidth = constraints.maxWidth;
    widget.model.minheight = constraints.minHeight;
    widget.model.maxheight = constraints.maxHeight;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // wait for controller to initialize
    if ((controller == null) || (!controller!.value.isInitialized))
      return Container();

    //////////
    /* View */
    //////////
    Widget view;

    _pointers = 0;

    // camera
    view = CameraPreview(controller!, child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        onTapDown: (TapDownDetails details) =>
            onViewFinderTap(details, constraints),
      );
    }));

    // camera
    view = Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: view);

    //////////////////
    /* Constrained? */
    //////////////////
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    if (widget.model.constrained) {
      var constraints = widget.model.getConstraints();
      view = ConstrainedBox(
          child: view,
          constraints: BoxConstraints(
              minHeight: constraints.minHeight!,
              maxHeight: constraints.maxHeight!,
              minWidth: constraints.minWidth!,
              maxWidth: constraints.maxWidth!));
    } else
      view = Container(child: view, width: width, height: height);

    // stack children
    List<Widget> children = [];
    children.add(view);

    // hack to initialize background camera stream. current camera widget doesn't support streaming in web
    if ((kIsWeb) && (widget.model.stream) && (backgroundStream == null)) {
      backgroundStream = STREAM.View(widget.model);
      if (backgroundStream != null)
        children.add(Offstage(child: backgroundStream as Widget?));
    }

    if (widget.model.children != null)
      widget.model.children!.forEach((model) {
        if (model is IViewableWidget) {
          children.add((model as IViewableWidget).getView());
        }
      });

    // show controls
    if (widget.model.controls != false) {
      // zoom slider
      var zoomslider;
      if (_maxAvailableZoom > _minAvailableZoom) {
        zoomslider = Slider(
            value: _zoom,
            min: _minAvailableZoom,
            max: _maxAvailableZoom,
            activeColor: Colors.white,
            inactiveColor: Colors.white30,
            onChanged: (value) async {
              setState(() {
                _zoom = value;
              });
              await controller!.setZoomLevel(value);
            });
        children
            .add(Positioned(bottom: -10, left: 0, right: 0, child: zoomslider));
      }

      // camera selector
      Widget selector;
      if (cameras!.length > 1) {
        if (selectorbutton == null)
          selectorbutton = IconView(IconModel(null, null,
              icon: Icons.cameraswitch_sharp, size: 25, color: Colors.black));
        selector = UnconstrainedBox(
            child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                    onTap: toggleCamera,
                    child: Stack(alignment: Alignment.center, children: [
                      Icon(Icons.circle, color: Colors.white38, size: 65),
                      Icon(Icons.circle, color: Colors.white38, size: 50),
                      selectorbutton!
                    ]))));
        children.add(Positioned(bottom: 25, left: 10, child: selector));
      }

      // shutter
      if (shutterbutton == null)
        shutterbutton = IconView(IconModel(null, null,
            icon: Icons.circle, size: 65, color: Colors.white));
      var shutter = UnconstrainedBox(
          child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                  onTap: snapshot,
                  child: Stack(alignment: Alignment.center, children: [
                    Icon(Icons.circle, color: Colors.white38, size: 80),
                    shutterbutton!
                  ]))));
      children.add(Positioned(bottom: 25, left: 0, right: 0, child: shutter));
    }

    // final view
    return Stack(children: children);
  }

  void onStream(CameraImage image, CameraDescription camera) {
    // detect in stream
    if (widget.model.detectors != null) {
      DetectableImage detectable = DetectableImage.fromCamera(image, camera);
      widget.model.detectInStream(detectable);
    }
  }

  Future<bool> onSnapshot(XFile image) async {
    bool ok = true;

    // detect in image
    if (widget.model.detectors != null) {
      DetectableImage? detectable;

      // blob image - created in web
      if (image.path.startsWith("blob:")) {
        var bytes = await image.readAsBytes();
        var codec = await instantiateImageCodec(bytes);
        var frame = await codec.getNextFrame();
        var data  = await frame.image.toByteData(format: ImageByteFormat.rawRgba);
        if (data != null) detectable = DetectableImage.fromRgba(data.buffer.asUint8List(), frame.image.width, frame.image.height);
      }

      // blob image - created in mobile
      else detectable = DetectableImage.fromFilePath(image.path);

      //detect
      if (detectable != null) widget.model.detectInImage(detectable);
    }

    // apply transforms
    FILE.File file = await widget.model.applyTransforms(image);

    // return file
    widget.model.onFile(file);

    return ok;
  }
}
