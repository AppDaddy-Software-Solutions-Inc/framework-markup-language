// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:io';
import 'package:fml/widgets/icon/icon_model.dart';
import 'package:fml/widgets/icon/icon_view.dart';
import 'package:fml/widgets/video/IVideoPlayer.dart';
import 'package:fml/widgets/video/video_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:flutter/material.dart';
import 'package:dart_vlc/dart_vlc.dart';

StatefulWidget getVideoPlayerView(VideoModel model) => VideoViewVlc(model);

class VideoViewVlc extends StatefulWidget
{
  final VideoModel model;

  VideoViewVlc(this.model) : super(key: ObjectKey(model));

  @override
  VideoViewState createState() => VideoViewState();
}

class VideoViewState extends State<VideoViewVlc> implements IModelListener, IVideoPlayer
{
  static Widget getVideoPlayer() => Container();

  late final Player _controller;
  IconView? shutterbutton;
  IconModel shutterbuttonmodel = IconModel(null, null, icon: Icons.pause, size: 65, color: Colors.white);

  @override
  void initState()
  {
    super.initState();

    // register listener to the model
    widget.model.registerListener(this);

    // initialize DartVLC
    DartVLC.initialize();

    // create the player
    _controller = Player(id: 69420);

    // set player
    widget.model.player = this;

    // initialize the controller
    play(widget.model.url);
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Set Build Constraints in the [WidgetModel]
    widget.model.minWidth  = constraints.minWidth;
    widget.model.maxWidth  = constraints.maxWidth;
    widget.model.minHeight = constraints.minHeight;
    widget.model.maxHeight = constraints.maxHeight;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    var video = Video(player: _controller, scale: 1.0, showControls: widget.model.controls);

  // Constrained?
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    Widget view = Container(child: video, width: width, height: height);

    if (widget.model.hasSizing)
    {
      var constraints = widget.model.getConstraints();
      view = ConstrainedBox(
          child: video,
          constraints: BoxConstraints(
              minHeight: constraints.minHeight!,
              maxHeight: constraints.maxHeight!,
              minWidth: constraints.minWidth!,
              maxWidth: constraints.maxWidth!));
    }

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

    // final view
    return Stack(children: children);
  }

  Future<bool> play(String? url) async
  {
    Uri? uri = Uri.tryParse(url ?? "");
    if (uri != null)
    {
      Media media = Media.network(url, parse: false);
      _controller.open(media,autoStart: true);
    }
    return true;
  }

  Future<bool> start() async
  {
    await seek(0);
    _controller.play();
    return true;
  }

  Future<bool> stop() async
  {
    _controller.pause();
    await seek(0);
    return true;
  }

  Future<bool> pause() async
  {
    _controller.pause();
    return true;
  }

  Future<bool> resume() async
  {
    _controller.play();
    return true;
  }

  Future<bool> seek(int seconds) async
  {
    _controller.seek(Duration(seconds: seconds));
    return true;
  }
}
