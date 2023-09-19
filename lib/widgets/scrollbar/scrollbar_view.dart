// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/system.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/widget_state.dart';

typedef OnChangeCallback = void Function (double percent);

enum Direction {horizontal, vertical}

class ScrollbarView extends StatefulWidget
{
  final Direction direction;
  final ScrollController? controller;
  final OnChangeCallback? onchange;
  final double size;
  final double controllerSize;
  final double extent = isMobile ? 24 : 12;
  final double? itemExtent;

  ScrollbarView(this.direction, this.controller, this.size, this.controllerSize, {this.onchange, this.itemExtent});

  @override
  State<ScrollbarView> createState() => _ScrollbarViewState();

  bool isVisible()
  {
    if ((controllerSize == 0) || (size <= 0)) return false;
    return (((size / controllerSize) * size) < size);
  }
}

class _ScrollbarViewState extends WidgetState<ScrollbarView>
{
  static double on  = .5;
  static double off = .05;

  double opacity = on;
  int    delay = 2;
  double offset = 0;
  bool   dragging = false;
  Timer? t;

  @override
  void initState()
  {
    super.initState();
    offset = toLocal(widget.controller!.offset);
    widget.controller!.addListener(onScrollController);
  }

  @override
  void didUpdateWidget(ScrollbarView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller!.addListener(onScrollController);
  }

  @override
  void dispose()
  {
    if (t != null) t!.cancel();
    widget.controller!.removeListener(onScrollController);
    super.dispose();
  }

  onScrollController()
  {
    double offset = toLocal(widget.controller!.offset);
    if ((this.offset != offset) && (mounted)) {
      setState(()
    {
      opacity = on;
      this.offset = offset;
      onMouseExit(null);
    });
    }
  }

  double toLocal(double value)
  {
    if (value <= 0) return 0;
    double sizeratio = 1;
    if (widget.controllerSize > 0) sizeratio = widget.size / widget.controllerSize;
    return sizeratio * value;
  }

  double toGlobal(double value)
  {
    if (value <= 0) return 0;
    double percent = 1;
    if (widget.size > 0) percent = value / widget.size;
    return widget.controllerSize * percent;
  }

