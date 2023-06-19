// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/table/table_model.dart';
import 'package:fml/widgets/table/header/table_header_model.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class TableBodyView extends StatefulWidget implements IWidgetView
{
  @override
  final TableHeaderModel model;

  TableBodyView(this.model);

  @override
  State<TableBodyView> createState() => _TableBodyViewState();
}
//

class _TableBodyViewState extends WidgetState<TableBodyView>
{
  final double anchorWidth = 23;
  TableModel? tableModel;

  @override
  void initState()
  {
    super.initState();

    // CELL.Model cellModel = model;
    tableModel = widget.model.findAncestorOfExactType(TableModel);
  }

  @override
  Widget build(BuildContext context) => widget.model.getView();
}
