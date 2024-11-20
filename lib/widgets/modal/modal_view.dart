// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fml/event/event.dart';
import 'package:fml/helpers/color.dart';
import 'package:fml/widgets/measure/measure_view.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/framework/framework_model.dart';
import 'package:fml/widgets/modal/modal_manager_view.dart';
import 'package:fml/widgets/modal/modal_model.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';

// platform
import 'package:fml/platform/platform.vm.dart'
if (dart.library.io) 'package:fml/platform/platform.vm.dart'
if (dart.library.html) 'package:fml/platform/platform.web.dart';

class ModalView extends StatefulWidget implements ViewableWidgetView {
  @override
  final ModalModel model;

  ModalView(this.model) : super(key: ObjectKey(model));

  @override
  State<ModalView> createState() => ModalViewState();
}

class ModalViewState extends ViewableWidgetState<ModalView> {
  static double headerHeight = 30;
  static double headerIconSize = headerHeight - 10;
  static double headerIconDividerSize = 5;

  Widget? body;

  double? dx;
  double? dy;

  double? width;
  double? height;

  bool atMaxHeight = false;
  late double maxHeight;
  late double minHeight;

  bool atMaxWidth = false;
  late double maxWidth;
  late double minWidth;

  bool minimized = false;
  bool maximized = false;

  double? originalDx;
  double? originalDy;
  double? originalWidth;
  double? originalHeight;

  double? lastDx;
  double? lastDy;
  double? lastWidth;
  double? lastHeight;

  bool closeHovered = false;
  bool minimizeHovered = false;
  bool maximizedHovered = false;

  onMeasured(Size size, {dynamic data}) {
    height ??= size.height;
    width ??= size.width;
    setState(() {});
  }

  @override
  void initState() {
    width  = widget.model.width;
    height = widget.model.height;
    dx = widget.model.x;
    dy = widget.model.y;
    super.initState();
  }

  bool _atOriginal() {
    return (originalWidth == width) &&
        (originalHeight == height) &&
        (originalDx == dx) &&
        (originalDy == dy);
  }

  bool _atLast() {
    return (lastWidth == width) &&
        (lastHeight == height) &&
        (lastDx == dx) &&
        (lastDy == dy);
  }

  onMinimize() {
    if (widget.model.closeable == false) return;
    setState(() {
      minimized = true;
      maximized = false;
    });
  }

  onMaximizeWindow() {
    if (widget.model.closeable == false) return;
    dx = 0;
    dy = 0;
    width = maxWidth;
    height = maxHeight;

    // set resized width and height
    widget.model.setSize(width, height);
  }

  onMaximize() {
    if (widget.model.closeable == false) return;
    setState(() {
      minimized = false;
      maximized = true;
    });
  }

  onRestoreTo() {
    if (!_atOriginal()) return onRestoreToOriginal();
    if (!_atLast()) return onRestoreToLast();
  }

  onRestoreToOriginal() {

    minimized = false;
    maximized = false;
    dx = originalDx;
    dy = originalDy;
    width = originalWidth;
    height = originalHeight;

    // set resized width and height
    widget.model.setSize(width, height);
  }

  onRestoreToLast() {
    minimized = false;
    maximized = false;
    dx = lastDx;
    dy = lastDy;
    width = lastWidth;
    height = lastHeight;

    // set resized width and height
    widget.model.setSize(width, height);
  }

  onRestore() {
    if (widget.model.closeable == false) return;
    setState(() {
      minimized = false;
      maximized = false;
      onBringToFront(null);
    });
  }

  onClose() {
    if (widget.model.closeable == false) return;

    widget.model.resetSize();

    ModalManagerView? manager =
    context.findAncestorWidgetOfExactType<ModalManagerView>();
    if (manager != null) {
      manager.model.unpark(widget);
      manager.model.modals.remove(widget);
      manager.model.refresh();
    }

    // dispose of the model
    if (widget.model is FrameworkModel) {
      (widget.model as FrameworkModel).dispose();
    }
  }

