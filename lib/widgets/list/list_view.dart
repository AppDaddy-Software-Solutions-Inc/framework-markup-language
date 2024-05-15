// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'dart:ui';
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/dragdrop/draggable_view.dart';
import 'package:fml/widgets/dragdrop/droppable_view.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/widgets/list/list_model.dart';
import 'package:fml/widgets/list/item/list_item_view.dart';
import 'package:fml/widgets/list/item/list_item_model.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';

class ListLayoutView extends StatefulWidget implements ViewableWidgetView {
  @override
  final ListModel model;
  ListLayoutView(this.model) : super(key: ObjectKey(model));

  @override
  State<ListLayoutView> createState() => ListLayoutViewState();
}

class ListLayoutViewState extends ViewableWidgetState<ListLayoutView> {

  Future<ListModel>? listViewModel;
  Widget? busy;
  final ScrollController controller = ScrollController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// scrolls the widget with the specified context into view
  scrollTo(double? position, {bool animate = false}) {
    if (position == null) return;
    if (position < 0) position = 0;

    var max = widget.model.maxExtent;
    if (position > max) position = max;

    if (animate) {
    controller.animateTo(position,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut);
    }
    else {
      controller.jumpTo(position);
    }
  }

  /// moves the scroller by the specified pixels in the specified direction
  void scroll(double? pixels, {required bool animate})  {

    try {

      // check if pixels is null
      pixels ??= 0;

      // scroll up/left
      if (pixels < 0) {

        // already at the start of the list
        if (controller.offset == 0) return;

        // calculate pixels
        pixels = controller.offset - pixels.abs();
        if (pixels < 0) pixels = 0;

        if (animate) {
          controller.animateTo(pixels,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut);
        }
        else {
          controller.jumpTo(pixels);
        }
        return;
      }

      // scroll down/right
      if (pixels > 0) {

        // calculate pixels
        pixels = controller.offset + pixels;
        //if (pixels > controller.position.maxScrollExtent) pixels = controller.position.maxScrollExtent;

        if (animate) {
          controller.animateTo(pixels,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut);
        }
        else {
          controller.jumpTo(pixels);
        }
        return;
      }
    }
    catch (e) {
      Log().exception(e, caller: 'list.View');
    }
  }

  Widget? itemBuilder(BuildContext context, int index) {
    ListItemModel? model = widget.model.getItemModel(index);
    if (model == null) return null;

    Widget view = ListItemView(model);

    // droppable?
    if (model.droppable) {
      view = DroppableView(model, view);
    }

    // draggable?
    if (model.draggable) {
      view = DraggableView(model, view);
    }

    view = MouseRegion(cursor: SystemMouseCursors.click, child: view);
    view = GestureDetector(
        onTap: () => model.onTap(),
        behavior: HitTestBehavior.translucent,
        child: view);

    return view;
  }

  List<ExpansionPanelRadio> expansionItems(BuildContext context) {
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
        } else if (isNullOrEmpty(itemModel.title)) {
          List<dynamic>? descendants =
              itemModel.findDescendantsOfExactType(TextModel);
          if (descendants.isNotEmpty) {
            int i = 0;
            while (i < descendants.length && descendants[i].value == null) {
              i++;
            }
            title = Text(
              descendants[i].value,
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onSurface),
            );
          }
        } else if (isNullOrEmpty(itemModel.title)) {
          title = Text(index.toString());
        }
        ListTile header = ListTile(title: title);
        var item = ExpansionPanelRadio(
            value: index,
            body: listItem,
            headerBuilder: (BuildContext context, bool isExpanded) => header,
            canTapOnHeader: true);
        items.add(item);
      }
    } while (itemModel != null);
    return items;
  }

  Offset? positionOf() {
    RenderBox? render = context.findRenderObject() as RenderBox?;
    return render?.localToGlobal(Offset.zero);
  }

  Size? sizeOf() {
    RenderBox? render = context.findRenderObject() as RenderBox?;
    return render?.size;
  }

  @override
  Widget build(BuildContext context) => BoxView(widget.model, builder);

  List<Widget> builder(BuildContext context, BoxConstraints constraints) {

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const [Offstage()];

    /// Busy / Loading Indicator
    busy ??= BusyModel(widget.model,
            visible: widget.model.busy, observable: widget.model.busyObservable)
        .getView();

    // Direction
    var direction = Axis.vertical;
    if (widget.model.direction == 'horizontal') direction = Axis.horizontal;

    List<Widget> children = [];

    // View
    Widget view;
    switch (widget.model.collapsed) {
      // collapsed list
      case true:
        view = SingleChildScrollView(
            physics: widget.model.onpulldown != null
                ? const AlwaysScrollableScrollPhysics()
                : null,
            child: ExpansionPanelList.radio(
                dividerColor: Theme.of(context).colorScheme.onInverseSurface,
                initialOpenPanelValue: 0,
                elevation: 2,
                expandedHeaderPadding: const EdgeInsets.all(4),
                children: expansionItems(context)));
        break;

      // regular list
      case false:
        view = ListView.builder(
            reverse: widget.model.reverse,
            physics: widget.model.onpulldown != null
                ? const AlwaysScrollableScrollPhysics()
                : null,
            scrollDirection: direction,
            controller: controller,
            itemBuilder: itemBuilder);
        break;
    }

    if (widget.model.onpulldown != null) {
      view = RefreshIndicator(
          onRefresh: () => widget.model.onPull(context), child: view);
    }

    if (widget.model.onpulldown != null || widget.model.allowDrag) {
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

    // show busy spinner over list
    view = Stack(children: children);

    return [view];
  }
}
