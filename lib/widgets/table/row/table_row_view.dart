// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/widget/widget_model.dart'         ;
import 'package:fml/widgets/table/row/table_row_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class TableRowView extends StatefulWidget implements IWidgetView
{
  @override
  final TableRowModel model;
  final int? index;

  TableRowView(this.model, this.index);

  @override
  State<TableRowView> createState() => _TableRowViewState();
}

class _TableRowViewState extends WidgetState<TableRowView>
{
  onTap() async
  {
    WidgetModel.unfocus();
    await widget.model.onClick(context);
  }

  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // get view
    Widget view = widget.model.getView();

    // add gesture detector
    if (widget.model.onclick != null)
    {
      view = GestureDetector(onTap: onTap, child: view);
    }
    return view;
  }
}
