// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fml/event/event.dart';
import 'package:fml/helpers/color.dart';
import 'package:fml/widgets/measure/measure_view.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/framework/framework_model.dart';
import 'package:fml/widgets/window/window_manager_view.dart';
import 'package:fml/widgets/window/window_model.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';

// platform
import 'package:fml/platform/platform.vm.dart'
if (dart.library.io) 'package:fml/platform/platform.vm.dart'
if (dart.library.html) 'package:fml/platform/platform.web.dart';

class WindowView extends StatefulWidget implements ViewableWidgetView {
  @override
  final WindowModel model;

  WindowView(this.model) : super(key: ObjectKey(model));

  @override
  State<WindowView> createState() => WindowViewState();
}

class WindowViewState extends ViewableWidgetState<WindowView> {

  static double headerHeight  = 30;
  static double toolbarHeight = headerHeight/2;

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

  bool mustPosition = false;

  onMeasured(Size size, {dynamic data}) {
    height ??= size.height;
    width ??= size.width;
    setState(() {});
  }

  @override
  void initState() {
    width  = widget.model.width;
    height = widget.model.height;
    mustPosition = widget.model.left != null || widget.model.right != null || widget.model.top != null || widget.model.bottom != null;
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
    widget.model.resetSize();

    WindowManagerView? manager =
    context.findAncestorWidgetOfExactType<WindowManagerView>();
    if (manager != null) {
      manager.model.unpark(widget);
      manager.model.windows.remove(widget);
      manager.model.refresh();
    }

    // dispose of the model
    if (widget.model is FrameworkModel) {
      (widget.model as FrameworkModel).dispose();
    }
  }

  onDismiss() {
    if (!widget.model.dismissable) return;
    WindowManagerView? manager =
        context.findAncestorWidgetOfExactType<WindowManagerView>();
    if (manager != null) {
      manager.model.unpark(widget);
      manager.model.windows.remove(widget);
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
    WindowManagerView? overlay =
        context.findAncestorWidgetOfExactType<WindowManagerView>();
    if (overlay != null) overlay.model.bringToFront(widget);
  }

  void onCloseEvent(Event event) {
    String? id = (event.parameters != null) ? event.parameters!['id'] : null;
    if (isNullOrEmpty(id) || id == widget.model.id) {
      if (widget.model.closeable) {
        event.handled = true;
        onClose();
      }
    }
  }

  Widget _buildHeader(ColorScheme t) {

    Color c1 = widget.model.borderColor;
    Color c2 = ColorHelper.highlight(c1, .5);

    // build header top radius
    // the body radius tops are overridden ion the model
    // and set to zero
    var radius = widget.model.headerRadius;
    BorderRadius? containerRadius;
    if (radius > 0) {
      containerRadius = BorderRadius.only(
        topRight: Radius.circular(radius), topLeft: Radius.circular(radius));
    }

    // title
    Widget view = const Offstage();
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

    Color color = ColorHelper.highlight(widget.model.borderColor, .5);

    // window is maximized?
    bool isMaximized = atMaxHeight && atMaxWidth;

    const double padding = 5;
    const placeholder = Offstage();

    // Build View
    Widget close = placeholder;
    if (widget.model.closeable) {

        var icon = Icon(Icons.close, size: toolbarHeight, color: color);

        close = GestureDetector(
        onTap: () => onClose(),
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Padding(padding: const EdgeInsets.only(left: padding, right: padding), child: icon)));
    }

    Widget minimize = placeholder;
    if (widget.model.resizeable) {

        var icon = Icon(Icons.horizontal_rule, size: toolbarHeight, color: color);

        minimize = GestureDetector(
        onTap: () => onMinimize(),
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Padding(padding: const EdgeInsets.only(left: padding, right: padding), child: icon)));
    }

