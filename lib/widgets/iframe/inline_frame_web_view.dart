// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'dart:html' as HTML;
import 'dart:js' as JAVASCRIPT;
import 'dart:ui' as UI;
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:uuid/uuid.dart';
import '../../log/manager.dart';
import 'inline_frame_model.dart';
import 'inline_frame_view.dart';
import 'package:fml/helper/helper_barrel.dart';

InlineFrameView getView(model) => InlineFrameView(model);

class InlineFrameView extends StatefulWidget implements View
{
  final InlineFrameModel model;

  InlineFrameView(this.model) : super(key: ObjectKey(model));

  @override
  _InlineFrameViewState createState() => _InlineFrameViewState();
}

class _InlineFrameViewState extends State<InlineFrameView>
{
  IFrameWidget? iframe;

  @override
  Widget build(BuildContext context)
  {
    return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    InlineFrameModel model = widget.model;

    // Set Build Constraints in the [WidgetModel]
    widget.model.minwidth  = constraints.minWidth;
    widget.model.maxwidth  = constraints.maxWidth;
    widget.model.minheight = constraints.minHeight;
    widget.model.maxheight = constraints.maxHeight;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    ///////////
    /* Child */
    ///////////
    List<Widget> children = [];
    if (model.children != null)
      model.children!.forEach((model) {
        if (model is IViewableWidget) {
          children.add((model as IViewableWidget).getView());
        }
      });

    //////////
    /* View */
    //////////

    //This prevents the iframe from rebuilding and hiding the keyboard every time.
    if (iframe == null) iframe = IFrameWidget(model: model);
    Widget? view = iframe;

    //////////////////
    /* Constrained? */
    //////////////////
    if (model.constrained) {
      var constraints = model.getConstraints();
      view = ConstrainedBox(
          child: view,
          constraints: BoxConstraints(
              minHeight: constraints.minHeight!,
              maxHeight: constraints.maxHeight!,
              minWidth: constraints.minWidth!,
              maxWidth: constraints.maxWidth!));
    } else
      view = Container(
          child: view,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height);

    return view;
  }
}

class IFrameWidget extends StatelessWidget {
  final InlineFrameModel model;

  final String id = Uuid().v1().toString().substring(0, 5);

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
    catch (e)
    {
      Log().exception(e);
    }
  }
}
