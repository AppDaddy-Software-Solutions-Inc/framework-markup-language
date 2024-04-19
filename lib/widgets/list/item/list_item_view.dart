// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'package:fml/widgets/list/item/list_item_model.dart';

class ListItemView extends StatefulWidget implements ViewableWidgetView {
  @override
  final ListItemModel model;

  ListItemView(this.model) : super(key: ObjectKey(model));

  @override
  State<ListItemView> createState() => _ListItemViewState();
}

class _ListItemViewState extends ViewableWidgetState<ListItemView> {

  @override
  Widget build(BuildContext context) => BoxView(widget.model, widget.model.inflate());
}
