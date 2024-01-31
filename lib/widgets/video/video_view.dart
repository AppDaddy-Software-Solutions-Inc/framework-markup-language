// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/system.dart';
import 'package:fml/widgets/icon/icon_model.dart';
import 'package:fml/widgets/icon/icon_view.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/text/text_view.dart';
import 'package:fml/widgets/video/ivideo_player.dart';
import 'package:fml/widgets/video/video_model.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_win/video_player_win_plugin.dart';

class VideoView extends StatefulWidget implements IWidgetView
{
  @override
  final VideoModel model;

  VideoView(this.model) : super(key: ObjectKey(model));

  @override
  VideoViewState createState() => VideoViewState();
}

class VideoViewState extends WidgetState<VideoView> implements IVideoPlayer
{
  VideoPlayerController? _controller;
  IconView? playButton;
  IconModel playButtonModel = IconModel(null, null, icon: Icons.pause, size: 65, color: Colors.white);

  TextView? speedLabel;
  TextModel speedLabelModel = TextModel(null, null);

  static const List<double> _playbackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  @override
  void initState()
  {
    super.initState();

    // If running on windows ensure to register the Windows Media Player
    if (System().useragent == 'windows') WindowsVideoPlayer.registerWith();

    // set player
    widget.model.player = this;

    // initialize the controller
    play(widget.model.url);
  }

  @override
  void dispose()
  {
    _controller?.removeListener(onVideoController);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  onModelChange(WidgetModel model, {String? property, dynamic value})
  {
    if (mounted) setState((){});
  }

  Widget getPlayButton()
  {
    // shutter
    playButton ??= IconView(playButtonModel);
    var play = UnconstrainedBox(
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
                onTap: startstop,
                child: Stack(alignment: Alignment.center, children: [
                  Icon(Icons.circle, color: Colors.white38, size: 80),
                  playButton!
                ]))));
    return Positioned(bottom: 0, top: 0, left: 0, right: 0, child: play);
  }

  Widget getSpeedButton()
  {
    speedLabel ??= TextView(speedLabelModel);
    speedLabelModel.value = '${_controller?.value.playbackSpeed}x';

    var label = Stack(alignment: Alignment.center, children: [
      Icon(Icons.circle, color: Colors.white38, size: 40), speedLabel!]);

    var popup = PopupMenuButton<double>(
        initialValue: _controller?.value.playbackSpeed,
        tooltip: 'Playback speed',
        onSelected: (double speed)
        {
          _controller?.setPlaybackSpeed(speed);
          speedLabelModel.value = '${speed}x';
        },
        itemBuilder: (BuildContext context)
        {
          return <PopupMenuItem<double>>[for (final double speed in _playbackRates) PopupMenuItem<double>(value: speed, child: Text('${speed}x'))];
        },
        child: label);

      return Positioned(top: 5, right: 5, child: popup);
    }

  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // create the view
    Widget view = Container();
    if (_controller != null && _controller!.value.isInitialized)
    {
      var videoPlayer = VideoPlayer(_controller!);
      var subTitles   = ClosedCaption(text: _controller!.value.caption.text);
      var progressBar = widget.model.controls ? VideoProgressIndicator(_controller!, allowScrubbing: true) : Offstage();
      var playButton  = widget.model.controls ? getPlayButton()  : Offstage();
      var speedButton = widget.model.controls ? getSpeedButton() : Offstage();
      var stack = Stack(alignment: Alignment.bottomCenter, children: <Widget>[videoPlayer,subTitles,speedButton, playButton, progressBar]);
      view = AspectRatio(aspectRatio: _controller!.value.aspectRatio, child: stack);
      view = GestureDetector(onTap: startstop, child: view);
    }

    // add margins
    view = addMargins(view);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.tightestOrDefault);

    // final view
    return view;
  }

  void onVideoController()
  {
    if (_controller == null) return;
    if(!_controller!.value.isPlaying)
    {
      playButtonModel.icon = Icons.pause;
      playButtonModel.size = 65;
      if (_controller!.value.position == _controller!.value.duration) seek(0);
    }
    else
    {
      playButtonModel.icon = Icons.play_arrow;
      playButtonModel.size = 65;
    }
    _controller!.setLooping(widget.model.loop);
  }

  Future<bool> startstop() async
  {
    if (_controller == null) return false;
    if (_controller!.value.isPlaying) return await pause();
    if (_controller!.value.position == _controller!.value.duration) return await start();
    return await resume();
  }

  @override
  Future<bool> play(String? url) async
  {
    if (_controller != null) _controller!.dispose();
    Uri? uri = Uri.tryParse(url ?? "");
    if (uri != null)
    {
      // initialize the controller
      _controller = VideoPlayerController.networkUrl(uri)..initialize().then((_)
      {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        if (mounted) setState(() {});
      });
      _controller!.addListener(onVideoController);
    }
    return true;
  }

  @override
  Future<bool> start() async
  {
    if (_controller == null) return false;
    if (!_controller!.value.isInitialized) await _controller!.initialize();
    await seek(0);
    _controller!.play();
    return true;
  }

  @override
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

  @override
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

  @override
  Future<bool> seek(int seconds) async
  {
    if (_controller == null) return false;
    if (_controller!.value.isInitialized) await _controller!.seekTo(Duration(seconds: seconds));
    return true;
  }
}
