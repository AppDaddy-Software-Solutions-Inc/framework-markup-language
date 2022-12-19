// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/widgets/iframe/inline_frame_model.dart' as IFRAME;

import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:flutter/material.dart';
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
    if (widget.model.children != null)
    widget.model.children!.forEach((model)
    {
      if (model is IViewableWidget) {
        children.add((model as IViewableWidget).getView());
      }
    });
    if (children.isEmpty) children.add(Container());
    var child = children.length == 1 ? children[0] : Column(children: children, crossAxisAlignment: CrossAxisAlignment.start);

    //////////
    /* View */
    //////////
    Widget view = Container(alignment: Alignment.topLeft, child: child);

    //////////////////
    /* Constrained? */
    //////////////////
    if (widget.model.constrained)
    {
      Map<String,double?> constraints = widget.model.constraints;
      view = ConstrainedBox(child: view, constraints: BoxConstraints(
          minHeight: constraints['minheight']!, maxHeight: constraints['maxheight']!,
          minWidth: constraints['minwidth']!, maxWidth: constraints['maxwidth']!));
    }

    return view;
  }
}