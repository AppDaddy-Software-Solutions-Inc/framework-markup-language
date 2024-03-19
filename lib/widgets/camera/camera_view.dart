// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:fml/data/data.dart';
import 'package:fml/fml.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/camera/camera_model.dart';
import 'package:fml/widgets/camera/stream/stream.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/icon/icon_model.dart';
import 'package:fml/widgets/icon/icon_view.dart';
import 'package:fml/datasources/file/file.dart';
import 'package:flutter/material.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helpers/helpers.dart';

import 'package:fml/datasources/detectors/image/detectable_image.stub.dart'
if (dart.library.io)   'package:fml/datasources/detectors/image/detectable_image.mobile.dart'
if (dart.library.html) 'package:fml/datasources/detectors/image/detectable_image.web.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class CameraView extends StatefulWidget implements IWidgetView
{
  @override
  final CameraModel model;

  CameraView(this.model) : super(key: ObjectKey(model));

  @override
  CameraViewState createState() => CameraViewState();
}

class CameraViewState extends WidgetState<CameraView>
{
  CameraController? controller;
  List<CameraDescription>? cameras;

  StreamView? backgroundStream;

  int _pointers = 0;

  double _zoom = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _baseScale = 1.0;

  IconView? shutterbutton;
  IconView? selectorbutton;

  List<OverlayEntry> overlays = [];

  late bool initialized;

  @override
  void initState()
  {
    super.initState();

    // register camera
    widget.model.camera = this;

    _getCameras().then((value)
    {
      initialized = true;
      _configureCameras();
    });
  }

  @override
  void dispose()
  {
    super.dispose();
    _disposeOfCamera();
  }

  /// Callback to fire the [CameraViewState.build] when the [CameraModel] changes
  @override
  onModelChange(WidgetModel model, {String? property, dynamic value})
  {
    if (mounted)
    {
      var b = Binding.fromString(property);
      switch (b?.property)
      {
        // changed camera
        case 'index':
          reconfigureCameras();
          break;

        // enable/disable
        case 'enabled':
          widget.model.enabled ? start() : stop();
          break;

        // visible/hidden
        case 'visible':

          // stop the camera
          if (!widget.model.visible)
          {
            stop();
            setState(() {});
            break;
          }

          // start the camera
          if (controller != null)
          {
            start();
            setState(() {});
            break;
          }

          // initialize the camera
          else {
            reconfigureCameras();
          }
          break;

      }
    }
  }

  toggleCamera() async
  {
    if (cameras != null) {
      int index = widget.model.index ?? 0;
      index++;
      if (index >= cameras!.length) index = 0;

      // this will fire onModelChange
      widget.model.index = index;
    }
    else {
      Log().exception('No cameras to toggle',  caller: 'camera.View');
    }
  }

  Future<bool> _getCameras() async
  {
      // get cameras
      int tries = 0;
      while (cameras == null && tries < 5)
      {
        if (tries > 0) await Future.delayed(const Duration(seconds: 1));
        tries++;

        try
        {
          cameras = await availableCameras();
        }
        catch(e)
        {
          if (e is CameraException)
          {
          switch (e.code.toLowerCase())
          {
            case 'permissiondenied':
            // Thrown when user is not on a secure (https) connection.
              widget.model.onFail(Data(), message: "Camera is only available over a secure (https) connection");
              break;
            default:
            // Handle other errors here.
              widget.model.onFail(Data(), message: "Unable to get any available Cameras");
              Log().exception('Unable to get availableCameras() - ${e.code}: ${e.toString()}');
              break;
          }
        }
        else
        {
          Log().exception(e,  caller: 'camera.View');
        }
      }
    }
    return true;
  }

