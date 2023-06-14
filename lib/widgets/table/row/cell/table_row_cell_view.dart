// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/modal/modal_manager_view.dart';
import 'package:fml/widgets/modal/modal_model.dart';
import 'package:fml/widgets/modal/modal_view.dart';
import 'package:fml/widgets/table/row/cell/table_row_cell_model.dart';
import 'package:fml/widgets/table/row/table_row_model.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/widget/widget_state.dart' ;
import 'package:fml/widgets/alignment/alignment.dart';

class TableRowCellView extends StatefulWidget implements IWidgetView
{
  @override
  final TableRowCellModel model;
  final int? row;

  TableRowCellView(this.model, this.row);

  @override
  State<TableRowCellView> createState() => _TableRowCellViewState();
}

class _TableRowCellViewState extends WidgetState<TableRowCellView> with WidgetsBindingObserver
{
  @override
  void dispose()
  {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // save system constraints
    onLayout(constraints);

    // build the child views
    List<Widget> children = widget.model.inflate();
    if (children.isEmpty) children.add(Container());

    //this must go after the children are determined
    var alignment= WidgetAlignment(widget.model.layoutType, widget.model.center, widget.model.halign, widget.model.valign);

    // Contents
    Widget contents;
    if (widget.model.wrap == true) {
      contents = Wrap(
          children: children,
          direction: Axis.vertical,
          alignment: alignment.mainWrapAlignment,
          runAlignment: alignment.mainWrapAlignment,
          crossAxisAlignment: alignment.crossWrapAlignment);
    } else {
      contents = Column(
          children: children,
          mainAxisAlignment: alignment.mainAlignment,
          crossAxisAlignment: alignment.crossAlignment,
          mainAxisSize: MainAxisSize.min);
    }


    Color color;
    if(widget.model.color != null){
      color = ((((widget.row ?? 0) % 2) == 0)
          ? widget.model.color ?? Theme.of(context).colorScheme.onInverseSurface
          : widget.model.altcolor ?? Theme.of(context)
          .colorScheme
          .surfaceVariant);
    } else {
      color = ((((widget.row ?? 0) % 2) == 0)
          ? Theme.of(context).colorScheme.onInverseSurface
          : Theme.of(context)
          .colorScheme
          .surfaceVariant);
    }

    // Container
    int index = widget.model.index ?? 0;
    int lastIndex = (widget.model.parent as TableRowModel).cells.length - 1;
        // Colors.transparent;
    double borderwidth = widget.model.borderwidth;
    Color bordercolor = Colors.transparent;
    Color? outerbordercolor = widget.model.bordercolor;

    bool selectable = true;

    // Cell
    Widget cell = Container(
        //alignment: aligned, //this may cause a problem aligning both containers
        child: contents,
        padding: const EdgeInsets.all(1.0),
        decoration: BoxDecoration(
            color: color,
            border: Border(
                left: BorderSide(
                    color: outerbordercolor != null
                        ? index == 0
                            ? outerbordercolor
                            : bordercolor
                        : bordercolor,
                    width: borderwidth),
                right: BorderSide(
                    color: outerbordercolor != null
                        ? index == lastIndex
                            ? outerbordercolor
                            : bordercolor
                        : bordercolor,
                    width: borderwidth),
                top: BorderSide(
                    color: outerbordercolor?? bordercolor,
                    width: borderwidth),
                bottom: BorderSide(
                    color: outerbordercolor ?? bordercolor,
                    width: borderwidth))));

    ///////////////
    /* Outer Box */
    ///////////////
    // Widget box = Container(
    //     //alignment: aligned, //this may cause a problem aligning both containers
    //     child: cell,
    //     padding: const EdgeInsets.all(0.0),
    //     decoration: BoxDecoration(
    //         color: color,
    //         border: Border(
    //             left: index == 0
    //                 ? BorderSide(color: outerbordercolor)
    //                 : BorderSide.none,
    //             right: BorderSide(color: outerbordercolor),
    //             top: widget.row == 0
    //                 ? BorderSide(color: outerbordercolor)
    //                 : BorderSide.none,
    //             bottom: BorderSide(color: outerbordercolor))));

    // View
    return Listener(
        onPointerDown: (_) => onTap(selectable),
        behavior: HitTestBehavior.translucent,
        child: Container(child: MouseRegion(cursor: SystemMouseCursors.click, child: cell)));
  }

  onTap(bool selectable) async {
    if (selectable) {
      if ((widget.model.expandedheight != null) ||
          ((widget.model.expandedwidth != null))) {
        if (context.findAncestorWidgetOfExactType<ModalView>() !=
            null) return;
        _expand();
      }
      WidgetModel.unfocus();
      widget.model.onSelect();
    }
  }

  void _expand() {
    double? dx;
    double? dy;
    double? width = widget.model.expandedwidth;
    double? height = widget.model.expandedheight;

    dynamic box = context.findRenderObject();
    if (box is RenderBox) {
      var position = box.localToGlobal(Offset.zero);
      dx = position.dx;
      dy = position.dy;
      if ((box.size.width) >= (width ?? 0)) width = box.size.width;
      if ((box.size.height) >= (height ?? 0)) height = box.size.height;
    }

    // Build Overlay Entry
    ModalManagerView? manger = context.findAncestorWidgetOfExactType<ModalManagerView>();
    if (manger != null)
    {
      ModalView modal = ModalView(ModalModel(widget.model,null,
          child: widget,
          modal: true,
          x: dx,
          y: dy,
          width: width,
          height: height,
          draggable: false,
          closeable: false,
          dismissible: true));
      manger.model.modals.add(modal);
      manger.model.refresh();
    }
  }
}
