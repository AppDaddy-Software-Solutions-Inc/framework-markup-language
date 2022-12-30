// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/widgets/icon/icon_model.dart';
import 'package:fml/widgets/icon/icon_view.dart';
import 'package:fml/widgets/video/video_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget
{
  final VideoModel model;

  VideoView(this.model) : super(key: ObjectKey(model));

  @override
  VideoViewState createState() => VideoViewState();
}

class VideoViewState extends State<VideoView> implements IModelListener
{
  VideoPlayerController? _controller;
  IconView? shutterbutton;
  IconModel shutterbuttonmodel = IconModel(null, null, icon: Icons.pause, size: 65, color: Colors.white);

  @override
  void initState()
  {
    super.initState();

    // register listener to the model
    widget.model.registerListener(this);

    // set player
    widget.model.player = this;

    // initialize the controller
    load(widget.model.url);
  }

  /// Callback to fire the [CameraViewState.build] when the [CameraModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value})
  {
    if (this.mounted)
    {
      setState(() {});
    }
  }

  @override
  void dispose()
  {
    if (_controller != null) return;
    _controller!.removeListener(onVideoController);
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Set Build Constraints in the [WidgetModel]
    widget.model.minwidth  = constraints.minWidth;
    widget.model.maxwidth  = constraints.maxWidth;
    widget.model.minheight = constraints.minHeight;
    widget.model.maxheight = constraints.maxHeight;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // create the view
    Widget view = (_controller != null && _controller!.value.isInitialized) ? AspectRatio(aspectRatio: _controller!.value.aspectRatio, child: VideoPlayer(_controller!)) : Container();

    //if (_controller.value.isInitialized) _controller.play();

    // Constrained?
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
    }
    else view = Container(child: view, width: width, height: height);

    // stack children
    List<Widget> children = [];
    children.add(view);

    if (widget.model.children != null)
      widget.model.children!.forEach((model)
      {
        if (model is IViewableWidget)
        {
          children.add((model as IViewableWidget).getView());
        }
      });

    // show controls
    if (widget.model.controls != false)
    {
      // shutter
      if (shutterbutton == null) shutterbutton = IconView(shutterbuttonmodel);
      var shutter = UnconstrainedBox(
          child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                  onTap: startstop,
                  child: Stack(alignment: Alignment.center, children: [
                    Icon(Icons.circle, color: Colors.white38, size: 80),
                    shutterbutton!
                  ]))));
      children.add(Positioned(bottom: 25, left: 0, right: 0, child: shutter));
    }

    // final view
    return Stack(children: children);
  }

  void onVideoController()
  {
    if (_controller == null) return;
    if(!_controller!.value.isPlaying)
    {
      shutterbuttonmodel.icon = Icons.pause;
      shutterbuttonmodel.size = 65;
      if (_controller!.value.position == _controller!.value.duration) seek(0);
    }
    else
    {
      shutterbuttonmodel.icon = Icons.play_arrow;
      shutterbuttonmodel.size = 65;
    }
  }

  Future<bool> startstop() async
  {
    if (_controller == null) return false;
    if (_controller!.value.isPlaying) return await pause();
    if (_controller!.value.position == _controller!.value.duration) return await start();
    return await resume();
  }

  Future<bool> load(String? url) async
  {
    if (_controller != null) _controller!.dispose();
    Uri? uri = Uri.tryParse(url ?? "");
    if (uri != null)
    {
      // initialize the controller
      _controller = VideoPlayerController.network(url!)..initialize().then((_)
      {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        if (mounted) setState(() {});
      });
      _controller!.addListener(onVideoController);
    }
    return true;
  }

  Future<bool> start() async
  {
    if (_controller == null) return false;
    if (!_controller!.value.isInitialized) await _controller!.initialize();
    await seek(0);
    _controller!.play();
    return true;
  }

  Future<bool> stop() async
  {
    if (_controller == null) return false;
    if (_controller!.value.isInitialized)
    {
      await _controller!.pause();
      await seek(0);
    }
    return true;
  }

  Future<bool> pause() async
  {
    if (_controller == null) return false;
    if (_controller!.value.isInitialized) await _controller!.pause();
    return true;
  }

  Future<bool> resume() async
  {
    if (_controller == null) return false;
    if (!_controller!.value.isInitialized) await _controller!.initialize();
    _controller!.play();
    return true;
  }

  Future<bool> seek(int seconds) async
  {
    if (_controller == null) return false;
    if (_controller!.value.isInitialized) await _controller!.seekTo(Duration(seconds: seconds));
    return true;
  }
}
