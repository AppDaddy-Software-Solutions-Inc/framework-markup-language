// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/event/manager.dart';

import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_model.dart'    ;
import 'package:fml/event/event.dart'             ;
import 'package:fml/widgets/framework/framework_model.dart' ;
import 'package:fml/widgets/box/box_view.dart' as BOX;
import 'package:fml/widgets/drawer/drawer_model.dart' as DRAWER;
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class DrawerView extends StatefulWidget implements IDragListener, IWidgetView
{
  final List<Widget> children = [];
  final DRAWER.DrawerModel model;
  final Widget stackChildren;
  final List<IDragListener> listeners = [];

  DrawerView(this.model, this.stackChildren) : super(key: ObjectKey(model));

  @override
  DrawerViewState createState() => DrawerViewState();

  registerDrawerListener(IDragListener listener)
  {
    if (!listeners.contains(listener)) listeners.add(listener);
  }

  removeDrawerListener(IDragListener listener)
  {
    if (listeners.contains(listener)) listeners.remove(listener);
  }

  onDragOpen(DragStartDetails details, String dir)
  {
    listeners.forEach((listener) => listener.onDragOpen(details, dir));
  }

  onDragEnd(DragEndDetails details, String dir, bool isOpen)
  {
    listeners.forEach((listener) => listener.onDragEnd(details, dir, isOpen));
  }

  onDragSheet(DragUpdateDetails details, String dir, bool isOpen)
  {
    listeners.forEach((listener) => listener.onDragSheet(details, dir, isOpen));
  }
}

class DrawerViewState extends WidgetState<DrawerView> implements IDragListener
{
  BOX.BoxView? visibleDrawer;
  BOX.BoxView? top;
  BOX.BoxView? bottom;
  BOX.BoxView? left;
  BOX.BoxView? right;
  String? openSheet;
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
  void initState()
  {
    super.initState();
    widget.registerDrawerListener(this);
  }