  _configureCameras() async
  {
    try
    {
      // camera is busy
      widget.model.busy = true;

      if (!widget.model.visible) return;

      // a bug in the desktop controller causes the
      // program to crash if re-initialized;
      if (FmlEngine.isDesktop && controller != null)
      {
        setState(() {});
        return;
      }

      if (cameras == null) {
        Log().exception('Unable to access device Camera(s) to initialize', caller: 'camera.View');
        widget.model.onFail(Data(), message: "Unable to access device Camera(s) to initialize");
        return;
      }

      if (cameras!.isNotEmpty)
      {
        // set specified camera
        int index = widget.model.index ?? -1;
        if (index.isNegative)
        {
          // get the camera
          CameraLensDirection direction = toEnum(widget.model.direction, CameraLensDirection.values) ?? CameraLensDirection.back;
          var camera = cameras!.firstWhereOrNull((camera) => camera.lensDirection == direction);
          if (camera != null) {
            index = cameras!.indexOf(camera);
          } else {
            index = 0;
          }

          // this will fire onModelChange
          widget.model.index = index;
          return;
        }

        // index exceeds camera length
        if (widget.model.index! >= cameras!.length)
        {
          // this will fire onModelChange
          widget.model.index = cameras!.length - 1;
          return;
        }

        // set the camera
        CameraDescription camera = cameras![widget.model.index!];

        // front facing camera
        widget.model.direction = (camera.lensDirection == CameraLensDirection.external) || (camera.lensDirection == CameraLensDirection.front) ? fromEnum(CameraLensDirection.front) : fromEnum(CameraLensDirection.back);

        // camera name
        widget.model.name = camera.name;

        // default the format
        var format = ImageFormatGroup.yuv420;
        if (FmlEngine.isWeb) format = ImageFormatGroup.jpeg;

        // default the resolution
        ResolutionPreset resolution = toEnum(widget.model.resolution, ResolutionPreset.values) ?? ResolutionPreset.medium;
        if (widget.model.stream) resolution = (FmlEngine.isWeb) ? ResolutionPreset.medium : ResolutionPreset.low;

        // build the controller
        controller = CameraController(camera, resolution, imageFormatGroup: format, enableAudio: false);

        if (controller != null)
        {
          controller!.addListener(()
          {
            if (controller!.value.hasError) Log().debug('Camera Controller error ${controller!.value.errorDescription}', caller: 'camera/camera_view.dart => initialize()');
          });
        }
        else {
          Log().debug('Camera Controller is null', caller: 'camera/camera_view.dart => initialize()');
        }

        // initialize the controller
        try
        {
          await controller!.initialize();
          if (!mounted) return;
        }
        catch(e)
        {
          if (e is CameraException)
          {
            switch (e.code.toLowerCase())
            {
              case 'cameraaccessdenied':
              // Thrown when user denies the camera access permission.
                widget.model.onFail(Data(), message: "User denied Camera/Microphone access permissions");
                break;
              case 'cameraaccessdeniedwithoutprompt':
              // iOS only for now. Thrown when user has previously denied the permission. iOS does not allow prompting alert dialog a second time. Users will have to go to Settings > Privacy > Camera in order to enable camera access.
                widget.model.onFail(Data(), message: "User previously denied Camera access permissions, to change this go to Settings > Privacy > Camera");
                break;
              case 'cameraaccessrestricted':
              // iOS only for now. Thrown when camera access is restricted and users cannot grant permission (parental control).
                widget.model.onFail(Data(), message: "Parental control denied Camera access permissions");
                break;
              case 'audioaccessdenied':
              // Thrown when user denies the audio access permission.
                widget.model.onFail(Data(), message: "User denied Microphone access permissions");
                break;
              case 'audioaccessdeniedwithoutprompt':
              // iOS only for now. Thrown when user has previously denied the permission. iOS does not allow prompting alert dialog a second time. Users will have to go to Settings > Privacy > Microphone in order to enable audio access.
                widget.model.onFail(Data(), message: "User previously denied Microphone access permissions, to change this go to Settings > Privacy > Microphone");
                break;
              case 'audioaccessrestricted':
              // iOS only for now. Thrown when audio access is restricted and users cannot grant permission (parental control).
                widget.model.onFail(Data(), message: "Parental control denied Microphone access permissions");
                break;
              default:
              // Handle other errors here.
                widget.model.onFail(Data(), message: "Camera Initialization Error");
                break;
            }
          }
          else {
            Log().exception(e,  caller: 'camera.View');
          }
        }

        try {
          // min zoom
          _zoom = await controller!.getMinZoomLevel();
          _minAvailableZoom = _zoom;
        } catch(e)
        {
          Log().debug('$e');
        }

        try {
          // max zoom
          _maxAvailableZoom = await controller!.getMaxZoomLevel();
        } catch(e) {
          Log().debug('$e');
        }

        // set aspect ratio
        widget.model.scale = controller!.value.aspectRatio;

        // set display size
        widget.model.renderwidth = controller!.value.previewSize!.width;
        widget.model.renderheight = controller!.value.previewSize!.height;

        // set orientation
        widget.model.orientation = fromEnum(controller!.value.deviceOrientation);

        // start stream
        if (widget.model.stream)
        {
          if (!FmlEngine.isDesktop) {
            controller!.startImageStream((stream) => onStream(stream, camera));
          } else {
            Log().error('Streaming is not yet supported on desktop');
          }
        }

        // notify initilizied
        widget.model.onInitialized();

        // camera is busy
        widget.model.busy = false;

        // refresh
        setState(() {});
      }
    } catch(e) {
      Log().debug(e.toString());
      //DialogService().show(type: DialogType.error, description: e.toString());
    }
  }

