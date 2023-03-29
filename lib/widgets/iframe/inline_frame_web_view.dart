// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:universal_html/html.dart' as HTML;
import 'package:universal_html/js.dart' as JAVASCRIPT;
import 'dart:ui' as UI;
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'inline_frame_model.dart';
import 'inline_frame_view.dart';
import 'package:fml/helper/common_helpers.dart';

InlineFrameView getView(model) => InlineFrameView(model);

class InlineFrameView extends StatefulWidget implements View, IWidgetView
{
  final InlineFrameModel model;

  InlineFrameView(this.model) : super(key: ObjectKey(model));

  @override
  _InlineFrameViewState createState() => _InlineFrameViewState();
}

class _InlineFrameViewState extends WidgetState<InlineFrameView>
{
  IFrameWidget? iframe;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    InlineFrameModel model = widget.model;

    // save system constraints
    widget.model.systemConstraints = constraints;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    //This prevents the iframe from rebuilding and hiding the keyboard every time.
    if (iframe == null) iframe = IFrameWidget(model: model);
    Widget view = iframe!;

    // basic view
    view = Container(child: view, width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.modelConstraints);

    return view;
  }
}

class IFrameWidget extends StatelessWidget {
  final InlineFrameModel model;

  final String id = S.newId();

  late final Widget iFrame;
  late final HTML.IFrameElement iframe;
  final jsonEncoder = JsonEncoder();

  IFrameWidget({required this.model});

  void dispose()
  {
    Log().debug('disposing of iframe ...');
    HTML.window.removeEventListener('message', receive);
    iframe.remove();
  }

  @override
  Widget build(BuildContext context) {
    /////////////////////////////
    /* Create an iFrame widget */
    /////////////////////////////
    iFrame = HtmlElementView(key: UniqueKey(), viewType: id);

    ///////////////////////////
    /* Create IFrame Element */
    ///////////////////////////
    iframe = HTML.IFrameElement()
      ..style.border = 'none'
      // ..style.boxShadow = '0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 10px 0 rgba(0, 0, 0, 0.19)'
      // ..style.borderRadius = '5px'
      ..style.width = '100%'
      ..style.height = '100%';
    iframe.src = model.url;

    /////////////////////////////////////
    /* Contructor Callback from Script */
    /////////////////////////////////////
    JAVASCRIPT.context["flutter"] = (content)
    {
      //////////////////
      /* Add Listener */
      //////////////////
      HTML.window.removeEventListener('message', receive);
      HTML.window.addEventListener('message', receive);

      return id;
    };

    /////////////////////
    /* Register IFrame */
    /////////////////////
    // ignore: undefined_prefixed_name
    UI.platformViewRegistry.registerViewFactory(id, (int viewId) => iframe);

    return iFrame;
  }

  void receive(dynamic event) {
    try {
      ////////////////////
      /* Decode Message */
      ////////////////////
      Map<String?, dynamic> map = Map<String?, dynamic>();
      if (event.data is Map) {
        (event.data as Map).forEach((key, value) {
          String? k = S.toStr(key);
          String? v = S.toStr(value);
          if (!S.isNullOrEmpty(k)) map[k] = v;
        });
      } else if (event.data is String) {
        var data = jsonDecode(event.data);
        if (data is Map) map.addAll(data as Map<String?, dynamic>);
      }

      /////////////
      /* Set Map */
      /////////////
      this.model.data = map;

    }
    catch(e)
    {
      Log().exception(e);
    }
  }
}