  onDismiss() {
    if (!widget.model.dismissable) return;
    ModalManagerView? manager =
        context.findAncestorWidgetOfExactType<ModalManagerView>();
    if (manager != null) {
      manager.model.unpark(widget);
      manager.model.modals.remove(widget);
      manager.model.refresh();
    }
  }

  onResizeBR(DragUpdateDetails details) {

    if (!widget.model.resizeable) return;
    if (((width ?? 0) + details.delta.dx)  < minWidth) return;
    if (((height ?? 0) + details.delta.dy) < minHeight) return;

    // compute new size
    width = lastWidth = (width ?? 0) + details.delta.dx;
    height = lastHeight = (height ?? 0) + details.delta.dy;

    // set resized width and height
    widget.model.setSize(width, height);
  }

  onResizeBL(DragUpdateDetails details) {

    if (!widget.model.resizeable) return;
    if (((width ?? 0) - details.delta.dx) < minWidth) return;
    if (((height ?? 0) + details.delta.dy) < minHeight) return;

    // compute new size
    width = lastWidth = (width ?? 0) - details.delta.dx;
    height = lastHeight = (height ?? 0) + details.delta.dy;

    // compute new position
    dx = lastDx = dx! + details.delta.dx;

    // set resized width and height
    widget.model.setSize(width, height);
  }

  onResizeTL(DragUpdateDetails details) {

    if (!widget.model.resizeable) return;
    if (((width ?? 0) - details.delta.dx) < minWidth) return;
    if (((height ?? 0) + details.delta.dy) < minHeight) return;

    // compute new size
    width = lastWidth = (width ?? 0) - details.delta.dx;
    height = lastHeight = (height ?? 0) - details.delta.dy;

    // compute new position
    dx = lastDx = dx! + details.delta.dx;
    dy = lastDy = dy! + details.delta.dy;

    // set resized width and height
    widget.model.setSize(width, height);
  }

  onResizeTR(DragUpdateDetails details) {

    if (!widget.model.resizeable) return;
    if (((width ?? 0) + details.delta.dx) < minWidth) return;
    if (((height ?? 0) - details.delta.dy) < minHeight) return;

    // compute new size
    width = lastWidth = (width ?? 0) + details.delta.dx;
    height = lastHeight = (height ?? 0) - details.delta.dy;

    // compute new position
    dy = lastDy = dy! + details.delta.dy;

    // set resized width and height
    widget.model.setSize(width, height);
  }

  onResizeT(DragUpdateDetails details) {

    if (!widget.model.resizeable) return;
    if (((height ?? 0) - details.delta.dy) < minHeight) return;

    // compute new size
    height = lastHeight = (height ?? 0) - details.delta.dy;

    // compute new position
    dy = lastDy = dy! + details.delta.dy;

    // set resized width and height
    widget.model.setSize(width, height);
  }

  onResizeB(DragUpdateDetails details) {

    if (!widget.model.resizeable) return;
    if (((height ?? 0) + details.delta.dy) < minHeight) return;

    // compute new size
    height = lastHeight = (height ?? 0) + details.delta.dy;

    // set resized width and height
    widget.model.setSize(width, height);
  }

  onResizeL(DragUpdateDetails details) {

    if (!widget.model.resizeable) return;
    if (((width ?? 0) - details.delta.dx) < minWidth) return;

    // compute new size
    width = lastWidth = (width ?? 0) - details.delta.dx;

    // compute new position
    dx = lastDx = dx! + details.delta.dx;

    // set resized width and height
    widget.model.setSize(width, height);
  }

  onResizeR(DragUpdateDetails details) {

    if (!widget.model.resizeable) return;
    if (((width ?? 0) + details.delta.dx) < minWidth) return;

    // compute new size
    width = lastWidth = (width ?? 0) + details.delta.dx;

    // set resized width and height
    widget.model.setSize(width, height);
  }

