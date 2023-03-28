// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/iframe/inline_frame_model.dart' as IFRAME;
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'inline_frame_view.dart' as IFRAME;
import 'package:fml/helper/common_helpers.dart';

InlineFrameView getView(model) => InlineFrameView(model);

class InlineFrameView extends StatefulWidget implements IFRAME.View, IWidgetView
{
  final IFRAME.InlineFrameModel model;

  InlineFrameView(this.model) : super(key: ObjectKey(model));

  @override
  _InlineFrameViewState createState() => _InlineFrameViewState();
}

class _InlineFrameViewState extends WidgetState<InlineFrameView>
{
  WebViewWidget? iframe;
  late WebViewController controller;

  @override
  void initState()
  {
    controller = WebViewController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    var model = widget.model;

    // save system constraints
    widget.model.setSystemConstraints(constraints);

    // Check if widget is visible before wasting resources on building it
    if ((model.visible == false)) return Offstage();

    // build view
    Widget? view = iframe;
    if (view == null)
    {

      var uri = URI.parse(widget.model.url);
      if (uri != null) controller..setNavigationDelegate(NavigationDelegate())..setJavaScriptMode(JavaScriptMode.unrestricted)..loadRequest(uri)..addJavaScriptChannel('TOFLUTTER', onMessageReceived: onMessageReceived);
      view = WebViewWidget(controller: controller);
    }

    // basic view
    view = Container(child: view, width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.localConstraints);

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