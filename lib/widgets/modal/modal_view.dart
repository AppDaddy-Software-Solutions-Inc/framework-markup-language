// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/event/event.dart';
import 'package:fml/helper/string.dart';
import 'package:fml/phrase.dart';
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
  Widget? body;

  double padding = 15;

  double? dx;
  double? dy;

  double? width;
  double? height;

  late double maxHeight;
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

  @override
  void initState()
  {
    widget.model.state = this;

    width  = widget.model.width;
    height = widget.model.height;
    dx     = widget.model.x ?? 0;
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

  onMaximize()
  {
    if (widget.model.closeable == false) return;
    minimized = false;
    maximized = true;

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
    if (((width  ?? 0) + details.delta.dx) < 50) return;
    if (((height ?? 0) + details.delta.dy) < 50) return;

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
    if (((width  ?? 0) - details.delta.dx) < 50) return;
    if (((height ?? 0) + details.delta.dy) < 50) return;

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
    if (((width  ?? 0) - details.delta.dx) < 50) return;
    if (((height ?? 0) + details.delta.dy) < 50) return;

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

  onResizeT(DragUpdateDetails details)
  {
    if (widget.model.resizeable == false) return;
    if (((height ?? 0) - details.delta.dy) < 50) return;
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
    if (((height ?? 0) + details.delta.dy) < 50) return;

    setState(()
    {
      height = (height ?? 0) + details.delta.dy;
      lastHeight = height;
    });
  }

  onResizeL(DragUpdateDetails details)
  {
    if (widget.model.resizeable == false) return;
    if (((width  ?? 0) - details.delta.dx) < 50) return;
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
    if (((width  ?? 0) + details.delta.dx) < 50) return;
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

      print('on drag $dx,$dy...');
    });
  }

  onDragEnd(DragEndDetails details)
  {
    print('on drag end ...');
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

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    if (width == null) width = widget.model.width ?? 50;
    if (height == null) height = widget.model.height ?? 50;

    ColorScheme t = Theme.of(context).colorScheme;

    // Overlay Manager
    ModalManagerView? manager = context.findAncestorWidgetOfExactType<ModalManagerView>();

    // SafeArea
    double sa = MediaQuery.of(context).padding.top;

    // Exceeds Width of Viewport
    maxWidth  = MediaQuery.of(context).size.width;
    if (width! > (maxWidth - (padding * 4))) width = (maxWidth - (padding * 4));
    if (width! <= 0) width = 50;

    // Exceeds Height of Viewport
    maxHeight = MediaQuery.of(context).size.height - sa;
    if (height! > (maxHeight - (padding * 4))) height = (maxHeight - (padding * 4));
    if (height! <= 0) height = 50;

    // Card
    if (body == null) body = Material(child: BoxView(widget.model));

    // Non-Minimized View
    if (!minimized)
    {
      // Build View
      Widget close = (widget.model.closeable == false)
          ? Container()
          : Padding(padding: EdgeInsets.only(left: 10), child: GestureDetector(onTap: () => onClose(),
          child: MouseRegion(cursor: SystemMouseCursors.click, onHover: (ev) => setState(() => closeHovered = true), onExit: (ev) => setState(() => closeHovered = false),
              child: UnconstrainedBox(child: SizedBox(height: 36, width: 36,
                  child: Tooltip(message: phrase.close,    child: Icon(Icons.close, size: 32, color: !closeHovered ? t.surfaceVariant : t.onBackground)))))));

      Widget minimize = ((widget.model.closeable == false)  || (widget.model.modal == true))
          ? Container()
          : Padding(padding: EdgeInsets.only(left: 10), child: GestureDetector(onTap: () => onMinimize(),
          child: MouseRegion(cursor: SystemMouseCursors.click, onHover: (ev) => setState(() => minimizeHovered = true), onExit: (ev) => setState(() => minimizeHovered = false),
              child: UnconstrainedBox(child: SizedBox(height: 36, width: 36,
                  child: Tooltip(message: phrase.minimize, child: Icon(Icons.remove_circle, size: 32, color: !minimizeHovered ? t.surfaceVariant : t.onBackground)))))));

      Widget resize        = Icon(Icons.apps, size: 24, color: Colors.transparent);
      Widget resizeableBR  = (widget.model.resizeable == false) ? Container() : GestureDetector(child: MouseRegion(cursor: SystemMouseCursors.resizeUpLeftDownRight, child: resize), onPanUpdate: onResizeBR, onTapDown: onBringToFront);
      Widget resizeableBL  = (widget.model.resizeable == false) ? Container() : GestureDetector(child: MouseRegion(cursor: SystemMouseCursors.resizeUpRightDownLeft, child: resize), onPanUpdate: onResizeBL, onTapDown: onBringToFront);
      Widget resizeableTL  = (widget.model.resizeable == false) ? Container() : GestureDetector(child: MouseRegion(cursor: SystemMouseCursors.resizeUpLeftDownRight, child: resize), onPanUpdate: onResizeTL, onTapDown: onBringToFront);

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

      // View
      Widget content = UnconstrainedBox(child: Container(color: Colors.red, height: height! + (padding * 2), width: width! + (padding * 2),
          child: Stack(children: [
            Center(child: frame),
            Positioned(child: resizeableL, top: 0, left: 0),
            Positioned(child: resizeableR, top: 0, right: 0),
            Positioned(child: resizeableT, top: 0, left: 0),
            Positioned(child: resizeableB, bottom: 0, left: 0),
            Positioned(child: resizeableTL, top: 0, left: 0),
            Positioned(child: resizeableBL, bottom: 0, left: 0),
            Positioned(child: resizeableBR, bottom: 0, right: 0),
            Positioned(child: minimize, top: 15, right: 50),
            Positioned(child: close, top: 15, right: 15)])));

      // Remove from Park
      if (manager != null) manager.model.unpark(widget);

      Widget curtain = GestureDetector(child: content, onDoubleTap: onRestoreTo, onTapDown: onBringToFront, onPanStart: (_) => onBringToFront(null), onPanUpdate: onDrag, onPanEnd: onDragEnd, behavior: HitTestBehavior.deferToChild);

      // Return View
      print('positioned to $dx, $dy');
      return Positioned(top: dx, left: dy, child: curtain);
    }

    // Minimized View
    else
    {
      // Get Parking Spot
      int? slot = 0;
      if (manager != null) slot = manager.model.park(widget);

      // Build View
      Widget scaled  = Card(margin: EdgeInsets.all(1), child: SizedBox(width: 100, height: 50, child: Padding(child: FittedBox(child: body), padding:EdgeInsets.all(5))), elevation: 5, color: t.secondary.withOpacity(0.50), borderOnForeground: false, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0)), side: BorderSide(width: 2, color: t.primary)));
      Widget close   = (widget.model.closeable == false) ? Container() : Padding(padding: EdgeInsets.only(left: 10), child: GestureDetector(onTap: () => onClose(),  child: MouseRegion(cursor: SystemMouseCursors.click, child: UnconstrainedBox(child: SizedBox(height: 24, width: 24, child: Container(decoration: BoxDecoration(color: t.primaryContainer, shape: BoxShape.circle), child: Tooltip(message: phrase.close, child: Icon(Icons.close, size: 24, color: t.onPrimaryContainer))))))));
      Widget curtain = GestureDetector(onTap: onRestore, child: MouseRegion(cursor: SystemMouseCursors.click, child: SizedBox(width: 100, height: 50)));
      Widget view    = Stack(children: [scaled, curtain, Positioned(child: close, top: 15, right: 15)]);

      // Return View
      return Positioned(bottom: 10, left: 10 + (slot! * 110).toDouble(), child: view);
    }
  }
}
