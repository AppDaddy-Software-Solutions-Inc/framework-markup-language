// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'inline_frame_mobile_view.dart'
if (dart.library.io)   'inline_frame_mobile_view.dart'
if (dart.library.html) 'inline_frame_web_view.dart';

abstract class View
{
  factory View(model) => getView(model);
}