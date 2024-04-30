// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/widgets/goback/goback.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'package:fml/event/event.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/drawer/drawer_model.dart';
import 'package:fml/helpers/helpers.dart';

class DrawerView extends StatefulWidget implements IDragListener, ViewableWidgetView {

  @override
  final DrawerModel model;
  final Widget child;
  final List<IDragListener> listeners = [];

  DrawerView(this.model, this.child) : super(key: ObjectKey(model));

  @override
  DrawerViewState createState() => DrawerViewState();

  registerDrawerListener(IDragListener listener) {
    if (!listeners.contains(listener)) listeners.add(listener);
  }

  removeDrawerListener(IDragListener listener) {
    if (listeners.contains(listener)) listeners.remove(listener);
  }

  @override
  onDragStart(DragStartDetails details, DragDirection direction) {
    for (var listener in listeners) {
      listener.onDragStart(details, direction);
    }
  }

  @override
  onDragEnd(DragEndDetails details, DragDirection direction, bool isOpen) {
    for (var listener in listeners) {
      listener.onDragEnd(details, direction, isOpen);
    }
  }

  @override
  onDragging(DragUpdateDetails details, DragDirection direction, bool isOpen) {
    for (var listener in listeners) {
      listener.onDragging(details, direction, isOpen);
    }
  }
}

class DrawerViewState extends ViewableWidgetState<DrawerView> implements IDragListener {

  // drag leeway for completing open/closes on drag end
  static int dragLeeway = 200;

  BoxView? visibleDrawer;
  BoxView? top;
  BoxView? bottom;
  BoxView? left;
  BoxView? right;
  Drawers? activeDrawer;
  double? fromTop;
  double? fromBottom;
  double? fromLeft;
  double? fromRight;
  double dragEdge = 90;
  bool animate = false;
  bool animatingClose = false;
  Function? afterAnimation;
  double? oldHeight;
  double? oldWidth;

  @override
  void initState() {
    super.initState();
    widget.registerDrawerListener(this);
  }

