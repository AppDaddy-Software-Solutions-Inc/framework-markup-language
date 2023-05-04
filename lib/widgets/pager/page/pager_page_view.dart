// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/pager/page/pager_page_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class PagerPageView extends StatefulWidget implements IWidgetView
{
  @override
  final PagerPageModel model;
  PagerPageView(this.model) : super(key: ObjectKey(model));

  @override
  State<PagerPageView> createState() => _PagerPageViewState();
}

class _PagerPageViewState extends WidgetState<PagerPageView>
{
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Check if widget is visible before wasting resources on building it
    if (widget.model.visible == false) return Offstage();

    // save system constraints
    onLayout(constraints);

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // build the child views
    List<Widget> children = widget.model.inflate();
    if (children.isEmpty) children.add(Container());
    var child = Column(children: children, mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start);


    Widget view = child;

    // apply user defined constraints
    view = applyConstraints(view, widget.model.constraints.model);

    return view;
  }

  @override
  onModelChange(WidgetModel model, {String? property, value}) {
// TODO Missing setState?
  }
}