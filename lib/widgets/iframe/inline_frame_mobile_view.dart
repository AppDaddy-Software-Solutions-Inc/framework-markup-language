// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'package:fml/helper/uri.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/iframe/inline_frame_model.dart' as IFRAME;
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'inline_frame_view.dart' as IFRAME;

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
  WebViewWidget? iframe;
  late WebViewController controller;
  @override
  void initState()
  {
    controller = WebViewController();
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

      var uri = URI.parse(widget.model.url);
      if (uri != null) controller..setNavigationDelegate(NavigationDelegate())..setJavaScriptMode(JavaScriptMode.unrestricted)..loadRequest(uri)..addJavaScriptChannel('TOFLUTTER', onMessageReceived: onMessageReceived);
      view = WebViewWidget(controller: controller);
    }

    //////////////////
    /* Constrained? */
    //////////////////
    if (model.constrained)
    {
      var constraints = model.getConstraints();
      view = ConstrainedBox(child: view, constraints: BoxConstraints(
          minHeight: constraints.minHeight!, maxHeight: constraints.maxHeight!,
          minWidth: constraints.minWidth!, maxWidth: constraints.maxWidth!));
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