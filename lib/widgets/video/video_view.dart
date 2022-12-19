// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
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
  late VideoPlayerController _controller;

  @override
  void initState()
  {
    super.initState();

    // register listener to the model
    widget.model.registerListener(this);

    // initialize the controller
    if (widget.model.url != null)
    _controller = VideoPlayerController.network(widget.model.url!)..initialize().then((_)
    {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
    });
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: builder);
  }

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
    Widget view = _controller.value.isInitialized ? AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller)) : Container();

    if (_controller.value.isInitialized) _controller.play();

    // Constrained?
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    if (widget.model.constrained) {
      Map<String, double?> constraints = widget.model.constraints;
      view = ConstrainedBox(
          child: view,
          constraints: BoxConstraints(
              minHeight: constraints['minheight']!,
              maxHeight: constraints['maxheight']!,
              minWidth: constraints['minwidth']!,
              maxWidth: constraints['maxwidth']!));
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
    }

    // final view
    return Stack(children: children);
  }

  Future<bool> start() async
  {
    if (_controller.value.isInitialized && !_controller.value.isPlaying) _controller.play();
    return true;
  }

  Future<bool> stop() async
  {
    if (_controller.value.isInitialized && _controller.value.isPlaying)
    {
      _controller.pause();
      seek(0);
    }
    return true;
  }

  Future<bool> pause() async
  {
    if (_controller.value.isInitialized && _controller.value.isPlaying)
    {
      _controller.pause();
    }
    return true;
  }

  Future<bool> seek(int seconds) async
  {
    if (_controller.value.isInitialized && _controller.value.isPlaying)
    {
      _controller.seekTo(Duration(seconds: seconds));
    }
    return true;
  }
}
