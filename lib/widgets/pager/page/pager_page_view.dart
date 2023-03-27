// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/pager/page/pager_page_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class PagerPageView extends StatefulWidget implements IWidgetView
{
  final PagerPageModel model;
  PagerPageView(this.model) : super(key: ObjectKey(model));

  @override
  _PagerPageViewState createState() => _PagerPageViewState();
}

class _PagerPageViewState extends WidgetState<PagerPageView>
{
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Check if widget is visible before wasting resources on building it
    if (widget.model.visible == false) return Offstage();

    // save system constraints
    widget.model.setSystemConstraints(constraints);

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    ////////////////////
    /* Build Children */
    ////////////////////
    List<Widget> children = [];
    if (widget.model.children != null)
      widget.model.children!.forEach((model)
      {
        if (model is IViewableWidget) {
          children.add((model as IViewableWidget).getView());
        }
      });
    if (children.isEmpty) children.add(Container());
    var child = Column(children: children, mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start);


    Widget view = child;

    // wrap constraints
    view = applyConstraints(view, widget.model.getUserConstraints());

    return view;
  }

  @override
  onModelChange(WidgetModel model, {String? property, value}) {
// TODO Missing setState?
  }
}