    Widget maximize = placeholder;
    if (widget.model.resizeable) {

        var icon = Icon(isMaximized ? Icons.content_copy_sharp  : Icons.crop_square_sharp, size: toolbarHeight, color: color);

        maximize = GestureDetector(
        onTap: () => isMaximized ? onRestoreToLast() : onMaximizeWindow(),
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Padding(padding: const EdgeInsets.only(left: padding, right: padding), child: icon)));
    }

    Widget toolbar = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, children: [minimize, maximize, close]);

    return toolbar;
  }

  Widget _buildResizer(Alignment alignment) {

    if (!widget.model.resizeable) return const Offstage();

    switch (alignment) {

      case Alignment.bottomRight:
        return GestureDetector(
            onPanUpdate: onResizeBR,
            onTapDown: onBringToFront,
            child: const MouseRegion(
                cursor: SystemMouseCursors.resizeUpLeftDownRight,
                child: Icon(Icons.apps, size: 24, color: Colors.transparent)));

       case Alignment.bottomLeft:
        return GestureDetector(
            onPanUpdate: onResizeBL,
            onTapDown: onBringToFront,
            child: const MouseRegion(
                cursor: SystemMouseCursors.resizeUpRightDownLeft,
                child: Icon(Icons.apps, size: 24, color: Colors.transparent)));

        case Alignment.topLeft:
          return GestureDetector(
            onPanUpdate: onResizeTL,
            onTapDown: onBringToFront,
            child: const MouseRegion(
                cursor: SystemMouseCursors.resizeUpLeftDownRight,
                child: Icon(Icons.apps, size: 24, color: Colors.transparent)));

         case Alignment.topRight:
          return GestureDetector(
            onPanUpdate: onResizeTR,
            onTapDown: onBringToFront,
            child: const MouseRegion(
                cursor: SystemMouseCursors.resizeUpRightDownLeft,
                child: Icon(Icons.apps, size: 24, color: Colors.transparent)));

      case Alignment.centerLeft :
        return GestureDetector(
            onPanUpdate: onResizeL,
            onTapDown: onBringToFront,
            child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: SizedBox(width: isMobile ? 34 : 24, height: height)));

      case Alignment.centerRight:
        return GestureDetector(
            onPanUpdate: onResizeR,
            onTapDown: onBringToFront,
            child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: SizedBox(width: isMobile ? 34 : 24, height: height)));

      case Alignment.topCenter:
        return GestureDetector(
            onPanUpdate: onResizeT,
            onTapDown: onBringToFront,
            child: MouseRegion(
                cursor: SystemMouseCursors.resizeUpDown,
                child: SizedBox(width: width, height: isMobile ? 34 : 24)));

      case Alignment.bottomCenter:
        return GestureDetector(
            onPanUpdate: onResizeB,
            onTapDown: onBringToFront,
            child: MouseRegion(
                cursor: SystemMouseCursors.resizeUpDown,
                child: SizedBox(width: width, height: isMobile ? 34 : 24)));

      default:
        return const Offstage();
    }
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
    WindowManagerView? manager =
        context.findAncestorWidgetOfExactType<WindowManagerView>();

    // SafeArea
    double sa = MediaQuery.of(context).padding.top;

    // screen size
    var display = MediaQuery.of(context).size;

    // header size
    headerHeight = widget.model.titleBar ? 30 : 0;

    // Exceeds Width of Viewport
    atMaxWidth = false;
    maxWidth = min(widget.model.maxWidth ?? display.width, display.width);
    if (width! >= maxWidth) {
      atMaxWidth = true;
      width = maxWidth;
    }
    minWidth = widget.model.minWidth ?? (headerHeight - 10) * 3;
    if (width! <= minWidth) {
      width = minWidth;
    }

    // Exceeds Height of Viewport
    atMaxHeight = false;
    maxHeight = min(widget.model.maxHeight ?? display.height, display.height) - sa - headerHeight;
    if (height! >= maxHeight) {
      atMaxHeight = true;
      height = maxHeight;
    }
    minHeight = widget.model.minHeight ?? headerHeight;
    if (height! <= minHeight) {
      height = minHeight;
    }

    // Content Box
    body ??= Material(color: Colors.transparent, child: BoxView(widget.model, (_,__) => widget.model.inflate()));

    // Non-Minimized View
    if (!minimized) {

      // set positioning?
      if (mustPosition) {

        if (widget.model.left  != null) dx = widget.model.left;
        if (widget.model.right != null) dx = display.width - width! - widget.model.right!;

        if (widget.model.top    != null) dy = widget.model.top;
        if (widget.model.bottom != null) dy = display.height - height! - widget.model.bottom!;

        mustPosition = false;
      }

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

      // lower frame including the contents
      Widget frame = UnconstrainedBox(child: SizedBox(height: height, width: width, child: body));

      var header  = headerHeight > 0 ? _buildHeader(theme) : const Offstage();
      var toolbar = headerHeight > 0 ? _buildToolbar(theme) : const Offstage();

      // View
      Widget content = UnconstrainedBox(
          child: Container(
              color: Colors.transparent,
              height: height! + headerHeight,
              width: width!,
              child: Stack(children: [
                Positioned(top: 0, left: 0, child: header),
                Positioned(top: headerHeight, left: 0, child: frame),
                Positioned(top: 0, left: 0, child: _buildResizer(Alignment.centerLeft)),
                Positioned(top: 0, right: 0, child: _buildResizer(Alignment.centerRight)),
                Positioned(top: 0, left: 0, child: _buildResizer(Alignment.topCenter)),
                Positioned(bottom: 0, left: 0, child: _buildResizer(Alignment.bottomCenter)),
                Positioned(top: 0, left: 0, child: _buildResizer(Alignment.topLeft)),
                Positioned(bottom: 0, left: 0, child: _buildResizer(Alignment.bottomLeft)),
                Positioned(top: 0, right: 0, child: _buildResizer(Alignment.topRight)),
                Positioned(bottom: 0, right: 0, child: _buildResizer(Alignment.bottomRight)),
                Positioned(top: (headerHeight - toolbarHeight)/2, right: min(widget.model.headerRadius, headerHeight)/2, child: toolbar),
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
