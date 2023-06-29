import 'dart:async';
import 'package:fml/navigation/navigation_observer.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:flutter/material.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/tooltip/v2/tooltip_model.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'src/arrow.dart';
import 'src/bubble.dart';
import 'src/element_box.dart';
import 'src/modal.dart';
import 'src/position_manager.dart';
import 'src/tooltip_elements_display.dart';

class TooltipView extends StatefulWidget implements IWidgetView
{
  @override
  final TooltipModel model;
  final Widget child;
  late final Widget content;
  late final TooltipPosition position;

  TooltipView(this.model, this.child) : super(key: ObjectKey(model))
  {
    // set tooltip position
    var myPos = TooltipPosition.rightCenter;
    switch (model.position?.toLowerCase().trim())
    {
      case 'leftstart' :
        myPos = TooltipPosition.leftStart;
        break;

      case 'leftcenter' :
        myPos = TooltipPosition.leftCenter;
        break;

      case 'leftend' :
        myPos = TooltipPosition.leftEnd;
        break;

      case 'rightstart' :
        myPos = TooltipPosition.rightStart;
        break;

      case 'rightcenter' :
        myPos = TooltipPosition.rightCenter;
        break;

      case 'rightend' :
        myPos = TooltipPosition.rightEnd;
        break;

      case 'topstart' :
        myPos = TooltipPosition.topStart;
        break;

      case 'topcenter' :
        myPos = TooltipPosition.topCenter;
        break;

      case 'topend' :
        myPos = TooltipPosition.topEnd;
        break;
    }
    position = myPos;

    // set tooltip content
    List<Widget> children = model.inflate();
    content = children.length == 1 ? children[0] : Column(children: children, mainAxisSize: MainAxisSize.min);
  }

  @override
  TooltipViewState createState() => TooltipViewState();
}

/// _ElTooltipState extends ElTooltip class
class TooltipViewState extends WidgetState<TooltipView> with WidgetsBindingObserver implements INavigatorObserver
{
  // holds the wrapped view
  Widget view = Container();

  final ElementBox _arrowBox = ElementBox(h: 9.0, w: 14.0);
  ElementBox _overlayBox = ElementBox(h: 0.0, w: 0.0);
  OverlayEntry? overlayEntry;
  OverlayEntry? _overlayEntryHidden;
  final GlobalKey _widgetKey = GlobalKey();

  late OpenMethods opener;

  /// Init state and trigger the hidden overlay to measure its size
  @override
  void initState()
  {
    // set opener
    opener = widget.model.openMethod ?? (System().mouse ? OpenMethods.hover : OpenMethods.longpress);

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHiddenOverlay(context));
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  didChangeDependencies()
  {
    // listen to route changes
    NavigationObserver().registerListener(this);
    super.didChangeDependencies();
  }

    /// Automatically hide the overlay when the screen dimension changes
  /// or when the user scrolls. This is done to avoid displacement.
  @override
  void didChangeMetrics()
  {
    hideOverlay();
  }

  /// Dispose the observer
  @override
  void dispose()
  {
    // stop listening to route changes
    NavigationObserver().removeListener(this);

    // hide overlay
    hideOverlay();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Nav Changes used to hide overlay
  @override
  BuildContext getNavigatorContext() => context;
  @override
  Map<String,String>? onNavigatorPop() => null;
  @override
  void onNavigatorPush({Map<String?, String>? parameters}) {}
  @override
  onNavigatorChange() => hideOverlay();

  ElementBox get _screenSize => _getScreenSize();

  ElementBox get _triggerBox => _getTriggerSize();

  /// Measures the hidden tooltip after it's loaded with _loadHiddenOverlay(_)
  void _getHiddenOverlaySize(context) 
  {
    RenderBox box = _widgetKey.currentContext?.findRenderObject() as RenderBox;
    if (mounted)
    {
      setState(() 
      {
        _overlayBox = ElementBox(w: box.size.width, h: box.size.height);
        _overlayEntryHidden?.remove();
      });
    }
  }

  /// Loads the tooltip without opacity to measure the rendered size
  void _loadHiddenOverlay(_) {
    OverlayState? overlayStateHidden = Overlay.of(context);
    _overlayEntryHidden = OverlayEntry(
      builder: (context) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _getHiddenOverlaySize(context));
        return Opacity(
          opacity: 0,
          child: Center(
            child: Bubble(
              key: _widgetKey,
              padding: widget.model.paddingTop ?? 10,
              child: widget.content,
            ),
          ),
        );
      },
    );