  Future<void> _disposeOfCamera() async
  {
    try
    {
      await controller?.dispose();
    }
    catch(e){
      Log().debug('$e');
    }

    controller = null;
    backgroundStream = null;
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
      if (cameras != null && cameras!.isNotEmpty && controller != null
          && controller!.value.isInitialized && widget.model.busy != true) {
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
        if (widget.model.stream) {
          await controller?.startImageStream(
              (stream) => onStream(stream, cameras![widget.model.index ?? 0]));
        }

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
        widget.model.onFail(Data(), message: "Failed to take picture");
        Log().debug('Unable to take a snapshot');
      }
    } catch(e) {
      ok = false;
      Log().exception(e);
      widget.model.busy = false;
    }

    return ok;
  }

  void didChangeAppLifecycleState(AppLifecycleState state)
  {
    System.toast("Life cycle change");
    if (controller == null || !controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive)
    {
      _disposeOfCamera();
    }
    else if (state == AppLifecycleState.resumed)
    {
      reconfigureCameras();
    }
  }

  void reconfigureCameras() async
  {
    await _disposeOfCamera();
    if (initialized) _configureCameras();
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
    try {
      cameraController.setExposurePoint(offset);
    } catch(e) {
      Log().debug(e.toString(), caller: 'onViewFinderTap() cameraController.setExposurePoint');
    }
    try {
      cameraController.setFocusPoint(offset);
    } catch(e) {
      Log().debug(e.toString(), caller: 'onViewFinderTap() cameraController.setFocusPoint');
    }
  }

  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // wait for controller to initialize
    try {
      if (initialized != true || (controller == null) || (!controller!.value.isInitialized)) {
        return Container();
      }
    } catch(e) {
      return Container();
    }

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
    double width  = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    // basic constraints
    view = SizedBox(width: width, height: height, child: view);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.constraints);

    // stack children
    List<Widget> children = [];
    children.add(view);

    // hack to initialize background camera stream. current camera widget doesn't support streaming in web
    if ((FmlEngine.isWeb) && (widget.model.stream) && (backgroundStream == null)) {
      backgroundStream = StreamView(widget.model);
      if (backgroundStream != null) {
        children.add(Offstage(child: backgroundStream as Widget?));
      }
    }

    // build the child views
    children.addAll(widget.model.inflate());

    // show controls
    if (widget.model.controls != false) {
      // zoom slider
      Slider? zoomslider;
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
      if (cameras != null && cameras!.length > 1) {
        selectorbutton ??= IconView(IconModel(null, null,
              icon: Icons.cameraswitch_sharp, size: 25, color: Colors.black));
        selector = UnconstrainedBox(
            child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                    onTap: toggleCamera,
                    child: Stack(alignment: Alignment.center, children: [
                      const Icon(Icons.circle, color: Colors.white38, size: 65),
                      const Icon(Icons.circle, color: Colors.white38, size: 50),
                      selectorbutton!
                    ]))));
        children.add(Positioned(bottom: 25, left: 10, child: selector));
      }

      // shutter
      shutterbutton ??= IconView(IconModel(null, null,
            icon: Icons.circle, size: 65, color: Colors.white));
      var shutter = UnconstrainedBox(
          child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                  onTap: snapshot,
                  child: Stack(alignment: Alignment.center, children: [
                    const Icon(Icons.circle, color: Colors.white38, size: 80),
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
      else {
        detectable = DetectableImage.fromFilePath(image.path);
      }

      //detect
      if (detectable != null) widget.model.detectInImage(detectable);
    }

    // apply transforms
    File file = await widget.model.applyTransforms(image);

    // return file
    widget.model.onFile(file);

    return ok;
  }
}
