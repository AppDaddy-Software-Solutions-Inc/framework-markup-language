// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/grid/item/grid_item_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class GridItemView extends StatefulWidget implements IWidgetView
{
  @override
  final GridItemModel model;
  GridItemView(this.model) : super(key: ObjectKey(model));

  @override
  State<GridItemView> createState() => _GridItemViewState();
}

class _GridItemViewState extends WidgetState<GridItemView>
{
  @override
  Widget build(BuildContext context) => widget.model.getView();
}