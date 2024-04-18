// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/iframe/inline_frame_model.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/viewable_widget_view.dart';
import 'package:fml/widgets/widget/viewable_widget_state.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'inline_frame_view.dart' as widget_view;
import 'package:fml/helpers/helpers.dart';

InlineFrameView getView(model) => InlineFrameView(model);

class InlineFrameView extends StatefulWidget
    implements widget_view.View, ViewableWidgetView {
  @override
  final InlineFrameModel model;

  InlineFrameView(this.model) : super(key: ObjectKey(model));

  @override
  State<InlineFrameView> createState() => _InlineFrameViewState();
}

class _InlineFrameViewState extends ViewableWidgetState<InlineFrameView> {
  WebViewWidget? iframe;
  late WebViewController controller;

  @override
  void initState() {
    controller = WebViewController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var model = widget.model;

    // Check if widget is visible before wasting resources on building it
    if ((model.visible == false)) return const Offstage();

    // build view
    Widget? view = iframe;
    if (view == null) {
      var uri = URI.parse(widget.model.url);
      if (uri != null) {
        controller
          ..setNavigationDelegate(NavigationDelegate())
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(uri)
          ..addJavaScriptChannel('TOFLUTTER',
              onMessageReceived: onMessageReceived);
      }
      view = WebViewWidget(controller: controller);
    }

    // basic view
    view = SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: view);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.constraints);

    return view;
  }

  void onMessageReceived(dynamic message) {
    try {
      ////////////////////
      /* Decode Message */
      ////////////////////
      Map<String, dynamic> map = <String, dynamic>{};
      var data = jsonDecode(message.message);
      if (data is Map) map.addAll(data as Map<String, dynamic>);

      /////////////
      /* Set Map */
      /////////////
      widget.model.data = map;
    } catch (e) {
      Log().exception(e);
    }
  }
}
