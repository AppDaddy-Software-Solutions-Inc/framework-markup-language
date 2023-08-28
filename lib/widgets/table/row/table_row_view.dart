// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/widget/widget_model.dart'         ;
import 'package:fml/widgets/table/row/table_row_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class TableRowView extends StatefulWidget implements IWidgetView
{
  @override
  final TableRowModel model;
  final double? height;
  final Map<int, double>? width;
  final int? row;
  final Map<int, double>? padding;
  TableRowView(this.model, this.row, this.height, this.width, this.padding);

  @override
  State<TableRowView> createState() => _TableRowViewState();
}


class _TableRowViewState extends WidgetState<TableRowView>
{
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // save system constraints
    onLayout(constraints);

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    print('rebuild row');

    ///////////
    /* Cells */
    ///////////
    int i = 0;
    List<Widget> cells = [];
    for (var model in widget.model.cells) {
      //////////
      /* Size */
      //////////
      double? height = widget.height;
      double? width  = (widget.width != null) && (widget.width!.containsKey(i)) ? widget.width![i] : null;
      if ((width != null) && (widget.padding != null) && (widget.padding!.containsKey(i))) width += (widget.padding![i] ?? 0);

      //////////
      /* View */
      //////////
      Widget cell = RepaintBoundary(child: BoxView(model));
      if ((width != null) && (height != null)) {
        cells.add(UnconstrainedBox(child: ClipRect(child: SizedBox(width: width, height: height, child: cell))));
      } else {
        cells.add(cell);
      }
      i++;
    }

    //////////
    /* View */
    //////////
    Widget row = Row(children: cells, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize:  MainAxisSize.min);
    if (widget.model.onclick != null && cells.isNotEmpty) {
      row = GestureDetector(onTap: onTap, child: row);
    }
    return row;
  }

  onTap() async
  {
      WidgetModel.unfocus();
      await widget.model.onClick(context);
  }
}
