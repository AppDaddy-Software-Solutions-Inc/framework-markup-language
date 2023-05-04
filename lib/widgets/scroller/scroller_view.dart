// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/widgets/scroller/scroller_model.dart';
import 'package:fml/widgets/alignment/alignment.dart';
import 'package:fml/widgets/scroller/scroller_shadow_view.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/event/event.dart' ;
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:fml/widgets/layout/layout_model.dart';

/// Scroll View
///
/// Builds the Scroll View from [ScrollerModel] properties
/// This widget creates a scrollable widget that expands to its parents size
/// constraint, if the children would overflow because they are larger they will
/// instead be contained within this scrollable widget.
class ScrollerView extends StatefulWidget implements IWidgetView
{
  @override
  final ScrollerModel model;
  ScrollerView(this.model) : super(key: ObjectKey(model));

  @override
  State<ScrollerView> createState() => _ScrollerViewState();
}

class _ScrollerViewState extends WidgetState<ScrollerView>
{
  final ScrollController _scrollController = ScrollController();
  // state holder for when a maxextent updates and we need a recalculation cycle
  int _tryToScrollBeyond = 0;
  // Scrollbar position relative to full view size
  double? _viewSize;

  /// When true the scroller has been scrolled to the end
  bool hasScrolledThrough = false;

  @override
  void initState()
  {
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  didChangeDependencies()
  {
    // register event listeners
    EventManager.of(widget.model)?.registerEventListener(EventTypes.scrollto, onScrollTo, priority: 0);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(ScrollerView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.model != widget.model)
    {
      // remove old event listeners
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.scrollto, onScrollTo);

      // register new event listeners
      EventManager.of(widget.model)?.registerEventListener(EventTypes.scrollto, onScrollTo, priority: 0);
    }
  }

  @override
  void dispose()
  {
    // remove event listeners
    EventManager.of(widget.model)?.removeEventListener(EventTypes.scrollto, onScrollTo);
    _scrollController.dispose();
    super.dispose();
  }

  /// Takes an event (onscroll) and uses the id to scroll to that widget
  onScrollTo(Event event) {
    // BuildContext context;
    if (event.parameters!.containsKey('id')) {
      String? id = event.parameters!['id'];
      var child = widget.model.findDescendantOfExactType(null, id: id);

      // if there is an error with this, we need to check _controller.hasClients as it must not be false when using [ScrollPosition],such as [position], [offset], [animateTo], and [jumpTo],
      if ((child != null) && (child.context != null)) {
        event.handled = true;
        Scrollable.ensureVisible(child.context,
            duration: Duration(seconds: 1), alignment: 0.2);
      }
    }
  }

  // Listener for detecting if the scroller has reached the end
  _scrollListener() {
    if (hasScrolledThrough != true &&
        _scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (hasScrolledThrough != true) widget.model.scrolledToEnd(context);
      setState(() {
        hasScrolledThrough = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // save system constraints
    onLayout(constraints);

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // build the child views
    List<Widget> children = widget.model.inflate();
    if (children.isEmpty) children.add(Container());

    if (_tryToScrollBeyond == 1)
    {
      setState(() => _tryToScrollBeyond = 2);
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 10,
          duration: Duration(milliseconds: 50),
          curve: Curves.easeOut);
      Future.delayed(Duration(milliseconds: 50),
              () => setState(() => _tryToScrollBeyond = 0));
    }

    if (_viewSize != null) _viewSize = _scrollController.position.viewportDimension;

    // Flex: on my phone there is a 36px padding on the keyboard so I've subtracted it here
    if (widget.model.layout != 'row')
    {
      double keyboardSpacer = MediaQuery.of(context).viewInsets.bottom;
      children.add(Container(height: keyboardSpacer < 36 ? keyboardSpacer : (keyboardSpacer - 36)));
    }

    // get alignment
    var alignment = WidgetAlignment(widget.model.layoutType, false, widget.model.halign, widget.model.valign);

    // build body
    Axis direction = widget.model.layoutType == LayoutType.row ? Axis.horizontal : Axis.vertical;
    Widget child;
    if (direction == Axis.vertical) {
      child = Column(children: children, crossAxisAlignment: alignment.crossAlignment);
    } else {
      child = Row(children: children, crossAxisAlignment: alignment.crossAlignment);
    }
    children.add(Column(mainAxisSize: MainAxisSize.max));

    Widget scsv;
    ScrollBehavior behavior;
    // Check to see if pulldown is enabled, draggable is enabled, or horizontal is enabled (as web doesnt support device horizontal scrolling) and enable
    // dragging for the scroller.
    if(widget.model.onpulldown != null || widget.model.draggable == true || direction == Axis.horizontal) {
      behavior = ScrollConfiguration.of(context).copyWith(scrollbars: widget.model.scrollbar == false ? false : true, dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse});
    } else {
      behavior = ScrollConfiguration.of(context).copyWith(scrollbars: widget.model.scrollbar == false ? false : true);
    }

    if(widget.model.onpulldown != null)
    {
     scsv = RefreshIndicator(
         onRefresh: () => widget.model.onPull(context),
         child: SingleChildScrollView(
         physics: const AlwaysScrollableScrollPhysics(),
         child: child,
         scrollDirection: direction,
         controller: _scrollController));
    }
    else {
      scsv = SingleChildScrollView(child: child, scrollDirection: direction, controller: _scrollController);
    }

    // show no scroll bar
    // POINTERDEVICE MOUSE is not recommended on web due to text selection difficulty, but i have added it in since we do not have text selection.
    if (widget.model.scrollbar !=  false)
    {
      scsv = Container(
          child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: widget.model.scrollbar ?? false,
              child: scsv,));
    }
    scsv = ScrollConfiguration(behavior: behavior, child: scsv);

    Widget view;
    if (widget.model.scrollbar != true && direction == Axis.vertical)
    {
      view = Listener(behavior: HitTestBehavior.translucent,
        onPointerSignal: (ps) {
          // mouse wheel scrolling
        },
        child: Stack(
          fit: StackFit.loose,
          children: [
            scsv,
            ScrollShadow(_scrollController, 'top', Axis.vertical,
                widget.model.shadowcolor),
            ScrollShadow(_scrollController, 'bottom', Axis.vertical,
                widget.model.shadowcolor),
            SizedBox.expand(),
          ],
        ),
      );
    } else if (widget.model.scrollbar != true && direction == Axis.horizontal) {
      view = Listener(
        behavior: HitTestBehavior.translucent,
        onPointerSignal: (ps) {
          // mouse wheel scrolling
        },
        child: Stack(
          fit: StackFit.loose,
          children: [
            scsv,
            ScrollShadow(_scrollController, 'top', Axis.horizontal,
                widget.model.shadowcolor),
            ScrollShadow(_scrollController, 'bottom', Axis.horizontal,
                widget.model.shadowcolor),
            SizedBox.expand(),
          ],
        ),
      );
    } else {
      view = Listener(
        behavior: HitTestBehavior.translucent,
        onPointerSignal: (ps) {
          // mouse wheel scrolling
        },
        child: Stack(
          fit: StackFit.loose,
          children: [
            scsv,
            SizedBox.shrink(),
          ],
        ),
      );
    }

    // add margins
    view = addMargins(view);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.constraints.tightestOrDefault);

    return view;
  }
}
