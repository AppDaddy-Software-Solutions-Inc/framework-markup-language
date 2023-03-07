import 'dart:async';
import 'package:fml/navigation/navigation_observer.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:flutter/material.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/tooltip/v2/tooltip_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'src/arrow.dart';
import 'src/bubble.dart';
import 'src/element_box.dart';
import 'src/enum/el_tooltip_position.dart';
import 'src/modal.dart';
import 'src/position_manager.dart';
import 'src/tooltip_elements_display.dart';
export 'src/enum/el_tooltip_position.dart';

class TooltipView extends StatefulWidget implements IWidgetView
{
  final TooltipModel model;
  final Widget child;
  late final Widget content;
  late final ElTooltipPosition position;

  TooltipView(this.model, this.child) : super(key: ObjectKey(model))
  {
    // set tooltip position
    var _pos = ElTooltipPosition.rightCenter;
    switch (model.position?.toLowerCase().trim())
    {
      case 'leftstart' :
        _pos = ElTooltipPosition.leftStart;
        break;

      case 'leftcenter' :
        _pos = ElTooltipPosition.leftCenter;
        break;

      case 'leftend' :
        _pos = ElTooltipPosition.leftEnd;
        break;

      case 'rightstart' :
        _pos = ElTooltipPosition.rightStart;
        break;

      case 'rightcenter' :
        _pos = ElTooltipPosition.rightCenter;
        break;

      case 'rightend' :
        _pos = ElTooltipPosition.rightEnd;
        break;

      case 'topstart' :
        _pos = ElTooltipPosition.topStart;
        break;

      case 'topcenter' :
        _pos = ElTooltipPosition.topCenter;
        break;

      case 'topend' :
        _pos = ElTooltipPosition.topEnd;
        break;
    }
    this.position = _pos;

    // set tooltip content
    List<Widget> children = [];
    if (model.children != null)
    model.children!.forEach((model)
    {
      if (model is IViewableWidget) {
        children.add((model as IViewableWidget).getView());
      }
    });
    content = children.length == 1 ? children[0] : Column(children: children, mainAxisSize: MainAxisSize.min);
  }

  @override
  TooltipViewState createState() => TooltipViewState();
}

/// _ElTooltipState extends ElTooltip class
class TooltipViewState extends WidgetState<TooltipView> with WidgetsBindingObserver implements INavigatorObserver
{
  final ElementBox _arrowBox = ElementBox(h: 10.0, w: 16.0);
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
  BuildContext getNavigatorContext() => context;
  Map<String,String>? onNavigatorPop() => null;
  void onNavigatorPush({Map<String?, String>? parameters}) => null;
  onNavigatorChange() => hideOverlay();

  ElementBox get _screenSize => _getScreenSize();

  ElementBox get _triggerBox => _getTriggerSize();

  /// Measures the hidden tooltip after it's loaded with _loadHiddenOverlay(_)
  void _getHiddenOverlaySize(context) {
    RenderBox box = _widgetKey.currentContext?.findRenderObject() as RenderBox;
    if (mounted) {
      setState(() {
        _overlayBox = ElementBox(
          w: box.size.width,
          h: box.size.height,
        );
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
              triggerBox: _triggerBox,
              padding: widget.model.padding,
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
    if (mounted) {
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
    OverlayState? overlayState = Overlay.of(context);
    
    /// By calling [PositionManager.load()] we get returned the position
    /// of the tooltip, the arrow and the trigger.
    ToolTipElementsDisplay toolTipElementsDisplay = PositionManager(
      arrowBox: _arrowBox,
      overlayBox: _overlayBox,
      triggerBox: _triggerBox,
      screenSize: _screenSize,
      distance: widget.model.distance,
      radius: widget.model.radius,
    ).load(preferredPosition: widget.position);

    late Widget child;

    // mouse attached
    switch (opener)
    {
      case OpenMethods.hover:
        child = MouseRegion(onEnter: (_)
        {
          if (timer != null) timer!.cancel();
        },
        onExit: (_)
        {
          if (timer != null) timer!.cancel();
          timer = Timer(Duration(milliseconds: widget.model.timeout > 0 ? widget.model.timeout : 250), () => hideOverlay());
        },
        child: widget.child);
        break;

      case OpenMethods.tap:
        child = GestureDetector(onTap: () => overlayEntry != null ? hideOverlay() : showOverlay(context), child: widget.child);
        break;

      case OpenMethods.longpress:
        child = GestureDetector(onLongPress: () => overlayEntry != null ? hideOverlay() : showOverlay(context), child: widget.child);
        break;

      default:
        child = widget.child;
        break;
    }
    
    overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [

            // modal curtain
            Modal(
              color: Colors.black87,
              opacity: 0.7,
              visible: widget.model.modal,
              onTap: () {
                hideOverlay();
              },
            ),

            // bubble
            Positioned(
              top: toolTipElementsDisplay.bubble.y,
              left: toolTipElementsDisplay.bubble.x,
              child: Bubble(
                triggerBox: _triggerBox,
                padding: widget.model.padding,
                radius: toolTipElementsDisplay.radius,
                color: widget.model.color ?? Theme.of(context).colorScheme.surfaceVariant,
                child: widget.content,
              ),
            ),

            // arrow
            Positioned(
              top: toolTipElementsDisplay.arrow.y,
              left: toolTipElementsDisplay.arrow.x,
              child: Arrow(
                color: widget.model.color ?? Theme.of(context).colorScheme.surfaceVariant,
                position: toolTipElementsDisplay.position,
                width: _arrowBox.w,
                height: _arrowBox.h,
              ),
            ),

            // child
            Positioned(
              top: _triggerBox.y,
              left: _triggerBox.x,
              child: child
            ),
          ],
        );
      },
    );

    if (overlayEntry != null) overlayState.insert(overlayEntry!);

    // Add timeout for the tooltip to disappear after a few seconds
    if (widget.model.timeout > 0 && opener != OpenMethods.hover) await Future.delayed(Duration(milliseconds: widget.model.timeout > 0 ? widget.model.timeout : 3000)).whenComplete(() => hideOverlay());
  }

  /// Method to hide the tooltip
  void hideOverlay() {
    if (overlayEntry != null) {
      overlayEntry?.remove();
      overlayEntry = null;
    }
  }

  Timer? timer;

  @override
  Widget build(BuildContext context)
  {
    late Widget child;

    // mouse attached
    switch (opener)
    {
      case OpenMethods.hover:
        child = MouseRegion(
          onEnter: (_)
          {
            if (timer != null) timer!.cancel();
            if (overlayEntry == null) showOverlay(context);
          },
          child: widget.child,
        );
        break;

      case OpenMethods.tap:
        child = GestureDetector(
        onTap: () {
          overlayEntry != null ? hideOverlay() : showOverlay(context);
        },
        child: widget.child,
        );
        break;

      case OpenMethods.longpress:
        child = GestureDetector(
          onLongPress: () {
            overlayEntry != null ? hideOverlay() : showOverlay(context);
          },
          child: widget.child,
        );
        break;

      default:
        child = widget.child;
        break;
    }
    return child;
  }
}
