// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/widgets/popover/item/popover_item_model.dart';
import 'package:fml/widgets/popover/popover_model.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class PopoverView extends StatefulWidget implements IWidgetView
{
  @override
  final PopoverModel model;
  final Widget? child;

  PopoverView(this.model, {this.child});

  @override
  State<PopoverView> createState() => _PopoverViewState();
}

class _PopoverViewState extends WidgetState<PopoverView>
{
  Widget _buildPopover()
  {
    var color = Theme.of(context).colorScheme.onSecondaryContainer;

    List<PopupMenuEntry> itemsList = [];
    for (var item in widget.model.items)
    {
      if (item.visible)
      {
        Widget child;
        if (item.viewableChildren.isNotEmpty)
        {
          // note: children cannot use LayoutBuilder
          // this causes the Popover to crash
          List<Widget> children = [];
          for (var model in item.viewableChildren)
          {
            var view = model.getView();
            if (view != null)
            {
              children.add(view);
            }
          }
          child = ListTile(title: Row(mainAxisSize: MainAxisSize.min, children: children));
        }
        else
        {
          child = Text(item.label, style: TextStyle(color: color));
          if (item.icon != null)
          {
            child = ListTile(title: child, leading: Icon(item.icon, color: color));
          }
        }

        var view = PopupMenuItem(child: child, value: item);
        itemsList.add(view);
      }
    }

    var icon = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.model.icon ?? Icons.more_vert,
              color: widget.model.color ??
                  Theme.of(context).colorScheme.inverseSurface),
          widget.model.label != null ? Text(widget.model.label!, style: TextStyle(
            color: widget.model.color ?? Theme.of(context).colorScheme.onBackground,
            fontSize: 10,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
          )) : Offstage(),
        ]);

    Widget view = PopupMenuButton(
        enabled: widget.model.enabled,
        color: Theme.of(context).colorScheme.surfaceVariant,
        icon: icon,
        padding: EdgeInsets.all(5),
        onSelected: (dynamic item) => (item as PopoverItemModel).onTap(),
        itemBuilder: (BuildContext context) => <PopupMenuEntry>[...itemsList]);

    view = SizedBox(height: 50, child: view);

    if (widget.model.enabled)
    {
      view = MouseRegion(cursor: SystemMouseCursors.click, child: view);
    }
    else
    {
      view = Opacity(opacity: 0.5, child: view);
    }

    return view;
  }

  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible || widget.model.items.isEmpty) return Offstage();

    // build the view
    Widget view = _buildPopover();

    return view;
  }
}