  @override
  didChangeDependencies()
  {
    widget.registerDrawerListener(this);

    // register event listeners
    EventManager.of(widget.model)?.registerEventListener(EventTypes.open, onOpen);
    EventManager.of(widget.model)?.registerEventListener(EventTypes.close, onClose, priority: 0);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(DrawerView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.model != widget.model))
    {
      // remove old event listeners
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.open, onOpen);
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.close, onClose);

      // register new event listeners
      EventManager.of(widget.model)?.registerEventListener(EventTypes.open, onOpen);
      EventManager.of(widget.model)?.registerEventListener(EventTypes.close, onClose, priority: 0);
    }
    widget.registerDrawerListener(this);
  }

  @override
  void dispose()
  {
    widget.removeDrawerListener(this);

    // remove event listeners
    EventManager.of(widget.model)?.removeEventListener(EventTypes.open, onOpen);
    EventManager.of(widget.model)?.removeEventListener(EventTypes.close, onClose);

    super.dispose();
  }

  void onOpen(Event event)
  {
    if (event.parameters == null) return;

    if (!S.isNullOrEmpty(event.parameters!['url']))
    {
      if (event.parameters!['url'] == widget.model.idLeft) {
        event.handled = true;
        openDrawer('left');
      }
      else if (event.parameters!['url'] == widget.model.idRight) {
        event.handled = true;
        openDrawer('right');
      }
      else if (event.parameters!['url'] == widget.model.idTop) {
        event.handled = true;
        openDrawer('top');
      }
      else if (event.parameters!['url'] == widget.model.idBottom) {
        event.handled = true;
        openDrawer('bottom');
      }
    }
  }

  void onClose(Event event)
  {
    if (event.parameters == null) return;

    if (!S.isNullOrEmpty(event.parameters!['window']))
    {
      if (event.parameters!['window'] == widget.model.idLeft) {
        event.handled = true;
        closeDrawer('left');
      }
      else if (event.parameters!['window'] == widget.model.idRight) {
        event.handled = true;
        closeDrawer('right');
      }
      else if (event.parameters!['window'] == widget.model.idTop) {
        event.handled = true;
        closeDrawer('top');
      }
      else if (event.parameters!['window'] == widget.model.idBottom) {
        event.handled = true;
        closeDrawer('bottom');
      }
    }
  }
  /// Callback function for when the model changes, used to force a rebuild with setState()
  onModelChange(WidgetModel model,{String? property, dynamic value})
  {
    if (this.mounted) setState((){});
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // save system constraints
    widget.model.setSystemConstraints(constraints);

    var con = widget.model.getBlendedConstraints();
    double h = con.maxHeight ?? MediaQuery.of(context).size.height;
    double w = con.maxWidth  ?? MediaQuery.of(context).size.width;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    if (openSheet == null) {
      fromTop = h;
      fromBottom = h;
      fromLeft = w;
      fromRight = w;
    }

    top     = widget.model.top    != null ? BOX.BoxView(widget.model.top!)    : null;
    bottom  = widget.model.bottom != null ? BOX.BoxView(widget.model.bottom!) : null;
    left    = widget.model.left   != null ? BOX.BoxView(widget.model.left!)   : null;
    right   = widget.model.right  != null ? BOX.BoxView(widget.model.right!)  : null;

    double screenHeight = h;
    double screenWidth = w;
    // preset the original dimensions
    if (oldHeight == null)
      oldHeight = screenHeight;
    if (oldWidth == null)
      oldWidth = screenWidth;
    // check the dimensions for changes, if it has changed, close the any open drawer
    if (screenHeight != oldHeight) {
      oldHeight = screenHeight;
      if (openSheet != null)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          closeDrawer(openSheet);
        });
    }
    else if (screenWidth != oldWidth) {
      oldWidth = screenWidth;
      if (openSheet != null)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          closeDrawer(openSheet);
        });
    }

    ///////////
    /* Child */
    ///////////
    List<Widget> children = [];
    if (widget.model.children != null)
    widget.model.children!.forEach((model)
    {
      if (model is IViewableWidget) {
        children.add((model as IViewableWidget).getView());
      }
    });

    if (children.isEmpty) children.add(Container());

    BorderRadius drawerHandle = BorderRadius.zero;
    if (openSheet == 'top') {
      visibleDrawer = top;
      drawerHandle = widget.model.rounded == false
          ? BorderRadius.zero
          : BorderRadius.only(
          topLeft: Radius.elliptical(0, 0),
          topRight: Radius.elliptical(0, 0),
          bottomLeft: Radius.elliptical(screenWidth*.5, (screenHeight*((widget.model.sizeTop != null) ? widget.model.sizeBottom! / screenHeight : 1))*0.05),
          bottomRight: Radius.elliptical(screenWidth*.5, (screenHeight*((widget.model.sizeBottom != null) ? widget.model.sizeTop! / screenHeight : 1))*0.05));
    }
    else if (openSheet == 'bottom') {
      visibleDrawer = bottom;
      drawerHandle = widget.model.rounded == false
          ? BorderRadius.zero
          : BorderRadius.only(
          topLeft: Radius.elliptical(screenWidth*.5, (screenHeight*((widget.model.sizeBottom != null) ? widget.model.sizeBottom! / screenHeight : 1))*0.05),
          topRight: Radius.elliptical(screenWidth*.5, (screenHeight*((widget.model.sizeBottom != null) ? widget.model.sizeBottom! / screenHeight : 1))*0.05),
          bottomLeft: Radius.elliptical(0, 0),
          bottomRight: Radius.elliptical(0, 0));
    }
    else if (openSheet == 'left') {
      visibleDrawer = left;
      drawerHandle = widget.model.rounded == false
          ? BorderRadius.zero
          : BorderRadius.only(
          topLeft: Radius.elliptical(0, 0),
          topRight: Radius.elliptical(screenHeight*0.05, (screenWidth*((widget.model.sizeLeft != null) ? widget.model.sizeLeft! / screenHeight : 1))*.5),
          bottomLeft: Radius.elliptical(0, 0),
          bottomRight: Radius.elliptical(screenHeight*0.05, (screenWidth*((widget.model.sizeLeft != null) ? widget.model.sizeLeft! / screenHeight : 1))*.5));
    }
    else if (openSheet == 'right') {
      visibleDrawer = right;
      drawerHandle = widget.model.rounded == false
          ? BorderRadius.zero
          : BorderRadius.only(
          topLeft: Radius.elliptical(screenHeight*0.05, (screenWidth*((widget.model.sizeRight != null) ? widget.model.sizeRight! / screenHeight : 1))*.5),
          topRight: Radius.elliptical(0, 0),
          bottomLeft: Radius.elliptical(screenHeight*0.05, (screenWidth*((widget.model.sizeRight != null) ? widget.model.sizeRight! / screenHeight : 1))*.5),
          bottomRight: Radius.elliptical(0, 0));
    }

    double? containerSize(String? sheet) {
      if (sheet == 'left')
        return widget.model.sizeLeft != null ? widget.model.sizeLeft : screenWidth;
      else if (sheet == 'right')
        return widget.model.sizeRight != null ? widget.model.sizeRight : screenWidth;
      else if (sheet == 'top')
        return widget.model.sizeTop != null ? widget.model.sizeTop : screenHeight;
      else if (sheet == 'bottom')
        return widget.model.sizeBottom != null ? widget.model.sizeBottom : screenHeight;
      else
        return screenWidth as bool? ?? 300 < screenHeight ? screenHeight : screenWidth;
    }

    AnimatedPositioned leftDrawer = AnimatedPositioned(curve: Curves.easeOutCubic, duration: Duration(milliseconds: animate == true ? 400 : 0), onEnd: () => finishedAnimation(), right: fromRight ?? screenWidth,
      child: GestureDetector(behavior: HitTestBehavior.opaque, onHorizontalDragUpdate: (dragUpdateDetails) => onDragSheet(dragUpdateDetails, 'horizontal', false), onHorizontalDragEnd: (dragEndDetails) => onDragEnd(dragEndDetails, 'horizontal', true),
        child: ClipRRect(borderRadius: drawerHandle,
          child: Container(width: ((openSheet == 'left' || openSheet == 'right') ? containerSize(openSheet) : screenWidth), height: ((openSheet == 'top' || openSheet == 'bottom') ? containerSize(openSheet) : screenHeight),
            child: openSheet == 'left' ? left ?? Container() : Offstage()
          ),),),);

    AnimatedPositioned rightDrawer = AnimatedPositioned(curve: Curves.easeOutCubic, duration: Duration(milliseconds: animate == true ? 400 : 0), onEnd: () => finishedAnimation(), left: fromLeft ?? screenWidth,
      child: GestureDetector(behavior: HitTestBehavior.opaque, onHorizontalDragUpdate: (dragUpdateDetails) => onDragSheet(dragUpdateDetails, 'horizontal', false), onHorizontalDragEnd: (dragEndDetails) => onDragEnd(dragEndDetails, 'horizontal', true),
        child: ClipRRect(borderRadius: drawerHandle,
          child: Container(width: ((openSheet == 'left' || openSheet == 'right') ? containerSize(openSheet) : screenWidth), height: ((openSheet == 'top' || openSheet == 'bottom') ? containerSize(openSheet) : screenHeight),
              child: openSheet == 'right' ? right ?? Container() : Offstage()
          ),),),);

    AnimatedPositioned topDrawer = AnimatedPositioned(curve: Curves.easeOutCubic, duration: Duration(milliseconds: animate == true ? 400 : 0), onEnd: () => finishedAnimation(), bottom: fromBottom ?? screenHeight,
      child: GestureDetector(behavior: HitTestBehavior.opaque, onVerticalDragUpdate: (dragUpdateDetails) => onDragSheet(dragUpdateDetails, 'vertical', false), onVerticalDragEnd: (dragEndDetails) => onDragEnd(dragEndDetails, 'vertical', true),
        child: ClipRRect(borderRadius: drawerHandle,
          child: Container(width: ((openSheet == 'left' || openSheet == 'right') ? containerSize(openSheet) : screenWidth), height: ((openSheet == 'top' || openSheet == 'bottom') ? containerSize(openSheet) : screenHeight),
              child: openSheet == 'top' ? top ?? Container() : Offstage()
          ),),),);

    AnimatedPositioned bottomDrawer = AnimatedPositioned(curve: Curves.easeOutCubic, duration: Duration(milliseconds: animate == true ? 400 : 0), onEnd: () => finishedAnimation(), top: fromTop ?? screenHeight,
      child: GestureDetector(behavior: HitTestBehavior.opaque, onVerticalDragUpdate: (dragUpdateDetails) => onDragSheet(dragUpdateDetails, 'vertical', false), onVerticalDragEnd: (dragEndDetails) => onDragEnd(dragEndDetails, 'vertical', true),
        child: ClipRRect(borderRadius: drawerHandle,
          child: Container(width: ((openSheet == 'left' || openSheet == 'right') ? containerSize(openSheet) : screenWidth), height: ((openSheet == 'top' || openSheet == 'bottom') ? containerSize(openSheet) : screenHeight),
              child: openSheet == 'bottom' ? bottom ?? Container() : Offstage()
          ),),),);

    Widget leftHandle = Container();
    Widget rightHandle = Container();
    Widget topHandle = Container();
    Widget bottomHandle = Container();

    if (widget.model.handleLeft == true)
      leftHandle = AnimatedPositioned(
          curve: Curves.easeOutCubic, duration: Duration(milliseconds: animate == true ? 500 : 0),
          right: (fromRight ?? screenWidth) - 10,
          child: Container(height: screenHeight, child: Center(child: ClipRRect(borderRadius: BorderRadius.all(Radius.circular(2)),
              child: MouseRegion(cursor: SystemMouseCursors.click,
                  child: Container(width: 4, height: 50, color: Theme.of(context).colorScheme.onSurfaceVariant))))));

    if (widget.model.handleRight == true)
      rightHandle = AnimatedPositioned(
          curve: Curves.easeOutCubic, duration: Duration(milliseconds: animate == true ? 500 : 0),
          left: (fromLeft ?? screenWidth) - 10,
          child: Container(height: screenHeight, child: Center(child: ClipRRect(borderRadius: BorderRadius.all(Radius.circular(2)),
              child: MouseRegion(cursor: SystemMouseCursors.click,
                  child: Container(width: 4, height: 50, color: Theme.of(context).colorScheme.onSurfaceVariant))))));

    if (widget.model.handleTop == true)
      topHandle = AnimatedPositioned(
          curve: Curves.easeOutCubic, duration: Duration(milliseconds: animate == true ? 500 : 0),
          bottom: (fromBottom ?? screenHeight) - 10,
          child: Container(width: screenWidth, child: Center(child: ClipRRect(borderRadius: BorderRadius.all(Radius.circular(2)),
              child: MouseRegion(cursor: SystemMouseCursors.click,
                  child: Container(width: 50, height: 4, color: Theme.of(context).colorScheme.onSurfaceVariant))))));

    if (widget.model.handleBottom == true)
      bottomHandle = AnimatedPositioned(
          curve: Curves.easeOutCubic, duration: Duration(milliseconds: animate == true ? 500 : 0),
          top: (fromTop ?? screenHeight) - 10,
          child: Container(width: screenWidth, child: Center(child: ClipRRect(borderRadius: BorderRadius.all(Radius.circular(2)),
              child: MouseRegion(cursor: SystemMouseCursors.click,
                  child: Container(width: 50, height: 4, color: Theme.of(context).colorScheme.onSurfaceVariant))))));

    dynamic view = Stack(children: [
      widget.stackChildren,
      openSheet != null ? GestureDetector(onTap: () => closeDrawer(openSheet)) : Container(),
      leftHandle,
      rightHandle,
      topHandle,
      bottomHandle,
      leftDrawer,
      rightDrawer,
      topDrawer,
      bottomDrawer,
    ]); // view;

    // wrap constraints
    view = applyConstraints(view, widget.model.getUserConstraints());

    view = WillPopScope(onWillPop: () async => preventPop(), child: view);

    return view;
  }

  preventPop() {
    if (openSheet != null) {
      closeDrawer(openSheet);
    return false;
    } else return true;
  }

  finishedAnimation() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    if (animate = true) {
      Future.delayed(Duration(milliseconds: 100), () =>
          setState(() {
            animate = false;
            if (openSheet == null) {
              fromTop = null;
              fromBottom = null;
              fromLeft = null;
              fromRight =  null;
            }
            if (animatingClose == true) {
              animatingClose = false;
              openSheet = null;
            }
            // widget.model.open = '';
          })
      );
    }
    if (afterAnimation != null ) {
      afterAnimation!();
      afterAnimation = null;
    }
    // });
  }

  onDragOpen(DragStartDetails dragStartDetails, String dir) {
    // print('drag open broadcast recieved');
    // if (animate == false) {


    var con = widget.model.getBlendedConstraints();
    double h = con.maxHeight ?? MediaQuery.of(context).size.height;
    double w = con.maxWidth  ?? MediaQuery.of(context).size.width;

    double screenHeight = h;
    double screenWidth = w;

    if (dir == 'vertical') {
      if (dragStartDetails.globalPosition.dy < dragEdge && openSheet == null && widget.model.drawerExists('top'))
      {
        setState(() {
          // fromLeft = fromRight = 0;
          fromBottom = screenHeight;
          // fromTop = screenHeight - fromBottom;
          openSheet = 'top';
        });
        // print('open top sheet');
      }
      else if(dragStartDetails.globalPosition.dy > (screenHeight - dragEdge) && openSheet == null && widget.model.drawerExists('bottom'))
      {
        setState(() {
          // fromLeft = fromRight = 0;
          fromTop = screenHeight;
          // fromBottom = screenHeight - fromTop;
          openSheet = 'bottom';
        });
        // print('open bottom sheet');
      }
      // else
        // print('not dragging from top/bottom');
    }
    if (dir == 'horizontal') {
      if (dragStartDetails.globalPosition.dx < dragEdge && openSheet == null && widget.model.drawerExists('left'))
      {
        setState(() {
          // fromTop = fromBottom = 0;
          fromRight = screenWidth;
          // fromLeft = screenWidth - fromRight;
          openSheet = 'left';
        });
        // print('open left sheet');
      }
      else if(dragStartDetails.globalPosition.dx > (screenWidth - dragEdge) && openSheet == null && widget.model.drawerExists('right'))
      {
        setState(() {
          // fromTop = fromBottom = 0;
          fromLeft = screenWidth;
          // fromRight = screenWidth - fromLeft;
          openSheet = 'right';
        });
        // print('open right sheet');
      }
      // else
        // print('not dragging from left/right');
    }
  }

  onDragEnd(dragEndDetails, String dir, bool isOpen)
  {
    const int dragLeeway = 200; // drag leeway for completing open/closes on drag end

    var con = widget.model.getBlendedConstraints();
    double h = con.maxHeight?? MediaQuery.of(context).size.height;
    double w = con.maxWidth ?? MediaQuery.of(context).size.width;

    double screenHeight = h;
    double screenWidth = w;
    if (animate == false) {
      if (dir == 'vertical') {
        // TOP SHEET
        if (openSheet == 'top') {
          if (isOpen) { // should close ?
            if (dragEndDetails.primaryVelocity! < -300 ||
                (fromBottom! > (screenHeight - widget.model.sizeTop!) + (dragLeeway *
                    ((widget.model.sizeTop != null) ? widget.model.sizeTop! /
                        screenHeight : 1)))) { // yes, close
              setState(() {
                animate = true;
                fromBottom = screenHeight;
                openSheet = null;
              });
            }
            else { // no, keep open
              setState(() {
                animate = true;
                fromBottom = widget.model.sizeTop != null
                    ? screenHeight - widget.model.sizeTop!
                    : 0;
              });
            }
          }
          else { // should open ?
            if (dragEndDetails.primaryVelocity! > 300 ||
                (screenHeight - fromBottom!) > (dragLeeway *
                    ((widget.model.sizeTop != null) ? widget.model.sizeTop! /
                        screenHeight : 1))) { // yes, open
              setState(() {
                animate = true;
                fromBottom = widget.model.sizeTop != null
                    ? screenHeight - widget.model.sizeTop!
                    : 0;
              });
            }
            else { // no, keep closed
              setState(() {
                animate = true;
                fromBottom = screenHeight;
                openSheet = null;
              });
            }
          }
        }
        // BOTTOM SHEET
        if (openSheet == 'bottom') {
          if (isOpen) { // should close ?
            if (dragEndDetails.primaryVelocity! > 300 ||
                (fromTop! > (screenHeight - widget.model.sizeBottom!) + (dragLeeway *
                    ((widget.model.sizeBottom != null) ? widget.model.sizeBottom! /
                        screenHeight : 1)))) { // yes, close
              setState(() {
                animate = true;
                fromTop = screenHeight;
                openSheet = null;
              });
            }
            else { // no, keep open
              setState(() {
                animate = true;
                fromTop = widget.model.sizeBottom != null ? screenHeight -
                    widget.model.sizeBottom! : 0;
              });
            }
          }
          else { // should open ?
            if (dragEndDetails.primaryVelocity! < -300 ||
                (screenHeight - fromTop!) > (dragLeeway *
                    ((widget.model.sizeBottom != null) ? widget.model.sizeBottom! /
                        screenHeight : 1))) { // yes, open
              setState(() {
                animate = true;
                fromTop = widget.model.sizeBottom != null ? screenHeight -
                    widget.model.sizeBottom! : 0;
              });
            }
            else { // no, keep closed
              setState(() {
                animate = true;
                fromTop = screenHeight;
                openSheet = null;
              });
            }
          }
        }
      }
      else if (dir == 'horizontal') {
        // LEFT SHEET
        if (openSheet == 'left') {
          if (isOpen) { // should close ?
            if (dragEndDetails.primaryVelocity! < -300 ||
                (fromRight! > (screenWidth - widget.model.sizeLeft!) + (dragLeeway *
                    ((widget.model.sizeLeft != null) ? widget.model.sizeLeft! /
                        screenWidth : 1)))) { // yes, close
              setState(() {
                animate = true;
                fromRight = screenWidth;
                openSheet = null;
              });
            }
            else { // no, keep open
              setState(() {
                animate = true;
                fromRight = widget.model.sizeLeft != null
                    ? screenWidth - widget.model.sizeLeft!
                    : 0;
              });
            }
          }
          else { // should open ?
            if (dragEndDetails.primaryVelocity! > 300 ||
                (screenWidth - fromRight!) > (dragLeeway *
                    ((widget.model.sizeLeft != null) ? widget.model.sizeLeft! /
                        screenWidth : 1))) { // yes, open
              setState(() {
                animate = true;
                fromRight = widget.model.sizeLeft != null
                    ? screenWidth - widget.model.sizeLeft!
                    : 0;
              });
            }
            else { // no, keep closed
              setState(() {
                animate = true;
                fromRight = screenWidth;
                openSheet = null;
              });
            }
          }
        }
        // RIGHT SHEET
        if (openSheet == 'right') {
          if (isOpen) { // should close ?
            if (dragEndDetails.primaryVelocity! > 300 ||
                (fromLeft! > (screenWidth - widget.model.sizeRight!) + (dragLeeway *
                    ((widget.model.sizeRight != null) ? widget.model.sizeRight! /
                        screenWidth : 1)))) { // yes, close
              setState(() {
                animate = true;
                fromLeft = screenWidth;
                openSheet = null;
              });
            }
            else { // no, keep open
              setState(() {
                animate = true;
                fromLeft = widget.model.sizeRight != null ? screenWidth -
                    widget.model.sizeRight! : 0;
              });
            }
          }
          else { // should open ?
            if (dragEndDetails.primaryVelocity! < -300 ||
                (screenWidth - fromLeft!) > (dragLeeway *
                    ((widget.model.sizeRight != null) ? widget.model.sizeRight! /
                        screenWidth : 1))) { // yes, open
              setState(() {
                animate = true;
                fromLeft = widget.model.sizeRight != null ? screenWidth -
                    widget.model.sizeRight! : 0;
              });
            }
            else { // no, keep closed
              setState(() {
                animate = true;
                fromLeft = screenWidth;
                openSheet = null;
              });
            }
          }
        }
      }
    }
  }

  onDragSheet(DragUpdateDetails dragUpdateDetails, String dir, bool opening) {
    if (animate == false)
    {
      var constraints = widget.model.getBlendedConstraints();
      double h = constraints.maxHeight?? MediaQuery.of(context).size.height;
      double w = constraints.maxWidth ?? MediaQuery.of(context).size.width;
      double screenHeight = h;
      double screenWidth = w;

      if (openSheet == null) {
        // print('not dragging a sheet');
      } else {
        var animateEdge = dragEdge * 0.5;
        // TOP SHEET
        if (openSheet == 'top' && dir == 'vertical') {
          // print(dragUpdateDetails.globalPosition.dy.toString() + ' from top');
          // Animate top sheet closed when near edge
          if (dragUpdateDetails.globalPosition.dy < animateEdge && opening == false && dragUpdateDetails.primaryDelta! > 0) {
            setState(() {
              animate = true;
              animatingClose = true;
              fromBottom = screenHeight;
            });
            // print('top sheet animated closed');
          }
          // Animate top sheet open when near edge
          else if ((screenHeight - dragUpdateDetails.globalPosition.dy) < (widget.model.sizeTop != null ? screenHeight - widget.model.sizeTop! - animateEdge : animateEdge) && opening == true) {
            setState(() {
              animate = true;
              fromBottom = widget.model.sizeTop != null ? screenHeight - widget.model.sizeTop! : 0;
            });
            // print('top sheet animated open');
          }
          // Drag top sheet, no animation
          else {
            // Determine if we are opening or closing
            var calcFromBottom = opening ? screenHeight - dragUpdateDetails.globalPosition.dy : fromBottom! - dragUpdateDetails.primaryDelta!;
            // Prevent dragging past open/close range
            if (widget.model.sizeTop != null && calcFromBottom < screenHeight - widget.model.sizeTop!) calcFromBottom = screenHeight - widget.model.sizeTop!;
            else if (calcFromBottom < 0) calcFromBottom = 0;
            else if (calcFromBottom > screenHeight) calcFromBottom = screenHeight;
            setState(() {
              fromBottom = calcFromBottom;
            });
          }
        }
        // BOTTOM SHEET
        else if (openSheet == 'bottom' && dir == 'vertical') {
          // print((screenHeight - dragUpdateDetails.globalPosition.dy).toString() + ' from bottom');
          // Animate bottom sheet closed when near edge
          if ((screenHeight - dragUpdateDetails.globalPosition.dy) < animateEdge && opening == false && dragUpdateDetails.primaryDelta! < 0) {
            setState(() {
              animate = true;
              animatingClose = true;
              fromTop = screenHeight;
            });
            // print('bottom sheet animated closed');
          }
          // Animate bottom sheet open when near edge
          else if (dragUpdateDetails.globalPosition.dy < (widget.model.sizeBottom != null ? screenHeight - widget.model.sizeBottom! - animateEdge : animateEdge) && opening == true) {
            setState(() {
              animate = true;
              fromTop = widget.model.sizeBottom != null ? screenHeight - widget.model.sizeBottom! : 0;
            });
            // print('bottom sheet animated open');
          }
          // Drag bottom sheet, no animation
          else {
            // Determine if we are opening or closing
            var calcFromTop = opening ? dragUpdateDetails.globalPosition.dy : fromTop! + dragUpdateDetails.primaryDelta!;
            // Prevent dragging past open/close range
            if (widget.model.sizeBottom != null && calcFromTop < screenHeight - widget.model.sizeBottom!)
              calcFromTop = screenHeight - widget.model.sizeBottom!;
            else if (calcFromTop < 0)
              calcFromTop = 0;
            else if (calcFromTop > screenHeight)
              calcFromTop = screenHeight;
            setState(() {
              fromTop = calcFromTop;
            });
          }
        }
        // LEFT SHEET
        else if (openSheet == 'left' && dir == 'horizontal') {
          // print(dragUpdateDetails.globalPosition.dx.toString() + ' from left');
          // Animate left sheet closed when near edge
          if (dragUpdateDetails.globalPosition.dx < animateEdge && opening == false && dragUpdateDetails.primaryDelta! < 0) {
            setState(() {
              animate = true;
              animatingClose = true;
              fromRight = screenWidth;
            });
            // print('left sheet animated closed');
          }
          // Animate left sheet open when near edge
          else if ((screenWidth - dragUpdateDetails.globalPosition.dx) < (widget.model.sizeLeft != null ? screenWidth - widget.model.sizeLeft! - animateEdge : animateEdge) && opening == true) {
            setState(() {
              animate = true;
              fromRight = widget.model.sizeLeft != null ? screenWidth - widget.model.sizeLeft! : 0;
            });
            // print('left sheet animated open');
          }
          // Drag left sheet, no animation
          else {
            // Determine if we are opening or closing
            var calcFromRight = opening ? screenWidth - dragUpdateDetails.globalPosition.dx : fromRight! - dragUpdateDetails.primaryDelta!;
            // Prevent dragging past open/close range
            if (widget.model.sizeLeft != null && calcFromRight < screenWidth - widget.model.sizeLeft!) calcFromRight = screenWidth - widget.model.sizeLeft!;
            else if (calcFromRight < 0) calcFromRight = 0;
            else if (calcFromRight > screenWidth) calcFromRight = screenWidth;
            setState(() {
              fromRight = calcFromRight;
            });
          }
        }
        // RIGHT SHEET
        else if (openSheet == 'right' && dir == 'horizontal') {
          // print((screenWidth - dragUpdateDetails.globalPosition.dx).toString() + ' from right');
          // Animate right sheet closed when near edge
          if ((screenWidth - dragUpdateDetails.globalPosition.dx) < animateEdge && opening == false && dragUpdateDetails.primaryDelta! > 0) {
            setState(() {
              animate = true;
              animatingClose = true;
              fromLeft = screenWidth;
            });
            // print('right sheet animated close');
          }
          // Animate right sheet open when near edge
          else if (dragUpdateDetails.globalPosition.dx < (widget.model.sizeRight != null ? screenWidth - widget.model.sizeRight! - animateEdge : animateEdge) && opening == true) {
            setState(() {
              animate = true;
              fromLeft = widget.model.sizeRight != null ? screenWidth - widget.model.sizeRight! : 0;
            });
            // print('right sheet animated open');
          }
          // Drag right sheet, no animation
          else {
            // Determine if we are opening or closing
            var calcFromLeft = opening ? dragUpdateDetails.globalPosition.dx : fromLeft! + dragUpdateDetails.primaryDelta!;
            // Prevent dragging past open/close range
            if (widget.model.sizeRight != null && calcFromLeft < screenWidth - widget.model.sizeRight!) calcFromLeft = screenWidth - widget.model.sizeRight!;
            else if (calcFromLeft < 0) calcFromLeft = 0;
            else if (calcFromLeft > screenWidth) calcFromLeft = screenWidth;
            setState(() {
              fromLeft = calcFromLeft;
            });
          }
        }
      }
    }
    else {
      setState(() {
        animate = false;
      });
    }
  }

  openDrawer(String? drawer)
  {
    if (drawer == 'top' && widget.model.drawerExists('top')) {
      if (openSheet != null && openSheet != 'top')
        closeDrawer(openSheet, cb: openTop);
        else openTop();
    }
    else if (drawer == 'bottom' && widget.model.drawerExists('bottom')) {
      if (openSheet != null && openSheet != 'bottom')
        closeDrawer(openSheet, cb: openBottom);
      else openBottom();
    }
    else if (drawer == 'left' && widget.model.drawerExists('left')) {
      if (openSheet != null && openSheet != 'left')
        closeDrawer(openSheet, cb: openLeft);
      else openLeft();
    }
    else if (drawer == 'right' && widget.model.drawerExists('right')) {
      if (openSheet != null && openSheet != 'right')
        closeDrawer(openSheet, cb: openRight);
      else openRight();
    }
  }

  void openTop() {
    var constraints = widget.model.getBlendedConstraints();

    double h = constraints.maxHeight?? MediaQuery.of(context).size.height;
    double screenHeight = h;
    setState(() {
      animate = true;
      // fromLeft = fromRight = 0;
      // fromTop = null; screenHeight - fromBottom;
      fromBottom = widget.model.sizeTop != null ? screenHeight - widget.model.sizeTop! : 0;
      openSheet = 'top';
    });
  }

  void openBottom() {
    var constraints = widget.model.getBlendedConstraints();
    double h = constraints.maxHeight?? MediaQuery.of(context).size.height;
    double screenHeight = h;
    setState(() {
      animate = true;
      // fromLeft = fromRight = 0;
      // fromBottom = null;
      fromTop = widget.model.sizeBottom != null ? screenHeight - widget.model.sizeBottom! : 0;
      openSheet = 'bottom';
    });
  }

  void openLeft() {
    var constraints = widget.model.getBlendedConstraints();
    double w = constraints.maxWidth ?? MediaQuery.of(context).size.width;
    double screenWidth = w;
    setState(() {
      animate = true;
      // fromTop = fromBottom = 0;
      // fromLeft = null;
      // fromLeft = screenWidth - fromRight;
      fromRight = widget.model.sizeLeft != null ? screenWidth - widget.model.sizeLeft! : 0;
      openSheet = 'left';
    });
  }

  void openRight() {
    var constraints = widget.model.getBlendedConstraints();
    double w = constraints.maxWidth ?? MediaQuery.of(context).size.width;
    double screenWidth = w;
    setState(() {
      animate = true;
      // fromTop = fromBottom = 0;
      // fromRight = null;
      // fromRight = screenWidth - fromLeft;
      fromLeft = widget.model.sizeRight != null ? screenWidth - widget.model.sizeRight! : 0;
      openSheet = 'right';
    });
  }

  closeDrawer(String? drawer, {cb}) {
    var constraints = widget.model.getBlendedConstraints();
    double h = constraints.maxHeight?? MediaQuery.of(context).size.height;
    double w = constraints.maxWidth ?? MediaQuery.of(context).size.width;
    var screenHeight = h;
    var screenWidth = w;
    if (drawer == 'top') {
      afterAnimation = cb;
      setState(() {
        animate = true;
        animatingClose = true;
        fromBottom = screenHeight;
      });
    }
    else if (drawer == 'bottom') {
      afterAnimation = cb;
      setState(() {
        animate = true;
        animatingClose = true;
        fromTop = screenHeight;
      });
    }
    else if (drawer == 'left') {
      afterAnimation = cb;
      setState(() {
        animate = true;
        animatingClose = true;
        fromRight = screenWidth;
      });
    }
    else if (drawer == 'right') {
      afterAnimation = cb;
      setState(() {
        animate = true;
        animatingClose = true;
        fromLeft = screenWidth;
      });
    }
  }

}
