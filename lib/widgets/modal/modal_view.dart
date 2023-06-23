// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/event/event.dart';
import 'package:fml/helper/measured.dart';
import 'package:fml/helper/string.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/framework/framework_model.dart';
import 'package:fml/widgets/modal/modal_manager_view.dart';
import 'package:fml/widgets/modal/modal_model.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class ModalView extends StatefulWidget implements IWidgetView
{
  @override
  final ModalModel model;

  ModalView(this.model) : super(key: ObjectKey(model));

  @override
  State<ModalView> createState() => ModalViewState();
}

class ModalViewState extends WidgetState<ModalView>
{
  static double headerSize = 30;
  static double headerIconSize = headerSize - 10;
  static double headerIconDividerSize = 5;
  static double minimumSize = (headerIconSize * 3) + (headerIconDividerSize * 4);

  Widget? body;

  double padding = 15;

  double? dx;
  double? dy;

  double? width;
  double? height;

  bool atMaxHeight = false;
  late double maxHeight;

  bool atMaxWidth = false;
  late double maxWidth;

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

  onMeasured(Size size, {dynamic data})
  {
    height ??= size.height;
    width ??= size.width;
    setState(() {});
  }

  @override
  void initState()
  {
    widget.model.state = this;

    width  = widget.model.width;
    height = widget.model.height;
    dx     = widget.model.x;
    dy     = widget.model.y;
    super.initState();
  }

  bool _atOriginal()
  {
    return (originalWidth == width) && (originalHeight == height) && (originalDx == dx) && (originalDy == dy);
  }

  bool _atLast()
  {
    return (lastWidth == width) && (lastHeight == height) && (lastDx == dx) && (lastDy == dy);
  }

  onMinimize()
  {
    if (widget.model.closeable == false) return;
    setState(()
    {
      minimized = true;
      maximized = false;
    });
  }

  onMaximizeWindow()
  {
    if (widget.model.closeable == false) return;
    setState(()
    {
      dx = 0;
      dy = 0;
      width = maxWidth;
      height = maxHeight;
    });
  }

  onMaximize()
  {
    if (widget.model.closeable == false) return;
    setState(()
    {
      minimized = false;
      maximized = true;
    });
  }

  onRestoreTo()
  {
    if (!_atOriginal()) return onRestoreToOriginal();
    if (!_atLast())     return onRestoreToLast();
  }

  onRestoreToOriginal()
  {
    setState(()
    {
      minimized = false;
      maximized = false;
      dx     = originalDx;
      dy     = originalDy;
      width  = originalWidth;
      height = originalHeight;
    });
  }

  onRestoreToLast()
  {
    setState(()
    {
      minimized = false;
      maximized = false;
      dx     = lastDx;
      dy     = lastDy;
      width  = lastWidth;
      height = lastHeight;
    });
  }

  onRestore()
  {
    if (widget.model.closeable == false) return;
    setState(()
    {
      minimized = false;
      maximized = false;
      onBringToFront(null);
    });
  }

  onClose()
  {
    if (widget.model.closeable == false) return;

    ModalManagerView? manager = context.findAncestorWidgetOfExactType<ModalManagerView>();
    if (manager != null)
    {
      manager.model.unpark(widget);
      manager.model.modals.remove(widget);
      manager.model.refresh();
    }

    // dispose of the model
    if (widget.model is FrameworkModel) (widget.model as FrameworkModel).dispose();
  }

  onDismiss()
  {
    if (!widget.model.dismissable) return;
    ModalManagerView? manager = context.findAncestorWidgetOfExactType<ModalManagerView>();
    if (manager != null)
    {
      manager.model.unpark(widget);
      manager.model.modals.remove(widget);
      manager.model.refresh();
    }
  }

  onResizeBR(DragUpdateDetails details)
  {
    if (widget.model.resizeable == false) return;
    if (((width  ?? 0) + details.delta.dx) < minimumSize) return;
    if (((height ?? 0) + details.delta.dy) < minimumSize) return;

    setState(()
    {
      width  = (width  ?? 0) + details.delta.dx;
      height = (height ?? 0) + details.delta.dy;

      lastDx     = dx;
      lastDy     = dy;

      lastWidth  = width;
      lastHeight = height;
    });
  }

