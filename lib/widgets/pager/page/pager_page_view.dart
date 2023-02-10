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
    return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    //String? _id = widget.model.id;

    // Check if widget is visible before wasting resources on building it
    if (widget.model.visible == false) return Offstage();

    // Set Build Constraints in the [WidgetModel]
    widget.model.minWidth  = constraints.minWidth;
    widget.model.maxWidth  = constraints.maxWidth;
    widget.model.minHeight = constraints.minHeight;
    widget.model.maxHeight = constraints.maxHeight;


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


    Widget view;

    if(widget.model.hasSizing)
    {
      var constr = widget.model.getConstraints();
      view = ConstrainedBox(
          child: child,
          constraints: BoxConstraints(
              minWidth: constr.minWidth!,
              maxWidth: constr.maxWidth!,
              minHeight: constr.minHeight!,
              maxHeight: constr.maxHeight!
          ));
    } else view = child;

    return view;

  }

  @override
  onModelChange(WidgetModel model, {String? property, value}) {
// TODO Missing setState?
  }

}