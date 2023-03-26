// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/treeview/node/tree_node_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class TreeNodeView extends StatefulWidget implements IWidgetView
{
  final TreeNodeModel model;

  TreeNodeView(this.model) : super(key: ObjectKey(model));

  @override
  _TreeNodeViewState createState() => _TreeNodeViewState();
}

class _TreeNodeViewState extends WidgetState<TreeNodeView>
{
  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // build children
    List<Widget> children = [];
    List<Widget> nodes    = [];
    if (widget.model.children != null)
      widget.model.children!.forEach((model)
      {
        if (model is TreeNodeModel) {
          nodes.add(TreeNodeView(model));
        }
        else if (model is IViewableWidget) {
          children.add((model as IViewableWidget).getView());
        }
      });

    //////////
    /* Icon */
    //////////
    if (children.isEmpty)
    {
      //////////
      /* Icon */
      //////////
      if (widget.model.expanded!)
      {
        if (widget.model.expandedicon != null) children.insert(0, Padding(padding: EdgeInsets.only(right: 0), child: Icon(widget.model.expandedicon, color: widget.model.color ?? Theme.of(context).colorScheme.onPrimaryContainer)));
        else if (widget.model.icon != null && widget.model.children != null) children.insert(0, Padding(padding: EdgeInsets.only(right: 0), child: Icon(widget.model.icon, color: widget.model.color)));
        else children.insert(0, Padding(padding: EdgeInsets.only(top: 10, bottom: 10, right: 24), child: Container()));
      }
      else
      {
        if (widget.model.icon != null && widget.model.children != null) children.insert(0, Padding(padding: EdgeInsets.only(right: 0), child: Icon(widget.model.icon, color: widget.model.color ?? Theme.of(context).colorScheme.onPrimaryContainer)));
        else children.insert(0, Padding(padding: EdgeInsets.only(top: widget.model.selected! ? 4 : 10, bottom: widget.model.selected! ? 4 : 10, right: widget.model.selected! ? 4 : 16, left: 8),
            child: widget.model.selected! ?  Icon(Icons.horizontal_rule, size: 12, color: Theme.of(context).colorScheme.primary) : Container()));
      }

      //////////
      /* Text */
      //////////
      children.add(Text(widget.model.label,
          style: TextStyle(
            // decoration: widget.model.selected ? TextDecoration.underline : TextDecoration.none,
            fontWeight: widget.model.selected! ? FontWeight.normal : FontWeight.normal,
            color: widget.model.selected! ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onBackground)));
    }


    ////////////////////
    /* Build the Tree */
    ////////////////////
    Widget view = Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: children, mainAxisSize: MainAxisSize.min);
    if (nodes.isNotEmpty)
    {
      if (S.isNullOrEmpty(widget.model.onclick) && widget.model.children == null)
        view = Opacity(opacity: 0.5, child: view); // Disable treeview nav links without onclick properties
      else view = MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(child: view, onTap: () => onTap()));
      if (widget.model.expanded!)
      {
        Widget child = Padding(padding: EdgeInsets.only(left: 17), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: nodes));
        view = Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [view, child]);
      }
    }
    else if (widget.model.onclick != null && widget.model.onclick != '')
      view = MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(child: view, onTap: () => onClick()));

    if (S.isNullOrEmpty(widget.model.onclick) && widget.model.children == null)
      view = Opacity(opacity: 0.5, child: view); // Disable treeview nav links without onclick properties
    return view;
  }

  onClick() async
  {
    selectNode(widget.model);
    await widget.model.onClick(context);
  }

  selectNode(TreeNodeModel node)
  {
    widget.model.treeview!.focusTreeNode(node);
  }

  onTap()
  {
    widget.model.expanded = !widget.model.expanded!;
  }
}