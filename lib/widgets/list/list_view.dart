// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:ui';
import 'package:fml/event/manager.dart';
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/event/event.dart'        ;
import 'package:fml/widgets/dragdrop/draggable_view.dart';
import 'package:fml/widgets/dragdrop/droppable_view.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/widgets/list/list_model.dart';
import 'package:fml/widgets/list/item/list_item_view.dart';
import 'package:fml/widgets/list/item/list_item_model.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class ListLayoutView extends StatefulWidget implements IWidgetView
{
  @override
  final ListModel model;
  ListLayoutView(this.model) : super(key: ObjectKey(model));

  @override
  State<ListLayoutView> createState() => ListLayoutViewState();
}

class ListLayoutViewState extends WidgetState<ListLayoutView> implements IEventScrolling
{
  Future<ListModel>? listViewModel;
  Widget? busy;
  final ScrollController controller = ScrollController();

  @override
  didChangeDependencies()
  {
    // register event listeners
    EventManager.of(widget.model)?.registerEventListener(EventTypes.scroll,  onScroll);
    EventManager.of(widget.model)?.registerEventListener(EventTypes.scrollto, onScrollTo, priority: 0);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(ListLayoutView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.model != widget.model))
    {
      // remove old event listeners
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.scroll,  onScroll);
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.scrollto, onScrollTo);

      // register new event listeners
      EventManager.of(widget.model)?.registerEventListener(EventTypes.scroll,  onScroll);
      EventManager.of(widget.model)?.registerEventListener(EventTypes.scrollto, onScrollTo, priority: 0);
    }
  }

  @override
  void dispose()
  {
    // remove event listeners
    EventManager.of(widget.model)?.removeEventListener(EventTypes.scroll,  onScroll);
    EventManager.of(widget.model)?.removeEventListener(EventTypes.scrollto, onScrollTo);

    controller.dispose();
    super.dispose();
  }

  /// Takes an event (onscroll) and uses the id to scroll to that widget
  onScrollTo(Event event) {
    // BuildContext context;
    event.handled = true;
    if (event.parameters!.containsKey('id')) {
      String? id = event.parameters!['id'];
      var child = widget.model.findDescendantOfExactType(null, id: id);

      // if there is an error with this, we need to check _controller.hasClients as it must not be false when using [ScrollPosition],such as [position], [offset], [animateTo], and [jumpTo],
      if ((child != null) && (child.context != null)) {
        Scrollable.ensureVisible(child.context, duration: const Duration(seconds: 1), alignment: 0.2);
      }
    }
  }

  @override
  void onScroll(Event event) async
  {
    scroll(event, controller);
    event.handled = true;
  }

  scroll(Event event, ScrollController? sc) async
  {
    try {
      if (event.parameters!.containsKey("direction") && event.parameters!.containsKey("pixels")) {
        String? direction = event.parameters!["direction"];
        double distance = double.parse(event.parameters!["pixels"]!);
        if (direction != null)
        {
          if (direction == 'left' || direction == 'right')
          {
            double offset = sc!.offset;
            double moveToPosition = offset + (direction == 'left' ? -distance : distance);
            sc.animateTo(moveToPosition, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
          }
          else if (direction == 'up' || direction == 'down')
          {
            double offset = sc!.offset;
            double moveToPosition = offset + (direction == 'up' ? -distance : distance);
            sc.animateTo(moveToPosition, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
          }
        }
      }
    }
    catch(e)
    {
      Log().error('onScroll Error: ');
      Log().exception(e, caller: 'table.View');
    }
  }

  Widget? itemBuilder(BuildContext context, int index)
  {
    ListItemModel? model = widget.model.getItemModel(index);
    if (model == null) return null;

    Widget view = ListItemView(model);

    // droppable?
    if (model.droppable)
    {
      view = DroppableView(model, view);
    }

    // draggable?
    if (model.draggable)
    {
      view = DraggableView(model, view);
    }

    view = MouseRegion(cursor: SystemMouseCursors.click, child: view);
    view = GestureDetector(onTap: () => model.onTap(), behavior: HitTestBehavior.translucent, child: view);

    return view;
  }

  List<ExpansionPanelRadio> expansionItems(BuildContext context)
  {
    List<ExpansionPanelRadio> items = [];
    ListItemModel? itemModel;
    int index = 0;
    do {
      itemModel = widget.model.getItemModel(index++);
      if (itemModel != null) {
        var listItem = ListItemView(itemModel);
        Text? title;
        if (!isNullOrEmpty(itemModel.title)) {
          title = Text(itemModel.title!);
        } else if (isNullOrEmpty(itemModel.title))
        {
          List<dynamic>? descendants = itemModel.findDescendantsOfExactType(TextModel);
          if (descendants.isNotEmpty)
          {
            int i = 0;
            while (i < descendants.length && descendants[i].value == null) {
              i++;
            }
            title = Text(descendants[i].value, style: TextStyle(color: Theme
                .of(context)
                .colorScheme
                .onBackground),);
          }
        }
        else if (isNullOrEmpty(itemModel.title)) {
          title = Text(index.toString());
        }
        ListTile header = ListTile(title: title);
        var item = ExpansionPanelRadio(value: index, body: listItem, headerBuilder: (BuildContext context, bool isExpanded) => header, canTapOnHeader: true);
        items.add(item);
      }
    } while (itemModel != null);
    return items;
  }

  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    /// Busy / Loading Indicator
    busy ??= BusyModel(widget.model, visible: widget.model.busy, observable: widget.model.busyObservable).getView();

    // Direction
    dynamic direction = Axis.vertical;
    if (widget.model.direction == 'horizontal') direction = Axis.horizontal;

    List<Widget> children = [];

    // View
    Widget view;

    if(widget.model.collapsed) {
      view = SingleChildScrollView(
        physics: widget.model.onpulldown != null ? const AlwaysScrollableScrollPhysics() : null,
        child: ExpansionPanelList.radio(
            dividerColor: Theme.of(context).colorScheme.onInverseSurface,
            initialOpenPanelValue: 0,
            elevation: 2,
            expandedHeaderPadding: const EdgeInsets.all(4),
            children: expansionItems(context)));
    } else {
      view = ListView.builder(reverse: widget.model.reverse, physics: widget.model.onpulldown != null ? const AlwaysScrollableScrollPhysics() : null, scrollDirection: direction, controller: controller, itemBuilder: itemBuilder);
    }


    if(widget.model.onpulldown != null) {
      view = RefreshIndicator(
        onRefresh: () => widget.model.onPull(context),
        child: view);
    }

    if(widget.model.onpulldown != null || widget.model.allowDrag) {
      view = ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      child: view,
    );
    }

    // add list
    children.add(view);

    // add busy
    children.add(Center(child: busy));

    view = Stack(children: children);

    // add margins
    view = addMargins(view);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.tightestOrDefault);

    return view;
  }

  Offset? positionOf()
  {
    RenderBox? render = context.findRenderObject() as RenderBox?;
    return render?.localToGlobal(Offset.zero);
  }

  Size? sizeOf()
  {
    RenderBox? render = context.findRenderObject() as RenderBox?;
    return render?.size;
  }
}