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
    widget.model.minWidth  = constraints.minWidth;
    widget.model.maxWidth  = constraints.maxWidth;
    widget.model.minHeight = constraints.minHeight;
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
    if (widget.model.hasSizing)
    {
      var constraints = widget.model.getConstraints();
      view = ConstrainedBox(child: view, constraints: BoxConstraints(
          minHeight: constraints.minHeight!, maxHeight: constraints.maxHeight!,
          minWidth: constraints.minWidth!, maxWidth: constraints.maxWidth!));
    }

    return view;
  }
}