  onResizeBL(DragUpdateDetails details)
  {
    if (widget.model.resizeable == false) return;
    if (((width  ?? 0) - details.delta.dx) < minimumSize) return;
    if (((height ?? 0) + details.delta.dy) < minimumSize) return;

    setState(()
    {
      width  = (width  ?? 0) - details.delta.dx;
      height = (height ?? 0) + details.delta.dy;

      dx = dx! + details.delta.dx;
      lastDx     = dx;

      lastWidth  = width;
      lastHeight = height;
    });
  }

  onResizeTL(DragUpdateDetails details)
  {
    if (widget.model.resizeable == false) return;
    if (((width  ?? 0) - details.delta.dx) < minimumSize) return;
    if (((height ?? 0) + details.delta.dy) < minimumSize) return;

    setState(()
    {
      width  = (width  ?? 0) - details.delta.dx;
      height = (height ?? 0) - details.delta.dy;

      dx = dx! + details.delta.dx;
      dy = dy! + details.delta.dy;

      lastDx     = dx;
      lastDy     = dy;

      lastWidth  = width;
      lastHeight = height;
    });
  }

  onResizeTR(DragUpdateDetails details)
  {
    if (widget.model.resizeable == false) return;
    if (((width  ?? 0) + details.delta.dx) < minimumSize) return;
    if (((height ?? 0) - details.delta.dy) < minimumSize) return;

    setState(()
    {
      width  = (width  ?? 0) + details.delta.dx;
      height = (height ?? 0) - details.delta.dy;

      dy = dy! + details.delta.dy;
      lastDy = dy;

      lastWidth  = width;
      lastHeight = height;
    });
  }

  onResizeT(DragUpdateDetails details)
  {
    if (widget.model.resizeable == false) return;
    if (((height ?? 0) - details.delta.dy) < minimumSize) return;
    setState(()
    {
      height = (height ?? 0) - details.delta.dy;
      dy = dy! + details.delta.dy;
      lastDy     = dy;
      lastHeight = height;
    });
  }

  onResizeB(DragUpdateDetails details)
  {
    if (widget.model.resizeable == false) return;
    if (((height ?? 0) + details.delta.dy) < minimumSize) return;

    setState(()
    {
      height = (height ?? 0) + details.delta.dy;
      lastHeight = height;
    });
  }

  onResizeL(DragUpdateDetails details)
  {
    if (widget.model.resizeable == false) return;
    if (((width  ?? 0) - details.delta.dx) < minimumSize) return;
    setState(()
    {
      width  = (width  ?? 0) - details.delta.dx;
      dx = dx! + details.delta.dx;
      lastDx     = dx;
      lastWidth  = width;
    });
  }

  onResizeR(DragUpdateDetails details)
  {
    if (widget.model.resizeable == false) return;
    if (((width  ?? 0) + details.delta.dx) < minimumSize) return;
    setState(()
    {
      width  = (width  ?? 0) + details.delta.dx;
      lastDx     = dx;
      lastWidth  = width;
    });
  }

  onDrag(DragUpdateDetails details)
  {
    if (!widget.model.draggable) return;
    setState(()
    {
      dx = dx! + details.delta.dx;
      dy = dy! + details.delta.dy;
      if (widget.model.modal == true)
      {
        var viewport = MediaQuery.of(context).size;
        if (dx!.isNegative) dx = 0;
        if (dy!.isNegative) dy = 0;
        if (dx! + (width!  + (padding * 2)) > viewport.width)  dx = viewport.width  - (width!  + (padding * 2));
        if (dy! + (height! + (padding * 2)) > viewport.height) dy = viewport.height - (height! + (padding * 2));
      }

      lastDx = dx;
      lastDy = dy;
      lastWidth  = width;
      lastHeight = height;

      // print('on drag $dx,$dy...');
    });
  }

  onDragEnd(DragEndDetails details)
  {
    // print('on drag end ...');
    if (!widget.model.draggable || widget.model.modal) return;
    var viewport = MediaQuery.of(context).size;
    bool minimize = (dx! + width! < 0) || (dx! > viewport.width) || (dy! + height! < 0) || (dy! > viewport.height);
    if (minimize)
    {
      dx     = originalDx;
      dy     = originalDy;
      lastDx = originalDx;
      lastDy = originalDy;
      onMinimize();
    }
  }

  onBringToFront(TapDownDetails? details)
  {
    ModalManagerView? overlay = context.findAncestorWidgetOfExactType<ModalManagerView>();
    if (overlay != null) overlay.model.bringToFront(widget);
  }

  void onCloseEvent(Event event)
  {
    String? id = (event.parameters != null)  ? event.parameters!['id'] : null;
    if ((S.isNullOrEmpty(id)) || (id == widget.model.id))
    {
      event.handled = true;
      onClose();
    }
  }

