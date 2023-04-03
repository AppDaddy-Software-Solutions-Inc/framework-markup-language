import 'package:flutter/material.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/video/video_model.dart';
import 'package:fml/widgets/video/video_view.dart';
import 'package:fml/widgets/video/video_view_vlc.dart';

class VideoPlayerSelector
{
  static Widget getView(VideoModel model)
  {
    if (System().useragent == "windows" || System().useragent == "linux")
         return VideoViewVlc(model);
    else return VideoView(model);
  }
}
