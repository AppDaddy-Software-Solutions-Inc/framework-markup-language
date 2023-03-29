// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_model.dart'         ;
import 'package:fml/widgets/table/row/table_row_model.dart' as ROW;
import 'package:fml/widgets/table/row/cell/table_row_cell_view.dart' as CELL;
import 'package:fml/widgets/widget/widget_state.dart';

class TableRowView extends StatefulWidget implements IWidgetView
{
  final ROW.TableRowModel model;
  final double? height;
  final Map<int, double>? width;
  final int? row;
  final Map<int, double>? padding;

  TableRowView(this.model, this.row, this.height, this.width, this.padding);

  @override
  _TableRowViewState createState() => _TableRowViewState();
}


class _TableRowViewState extends WidgetState<TableRowView>
{
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // save system constraints
    widget.model.systemConstraints = constraints;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    ///////////
    /* Cells */
    ///////////
    int i = 0;
    List<Widget> cells = [];
    widget.model.cells.forEach((model)
    {
      //////////
      /* Size */
      //////////
      double? height = widget.height;
      double? width  = (widget.width != null) && (widget.width!.containsKey(i)) ? widget.width![i] : null;
      if ((width != null) && (widget.padding != null) && (widget.padding!.containsKey(i))) width += (widget.padding![i] ?? 0);

      //////////
      /* View */
      //////////
      Widget cell = CELL.TableRowCellView(model, widget.row);
      if ((width != null) && (height != null))
           cells.add(UnconstrainedBox(child: ClipRect(child: SizedBox(width: width, height: height, child: cell))));
      else cells.add(cell);
      i++;
    });

    //////////
    /* View */
    //////////
    dynamic row = Row(children: cells, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize:  MainAxisSize.min);
    if (widget.model.onclick != null && cells.length > 0)
      row = GestureDetector(onTap: onTap, child: row);
    return row;
  }

  onTap() async
  {
      WidgetModel.unfocus();
      await widget.model.onClick(context);
  }
}