  Widget _buildHeader(ColorScheme t)
  {
    Color c1 = t.onSurfaceVariant;
    Color c2 = t.primary;
    Color c3 = widget.model.bordercolor;

    var divider = Container(width: headerIconDividerSize, height:1);

    // window is maximized?
    bool isMaximized = atMaxHeight && atMaxWidth;

    // Build View
    Widget close = (widget.model.closeable == false)
       ? Container()
       : GestureDetector(onTap: () => onClose(),
       child: MouseRegion(cursor: SystemMouseCursors.click, onHover: (ev) => setState(() => closeHovered = true), onExit: (ev) => setState(() => closeHovered = false),
           child: UnconstrainedBox(child: SizedBox(height: headerIconSize, width: headerIconSize,
               child: Icon(Icons.close, size: headerIconSize - 4, color: !closeHovered ? c1 : c2)))));

    Widget minimize = ((widget.model.closeable == false)  || (widget.model.modal == true))
       ? Container()
       : GestureDetector(onTap: () => onMinimize(),
       child: MouseRegion(cursor: SystemMouseCursors.click, onHover: (ev) => setState(() => minimizeHovered = true), onExit: (ev) => setState(() => minimizeHovered = false),
           child: UnconstrainedBox(child: SizedBox(height: headerIconSize, width: headerIconSize,
               child: Icon(Icons.horizontal_rule, size: headerIconSize - 4, color: !minimizeHovered ? c1 : c2)))));

    Widget maximize = ((widget.model.closeable == false)  || (widget.model.modal == true))
       ? Container()
       : GestureDetector(onTap: () => isMaximized ? onRestoreToLast() : onMaximizeWindow(),
       child: MouseRegion(cursor: SystemMouseCursors.click, onHover: (ev) => setState(() => maximizedHovered = true), onExit: (ev) => setState(() => maximizedHovered = false),
           child: UnconstrainedBox(child: SizedBox(height: headerIconSize, width: headerIconSize,
               child: Icon(isMaximized ? Icons.crop_7_5_sharp : Icons.crop_square_sharp, size: headerIconSize - 4, color: !maximizedHovered ? c1 : c2)))));

    // build header top radius
    // the body radius tops are overridden ion the model
    // and set to zero
    double radius = widget.model.headerRadius;
    if (radius <= 0) radius = 5;
    BorderRadius? containerRadius = BorderRadius.only(topRight: Radius.circular(radius), topLeft: Radius.circular(radius));

    var toolbar = Row(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.center, children: [minimize, divider, maximize, divider, close, divider]);

    return Container(decoration: BoxDecoration(borderRadius: containerRadius, color: c3), width: width!, height: headerSize, child: toolbar);
  }

  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // Size
    if ((width == null) || (height == null))
    {
      return UnconstrainedBox(child: MeasuredView(Material(child: BoxView(widget.model)), onMeasured));
    }

    ColorScheme t = Theme.of(context).colorScheme;

    // set the models default border color
    widget.model.defaultBorderColor = t.surfaceVariant;

    // Overlay Manager
    ModalManagerView? manager = context.findAncestorWidgetOfExactType<ModalManagerView>();

    // SafeArea
    double sa = MediaQuery.of(context).padding.top;

    // Exceeds Width of Viewport
    atMaxWidth = false;
    maxWidth  = MediaQuery.of(context).size.width;
    if (width! >= (maxWidth - (padding * 4)))
    {
      atMaxWidth = true;
      width = (maxWidth - (padding * 4));
    }
    if (width! <= 0) width = minimumSize;

    // Exceeds Height of Viewport
    atMaxHeight = false;
    maxHeight = MediaQuery.of(context).size.height - sa;
    if (height! >= (maxHeight - (padding * 4)))
    {
      atMaxHeight = true;
      height = (maxHeight - (padding * 4));
    }
    if (height! <= 0) height = minimumSize;

    // Content Box
    body ??= Material(child: BoxView(widget.model));