  onDrag(DragUpdateDetails details) {
    if (!widget.model.draggable) return;
    setState(() {
      dx = dx! + details.delta.dx;
      dy = dy! + details.delta.dy;
      if (widget.model.modal) {
        var viewport = MediaQuery.of(context).size;
        if (dx!.isNegative) dx = 0;
        if (dy!.isNegative) dy = 0;
        if (dx! + width! > viewport.width) {
          dx = viewport.width - width!;
        }
        if (dy! + height! > viewport.height) {
          dy = viewport.height - height!;
        }
      }

      lastDx = dx;
      lastDy = dy;
      lastWidth = width;
      lastHeight = height;
    });
  }

  onDragEnd(DragEndDetails details) {
    // print('on drag end ...');
    if (!widget.model.draggable || widget.model.modal) return;
    var viewport = MediaQuery.of(context).size;
    bool minimize = (dx! + width! < 0) ||
        (dx! > viewport.width) ||
        (dy! + height! < 0) ||
        (dy! > viewport.height);
    if (minimize) {
      dx = originalDx;
      dy = originalDy;
      lastDx = originalDx;
      lastDy = originalDy;
      onMinimize();
    }
  }

  onBringToFront(TapDownDetails? details) {
    ModalManagerView? overlay =
        context.findAncestorWidgetOfExactType<ModalManagerView>();
    if (overlay != null) overlay.model.bringToFront(widget);
  }

  void onCloseEvent(Event event) {
    String? id = (event.parameters != null) ? event.parameters!['id'] : null;
    if ((isNullOrEmpty(id)) || (id == widget.model.id)) {
      event.handled = true;
      onClose();
    }
  }

  Widget _buildHeader(ColorScheme t) {

    Color c1 = widget.model.borderColor ?? t.outline;
    Color c2 = ColorHelper.highlight(c1, .5);

    // build header top radius
    // the body radius tops are overridden ion the model
    // and set to zero
    double radius = widget.model.headerRadius;
    if (radius <= 0) radius = 5;
    BorderRadius? containerRadius = BorderRadius.only(
        topRight: Radius.circular(radius), topLeft: Radius.circular(radius));

    // title
    Widget view = Offstage();
    if (!isNullOrEmpty(widget.model.title)) {
      Widget title = DefaultTextStyle(style: TextStyle(color: c2, fontSize: headerHeight * .45, fontWeight: FontWeight.bold), child: Text(widget.model.title!, overflow: TextOverflow.ellipsis));
      view = Center(child: title);
    }

    return Container(
        decoration: BoxDecoration(borderRadius: containerRadius, color: c1),
        width: width!,
        height: headerHeight,
        child: view);
  }

  Widget _buildToolbar(ColorScheme t) {

    Color c1 = widget.model.borderColor ?? t.outline;
    Color c2 = ColorHelper.highlight(c1, .5);
    Color c3 = ColorHelper.highlight(c1, 1);

    // window is maximized?
    bool isMaximized = atMaxHeight && atMaxWidth;

    var divider = SizedBox(width: headerIconDividerSize, height: 1);

    // Build View
    Widget close = !widget.model.closeable
        ? Container()
        : GestureDetector(
        onTap: () => onClose(),
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onHover: (ev) => setState(() => closeHovered = true),
            onExit: (ev) => setState(() => closeHovered = false),
            child: UnconstrainedBox(
                child: SizedBox(
                    height: headerIconSize,
                    width: headerIconSize,
                    child: Icon(Icons.close,
                        size: headerIconSize - 4,
                        color: !closeHovered ? c2 : c3)))));

