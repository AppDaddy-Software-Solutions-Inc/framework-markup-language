// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/list/item/list_item_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class ListItemView extends StatefulWidget implements IWidgetView {
  @override
  final ListItemModel model;

  ListItemView(this.model) : super(key: ObjectKey(model));

  @override
  State<ListItemView> createState() => _ListItemViewState();
}

class _ListItemViewState extends WidgetState<ListItemView> {
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints) {
    return BoxView(widget.model);
  }
}
