// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/widget/widget_model_interface.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:universal_html/html.dart' as universal_html;
import 'package:universal_html/js.dart' as universal_js;
import 'dart:ui' as dart_ui;
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'inline_frame_model.dart';
import 'inline_frame_view.dart' as widget_view;
import 'package:fml/helpers/helpers.dart';

InlineFrameView getView(model) => InlineFrameView(model);

class InlineFrameView extends StatefulWidget implements widget_view.View, IWidgetView
{
  @override
  final InlineFrameModel model;

  InlineFrameView(this.model) : super(key: ObjectKey(model));

  @override
  State<InlineFrameView> createState() => _InlineFrameViewState();
}

class _InlineFrameViewState extends WidgetState<InlineFrameView>
{
  IFrameWidget? iframe;

  @override
  void dispose()
  {
    super.dispose();
    iframe?.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    InlineFrameModel model = widget.model;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    //This prevents the iframe from rebuilding and hiding the keyboard every time.
    iframe ??= IFrameWidget(model: model);
    Widget view = iframe!;

    // basic view
    view = SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, child: view);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.constraints);

    return view;
  }
}

class IFrameWidget extends StatelessWidget implements IModelListener
{
  final InlineFrameModel model;

  final String id = newId();

  late final Widget iFrame;
  late final universal_html.IFrameElement iframe;
  final jsonEncoder = const JsonEncoder();

  IFrameWidget({super.key, required this.model});

  @override
  onModelChange(WidgetModel model,{String? property, dynamic value})
  {
    iframe.src = this.model.url;
  }

  void dispose()
  {
    universal_html.window.removeEventListener('message', receive);
    iframe.remove();
    model.removeListener(this);
  }

  @override
  Widget build(BuildContext context)
  {
    // create an iFrame widget
    iFrame = HtmlElementView(key: UniqueKey(), viewType: id);

    // create IFrame element
    iframe = universal_html.IFrameElement()
      ..style.border = 'none'
      // ..style.boxShadow = '0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 10px 0 rgba(0, 0, 0, 0.19)'
      // ..style.borderRadius = '5px'
      ..style.width = '100%'
      ..style.height = '100%';
    iframe.src = model.url;

    // contructor callback from script
    universal_js.context["flutter"] = (content)
    {
      // add listener
      universal_html.window.removeEventListener('message', receive);
      universal_html.window.addEventListener('message', receive);
      return id;
    };

    // register the IFrame
    // ignore: undefined_prefixed_name
    dart_ui.platformViewRegistry.registerViewFactory(id, (int viewId) => iframe);

    // register a model listener
    model.registerListener(this);

    return iFrame;
  }

  void receive(dynamic event) {
    try
    {
      // decode message
      Map<String?, dynamic> map = <String?, dynamic>{};
      if (event.data is Map)
      {
        (event.data as Map).forEach((key, value)
        {
          String? k = toStr(key);
          String? v = toStr(value);
          if (!isNullOrEmpty(k)) map[k] = v;
        });
      }
      else if (event.data is String)
      {
        var data = jsonDecode(event.data);
        if (data is Map) map.addAll(data as Map<String?, dynamic>);
      }

      // set map
      model.data = map;
    }
    catch (e)
    {
      Log().exception(e);
    }
  }
}
