// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/gestures.dart';
import 'package:fml/fml.dart';
import 'package:fml/log/manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/widgets/scroller/scroller_behavior.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'package:fml/widgets/menu/menu_model.dart';

class MenuView extends StatefulWidget implements ViewableWidgetView {
  @override
  final MenuModel model;
  const MenuView(this.model, {super.key});

  @override
  State<MenuView> createState() => MenuViewState();
}

class MenuViewState extends ViewableWidgetState<MenuView>  {
  Widget? busy;
  final ScrollController controller = ScrollController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// scrolls the widget with the specified context into view
  scrollToContext(BuildContext context, {required bool animate}) {
    Scrollable.ensureVisible(context, duration: animate ? const Duration(seconds: 1) : Duration.zero, alignment: 0.2);
  }

  /// scrolls the widget with the specified context into view
  scrollTo(double? position, {bool animate = false}) {
    if (position == null) return;
    if (position < 0) position = 0;

    var max = controller.position.maxScrollExtent;
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
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        }
        else {
          controller.jumpTo(pixels);
        }
        return;
      }

      // scroll down/right
      if (pixels > 0) {

        // already at the end of the list
        if (controller.position.maxScrollExtent == controller.offset) return;

        // calculate pixels
        pixels = controller.offset + pixels;
        if (pixels > controller.position.maxScrollExtent) pixels = controller.position.maxScrollExtent;

        if (animate) {
          controller.animateTo(pixels,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        }
        else {
          controller.jumpTo(pixels);
        }
        return;
      }
    }
    catch (e) {
      Log().exception(e, caller: 'menu.View');
    }
  }

  Widget _buildMenuItems(double width) {
    List<Widget> tilesList = []; //list of tiles
    List<Widget> tileRows = []; // row of tiles from list
    List<Row> rowsList = []; // list of rows containing tiles

    // build menu tiles
    for (var item in widget.model.items) {
      tilesList.add(item.getView());
    }

    double menuColPadding = FmlEngine.isMobile ? 0.0 : 25.0;
    double tilePadding = FmlEngine.isMobile ? 5.0 : 0;

    int tilesPerRow =
        ((/*MediaQuery.of(context).size.*/ width - (menuColPadding * 2)) ~/
            (FmlEngine.isMobile
                ? (170 + (tilePadding * 2))
                : (270 + (tilePadding * 2))));
    int tileCountForRow = 0;

    for (int i = 0; i < tilesList.length; i++) {
      tileRows.add(
          Padding(padding: EdgeInsets.all(tilePadding), child: tilesList[i]));
      tileCountForRow++;
      if (tileCountForRow >= tilesPerRow) {
        rowsList.add(Row(
          mainAxisSize: MainAxisSize.min,
          children: tileRows,
        ));
        tileRows = [];
        tileCountForRow = 0;
      }
      if (i == tilesList.length - 1 && tileRows.isNotEmpty) {
        // add partially filled row
        rowsList.add(Row(
          mainAxisSize: MainAxisSize.min,
          children: tileRows,
        ));
      }
    }

    return Center(
        child: Padding(
            padding: EdgeInsets.all(menuColPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rowsList,
            )));
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
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    //var background = BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor);

    /// Busy / Loading Indicator
    busy ??= BusyModel(widget.model,
            visible: widget.model.busy, observable: widget.model.busyObservable)
        .getView();

    // view
    Widget view = Stack(children: [
      _buildMenuItems(widget.model.myMaxWidthOrDefault),
      Center(child: busy)
    ]);

    // scrollable
    view = SingleChildScrollView(controller: controller, child: view);

    // allow mouse drag
    if (widget.model.allowDrag) {
      view = ScrollConfiguration(
        behavior: ProperScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: view,
      );
    } else {
      view = ScrollConfiguration(behavior: ProperScrollBehavior(), child: view);
    }

    return Container(
        color: widget.model.color ?? Theme.of(context).colorScheme.background,
        child: Center(child: view));
  }
}
