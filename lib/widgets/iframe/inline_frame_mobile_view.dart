// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/iframe/inline_frame_model.dart' as IFRAME;

import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'inline_frame_view.dart' as IFRAME;
import 'package:fml/helper/helper_barrel.dart';

InlineFrameView getView(model) => InlineFrameView(model);

class InlineFrameView extends StatefulWidget implements IFRAME.View
{
  final IFRAME.InlineFrameModel model;

  InlineFrameView(this.model) : super(key: ObjectKey(model));

  @override
  _InlineFrameViewState createState() => _InlineFrameViewState();
}

class _InlineFrameViewState extends State<InlineFrameView>
{
  WebView? iframe;
  @override
  void initState()
  {
    super.initState();
  }

  @override
  Widget build(BuildContext context)
  {
    return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    var model = widget.model;

    // Set Build Constraints in the [WidgetModel]

      model.minwidth  = constraints.minWidth;
      model.maxwidth  = constraints.maxWidth;
      model.minheight = constraints.minHeight;
      model.maxheight = constraints.maxHeight;


    // Check if widget is visible before wasting resources on building it
    if ((model.visible == false)) return Offstage();

    ///////////
    /* Child */
    ///////////
    List<Widget> children = [];
    if (model.children != null)
      model.children!.forEach((model)
      {
        if (model is IViewableWidget) {
          children.add((model as IViewableWidget).getView());
        }
      });

    //////////
    /* View */
    //////////
    Widget? view = iframe;
    if (view == null)
    {
      String url = Url.toAbsolute(widget.model.url ?? "");
      view = WebView(initialUrl: url, javascriptMode: JavascriptMode.unrestricted, javascriptChannels: [JavascriptChannel(name: 'TOFLUTTER', onMessageReceived: onMessageReceived)].toSet());
    }

    //////////////////
    /* Constrained? */
    //////////////////
    if (model.constrained)
    {
      Map<String,double?> constraints = model.constraints;
      view = ConstrainedBox(child: view, constraints: BoxConstraints(
          minHeight: constraints['minheight']!, maxHeight: constraints['maxheight']!,
          minWidth: constraints['minwidth']!, maxWidth: constraints['maxwidth']!));
    }
    else view = Container(child: view, width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height);
    return view;
  }

  void onMessageReceived(dynamic message)
  {
    try
    {
      ////////////////////
      /* Decode Message */
      ////////////////////
      Map<String, dynamic> map = Map<String, dynamic>();
      var data = jsonDecode(message.message);
      if (data is Map) map.addAll(data as Map<String, dynamic>);

      /////////////
      /* Set Map */
      /////////////
      widget.model.data = map;
    }
    catch(e)
    {
      Log().exception(e);
    }
  }
}