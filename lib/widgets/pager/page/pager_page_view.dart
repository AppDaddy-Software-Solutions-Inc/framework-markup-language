// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/pager/page/pager_page_model.dart';

class PagerPageView extends StatefulWidget
{
  final PagerPageModel model;
  PagerPageView(this.model) : super(key: ObjectKey(model));

  @override
  _PagerPageViewState createState() => _PagerPageViewState();
}

class _PagerPageViewState extends State<PagerPageView> implements IModelListener {

  Widget build(BuildContext context) {

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
    var child = children.length == 1 ? children[0] : Column(children: children, mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start);

    final bottom = MediaQuery.of(context).viewInsets.bottom;

    SingleChildScrollView scsv =  SingleChildScrollView(child: child, padding: EdgeInsets.only(bottom: bottom));

    return scsv;

  }

  @override
  onModelChange(WidgetModel model, {String? property, value}) {
// TODO Missing setState?
  }

}