  @override
  didChangeDependencies() {
    widget.registerDrawerListener(this);

    // register event listeners
    EventManager.of(widget.model)
        ?.registerEventListener(EventTypes.open, onOpen);
    EventManager.of(widget.model)
        ?.registerEventListener(EventTypes.close, onClose, priority: 0);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(DrawerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.model != widget.model)) {
      // remove old event listeners
      EventManager.of(oldWidget.model)
          ?.removeEventListener(EventTypes.open, onOpen);
      EventManager.of(oldWidget.model)
          ?.removeEventListener(EventTypes.close, onClose);

      // register new event listeners
      EventManager.of(widget.model)
          ?.registerEventListener(EventTypes.open, onOpen);
      EventManager.of(widget.model)
          ?.registerEventListener(EventTypes.close, onClose, priority: 0);
    }
    widget.registerDrawerListener(this);
  }

  @override
  void dispose() {
    widget.removeDrawerListener(this);

    // remove event listeners
    EventManager.of(widget.model)?.removeEventListener(EventTypes.open, onOpen);
    EventManager.of(widget.model)
        ?.removeEventListener(EventTypes.close, onClose);

    super.dispose();
  }

  void onOpen(Event event) {
    if (event.parameters == null) return;

    if (!isNullOrEmpty(event.parameters!['url'])) {
      if (event.parameters!['url'] == widget.model.idLeft) {
        event.handled = true;
        openDrawer(Drawers.left);
      } else if (event.parameters!['url'] == widget.model.idRight) {
        event.handled = true;
        openDrawer(Drawers.right);
      } else if (event.parameters!['url'] == widget.model.idTop) {
        event.handled = true;
        openDrawer(Drawers.top);
      } else if (event.parameters!['url'] == widget.model.idBottom) {
        event.handled = true;
        openDrawer(Drawers.bottom);
      }
    }
  }

  void onClose(Event event) {
    if (event.parameters == null) return;

    if (!isNullOrEmpty(event.parameters!['window'])) {
      if (event.parameters!['window'] == widget.model.idLeft) {
        event.handled = true;
        closeDrawer(Drawers.left);
      } else if (event.parameters!['window'] == widget.model.idRight) {
        event.handled = true;
        closeDrawer(Drawers.right);
      } else if (event.parameters!['window'] == widget.model.idTop) {
        event.handled = true;
        closeDrawer(Drawers.top);
      } else if (event.parameters!['window'] == widget.model.idBottom) {
        event.handled = true;
        closeDrawer(Drawers.bottom);
      }
    }
  }

  preventPop() {
    if (activeDrawer != null) {
      closeDrawer(activeDrawer);
      return false;
    }
    return true;
  }

  finishedAnimation() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    if (animate = true) {
      Future.delayed(
          const Duration(milliseconds: 100),
          () => setState(() {
                animate = false;
                if (activeDrawer == null) {
                  fromTop = null;
                  fromBottom = null;
                  fromLeft = null;
                  fromRight = null;
                }
                if (animatingClose == true) {
                  animatingClose = false;
                  activeDrawer = null;
                }
                // widget.model.open = '';
              }));
    }
    if (afterAnimation != null) {
      afterAnimation!();
      afterAnimation = null;
    }
    // });
  }
  
  @override
  onDragStart(DragStartDetails dragStartDetails, DragDirection direction) {

    double height = widget.model.constraints.maxHeight ?? 0;
    double width = widget.model.constraints.maxWidth ?? 0;

    switch (direction) {

      // vertical drag
      case DragDirection.vertical:
        if (dragStartDetails.localPosition.dy < dragEdge &&
            activeDrawer == null &&
            widget.model.drawerExists(Drawers.top)) {
          setState(() {
            fromBottom = height;
            activeDrawer = Drawers.top;
          });
        }
        else if (dragStartDetails.localPosition.dy >
            (height - dragEdge) &&
            activeDrawer == null &&
            widget.model.drawerExists(Drawers.bottom)) {
          setState(() {
            fromTop = height;
            activeDrawer = Drawers.bottom;
          });
        }
        break;

      // horizontal drag
      case DragDirection.horizontal:
        if (dragStartDetails.localPosition.dx < dragEdge &&
            activeDrawer == null &&
            widget.model.drawerExists(Drawers.left)) {
          setState(() {
            fromRight = width;
            activeDrawer = Drawers.left;
          });
        }
        else if (dragStartDetails.localPosition.dx >
            (width - dragEdge) &&
            activeDrawer == null &&
            widget.model.drawerExists(Drawers.right)) {
          setState(() {
            fromLeft = width;
            activeDrawer = Drawers.right;
          });
        }
        break;
    }

  }

  _onDragEndTop(DragEndDetails details, DragDirection direction, bool isOpen)
  {
    double height = widget.model.constraints.maxHeight ?? 0;

    // drawer is open
    if (isOpen) {
      // should close ?
      if (details.primaryVelocity! < -300 ||
          (fromBottom! >
              (height - widget.model.sizeTop!) +
                  (dragLeeway *
                      ((widget.model.sizeTop != null)
                          ? widget.model.sizeTop! / height
                          : 1)))) {
        // yes, close
        setState(() {
          animate = true;
          fromBottom = height;
          activeDrawer = null;
        });
      } else {
        // no, keep open
        setState(() {
          animate = true;
          fromBottom = widget.model.sizeTop != null
              ? height - widget.model.sizeTop!
              : 0;
        });
      }
    }

    // drawer is closed
    else {
      // should open ?
      if (details.primaryVelocity! > 300 ||
          (height - fromBottom!) >
              (dragLeeway *
                  ((widget.model.sizeTop != null)
                      ? widget.model.sizeTop! / height
                      : 1))) {
        // yes, open
        setState(() {
          animate = true;
          fromBottom = widget.model.sizeTop != null
              ? height - widget.model.sizeTop!
              : 0;
        });
      }
      else {
        // no, keep closed
        setState(() {
          animate = true;
          fromBottom = height;
          activeDrawer = null;
        });
      }
    }
  }

  _onDragEndBottom(DragEndDetails details, DragDirection direction, bool isOpen) {

    double height = widget.model.constraints.maxHeight ?? 0;

    // drawer is open
    if (isOpen) {
      // should close ?
      if (details.primaryVelocity! > 300 ||
          (fromTop! >
              (height - widget.model.sizeBottom!) +
                  (dragLeeway *
                      ((widget.model.sizeBottom != null)
                          ? widget.model.sizeBottom! / height
                          : 1)))) {
        // yes, close
        setState(() {
          animate = true;
          fromTop = height;
          activeDrawer = null;
        });
      } else {
        // no, keep open
        setState(() {
          animate = true;
          fromTop = widget.model.sizeBottom != null
              ? height - widget.model.sizeBottom!
              : 0;
        });
      }
    }

    // drawer is closed
    else {
      // should open ?
      if (details.primaryVelocity! < -300 ||
          (height - fromTop!) >
              (dragLeeway *
                  ((widget.model.sizeBottom != null)
                      ? widget.model.sizeBottom! / height
                      : 1))) {
        // yes, open
        setState(() {
          animate = true;
          fromTop = widget.model.sizeBottom != null
              ? height - widget.model.sizeBottom!
              : 0;
        });
      } else {
        // no, keep closed
        setState(() {
          animate = true;
          fromTop = height;
          activeDrawer = null;
        });
      }
    }
  }

  _onDragEndLeft(DragEndDetails details, DragDirection direction, bool isOpen) {

    double width = widget.model.constraints.maxWidth ?? 0;

    // drawer is open
    if (isOpen) {
      // should close ?
      if (details.primaryVelocity! < -300 ||
          (fromRight! >
              (width - widget.model.sizeLeft!) +
                  (dragLeeway *
                      ((widget.model.sizeLeft != null)
                          ? widget.model.sizeLeft! / width
                          : 1)))) {
        // yes, close
        setState(() {
          animate = true;
          fromRight = width;
          activeDrawer = null;
        });
      } else {
        // no, keep open
        setState(() {
          animate = true;
          fromRight = widget.model.sizeLeft != null
              ? width - widget.model.sizeLeft!
              : 0;
        });
      }
    }

    // drawer is closed
    else {
      // should open ?
      if (details.primaryVelocity! > 300 ||
          (width - fromRight!) >
              (dragLeeway *
                  ((widget.model.sizeLeft != null)
                      ? widget.model.sizeLeft! / width
                      : 1))) {
        // yes, open
        setState(() {
          animate = true;
          fromRight = widget.model.sizeLeft != null
              ? width - widget.model.sizeLeft!
              : 0;
        });
      } else {
        // no, keep closed
        setState(() {
          animate = true;
          fromRight = width;
          activeDrawer = null;
        });
      }
    }
  }

  _onDragEndRight(DragEndDetails details, DragDirection direction, bool isOpen) {

    double width = widget.model.constraints.maxWidth ?? 0;

    // drawer is open
    if (isOpen) {
      // should close ?
      if (details.primaryVelocity! > 300 ||
          (fromLeft! >
              (width - widget.model.sizeRight!) +
                  (dragLeeway *
                      ((widget.model.sizeRight != null)
                          ? widget.model.sizeRight! / width
                          : 1)))) {
        // yes, close
        setState(() {
          animate = true;
          fromLeft = width;
          activeDrawer = null;
        });
      } else {
        // no, keep open
        setState(() {
          animate = true;
          fromLeft = widget.model.sizeRight != null
              ? width - widget.model.sizeRight!
              : 0;
        });
      }
    }

    // drawer is closed
    else {
      // should open ?
      if (details.primaryVelocity! < -300 ||
          (width - fromLeft!) >
              (dragLeeway *
                  ((widget.model.sizeRight != null)
                      ? widget.model.sizeRight! / width
                      : 1))) {
        // yes, open
        setState(() {
          animate = true;
          fromLeft = widget.model.sizeRight != null
              ? width - widget.model.sizeRight!
              : 0;
        });
      } else {
        // no, keep closed
        setState(() {
          animate = true;
          fromLeft = width;
          activeDrawer = null;
        });
      }
    }
  }

  @override
  onDragEnd(DragEndDetails details, DragDirection direction, bool isOpen) {

    if (animate) return;

    switch (direction) {

      case DragDirection.vertical:
        switch (activeDrawer) {
          case Drawers.top:
            _onDragEndTop(details, direction, isOpen);
            break;
          case Drawers.bottom:
            _onDragEndBottom(details, direction, isOpen);
            break;
          default:
            break;
        }
        break;

      case DragDirection.horizontal:
        switch (activeDrawer) {
          case Drawers.left:
            _onDragEndLeft(details, direction, isOpen);
            break;
          case Drawers.right:
            _onDragEndRight(details, direction, isOpen);
            break;
          default:
            break;
        }
        break;
    }
  }

  _dragTopDrawer(DragUpdateDetails details, DragDirection direction, bool isOpen) {

    double height = widget.model.constraints.maxHeight ?? 0;
    var animateEdge = dragEdge * 0.5;

    // Animate top drawer closed when near edge
    if (details.localPosition.dy < animateEdge &&
        !isOpen &&
        details.primaryDelta! > 0) {
      setState(() {
        animate = true;
        animatingClose = true;
        fromBottom = height;
      });
    }

    // Animate top drawer open when near edge
    else if ((height - details.localPosition.dy) <
        (widget.model.sizeTop != null
            ? height - widget.model.sizeTop! - animateEdge
            : animateEdge) &&
        isOpen) {
      setState(() {
        animate = true;
        fromBottom = widget.model.sizeTop != null
            ? height - widget.model.sizeTop!
            : 0;
      });
    }

    // Drag top drawer, no animation
    else {
      // Determine if we are opening or closing
      var calcFromBottom = isOpen
          ? height - details.localPosition.dy
          : fromBottom! - details.primaryDelta!;
      // Prevent dragging past open/close range
      if (widget.model.sizeTop != null &&
          calcFromBottom < height - widget.model.sizeTop!) {
        calcFromBottom = height - widget.model.sizeTop!;
      } else if (calcFromBottom.isNegative) {
        calcFromBottom = 0;
      } else if (calcFromBottom > height) {
        calcFromBottom = height;
      }
      setState(() {
        fromBottom = calcFromBottom;
      });
    }
  }

  _dragBottomDrawer(DragUpdateDetails details, DragDirection direction, bool isOpen) {

    double height = widget.model.constraints.maxHeight ?? 0;
    var animateEdge = dragEdge * 0.5;

    // Animate bottom drawer closed when near edge
    if ((height - details.localPosition.dy) <
        animateEdge &&
        !isOpen &&
        details.primaryDelta!.isNegative) {
      setState(() {
        animate = true;
        animatingClose = true;
        fromTop = height;
      });
    }

    // Animate bottom drawer open when near edge
    else if (details.localPosition.dy <
        (widget.model.sizeBottom != null
            ? height - widget.model.sizeBottom! - animateEdge
            : animateEdge) &&
        isOpen) {
      setState(() {
        animate = true;
        fromTop = widget.model.sizeBottom != null
            ? height - widget.model.sizeBottom!
            : 0;
      });
    }

    // Drag bottom drawer, no animation
    else {
      // Determine if we are opening or closing
      var calcFromTop = isOpen
          ? details.localPosition.dy
          : fromTop! + details.primaryDelta!;
      // Prevent dragging past open/close range
      if (widget.model.sizeBottom != null &&
          calcFromTop < height - widget.model.sizeBottom!) {
        calcFromTop = height - widget.model.sizeBottom!;
      } else if (calcFromTop.isNegative) {
        calcFromTop = 0;
      } else if (calcFromTop > height) {
        calcFromTop = height;
      }
      setState(() {
        fromTop = calcFromTop;
      });
    }
  }

  _dragLeftDrawer(DragUpdateDetails details, DragDirection direction, bool isOpen) {

    double width = widget.model.constraints.maxWidth ?? 0;
    var animateEdge = dragEdge * 0.5;

    // Animate left drawer closed when near edge
    if (details.localPosition.dx < animateEdge &&
        !isOpen &&
        details.primaryDelta!.isNegative) {
      setState(() {
        animate = true;
        animatingClose = true;
        fromRight = width;
      });
    }

    // Animate left drawer open when near edge
    else if ((width - details.localPosition.dx) <
        (widget.model.sizeLeft != null
            ? width - widget.model.sizeLeft! - animateEdge
            : animateEdge) &&
        isOpen) {
      setState(() {
        animate = true;
        fromRight = widget.model.sizeLeft != null
            ? width - widget.model.sizeLeft!
            : 0;
      });
    }

    // Drag left drawer, no animation
    else {
      // Determine if we are opening or closing
      var calcFromRight = isOpen
          ? width - details.localPosition.dx
          : fromRight! - details.primaryDelta!;

      // Prevent dragging past open/close range
      if (widget.model.sizeLeft != null &&
          calcFromRight < width - widget.model.sizeLeft!) {
        calcFromRight = width - widget.model.sizeLeft!;
      } else if (calcFromRight.isNegative) {
        calcFromRight = 0;
      } else if (calcFromRight > width) {
        calcFromRight = width;
      }
      setState(() {
        fromRight = calcFromRight;
      });
    }
  }

  _dragRightDrawer(DragUpdateDetails details, DragDirection direction, bool isOpen) {

    double width = widget.model.constraints.maxWidth ?? 0;
    var animateEdge = dragEdge * 0.5;

    // Animate right drawer closed when near edge
    if ((width - details.localPosition.dx) <
        animateEdge &&
        !isOpen &&
        details.primaryDelta! > 0) {
      setState(() {
        animate = true;
        animatingClose = true;
        fromLeft = width;
      });
    }

    // Animate right drawer open when near edge
    else if (details.localPosition.dx <
        (widget.model.sizeRight != null
            ? width - widget.model.sizeRight! - animateEdge
            : animateEdge) &&
        isOpen) {
      setState(() {
        animate = true;
        fromLeft = widget.model.sizeRight != null
            ? width - widget.model.sizeRight!
            : 0;
      });
    }

    // Drag right drawer, no animation
    else {
      // Determine if we are opening or closing
      var calcFromLeft = isOpen
          ? details.localPosition.dx
          : fromLeft! + details.primaryDelta!;
      // Prevent dragging past open/close range
      if (widget.model.sizeRight != null &&
          calcFromLeft < width - widget.model.sizeRight!) {
        calcFromLeft = width - widget.model.sizeRight!;
      } else if (calcFromLeft.isNegative) {
        calcFromLeft = 0;
      } else if (calcFromLeft > width) {
        calcFromLeft = width;
      }
      setState(() {
        fromLeft = calcFromLeft;
      });
    }
  }

  @override
  onDragging(DragUpdateDetails details, DragDirection direction, bool isOpen) {

    if (animate) {
     setState(() {
       animate = false;
     });
     return;
    }

    // top drawer
    if (activeDrawer == Drawers.top && direction == DragDirection.vertical) {
      _dragTopDrawer(details, direction, isOpen);
      return;
    }

    // bottom drawer
    if (activeDrawer == Drawers.bottom && direction == DragDirection.vertical) {
      _dragBottomDrawer(details, direction, isOpen);
      return;
    }

    // left drawer
    if (activeDrawer == Drawers.left && direction == DragDirection.horizontal) {
      _dragLeftDrawer(details, direction, isOpen);
      return;
    }

    // right drawer
    if (activeDrawer == Drawers.right && direction == DragDirection.horizontal) {
      _dragRightDrawer(details, direction, isOpen);
      return;
    }
  }

  openDrawer(Drawers drawer) {

    if (drawer == Drawers.top && widget.model.drawerExists(Drawers.top)) {
      if (activeDrawer != null && activeDrawer != Drawers.top) {
        closeDrawer(activeDrawer, cb: openTop);
      } else {
        openTop();
      }
    } else if (drawer == Drawers.bottom && widget.model.drawerExists(Drawers.bottom)) {
      if (activeDrawer != null && activeDrawer != Drawers.bottom) {
        closeDrawer(activeDrawer, cb: openBottom);
      } else {
        openBottom();
      }
    } else if (drawer == Drawers.left && widget.model.drawerExists(Drawers.left)) {
      if (activeDrawer != null && activeDrawer != Drawers.left) {
        closeDrawer(activeDrawer, cb: openLeft);
      } else {
        openLeft();
      }
    } else if (drawer == Drawers.right && widget.model.drawerExists(Drawers.right)) {
      if (activeDrawer != null && activeDrawer != Drawers.right) {
        closeDrawer(activeDrawer, cb: openRight);
      } else {
        openRight();
      }
    }
  }

  void openTop() {

    double height = widget.model.constraints.maxHeight ?? 0;
    
    setState(() {
      animate = true;
      fromBottom = widget.model.sizeTop != null
          ? height - widget.model.sizeTop!
          : 0;
      activeDrawer = Drawers.top;
    });
  }

  void openBottom() {
    
    double height = widget.model.constraints.maxHeight ?? 0;
    
    setState(() {
      animate = true;
      fromTop = widget.model.sizeBottom != null
          ? height - widget.model.sizeBottom!
          : 0;
      activeDrawer = Drawers.bottom;
    });
  }

  void openLeft() {
    
    double width = widget.model.constraints.maxWidth ?? 0;

    setState(() {
      animate = true;
      fromRight = widget.model.sizeLeft != null
          ? width - widget.model.sizeLeft!
          : 0;
      activeDrawer = Drawers.left;
    });
  }

  void openRight() {
    
    double width = widget.model.constraints.maxWidth ?? 0;

    setState(() {
      animate = true;
      // fromTop = fromBottom = 0;
      // fromRight = null;
      // fromRight = screenWidth - fromLeft;
      fromLeft = widget.model.sizeRight != null
          ? width - widget.model.sizeRight!
          : 0;
      activeDrawer = Drawers.right;
    });
  }

  closeDrawer(Drawers? drawer, {cb}) {
    
    double height = widget.model.constraints.maxHeight ?? 0;
    double width = widget.model.constraints.maxWidth ?? 0;

    
    if (drawer == Drawers.top) {
      afterAnimation = cb;
      setState(() {
        animate = true;
        animatingClose = true;
        fromBottom = height;
      });
    } else if (drawer == Drawers.bottom) {
      afterAnimation = cb;
      setState(() {
        animate = true;
        animatingClose = true;
        fromTop = height;
      });
    } else if (drawer == Drawers.left) {
      afterAnimation = cb;
      setState(() {
        animate = true;
        animatingClose = true;
        fromRight = width;
      });
    } else if (drawer == Drawers.right) {
      afterAnimation = cb;
      setState(() {
        animate = true;
        animatingClose = true;
        fromLeft = width;
      });
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints) {
    
    // get constraints
    double height = constraints.maxHeight.isFinite ? constraints.maxHeight : MediaQuery.of(context).size.height;
    double width  = constraints.maxWidth.isFinite  ? constraints.maxWidth  : MediaQuery.of(context).size.width;

    // set constraints
    widget.model.maxHeight = height;
    widget.model.maxWidth = width;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    if (activeDrawer == null) {
      fromTop = height;
      fromBottom = height;
      fromLeft = width;
      fromRight = width;
    }

    top = widget.model.top != null ? BoxView(widget.model.top!, (_,__) => widget.model.top!.inflate()) : null;
    bottom = widget.model.bottom != null ? BoxView(widget.model.bottom!, (_,__) => widget.model.bottom!.inflate()) : null;
    left = widget.model.left != null ? BoxView(widget.model.left!, (_,__) => widget.model.left!.inflate()) : null;
    right = widget.model.right != null ? BoxView(widget.model.right!, (_,__) => widget.model.left!.inflate()) : null;

    double screenHeight = height;
    double screenWidth = width;

    // preset the original dimensions
    oldHeight ??= screenHeight;
    oldWidth ??= screenWidth;

    // check the dimensions for changes, if it has changed, close the any open drawer
    if (screenHeight != oldHeight) {
      oldHeight = screenHeight;
      if (activeDrawer != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          closeDrawer(activeDrawer);
        });
      }
    } else if (screenWidth != oldWidth) {
      oldWidth = screenWidth;
      if (activeDrawer != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          closeDrawer(activeDrawer);
        });
      }
    }

    // build the child views
    List<Widget> children = widget.model.inflate();
    if (children.isEmpty) children.add(Container());

    BorderRadius drawerHandle = BorderRadius.zero;
    if (activeDrawer == Drawers.top) {
      visibleDrawer = top;
      drawerHandle = widget.model.rounded == false
          ? BorderRadius.zero
          : BorderRadius.only(
              topLeft: const Radius.elliptical(0, 0),
              topRight: const Radius.elliptical(0, 0),
              bottomLeft: Radius.elliptical(
                  screenWidth * .5,
                  (screenHeight *
                          ((widget.model.sizeTop != null)
                              ? widget.model.sizeBottom! / screenHeight
                              : 1)) *
                      0.05),
              bottomRight: Radius.elliptical(
                  screenWidth * .5,
                  (screenHeight *
                          ((widget.model.sizeBottom != null)
                              ? widget.model.sizeTop! / screenHeight
                              : 1)) *
                      0.05));
    } else if (activeDrawer == Drawers.bottom) {
      visibleDrawer = bottom;
      drawerHandle = widget.model.rounded == false
          ? BorderRadius.zero
          : BorderRadius.only(
              topLeft: Radius.elliptical(
                  screenWidth * .5,
                  (screenHeight *
                          ((widget.model.sizeBottom != null)
                              ? widget.model.sizeBottom! / screenHeight
                              : 1)) *
                      0.05),
              topRight: Radius.elliptical(
                  screenWidth * .5,
                  (screenHeight *
                          ((widget.model.sizeBottom != null)
                              ? widget.model.sizeBottom! / screenHeight
                              : 1)) *
                      0.05),
              bottomLeft: const Radius.elliptical(0, 0),
              bottomRight: const Radius.elliptical(0, 0));
    } else if (activeDrawer == Drawers.left) {
      visibleDrawer = left;
      drawerHandle = widget.model.rounded == false
          ? BorderRadius.zero
          : BorderRadius.only(
              topLeft: const Radius.elliptical(0, 0),
              topRight: Radius.elliptical(
                  screenHeight * 0.05,
                  (screenWidth *
                          ((widget.model.sizeLeft != null)
                              ? widget.model.sizeLeft! / screenHeight
                              : 1)) *
                      .5),
              bottomLeft: const Radius.elliptical(0, 0),
              bottomRight: Radius.elliptical(
                  screenHeight * 0.05,
                  (screenWidth *
                          ((widget.model.sizeLeft != null)
                              ? widget.model.sizeLeft! / screenHeight
                              : 1)) *
                      .5));
    } else if (activeDrawer == Drawers.right) {
      visibleDrawer = right;
      drawerHandle = widget.model.rounded == false
          ? BorderRadius.zero
          : BorderRadius.only(
              topLeft: Radius.elliptical(
                  screenHeight * 0.05,
                  (screenWidth *
                          ((widget.model.sizeRight != null)
                              ? widget.model.sizeRight! / screenHeight
                              : 1)) *
                      .5),
              topRight: const Radius.elliptical(0, 0),
              bottomLeft: Radius.elliptical(
                  screenHeight * 0.05,
                  (screenWidth *
                          ((widget.model.sizeRight != null)
                              ? widget.model.sizeRight! / screenHeight
                              : 1)) *
                      .5),
              bottomRight: const Radius.elliptical(0, 0));
    }

    double? containerSize(Drawers? drawer) {
      if (drawer == Drawers.left) {
        return widget.model.sizeLeft ?? screenWidth;
      } else if (drawer == Drawers.right) {
        return widget.model.sizeRight ?? screenWidth;
      } else if (drawer == Drawers.top) {
        return widget.model.sizeTop ?? screenHeight;
      } else if (drawer == Drawers.bottom) {
        return widget.model.sizeBottom ?? screenHeight;
      } else {
        return screenWidth as bool? ?? 300 < screenHeight
            ? screenHeight
            : screenWidth;
      }
    }

    AnimatedPositioned leftDrawer = AnimatedPositioned(
      curve: Curves.easeOutCubic,
      duration: Duration(milliseconds: animate ? 400 : 0),
      onEnd: () => finishedAnimation(),
      right: fromRight ?? screenWidth,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (dragUpdateDetails) =>
            onDragging(dragUpdateDetails, DragDirection.horizontal, false),
        onHorizontalDragEnd: (dragEndDetails) =>
            onDragEnd(dragEndDetails, DragDirection.horizontal, true),
        child: ClipRRect(
          borderRadius: drawerHandle,
          child: SizedBox(
              width: ((activeDrawer == Drawers.left || activeDrawer == Drawers.right)
                  ? containerSize(activeDrawer)
                  : screenWidth),
              height: ((activeDrawer == Drawers.top || activeDrawer == Drawers.bottom)
                  ? containerSize(activeDrawer)
                  : screenHeight),
              child:
                  activeDrawer == Drawers.left ? left ?? Container() : const Offstage()),
        ),
      ),
    );

    AnimatedPositioned rightDrawer = AnimatedPositioned(
      curve: Curves.easeOutCubic,
      duration: Duration(milliseconds: animate ? 400 : 0),
      onEnd: () => finishedAnimation(),
      left: fromLeft ?? screenWidth,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (dragUpdateDetails) =>
            onDragging(dragUpdateDetails, DragDirection.horizontal, false),
        onHorizontalDragEnd: (dragEndDetails) =>
            onDragEnd(dragEndDetails, DragDirection.horizontal, true),
        child: ClipRRect(
          borderRadius: drawerHandle,
          child: SizedBox(
              width: ((activeDrawer == Drawers.left || activeDrawer == Drawers.right)
                  ? containerSize(activeDrawer)
                  : screenWidth),
              height: ((activeDrawer == Drawers.top || activeDrawer == Drawers.bottom)
                  ? containerSize(activeDrawer)
                  : screenHeight),
              child: activeDrawer == Drawers.right
                  ? right ?? Container()
                  : const Offstage()),
        ),
      ),
    );

    AnimatedPositioned topDrawer = AnimatedPositioned(
      curve: Curves.easeOutCubic,
      duration: Duration(milliseconds: animate ? 400 : 0),
      onEnd: () => finishedAnimation(),
      bottom: fromBottom ?? screenHeight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (dragUpdateDetails) =>
            onDragging(dragUpdateDetails, DragDirection.vertical, false),
        onVerticalDragEnd: (dragEndDetails) =>
            onDragEnd(dragEndDetails, DragDirection.vertical, true),
        child: ClipRRect(
          borderRadius: drawerHandle,
          child: SizedBox(
              width: ((activeDrawer == Drawers.left || activeDrawer == Drawers.right)
                  ? containerSize(activeDrawer)
                  : screenWidth),
              height: ((activeDrawer == Drawers.top || activeDrawer == Drawers.bottom)
                  ? containerSize(activeDrawer)
                  : screenHeight),
              child:
                  activeDrawer == Drawers.top ? top ?? Container() : const Offstage()),
        ),
      ),
    );

    AnimatedPositioned bottomDrawer = AnimatedPositioned(
      curve: Curves.easeOutCubic,
      duration: Duration(milliseconds: animate ? 400 : 0),
      onEnd: () => finishedAnimation(),
      top: fromTop ?? screenHeight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (dragUpdateDetails) =>
            onDragging(dragUpdateDetails, DragDirection.vertical, false),
        onVerticalDragEnd: (dragEndDetails) =>
            onDragEnd(dragEndDetails, DragDirection.vertical, true),
        child: ClipRRect(
          borderRadius: drawerHandle,
          child: SizedBox(
              width: ((activeDrawer == Drawers.left || activeDrawer == Drawers.right)
                  ? containerSize(activeDrawer)
                  : screenWidth),
              height: ((activeDrawer == Drawers.top || activeDrawer == Drawers.bottom)
                  ? containerSize(activeDrawer)
                  : screenHeight),
              child: activeDrawer == Drawers.bottom
                  ? bottom ?? Container()
                  : const Offstage()),
        ),
      ),
    );

    Widget leftHandle = Container();
    Widget rightHandle = Container();
    Widget topHandle = Container();
    Widget bottomHandle = Container();

    if (widget.model.handleLeft == true) {
      leftHandle = AnimatedPositioned(
          curve: Curves.easeOutCubic,
          duration: Duration(milliseconds: animate ? 500 : 0),
          right: (fromRight ?? screenWidth) - 10,
          child: SizedBox(
              height: screenHeight,
              child: Center(
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                      child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                              width: 4,
                              height: 50,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant))))));
    }

    if (widget.model.handleRight == true) {
      rightHandle = AnimatedPositioned(
          curve: Curves.easeOutCubic,
          duration: Duration(milliseconds: animate ? 500 : 0),
          left: (fromLeft ?? screenWidth) - 10,
          child: SizedBox(
              height: screenHeight,
              child: Center(
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                      child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                              width: 4,
                              height: 50,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant))))));
    }

    if (widget.model.handleTop == true) {
      topHandle = AnimatedPositioned(
          curve: Curves.easeOutCubic,
          duration: Duration(milliseconds: animate ? 500 : 0),
          bottom: (fromBottom ?? screenHeight) - 10,
          child: SizedBox(
              width: screenWidth,
              child: Center(
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                      child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                              width: 50,
                              height: 4,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant))))));
    }

    if (widget.model.handleBottom == true) {
      bottomHandle = AnimatedPositioned(
          curve: Curves.easeOutCubic,
          duration: Duration(milliseconds: animate ? 500 : 0),
          top: (fromTop ?? screenHeight) - 10,
          child: SizedBox(
              width: screenWidth,
              child: Center(
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                      child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                              width: 50,
                              height: 4,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant))))));
    }

   var drawer = activeDrawer != null
       ? GestureDetector(onTap: () => closeDrawer(activeDrawer))
       : Container();

    Widget view = Stack(children: [
      widget.child,
      drawer,
      leftHandle,
      rightHandle,
      topHandle,
      bottomHandle,
      leftDrawer,
      rightDrawer,
      topDrawer,
      bottomDrawer,
    ]); // view;

    // apply user defined constraints
    view = applyConstraints(view, widget.model.constraints);

    // apply visual transforms
    view = applyTransforms(view);

    view = GoBack(canGoBack: () async => preventPop(), child: view);

    return view;
  }
}

abstract class IDragListener {
  onDragStart(DragStartDetails details, DragDirection direction);
  onDragEnd(DragEndDetails details, DragDirection direction, bool isOpen);
  onDragging(DragUpdateDetails details, DragDirection direction, bool isOpen);
}