    Widget minimize = !widget.model.resizeable
        ? Container()
        : GestureDetector(
        onTap: () => onMinimize(),
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onHover: (ev) => setState(() => minimizeHovered = true),
            onExit: (ev) => setState(() => minimizeHovered = false),
            child: UnconstrainedBox(
                child: SizedBox(
                    height: headerIconSize,
                    width: headerIconSize,
                    child: Icon(Icons.horizontal_rule,
                        size: headerIconSize - 4,
                        color: !minimizeHovered ? c2 : c3)))));

    Widget maximize = !widget.model.resizeable
        ? Container()
        : GestureDetector(
        onTap: () => isMaximized ? onRestoreToLast() : onMaximizeWindow(),
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onHover: (ev) => setState(() => maximizedHovered = true),
            onExit: (ev) => setState(() => maximizedHovered = false),
            child: UnconstrainedBox(
                child: SizedBox(
                    height: headerIconSize,
                    width: headerIconSize,
                    child: Icon(
                        isMaximized
                            ? Icons.crop_7_5_sharp
                            : Icons.crop_square_sharp,
                        size: headerIconSize - 4,
                        color: !maximizedHovered ? c2 : c3)))));

    Widget toolbar = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [minimize, divider, maximize, divider, close, divider]);

    return toolbar;
  }

  @override
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // compute size
    if (width == null || height == null) {
      return UnconstrainedBox(
          child:
              MeasureView(Material(child: BoxView(widget.model, (_,__) => widget.model.inflate())), onMeasured));
    }

    ColorScheme theme = Theme.of(context).colorScheme;

    // Overlay Manager
    ModalManagerView? manager =
        context.findAncestorWidgetOfExactType<ModalManagerView>();

    // SafeArea
    double sa = MediaQuery.of(context).padding.top;

    var size = MediaQuery.of(context).size;

    // Exceeds Width of Viewport
    atMaxWidth = false;
    maxWidth = min(widget.model.maxWidth ?? size.width, size.width);
    if (width! >= maxWidth) {
      atMaxWidth = true;
      width = maxWidth;
    }
    minWidth = widget.model.minWidth ?? ((headerIconSize * 3) + (headerIconDividerSize * 4));
    if (width! <= minWidth) {
      width = minWidth;
    }

    // Exceeds Height of Viewport
    atMaxHeight = false;
    maxHeight = min(widget.model.maxHeight ?? size.height, size.height) - sa - headerHeight;
    if (height! >= maxHeight) {
      atMaxHeight = true;
      height = maxHeight;
    }
    minHeight = widget.model.minHeight ?? headerIconSize;
    if (height! <= minHeight) {
      height = minHeight;
    }

    // Content Box
    body ??= Material(child: BoxView(widget.model, (_,__) => widget.model.inflate()));

    // Non-Minimized View
    if (!minimized) {

      Widget resize =
          const Icon(Icons.apps, size: 24, color: Colors.transparent);

      Widget resizeableBR = !widget.model.resizeable
          ? Container()
          : GestureDetector(
              onPanUpdate: onResizeBR,
              onTapDown: onBringToFront,
              child: MouseRegion(
                  cursor: SystemMouseCursors.resizeUpLeftDownRight,
                  child: resize));
      Widget resizeableBL = !widget.model.resizeable
          ? Container()
          : GestureDetector(
              onPanUpdate: onResizeBL,
              onTapDown: onBringToFront,
              child: MouseRegion(
                  cursor: SystemMouseCursors.resizeUpRightDownLeft,
                  child: resize));
      Widget resizeableTL = !widget.model.resizeable
          ? Container()
          : GestureDetector(
              onPanUpdate: onResizeTL,
              onTapDown: onBringToFront,
              child: MouseRegion(
                  cursor: SystemMouseCursors.resizeUpLeftDownRight,
                  child: resize));
      Widget resizeableTR = !widget.model.resizeable
          ? Container()
          : GestureDetector(
              onPanUpdate: onResizeTR,
              onTapDown: onBringToFront,
              child: MouseRegion(
                  cursor: SystemMouseCursors.resizeUpRightDownLeft,
                  child: resize));

      Widget resize2 =
          SizedBox(width: isMobile ? 34 : 24, height: height);
      Widget resizeableL = !widget.model.resizeable
          ? Container()
          : GestureDetector(
              onPanUpdate: onResizeL,
              onTapDown: onBringToFront,
              child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight, child: resize2));
      Widget resizeableR = !widget.model.resizeable
          ? Container()
          : GestureDetector(
              onPanUpdate: onResizeR,
              onTapDown: onBringToFront,
              child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight, child: resize2));

      Widget resize3 =
          SizedBox(width: width, height: isMobile ? 34 : 24);
      Widget resizeableT = !widget.model.resizeable
          ? Container()
          : GestureDetector(
              onPanUpdate: onResizeT,
              onTapDown: onBringToFront,
              child: MouseRegion(
                  cursor: SystemMouseCursors.resizeUpDown, child: resize3));
      Widget resizeableB = !widget.model.resizeable
          ? Container()
          : GestureDetector(
              onPanUpdate: onResizeB,
              onTapDown: onBringToFront,
              child: MouseRegion(
                  cursor: SystemMouseCursors.resizeUpDown, child: resize3));

      // Positioned
      dx ??= (maxWidth / 2) - (width! / 2);
      dy ??= (maxHeight / 2) - (height! / 2) + sa;

      // Original Size/Position
      originalDx ??= dx;
      originalDy ??= dy;
      originalWidth ??= width;
      originalHeight ??= height;

      // Last Size/Position
      lastDx ??= dx;
      lastDy ??= dy;
      lastWidth ??= width;
      lastHeight ??= height;

      Widget frame = UnconstrainedBox(
          child: ClipRect(
              child: SizedBox(height: height, width: width, child: body)));

      var header  = _buildHeader(theme);
      var toolbar = _buildToolbar(theme);

      // View
      Widget content = UnconstrainedBox(
          child: Container(
              color: Colors.transparent,
              height: height! + headerHeight,
              width: width!,
              child: Stack(children: [
                Positioned(top: 0, left: 0, child: header),
                Positioned(top: headerHeight, left: 0, child: frame),
                Positioned(top: 0, left: 0, child: resizeableL),
                Positioned(top: 0, right: 0, child: resizeableR),
                Positioned(top: 0, left: 0, child: resizeableT),
                Positioned(bottom: 0, left: 0, child: resizeableB),
                Positioned(top: 0, left: 0, child: resizeableTL),
                Positioned(bottom: 0, left: 0, child: resizeableBL),
                Positioned(bottom: 0, right: 0, child: resizeableBR),
                Positioned(top: 0, right: 0, child: resizeableTR),
                Positioned(top: (headerHeight - (headerIconSize - 2))/2, right: 0, child: toolbar),
              ])));

      // Remove from Park
      if (manager != null) manager.model.unpark(widget);

      Widget curtain = GestureDetector(
          onDoubleTap: onRestoreTo,
          onTapDown: onBringToFront,
          onPanStart: (_) => onBringToFront(null),
          onPanUpdate: onDrag,
          onPanEnd: onDragEnd,
          behavior: HitTestBehavior.deferToChild,
          child: content);

      // Return View
      return Positioned(top: dy, left: dx, child: curtain);
    }

    // Minimized View
    else {
      // Get Parking Spot
      int? slot = 0;
      if (manager != null) slot = manager.model.park(widget);

      // Build View
      Widget scaled = Card(
          margin: const EdgeInsets.all(1),
          elevation: 5,
          color: theme.secondary.withOpacity(0.5),
          borderOnForeground: false,
          shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
              side: BorderSide(width: 2, color: theme.primary)),
          child: SizedBox(
              width: 100,
              height: 50,
              child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: FittedBox(child: body))));
      Widget curtain = GestureDetector(
          onTap: onRestore,
          child: const MouseRegion(
              cursor: SystemMouseCursors.click,
              child: SizedBox(width: 100, height: 50)));
      Widget view = Stack(children: [scaled, curtain]);

      // Return View
      return Positioned(
          bottom: 10, left: 10 + (slot! * 110).toDouble(), child: view);
    }
  }
}
