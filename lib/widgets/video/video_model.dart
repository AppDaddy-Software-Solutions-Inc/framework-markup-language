// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/system.dart';
import 'package:fml/widgets/video/IVideoPlayer.dart';
import 'package:fml/widgets/video/video_view.dart';
import 'package:fml/widgets/video/video_view_vlc.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/widget/decorated_widget_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/event/handler.dart' ;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';

class VideoModel extends DecoratedWidgetModel implements IViewableWidget
{
  IVideoPlayer? player;

  // url
  StringObservable? _url;
  set url(dynamic v)
  {
    if (_url != null)
    {
      _url!.set(v);
    }
    else if (v != null)
    {
      _url = StringObservable(Binding.toKey(id, 'url'), v, scope: scope, listener: onPropertyChange);
      _url!.registerListener(onUrlChange);
    }
  }
  String? get url => _url?.get();

  // show controls
  BooleanObservable? _controls;
  set controls(dynamic v)
  {
    if (_controls != null)
    {
      _controls!.set(v);
    }
    else if (v != null)
    {
      _controls = BooleanObservable(Binding.toKey(id, 'controls'), v, scope: scope, listener: onPropertyChange);
    }
  }
  bool get controls => _controls?.get() ?? true;

  // on initialized event
  StringObservable? _oninitialized;
  set oninitialized(dynamic v)
  {
    if (_oninitialized != null)
    {
      _oninitialized!.set(v);
    }
    else if (v != null)
    {
      _oninitialized = StringObservable(Binding.toKey(id, 'oninitialized'), v, scope: scope, lazyEval: true);
    }
  }
  String? get oninitialized => _oninitialized?.get();
  
  VideoModel(WidgetModel parent, String?  id) : super(parent, id)
  {
    // instantiate busy observable
    busy = false;
  }

  static VideoModel? fromXml(WidgetModel parent, XmlElement xml)
  {
    VideoModel? model;
    try
    {
      /////////////////
      /* Build Model */
      /////////////////
      model = VideoModel(parent, Xml.get(node: xml, tag: 'id'));
      model.deserialize(xml);
    }
    catch(e)
    {
      Log().exception(e,  caller: 'webcam.Model');
      model = null;
    }
    return model;
  }

  /// Deserializes the FML template elements, attributes and children
  @override
  void deserialize(XmlElement xml)
  {
    // deserialize
    super.deserialize(xml);

    // properties
    url      = Xml.get(node: xml, tag: 'url');
    enabled  = Xml.get(node: xml, tag: 'enabled');
    controls = Xml.get(node: xml, tag: 'controls');
  }

  @override
  void dispose()
  {
    // Log().debug('dispose called on => <$elementName id="$id">');
    super.dispose();
  }

  Future<bool> start({bool force = false, bool refresh = false, String? key}) async
  {
    //if (camera != null) camera!.start();
    return true;
  }

  @override
  Future<bool?> execute(String caller, String propertyOrFunction, List<dynamic> arguments) async
  {
    /// setter
    if (scope == null) return null;
    var function = propertyOrFunction.toLowerCase().trim();

    if (player != null)
    switch (function)
    {
      case "start"    : return await player!.start();
      case "play"     : return await player!.start();
      case "stop"     : return await player!.stop();
      case "pause"    : return await player!.pause();
      case "rewind"   : return await player!.seek(0);
      case "seek"     : return await player!.seek(S.toInt(S.item(arguments, 0)) ?? 0);
    }
    return super.execute(caller, propertyOrFunction, arguments);
  }

  Future<bool> onInitialized(BuildContext context) async
  {
    if (this.oninitialized == null) return true;
    return await EventHandler(this).execute(_oninitialized);
  }

  onUrlChange(Observable observable)
  {
    if (player != null && url != null) player!.play(url!);
  }

  Widget getView({Key? key})
  {
    if (System().useragent == "windows" || System().useragent == "linux")
         return VideoViewVlc(this);
    else return VideoView(this);
  }
}