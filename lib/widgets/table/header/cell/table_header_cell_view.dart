// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/table/header/cell/table_header_cell_model.dart';
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
  Widget _addSortIndicator(Widget view, BuildContext context)
  {
    if (S.isNullOrEmpty(widget.model.sort)) return view;

    ColorScheme t = Theme.of(context).colorScheme;

    double rpad = 2;

    // sort icon
    double size = 16;
    Widget icon = UnconstrainedBox(child: Container(width: 16, height: 24, alignment: Alignment.center, constraints: BoxConstraints(maxHeight: 24),
        child: Stack(
            children: [
              Positioned(top: 0, child: Icon(Icons.keyboard_arrow_up, color: t.onSecondaryContainer.withOpacity(0.35), size: size)),
              Positioned(bottom: 0, child: Icon(Icons.keyboard_arrow_down, color: t.onSecondaryContainer.withOpacity(0.35), size: size)),
            ])
    ));


    if (widget.model.sorted == true)
    {
      if (widget.model.sortAscending == true)
      {
        icon = UnconstrainedBox(child: Container(width: 16,
            height: 24,
            alignment: Alignment.center,
            constraints: BoxConstraints(maxHeight: 24),
            child: Stack(
                children: [
                  Positioned(top: 0,
                      child: Icon(Icons.keyboard_arrow_up,
                          color: t.onSecondaryContainer, size: size)),
                  Positioned(bottom: 0,
                      child: Icon(Icons.keyboard_arrow_down,
                          color: t.onSecondaryContainer.withOpacity(0.15),
                          size: size)),
                ])));
      }

      else
      {
        icon = UnconstrainedBox(child: Container(width: 16, height: 24, alignment: Alignment.center, constraints: BoxConstraints(maxHeight: 24),
          child: Stack(
              children: [
                Positioned(top: 0, child: Icon(Icons.keyboard_arrow_up, color: t.onSecondaryContainer.withOpacity(0.15), size: size)),
                Positioned(bottom: 0, child: Icon(Icons.keyboard_arrow_down, color: t.onSecondaryContainer, size: size)),
              ])));
      }

      // button
      Widget sort = MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(child: icon, onTap: () => widget.model.onSort()));
      view = Stack(fit: StackFit.passthrough, children: [Padding(padding: EdgeInsets.only(left: 4, right: 12), child: view), Positioned(top: 0, bottom: 0, right: 0, child: sort)]);

      // Add Right Padding
      rpad = rpad + size;
    }

    return view;
  }

  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // sort
    if (widget.model.sortbydefault && !widget.model.isSorting && !widget.model.sorted)
    {
      widget.model.onSort();
    }

    // contents
    Widget view = BoxView(widget.model);

    // overlay sort indicator
    view = _addSortIndicator(view,context);

    // view
    view = GestureDetector(onTap: onTap, child: MouseRegion(cursor: SystemMouseCursors.click, child: view));

    return view;
  }

  onTap() async {}
}

