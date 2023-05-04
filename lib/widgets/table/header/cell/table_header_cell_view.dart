// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/table/header/cell/table_header_cell_model.dart';
import 'package:fml/widgets/alignment/alignment.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class TableHeaderCellView extends StatefulWidget implements IWidgetView
{
  @override
  final TableHeaderCellModel model;

  TableHeaderCellView(this.model) : super(key: ObjectKey(model));

  @override
  State<TableHeaderCellView> createState() => _TableHeaderCellViewState();
}

class _TableHeaderCellViewState extends WidgetState<TableHeaderCellView>
{
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    if (widget.model.sortbydefault && !widget.model.isSorting && !widget.model.sorted)
    {
      widget.model.onSort();
    }

    // save system constraints
    onLayout(constraints);

      // Check if widget is visible before wasting resources on building it
      if (!widget.model.visible) return Offstage();

      ColorScheme t = Theme.of(context).colorScheme;

      // build the child views
      List<Widget> children = widget.model.inflate();
      if (children.isEmpty) children.add(Container());

      //this must go after the children are determined
      var alignment = WidgetAlignment(widget.model.layoutType, widget.model.center, widget.model.halign, widget.model.valign);

      //////////////
      /* Contents */
      //////////////
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

      ///////////////
      /* Container */
      ///////////////
      // int index              = widget.model.index ?? 0;
      Color color = widget.model.color ?? t.inversePrimary;
      Color borderColor = widget.model.bordercolor ?? Colors.transparent;
      double borderWidth = widget.model.borderwidth ?? 1;
      // Color outerbordercolor = widget.model.outerbordercolor ?? Colors.transparent;

      //////////
      /* Sort */
      //////////
      double rpad = 2;
      Widget view = contents;
      if (!S.isNullOrEmpty(widget.model.sort)) {
        //////////
        /* Icon */
        //////////
        double size = 16;
        Widget icon = UnconstrainedBox(child: Container(width: 16, height: 24, alignment: Alignment.center, constraints: BoxConstraints(maxHeight: 24),
          child: Stack(
            children: [
              Positioned(top: 0, child: Icon(Icons.keyboard_arrow_up, color: t.onSecondaryContainer.withOpacity(0.35), size: size)),
              Positioned(bottom: 0, child: Icon(Icons.keyboard_arrow_down, color: t.onSecondaryContainer.withOpacity(0.35), size: size)),
          ])
        ));
        if (widget.model.sorted == true) {
          icon = (widget.model.sortAscending == true)
              ? UnconstrainedBox(child: Container(width: 16, height: 24, alignment: Alignment.center, constraints: BoxConstraints(maxHeight: 24),
                  child: Stack(
                      children: [
                        Positioned(top: 0, child: Icon(Icons.keyboard_arrow_up, color: t.onSecondaryContainer, size: size)),
                        Positioned(bottom: 0, child: Icon(Icons.keyboard_arrow_down, color: t.onSecondaryContainer.withOpacity(0.15), size: size)),
                      ])
              ))
              : UnconstrainedBox(child: Container(width: 16, height: 24, alignment: Alignment.center, constraints: BoxConstraints(maxHeight: 24),
                  child: Stack(
                      children: [
                        Positioned(top: 0, child: Icon(Icons.keyboard_arrow_up, color: t.onSecondaryContainer.withOpacity(0.15), size: size)),
                        Positioned(bottom: 0, child: Icon(Icons.keyboard_arrow_down, color: t.onSecondaryContainer, size: size)),
                      ])
              ));
        }

        ////////////
        /* Button */
        ////////////
        Widget sort = MouseRegion(
            cursor: SystemMouseCursors.click,
            child:
            GestureDetector(child: icon, onTap: () => widget.model.onSort()));
        view = Stack(fit: StackFit.passthrough, children: [
          Padding(padding: EdgeInsets.only(left: 4, right: 12), child: contents),
          Positioned(top: 0, bottom: 0, right: 0, child: sort)
        ]);

        ///////////////////////
        /* Add Right Padding */
        ///////////////////////
        rpad = rpad + size;
      }

      //////////
      /* Cell */
      //////////
      Widget cell = Container(
          child: view,
          //alignment: aligned, //this causes a problem
          padding: EdgeInsets.only(left: 1, right: 4, top: 1, bottom: 1),
          decoration: BoxDecoration(
              color: color,
              border: Border(
                  left: BorderSide(color: borderColor, width: borderWidth),
                  right: BorderSide(color: borderColor, width: borderWidth),
                  top: BorderSide(color: borderColor, width: borderWidth),
                  bottom: BorderSide(color: borderColor, width: borderWidth))));

      ///////////////
      /* Outer Box */
      ///////////////
      // Removed because it adds extra pixels and doesn't line up
      // Widget box = Container(
      //     child: cell,
      //     //alignment: aligned, //this causes a problem
      //     padding: const EdgeInsets.only(bottom: 1),
      //     decoration: BoxDecoration(
      //         color: color,
      //         border: Border(
      //             left: index == 0
      //                 ? BorderSide(color: outerbordercolor)
      //                 : BorderSide.none,
      //             right: BorderSide(color: outerbordercolor),
      //             top: BorderSide.none,
      //             bottom: BorderSide(color: outerbordercolor))));

      //////////
      /* View */
      //////////
      return GestureDetector(
          onTap: onTap,
          child: MouseRegion(cursor: SystemMouseCursors.click, child: cell));
    }
  }

  onTap() async {}