    // Non-Minimized View
    if (!minimized)
    {
      Widget resize        = Icon(Icons.apps, size: 24, color: Colors.transparent);
      Widget resizeableBR  = (widget.model.resizeable == false) ? Container() : GestureDetector(child: MouseRegion(cursor: SystemMouseCursors.resizeUpLeftDownRight, child: resize), onPanUpdate: onResizeBR, onTapDown: onBringToFront);
      Widget resizeableBL  = (widget.model.resizeable == false) ? Container() : GestureDetector(child: MouseRegion(cursor: SystemMouseCursors.resizeUpRightDownLeft, child: resize), onPanUpdate: onResizeBL, onTapDown: onBringToFront);
      Widget resizeableTL  = (widget.model.resizeable == false) ? Container() : GestureDetector(child: MouseRegion(cursor: SystemMouseCursors.resizeUpLeftDownRight, child: resize), onPanUpdate: onResizeTL, onTapDown: onBringToFront);
      Widget resizeableTR  = (widget.model.resizeable == false) ? Container() : GestureDetector(child: MouseRegion(cursor: SystemMouseCursors.resizeUpRightDownLeft, child: resize), onPanUpdate: onResizeTR, onTapDown: onBringToFront);

      Widget resize2       = Container(width: isMobile ? 34 : 24, height: height);
      Widget resizeableL   = (widget.model.resizeable == false) ? Container() : GestureDetector(child: MouseRegion(cursor: SystemMouseCursors.resizeLeftRight, child: resize2), onPanUpdate: onResizeL, onTapDown: onBringToFront);
      Widget resizeableR   = (widget.model.resizeable == false) ? Container() : GestureDetector(child: MouseRegion(cursor: SystemMouseCursors.resizeLeftRight, child: resize2), onPanUpdate: onResizeR, onTapDown: onBringToFront);

      Widget resize3       = Container(width: width, height: isMobile ? 34 : 24);
      Widget resizeableT   = (widget.model.resizeable == false) ? Container() : GestureDetector(child: MouseRegion(cursor: SystemMouseCursors.resizeUpDown, child: resize3), onPanUpdate: onResizeT, onTapDown: onBringToFront);
      Widget resizeableB   = (widget.model.resizeable == false) ? Container() : GestureDetector(child: MouseRegion(cursor: SystemMouseCursors.resizeUpDown, child: resize3), onPanUpdate: onResizeB, onTapDown: onBringToFront);

      // Positioned
      dx ??= (maxWidth / 2)  - ((width!  + (padding * 2)) / 2);
      dy ??= (maxHeight / 2) - ((height! + (padding * 2)) / 2) + sa;

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

      Widget frame = UnconstrainedBox(child: ClipRect(child: SizedBox(height: height, width: width, child: body)));

      double headerHeight = 30;
      var header = _buildHeader(t);

      // View
      Widget content = UnconstrainedBox(child: Container(color: Colors.transparent, height: height! + (padding * 2) + headerHeight, width: width! + (padding * 2),
          child: Stack(children: [
            Positioned(child: header, top: padding, left: padding),
            Positioned(child: frame,   top: headerHeight + padding, left: padding),
            Positioned(child: resizeableL, top: 0, left: 0),
            Positioned(child: resizeableR, top: 0, right: 0),
            Positioned(child: resizeableT, top: 0, left: 0),
            Positioned(child: resizeableB, bottom: 0, left: 0),
            Positioned(child: resizeableTL, top: 0, left: 0),
            Positioned(child: resizeableBL, bottom: 0, left: 0),
            Positioned(child: resizeableBR, bottom: 0, right: 0),
            Positioned(child: resizeableTR, top: 0, right: 0),
          ])));

      // Remove from Park
      if (manager != null) manager.model.unpark(widget);

      Widget curtain = GestureDetector(child: content, onDoubleTap: onRestoreTo, onTapDown: onBringToFront, onPanStart: (_) => onBringToFront(null), onPanUpdate: onDrag, onPanEnd: onDragEnd, behavior: HitTestBehavior.deferToChild);

      // Return View
      return Positioned(top: dy, left: dx, child: curtain);
    }

    // Minimized View
    else
    {
      // Get Parking Spot
      int? slot = 0;
      if (manager != null) slot = manager.model.park(widget);

      // Build View
      Widget scaled  = Card(margin: EdgeInsets.all(1), child: SizedBox(width: 100, height: 50, child: Padding(child: FittedBox(child: body), padding:EdgeInsets.all(5))), elevation: 5, color: t.secondary.withOpacity(0.5), borderOnForeground: false, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0)), side: BorderSide(width: 2, color: t.primary)));
      Widget curtain = GestureDetector(onTap: onRestore, child: MouseRegion(cursor: SystemMouseCursors.click, child: SizedBox(width: 100, height: 50)));
      Widget view    = Stack(children: [scaled, curtain]);

      // Return View
      return Positioned(bottom: 10, left: 10 + (slot! * 110).toDouble(), child: view);
    }
  }
}