// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fml/widgets/scroller/scroller_interface.dart';
import 'package:fml/widgets/viewable/viewable_model.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'package:flutter/services.dart';

class DraggableView extends StatefulWidget implements ViewableWidgetView {
  @override
  final ViewableMixin model;
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

    Widget view = widget.view;

    // feeback is what is displayed while dragging
    var feedback = widget.view;
    if (width != null && height != null) {
      feedback = ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width!, maxHeight: height!),
          child: view);
    }
    // we need to wrap in Material, otherwise widgets like FieldText
    // will throw an exception when dragging starts.
    feedback = Material(color: Colors.transparent, child: feedback);

    // putting the view insidea container fixes the
    // issue with the view not being draggable until entered.
    // this happens with <INPUT/> elements
    view = Container(color: Colors.transparent, child: view);

    // build the draggable
   view = Draggable(
        feedback: feedback,
        data: widget.model,
        onDragCompleted: onDragCompleted,
        onDragStarted: onDragStarted,
        onDragEnd: onDragEnd,
        child: view);

   // show hand cursor over draggable
    view = MouseRegion(cursor: cursor, child: view);

    // is wrapped inside a IScrollable?
    var scroller = widget.model.firstAncestorWhere((element) => element is IScrollable);
    if (scroller == null) return view;

    // we want to force a scroll when we drag teh view to the edge of the scroller
    view = Listener(child: view, onPointerMove: (event) => onPointerMove(event, scroller));
    return view;
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

      const detectedRange = 100.0;
      const pixels = 3.0;

      // vertical scroller
      if (scroller.directionOf() == Axis.vertical) {

        double top = position.dy;
        double bottom = top + size.height;

        if (event.position.dy < top + detectedRange) {
          scroller.scroll(-1 * pixels);
          autoscroll = Timer.periodic(const Duration(milliseconds: 100),
                  (_) => scroller.scroll(-1 * detectedRange));
        }

        if (event.position.dy > bottom - detectedRange) {
          scroller.scroll(pixels);
          autoscroll = Timer.periodic(const Duration(milliseconds: 100),
                  (_) => scroller.scroll(detectedRange));
        }
      }

      // horizontal scroller
      else if (scroller.directionOf() == Axis.horizontal) {

        double left = position.dx;
        double right = left + size.width;

        if (event.position.dx < left + detectedRange) {
          scroller.scroll(-1 * pixels);
          autoscroll = Timer.periodic(const Duration(milliseconds: 100),
                  (_) => scroller.scroll(-1 * detectedRange));
        }

        if (event.position.dx > right - detectedRange) {
          scroller.scroll(pixels);
          autoscroll = Timer.periodic(const Duration(milliseconds: 100),
                  (_) => scroller.scroll(detectedRange));
        }
      }
    }
  }
}