  @override
  Widget build(BuildContext context)
  {
    ///////////////////////
    /* Dont Show if 100% */
    ///////////////////////
    double thumbsize = (widget.size / widget.controllerSize) * widget.size;
    if (thumbsize >= widget.size) return Container();

    Direction direction = widget.direction;
    //this.offset = toLocal(widget.controller.offset);

    Color? col = Theme.of(context).colorScheme.inversePrimary;

    /////////////////////////
    /* Horizontal Scroller */
    /////////////////////////
    if (direction == Direction.horizontal)
    {
      Widget thumb     = Container(width: thumbsize, height: widget.extent, decoration: ShapeDecoration(color: col, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0), side: BorderSide.none),));
      Widget draggable = MouseRegion(cursor: SystemMouseCursors.grab, onEnter: onMouseEnter, onExit: onMouseExit, child: GestureDetector(behavior: HitTestBehavior.deferToChild, child: thumb, onHorizontalDragUpdate: onHorizontalDrag, onHorizontalDragStart: (_) => dragging = true, onHorizontalDragEnd: (_) => dragging = false));
      Widget track     = MouseRegion(onEnter: onMouseEnter, onExit: onMouseExit, child: SizedBox(width: widget.size, height: widget.extent, child: Stack(fit: StackFit.passthrough, children: [Container(color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.8)), Positioned(left: offset, child: draggable)])));
      return UnconstrainedBox(child: track);
    }

    ///////////////////////
    /* Vertical Scroller */
    ///////////////////////
    else
    {
      Widget thumb     = Container(width: widget.extent, height: thumbsize, decoration: ShapeDecoration(color: col, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0), side: BorderSide.none)));
      Widget draggable = MouseRegion(cursor: SystemMouseCursors.grab, onEnter: onMouseEnter, onExit: onMouseExit, child: GestureDetector(behavior: HitTestBehavior.deferToChild, child: thumb, onVerticalDragUpdate: onVerticalDrag, onVerticalDragStart: onVerticalDragStart, onVerticalDragEnd: onVerticalDragEnd));
      Widget track     = MouseRegion(onEnter: onMouseEnter, onExit: onMouseExit, child: SizedBox(width: widget.extent, height: widget.size, child: Stack(fit: StackFit.passthrough, children: [Container(color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.8)), Positioned(top: offset, child: draggable)])));
      return UnconstrainedBox(child: track);
    }
  }

  void onMouseEnter(_)
  {
    //////////////////
    /* Cancel Timer */
    //////////////////
    if (t != null) t!.cancel();
    t = null;

    ///////////////////////////////////
    /* Scroller is Already Displayed */
    ///////////////////////////////////
    if ((opacity == on) || (dragging)) return;

    /////////////////
    /* Set Opacity */
    /////////////////
    if (mounted) setState(() => opacity = on);
  }

  void onMouseExit(_)
  {
    //////////////////
    /* Cancel Timer */
    //////////////////
    if (t != null) t!.cancel();

    ///////////////////////
    /* Hide the Scroller */
    ///////////////////////
    t = Timer(Duration(seconds: delay), _hide);
  }

  void _hide()
  {
    //////////////////
    /* Cancel Timer */
    //////////////////
    if (t != null) t!.cancel();
    t = null;

    /////////////////
    /* Set Opacity */
    /////////////////
    if (mounted) setState(() => opacity = off);
  }

  void onHorizontalDrag(DragUpdateDetails details)
  {
    double thumbsize = (widget.size / widget.controllerSize) * widget.size;
    double offset = this.offset + details.delta.dx;

    if (offset < 0.0) offset = 0.0;
    if (offset > (widget.size - thumbsize)) offset = widget.size - thumbsize;

    double value = toGlobal(offset);
    if (widget.controller != null) widget.controller!.jumpTo(value);
    if (widget.onchange   != null) widget.onchange!(value);

    if (mounted) setState(() => this.offset = offset);
  }

  Timer? timer;

  int time = DateTime.now().millisecondsSinceEpoch;
  void onVerticalDrag(DragUpdateDetails details)
  {
    //////////////
    /* Velocity */
    //////////////
    var    now      = DateTime.now().millisecond;
    int    elapsed  = (now - time);
    double distance =  details.delta.dy.abs();
    double? velocity = (elapsed > 0) && (distance > 0) ? distance / elapsed : null;
    time            = now;
    if (velocity == null) return;

    ////////////////
    /* Thumb Size */
    ////////////////
    double thumbsize = (widget.size / widget.controllerSize) * widget.size;

    ////////////
    /* Offset */
    ////////////
    double offset = this.offset + details.delta.dy;
    if (offset < 0.0) offset = 0.0;
    if (offset > (widget.size - thumbsize)) offset = widget.size - thumbsize;
    this.offset = offset;

    //////////////////
    /* Cancel Timer */
    //////////////////
    if (timer != null) timer!.cancel();

    /////////////
    /* Records */
    /////////////
    double items = (widget.itemExtent != null) && (widget.itemExtent! > 0) ? (toGlobal(offset) - (widget.controller!.offset)).abs() / widget.itemExtent! : 0;
    if (items > 10) {
      timer = Timer(Duration(milliseconds: 100), _scroll);
    } else {
      _scroll();
    }

    if (mounted) setState((){});
  }

  void onVerticalDragStart(dragEndDetails)
  {
    dragging = true;
  }

  void onVerticalDragEnd(dragEndDetails)
  {
    if (timer != null) timer!.cancel();
    dragging = false;
    _scroll();
  }

  void _scroll()
  {
    double value = toGlobal(offset);
    if (widget.controller != null) widget.controller!.jumpTo(value);
    if (widget.onchange   != null) widget.onchange!(value);
  }
}