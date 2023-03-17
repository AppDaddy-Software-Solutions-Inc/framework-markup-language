// // © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
// import 'dart:async';
// import 'package:fml/widgets/icon/icon_model.dart';
// import 'package:fml/widgets/icon/icon_view.dart';
// import 'package:fml/widgets/video/IVideoPlayer.dart';
// import 'package:fml/widgets/video/video_model.dart';
// import 'package:fml/widgets/widget/iViewableWidget.dart';
// import 'package:fml/widgets/widget/iWidgetView.dart';
// import 'package:flutter/material.dart';
// import 'package:dart_vlc/dart_vlc.dart';
// import 'package:fml/widgets/widget/widget_state.dart';
//
// StatefulWidget getVideoPlayerView(VideoModel model) => VideoViewVlc(model);
//
// class VideoViewVlc extends StatefulWidget implements IWidgetView
// {
//   final VideoModel model;
//
//   VideoViewVlc(this.model) : super(key: ObjectKey(model));
//
//   @override
//   VideoViewState createState() => VideoViewState();
// }
//
// class VideoViewState extends WidgetState<VideoViewVlc> implements IVideoPlayer
// {
//   static Widget getVideoPlayer() => Container();
//
//   late final Player _controller;
//   IconView? shutterbutton;
//   IconModel shutterbuttonmodel = IconModel(null, null, icon: Icons.pause, size: 65, color: Colors.white);
//
//   @override
//   void initState()
//   {
//     super.initState();
//
//     // initialize DartVLC
//     DartVLC.initialize();
//
//     // create the player
//     _controller = Player(id: 69420);
//
//     // set player
//     widget.model.player = this;
//
//     // initialize the controller
//     play(widget.model.url);
//   }
//
//   @override
//   void dispose()
//   {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) => LayoutBuilder(builder: builder);
//
//   Widget builder(BuildContext context, BoxConstraints constraints)
//   {
//     // Set Build Constraints in the [WidgetModel]
//     setConstraints(constraints);
//
//     // Check if widget is visible before wasting resources on building it
//     if (!widget.model.visible) return Offstage();
//
//     var video = Video(player: _controller, scale: 1.0, showControls: widget.model.controls);
//
//   // Constrained?
//     double width = MediaQuery.of(context).size.width;
//     double height = MediaQuery.of(context).size.height;
//     Widget view = Container(child: video, width: width, height: height);
//
//     if (widget.model.hasSizing)
//     {
//       var constraints = widget.model.getConstraints();
//       view = ConstrainedBox(
//           child: video,
//           constraints: BoxConstraints(
//               minHeight: constraints.minHeight!,
//               maxHeight: constraints.maxHeight!,
//               minWidth: constraints.minWidth!,
//               maxWidth: constraints.maxWidth!));
//     }
//
//     // stack children
//     List<Widget> children = [];
//     children.add(view);
//
//     if (widget.model.children != null)
//       widget.model.children!.forEach((model)
//       {
//         if (model is IViewableWidget)
//         {
//           children.add((model as IViewableWidget).getView());
//         }
//       });
//
//     // final view
//     return Stack(children: children);
//   }
//
//   Future<bool> play(String? url) async
//   {
//     Uri? uri = Uri.tryParse(url ?? "");
//     if (uri != null)
//     {
//       Media media = Media.network(url, parse: false);
//       _controller.open(media,autoStart: true);
//     }
//     return true;
//   }
//
//   Future<bool> start() async
//   {
//     await seek(0);
//     _controller.play();
//     return true;
//   }
//
//   Future<bool> stop() async
//   {
//     _controller.pause();
//     await seek(0);
//     return true;
//   }
//
//   Future<bool> pause() async
//   {
//     _controller.pause();
//     return true;
//   }
//
//   Future<bool> resume() async
//   {
//     _controller.play();
//     return true;
//   }
//
//   Future<bool> seek(int seconds) async
//   {
//     _controller.seek(Duration(seconds: seconds));
//     return true;
//   }
// }
