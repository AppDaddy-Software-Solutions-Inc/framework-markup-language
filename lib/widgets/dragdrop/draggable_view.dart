// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fml/widgets/scroller/scroller_interface.dart';
import 'package:fml/widgets/viewable/viewable_widget_mixin.dart';
import 'package:fml/widgets/widget/viewable_widget_view.dart';
import 'package:flutter/services.dart';
import 'package:fml/widgets/widget/viewable_widget_state.dart';

class DraggableView extends StatefulWidget implements ViewableWidgetView {
  @override
  final ViewableWidgetMixin model;
  final Widget view;

  DraggableView(this.model, this.view) : super(key: ObjectKey(model));

  @override
  State<DraggableView> createState() => _DraggableViewState();
}

class _DraggableViewState extends ViewableWidgetState<DraggableView> {
  Timer? autoscroll;

  double? width;
  double? height;

  bool dragging = false;
  SystemMouseCursor cursor = SystemMouseCursors.grab;

  @override
  void initState() {
    super.initState();
    dragging = false;
  }

  @override
  didChangeDependencies() {
    dragging = false;
    super.didChangeDependencies();
    width = null;
    height = null;
  }

  @override
  void didUpdateWidget(DraggableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    dragging = false;
    width = null;
    height = null;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints) {
    width ??= constraints.maxWidth;
    height ??= constraints.maxHeight;

    var child = widget.view;
    if (width != null && height != null) {
      child = ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width!, maxHeight: height!),
          child: widget.view);
    }

    // build the draggable
    var draggable = Draggable(
        feedback: child,
        data: widget.model,
        onDragCompleted: onDragCompleted,
        onDragStarted: onDragStarted,
        onDragEnd: onDragEnd,
        child: widget.view);

    var view = MouseRegion(cursor: cursor, child: draggable);

    // is wrapped inside a IScrollable?
    var scroller =
        widget.model.firstAncestorWhere((element) => element is IScrollable);

    // wrap in listener if in IScrollable
    return scroller == null
        ? view
        : Listener(
            child: view,
            onPointerMove: (event) => onPointerMove(event, scroller));
  }

  void onDragCompleted() {
    setState(() {
      dragging = false;
    });
  }

  void onDragStarted() {
    setState(() {
      dragging = true;
      cursor = SystemMouseCursors.grabbing;
    });
    widget.model.onDrag();
  }

  void onDragEnd(DraggableDetails details) {
    setState(() {
      autoscroll?.cancel();
      dragging = false;
      cursor = SystemMouseCursors.grab;
    });
  }

  void onPointerMove(PointerMoveEvent event, IScrollable scroller) {
    autoscroll?.cancel();

    if (!dragging) {
      return;
    }

    var position = scroller.positionOf();
    var size = scroller.sizeOf();
    if (size != null && position != null) {
      double topY = position.dy;
      double bottomY = topY + size.height;

      const detectedRange = 100.0;
      const pixels = 3.0;
      if (event.position.dy < topY + detectedRange) {
        scroller.scroll(-1 * pixels);
        autoscroll = Timer.periodic(const Duration(milliseconds: 100),
            (_) => scroller.scroll(-1 * detectedRange));
      }

      if (event.position.dy > bottomY - detectedRange) {
        scroller.scroll(pixels);
        autoscroll = Timer.periodic(const Duration(milliseconds: 100),
            (_) => scroller.scroll(detectedRange));
      }
    }
  }
}