    if (_overlayEntryHidden != null) {
      overlayStateHidden.insert(_overlayEntryHidden!);
    }
  }

  /// Measures the size of the trigger widget
  ElementBox _getTriggerSize() {
    if (mounted)
    {
      final renderBox = context.findRenderObject() as RenderBox;
      final offset = renderBox.localToGlobal(Offset.zero);
      return ElementBox(
        w: renderBox.size.width,
        h: renderBox.size.height,
        x: offset.dx,
        y: offset.dy,
      );
    }
    hideOverlay();
    return ElementBox(w: 0, h: 0, x: 0, y: 0);
  }

  /// Measures the size of the screen to calculate possible overflow
  ElementBox _getScreenSize() {
    return ElementBox(
      w: MediaQuery.of(context).size.width,
      h: MediaQuery.of(context).size.height,
    );
  }

  /// Loads the tooltip into view
  void showOverlay(BuildContext context) async
  {
    if (overlayEntry != null) return;

    OverlayState? overlayState = Overlay.of(context);
    
    /// By calling [PositionManager.load()] we get returned the position
    /// of the tooltip, the arrow and the trigger.
    ToolTipElementsDisplay toolTipElementsDisplay = PositionManager(
      showArrow: widget.model.arrow,
      arrowBox: _arrowBox,
      overlayBox: _overlayBox,
      triggerBox: _triggerBox,
      screenSize: _screenSize,
      distance: widget.model.distance,
      radius: widget.model.radius,
    ).load(preferredPosition: widget.position);


    // build the overlay
    List<Widget> children = [];

    // modal curtain
    if (widget.model.modal) children.add(Modal(visible: widget.model.modal, onTap: () => hideOverlay()));

    // bubble
    var bubble = Positioned(
      top:  toolTipElementsDisplay.bubble.y,
      left: toolTipElementsDisplay.bubble.x,
      child: Bubble(
        padding: widget.model.paddingTop ?? 10,
        radius: toolTipElementsDisplay.radius,
        color: widget.model.color ?? Theme.of(context).colorScheme.surfaceVariant,
        child: widget.content,
      ));
    children.add(bubble);

    // arrow
    var arrow = widget.model.arrow ? Positioned(
      top: toolTipElementsDisplay.arrow.y,
      left: toolTipElementsDisplay.arrow.x,
      child: Arrow(
        color: widget.model.color ?? Theme.of(context).colorScheme.surfaceVariant,
        position: toolTipElementsDisplay.position,
        width: _arrowBox.w,
        height: _arrowBox.h)) : Container();
    children.add(arrow);

    // child
    if (widget.model.modal) {
      children.add(Positioned(
          top: _triggerBox.y,
          left: _triggerBox.x,
          child: view));
    }

    // build overlay
    overlayEntry = OverlayEntry(builder: (context) => Stack(children: children));
    overlayState.insert(overlayEntry!);

    // Add timeout for the tooltip to disappear after a few seconds
    if (widget.model.timeout > 0 && opener != OpenMethods.hover) await Future.delayed(Duration(milliseconds: widget.model.timeout > 0 ? widget.model.timeout : 3000)).whenComplete(() => hideOverlay());
  }

  /// Method to hide the tooltip
  void hideOverlay()
  {
    if (overlayEntry != null)
    {
      overlayEntry?.remove();
      overlayEntry = null;
    }
  }

  Timer? timer;

  @override
  Widget build(BuildContext context)
  {
    // wrap child in detector
    switch (opener)
    {
      // hover
      case OpenMethods.hover:
        view = MouseRegion(onEnter: (_)
          {
            if (timer != null) timer!.cancel();
            showOverlay(context);
          },
          onExit: (_)
          {
            if (timer != null) timer!.cancel();
            timer = Timer(Duration(milliseconds: widget.model.timeout > 0 ? widget.model.timeout : 250), () => hideOverlay());
          },
          child: widget.child, hitTestBehavior: HitTestBehavior.translucent);
        break;

      // tap
      case OpenMethods.tap:
        view = GestureDetector(onTap: () => overlayEntry == null ? showOverlay(context) : hideOverlay(), child: widget.child, behavior: HitTestBehavior.translucent);
        break;

      // long tap
      case OpenMethods.longpress:
        view = GestureDetector(onLongPress: () => overlayEntry == null ? showOverlay(context) : hideOverlay(), child: widget.child, behavior: HitTestBehavior.translucent);
        break;

      // manual
      default:
        view = widget.child;
        break;
    }
    return view;
  }
}
