// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/grid/item/grid_item_model.dart' as ITEM;
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class GridItemView extends StatefulWidget implements IWidgetView
{
  final ITEM.GridItemModel? model;
  GridItemView({this.model}) : super(key: ObjectKey(model));

  @override
  _GridItemViewState createState() => _GridItemViewState();
}

class _GridItemViewState extends WidgetState<GridItemView>
{
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Check if widget is visible before wasting resources on building it
    if ((widget.model == null) || (widget.model!.visible == false)) return Offstage();

    // build children
    List<Widget> children = [];
    if (widget.model!.children != null)
    widget.model!.children!.forEach((model)
    {
      if (model is ViewableWidgetModel) {
        children.add(model.getView());
      }
    });

    if (children.isEmpty) children.add(Container());
    return Container(child: Center(child: children.length == 1 ? children[0] : Column(children: children, mainAxisSize: MainAxisSize.min)));
  }
}