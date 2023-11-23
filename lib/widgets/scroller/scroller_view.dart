// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/scroller/scroller_model.dart';
import 'package:fml/widgets/scroller/scroller_shadow_view.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/event/event.dart' ;
import 'package:fml/widgets/widget/widget_state.dart';

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
  State<ScrollerView> createState() => ScrollerViewState();
}

class ScrollerViewState extends WidgetState<ScrollerView>
{
  final ScrollController controller = ScrollController();

  /// When true the scroller has been scrolled to the end
  bool hasScrolledThrough = false;

  @override
  void initState()
  {
    controller.addListener(_scrollListener);
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
    controller.dispose();
    super.dispose();
  }

  /// Takes an event (onscroll) and uses the id to scroll to that widget
  onScrollTo(Event event) {
    // BuildContext context;
    if (event.parameters!.containsKey('id'))
    {
      String? id = event.parameters!['id'];
      var child = widget.model.findDescendantOfExactType(null, id: id);

      // if there is an error with this, we need to check _controller.hasClients as it must not be false when using [ScrollPosition],such as [position], [offset], [animateTo], and [jumpTo],
      if ((child != null) && (child.context != null))
      {
        event.handled = true;
        Scrollable.ensureVisible(child.context,
            duration: Duration(seconds: 1), alignment: 0.2);
      }
    }
  }

  // Listener for detecting if the scroller has reached the end
  _scrollListener() {
    if (hasScrolledThrough != true &&
        controller.offset >=
            controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (hasScrolledThrough != true) widget.model.scrolledToEnd(context);
      setState(() {
        hasScrolledThrough = true;
      });
    }
  }

  ScrollBehavior _getScrollBehaviour(Axis direction)
  {
    late ScrollBehavior behavior;

    // Check to see if pulldown is enabled, allowDrag is enabled, or horizontal is enabled (as web doesnt support device horizontal scrolling) and enable
    // dragging for the scroller.
    if(widget.model.onpulldown != null || widget.model.allowDrag || direction == Axis.horizontal)
    {
      behavior = ScrollConfiguration.of(context).copyWith(scrollbars: widget.model.scrollbar == false ? false : true, dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse});
    }
    else
    {
      behavior = ScrollConfiguration.of(context).copyWith(scrollbars: widget.model.scrollbar == false ? false : true);
    }
    return behavior;
  }

  Widget _addScrollShadows(Widget view, Axis direction)
  {
    switch (direction)
    {
      case Axis.vertical:
        view = Listener(behavior: HitTestBehavior.translucent,
            onPointerSignal: (ps) {},
            child: Stack(fit: StackFit.loose,
                children: [
                  view,
                  ScrollShadow(controller, 'top', Axis.vertical, widget.model.shadowcolor),
                  ScrollShadow(controller, 'bottom', Axis.vertical, widget.model.shadowcolor),
                  SizedBox.expand(),
                ]));
        break;

      case Axis.horizontal:
        view = Listener(
          behavior: HitTestBehavior.translucent,
          onPointerSignal: (ps) {},
          child: Stack(
            fit: StackFit.loose,
            children: [
              view,
              ScrollShadow(controller, 'top', Axis.horizontal, widget.model.shadowcolor),
              ScrollShadow(controller, 'bottom', Axis.horizontal, widget.model.shadowcolor),
              SizedBox.expand(),
            ],
          ),
        );
    }
    return view;
  }
  Widget _buildScrollbar(Widget child)
  {
    Widget view;

    // build body
    Axis direction = widget.model.layoutType == LayoutType.row ? Axis.horizontal : Axis.vertical;

    // add pull down
    if (widget.model.onpulldown != null)
    {
      view = RefreshIndicator(
          onRefresh: () => widget.model.onPull(context),
          child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: child,
              scrollDirection: direction,
              controller: controller));
    }
    else
    {
      view = SingleChildScrollView(child: child, scrollDirection: direction, controller: controller);
    }

    // add scroll bar
    if (widget.model.scrollbar)
    {
      view = Container(child: Scrollbar(controller: controller, thumbVisibility: widget.model.scrollbar, child: view));
      view = Listener(behavior: HitTestBehavior.translucent,
        onPointerSignal: (ps) {},
        child: Stack(fit: StackFit.loose, children: [view, SizedBox.shrink()]));
    }

    // no scroll bar - add scroll shadow
    else
    {
      view = _addScrollShadows(view, direction);
    }

    // set behavior
    view = ScrollConfiguration(behavior: _getScrollBehaviour(direction), child: view);

    return view;
  }

  Offset? positionOf()
  {
    RenderBox? render = context.findRenderObject() as RenderBox?;
    return render?.localToGlobal(Offset.zero);
  }

  Size? sizeOf()
  {
    RenderBox? render = context.findRenderObject() as RenderBox?;
    return render?.size;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // build the body
    var contents = BoxView(widget.model.getContentModel());

    // build the scroll bar
    Widget view = _buildScrollbar(contents);

    // apply constraints
    view = applyConstraints(view, widget.model.constraints);

    // add margins around the entire widget
    view = addMargins(view);

    // expand in both axis
    if (widget.model.expand)
    {
      view = SizedBox(width: constraints.maxWidth, height: constraints.maxHeight, child: view);
    }

    // contract in cross axis
    else
    {
      view = widget.model.layoutType == LayoutType.row ?
      Column(mainAxisSize: MainAxisSize.min, children: [view]) :
      Row(mainAxisSize: MainAxisSize.min, children: [view]);
    }

    return view;
  }
}
