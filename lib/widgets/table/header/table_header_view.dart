// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/table/table_model.dart';
import 'package:fml/widgets/table/header/table_header_model.dart';
import 'package:fml/widgets/table/header/cell/table_header_cell_view.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;

class TableHeaderView extends StatefulWidget
{
  final TableHeaderModel? model;
  final double? height;
  final Map<int, double>? width;
  final Map<int, double>? padding;

  TableHeaderView(this.model, this.height, this.width, this.padding);

  @override
  _TableHeaderViewState createState() => _TableHeaderViewState();
}
//

class _TableHeaderViewState extends State<TableHeaderView> implements IModelListener
{
  final double anchorWidth = 23;
  TableModel? tableModel;

  @override
  void initState()
  {
    super.initState();

    
    if (widget.model != null) widget.model!.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    if (widget.model != null) widget.model!.initialize();


    // CELL.Model cellModel = model;
    tableModel = widget.model!.findAncestorOfExactType(TableModel);
  }

  @override
  didChangeDependencies()
  {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(TableHeaderView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    
    if ((oldWidget.model != widget.model))
    {
      oldWidget.model!.removeListener(this);
      widget.model!.registerListener(this);
    }

  }

  @override
  void dispose()
  {
    if (widget.model != null) widget.model!.removeListener(this);

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
    if ((widget.model != null))
    {
      widget.model!.minWidth  = constraints.minWidth;
      widget.model!.maxWidth  = constraints.maxWidth;
      widget.model!.minHeight = constraints.minHeight;
      widget.model!.maxHeight = constraints.maxHeight;
    }

    // Check if widget is visible before wasting resources on building it
    if ((widget.model == null) || (widget.model!.visible == false)) return Offstage();

    ///////////
    /* Cells */
    ///////////
    int i = 0;
    List<Widget> cells = [];
    List<Widget> dragHandles = [];
    double widthTotal = 0;
    widget.model!.cells.forEach((model)
    {
      //////////
      /* Size */
      //////////
      double? height = widget.height;
      double? width  = (widget.width != null) && (widget.width!.containsKey(i)) ? widget.width![i] : 0;
      if ((width != null) && (widget.padding != null) && (widget.padding!.containsKey(i))) width += (widget.padding![i] ?? 0);

      //////////
      /* View */
      //////////
      Widget cell = TableHeaderCellView(model);

      ////////////
      /* Resize */
      ////////////
      Widget draghit   = Container(color: Colors.transparent, width: anchorWidth, height: height, child: Center(
          child: Container(width: 1, height: height, color: widget.model!.headerbordercolor ?? widget.model!.bordercolor ?? Theme.of(context).colorScheme.onSecondary.withOpacity(0.40))));
      Widget dragbox   = Container(color: Colors.transparent, width: anchorWidth, height: height);
      Widget draggable = MouseRegion(cursor: SystemMouseCursors.resizeLeftRight, child: Draggable(axis: Axis.horizontal, child: draghit, feedback: dragbox, onDragUpdate: (details) => onDrag(details, model.index)));

      if (widget.model!.draggable != false) {
        double widthPlusPrevious = width! + widthTotal - (anchorWidth / 2);
        widthTotal += width;
        if (widthPlusPrevious < 0) widthPlusPrevious = 0;
        cells.add(UnconstrainedBox(child: SizedBox(width: width > 0 ? width : null, height: height, child: cell)));
        dragHandles.add(Positioned(left: widthPlusPrevious,
            child: UnconstrainedBox(child: SizedBox(width: anchorWidth, height: height, child: draggable))));
      } else cells.add(cell);
      i++;
    });

    // We don't need the right edge handle
    if (dragHandles.length > 0)
      dragHandles.removeLast();

    //////////
    /* View */
    //////////
    return Stack(children: [
      Row(children: cells, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize:  MainAxisSize.min),
      ...dragHandles,
    ]);
  }

  void onDrag(DragUpdateDetails details, int? cellIndex)
  {
    try
    {
      if (details.localPosition.dx > 0 || details.localPosition.dx < 0)
      {
        if (tableModel != null)
        {
          int    index          = cellIndex!;
          double position       = tableModel!.getCellPosition(index);
          RenderBox? tableObject = this.context.findRenderObject() as RenderBox?;
          Offset? tableGlobalPos = tableObject?.localToGlobal(Offset.zero);
          double offset         = details.localPosition.dx + anchorWidth - (tableGlobalPos?.dx ?? 0);
          double width          = offset - position;
          double cw             = tableModel!.getCellWidth(index) ?? 0;
          double cp             = tableModel!.getCellPadding(index) ?? 0;
          double difference     = width - (cw + cp);
          if(cw + difference < 0) difference = width - (width / (tableModel!.cellpadding.length));

          if (width > anchorWidth)
          {
            tableModel!.setCellWidth(index, width);
            tableModel!.setCellPadding(index, 0);
            tableModel!.setCellWidth(index + 1, (tableModel!.getCellWidth(index + 1)! + tableModel!.getCellPadding(index + 1)!) - (width - (cw + cp)));
            tableModel!.setCellPadding(index + 1, 0);
            
            for (int i = 0; i < tableModel!.widths.length; i++)
              tableModel!.setCellWidth(i, tableModel!.getCellWidth(i)! + tableModel!.getCellPadding(i)!);
            tableModel!.notifyListeners('width', width);
          }
        }
      }
    }
    catch(e) {Log().exception(e);}
  }

}
