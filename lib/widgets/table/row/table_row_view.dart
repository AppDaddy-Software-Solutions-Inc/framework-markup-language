// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/widget_model.dart'         ;
import 'package:fml/widgets/table/row/table_row_model.dart' as ROW;
import 'package:fml/widgets/table/row/cell/table_row_cell_view.dart' as CELL;

class TableRowView extends StatefulWidget
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


class _TableRowViewState extends State<TableRowView> implements IModelListener
{
  @override
  void initState()
  {
    super.initState();

    
    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();
  }

  @override
  didChangeDependencies()
  {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(TableRowView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    
    if ((oldWidget.model != widget.model))
    {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }

  }

  @override
  void dispose()
  {
    widget.model.removeListener(this);

    super.dispose();
  }

  /// Callback function for when the model changes, used to force a rebuild with setState()
  onModelChange(WidgetModel model,{String? property, dynamic value})
  {
    if (this.mounted) setState((){});
  }

  @override
  Widget build(BuildContext context)
  {
return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Set Build Constraints in the [WidgetModel]
      widget.model.minWidth  = constraints.minWidth;
      widget.model.maxWidth  = constraints.maxWidth;
      widget.model.minHeight = constraints.minHeight;
      widget.model.maxHeight = constraints.maxHeight;

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
