// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/observable/binding.dart';
import 'package:fml/widgets/icon/icon_model.dart';
import 'package:fml/widgets/icon/icon_view.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/text/text_view.dart';
import 'package:fml/widgets/video/ivideo_player.dart';
import 'package:fml/widgets/video/video_model.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_win/video_player_win_plugin.dart';

// platform
import 'package:fml/platform/platform.vm.dart'
if (dart.library.io) 'package:fml/platform/platform.vm.dart'
if (dart.library.html) 'package:fml/platform/platform.web.dart';

class VideoView extends StatefulWidget implements ViewableWidgetView {
  @override
  final VideoModel model;

  VideoView(this.model) : super(key: ObjectKey(model));

  @override
  VideoViewState createState() => VideoViewState();
}

class VideoViewState extends ViewableWidgetState<VideoView> implements IVideoPlayer {
  VideoPlayerController? _controller;
  IconView? playButton;
  IconModel playButtonModel =
      IconModel(null, null, icon: Icons.pause, size: 65, color: Colors.white);

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
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(dynamic oldWidget){
    super.didUpdateWidget(oldWidget);
    _initializePlayer();
  }

  void _initializePlayer() {

    // If running on windows ensure to register the Windows Media Player
    if (isDesktop && Platform.operatingSystem == 'windows') {
      WindowsVideoPlayer.registerWith();
    }

    // set player
    widget.model.player = this;

    // initialize the controller
    play(widget.model.url);
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoControllerChange);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  onModelChange(Model model, {String? property, dynamic value}) {
    if (mounted) {
      var b = Binding.fromString(property);
      switch (b?.property) {

        // change volume
        case 'volume':
          _controller?.setVolume(widget.model.volume);
          break;

        // change playback speed
        case 'speed':
          _controller?.setPlaybackSpeed(widget.model.speed);
          break;

        default:
          setState(() {});
          break;
      }
    }
    else {
      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
    }
  }

  Widget getPlayButton() {
    // shutter
    playButton ??= IconView(playButtonModel);
    var play = UnconstrainedBox(
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
                onTap: startstop,
                child: Stack(alignment: Alignment.center, children: [
                  const Icon(Icons.circle, color: Colors.white38, size: 80),
                  playButton!
                ]))));
    return Positioned(bottom: 0, top: 0, left: 0, right: 0, child: play);
  }

  Widget getSpeedButton() {
    speedLabel ??= TextView(speedLabelModel);
    speedLabelModel.value = '${widget.model.speed}x';

    var label = Stack(alignment: Alignment.center, children: [
      const Icon(Icons.circle, color: Colors.white38, size: 40),
      speedLabel!
    ]);

    List<PopupMenuItem<double>> speeds = [];
    for (final double speed in _playbackRates) {
      speeds.add(PopupMenuItem<double>(value: speed, child: Text('${speed}x')));
    }

    PopupMenuButton popup = PopupMenuButton<double>(
        tooltip: 'Playback speed',
        onSelected: (double speed) {
          widget.model.speed = speed;
          speedLabelModel.value = '${speed}x';
        },
        itemBuilder: (BuildContext context) {
          return <PopupMenuItem<double>>[
            for (final double speed in _playbackRates)
              PopupMenuItem<double>(value: speed, child: Text('${speed}x'))
          ];
        },
        child: label);

    return Positioned(top: 5, right: 5, child: popup);
  }

  void _onVideoControllerChange() {
    playButtonModel.size = 65;
    playButtonModel.icon = _controller?.value.isPlaying ?? false ? Icons.play_arrow : Icons.pause;
    widget.model.playing = _controller?.value.isPlaying;
  }

  Future<bool> startstop() async {
    if (_controller == null) return false;
    if (_controller!.value.isPlaying) return await pause();
    if (_controller!.value.position == _controller!.value.duration) {
      return await start();
    }
    return await resume();
  }

  @override
  Future<bool> play(String? url) async {

    // build new controller
    var uri = URI.parse(url);
    if (uri?.url == _controller?.dataSource) return true;

    if (uri != null) {

      // dispose of existing controller
      _controller?.dispose();

      // create new controller
      _controller = VideoPlayerController.networkUrl(uri);

      // wait for the controller to initialize
      await _controller?.initialize();

      // fire onInitialized() event
      if (!isNullOrEmpty(widget.model.onInitialized)) {
        WidgetsBinding.instance.addPostFrameCallback((_) => widget.model.onInitializedHandler());
      }

      // ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      if (mounted) {
        setState(() {});
      }
      else {
        WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
      }

      _controller!.setLooping(widget.model.loop);
      _controller!.setVolume(widget.model.volume);
      _controller!.setPlaybackSpeed(widget.model.speed);

      if (widget.model.autoplay) {
        start();
      }

      // add listener to modify controls
      _controller!.addListener(_onVideoControllerChange);
    }

    return true;
  }

  @override
  Future<bool> start() async {
    if (_controller == null) return false;
    if (!_controller!.value.isInitialized) {
      await _controller!.initialize();
    }
    await seek(0);
    await _controller!.play();
    widget.model.playing = true;
    return true;
  }

  @override
  Future<bool> stop() async {
    if (_controller == null) return false;
    if (_controller!.value.isInitialized) {
      await _controller!.pause();
      await seek(0);
      widget.model.playing = false;
    }
    return true;
  }

  @override
  Future<bool> pause() async {
    if (_controller == null) return false;
    if (_controller!.value.isInitialized) {
      await _controller!.pause();
      widget.model.playing = false;
    }
    return true;
  }

  Future<bool> resume() async {
    if (_controller == null) return false;
    if (!_controller!.value.isInitialized) await _controller!.initialize();
    _controller!.play();
    widget.model.playing = true;
    return true;
  }

  @override
  Future<bool> seek(int seconds) async {
    if (_controller == null) return false;
    if (_controller!.value.isInitialized) {
      await _controller!.seekTo(Duration(seconds: seconds));
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // create the view
    Widget view = Container();

    if (_controller != null && _controller!.value.isInitialized) {

      Widget videoPlayer = VideoPlayer(_controller!);

      // size to cover parent container
      videoPlayer = SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ));

      var subTitles = ClosedCaption(text: _controller!.value.caption.text);

      var progressBar = widget.model.controls
          ? VideoProgressIndicator(_controller!, allowScrubbing: true)
          : const Offstage();

      var playButton =
      widget.model.controls ? getPlayButton() : const Offstage();

      var speedButton =
      widget.model.controls ? getSpeedButton() : const Offstage();

      view = Stack(alignment: Alignment.bottomCenter, children: <Widget>[
        videoPlayer,
        subTitles,
        speedButton,
        playButton,
        progressBar
      ]);

      //view = AspectRatio(
      //    aspectRatio: _controller!.value.aspectRatio, child: view);

      view = GestureDetector(onTap: startstop, child: view);
    }

    // add margins
    view = addMargins(view);

    // apply visual transforms
    view = applyTransforms(view);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.tightestOrDefault);

    // final view
    return view;
  }
}
