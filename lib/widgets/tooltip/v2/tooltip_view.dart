import 'dart:async';
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

/// Widget that displays a tooltip
/// It takes a widget as the trigger and a widget as the content
class TooltipView extends StatefulWidget implements IWidgetView
{
  final TooltipModel model;
  final Widget child;
  TooltipView(this.model, this.child) : super(key: ObjectKey(model));

  @override
  TooltipViewState createState() => TooltipViewState();
}

/// _ElTooltipState extends ElTooltip class
class TooltipViewState extends WidgetState<TooltipView> with WidgetsBindingObserver
{
  final ElementBox _arrowBox = ElementBox(h: 10.0, w: 16.0);
  ElementBox _overlayBox = ElementBox(h: 0.0, w: 0.0);
  OverlayEntry? overlayEntry;
  OverlayEntry? _overlayEntryHidden;
  final GlobalKey _widgetKey = GlobalKey();

  late openMethods opener;

  /// Init state and trigger the hidden overlay to measure its size
  @override
  void initState()
  {
    // set opener
    opener = widget.model.openMethod ?? (hasMouse ? openMethods.hover : openMethods.tap);

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHiddenOverlay(context));
    WidgetsBinding.instance.addObserver(this);
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
    hideOverlay();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Nav Changes
  BuildContext getNavigatorContext() => context;
  Map<String,String>? onNavigatorPop() => null;
  onNavigatorChange() => null;
  void onNavigatorPush({Map<String?, String>? parameters}) => null;

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
              child: widget.child,
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

    var position = ElTooltipPosition.rightCenter;
    switch (widget.model.position?.toLowerCase().trim())
    {
      case 'leftstart' :
        position = ElTooltipPosition.leftStart;
        break;

      case 'leftcenter' :
        position = ElTooltipPosition.leftCenter;
        break;

      case 'leftend' :
        position = ElTooltipPosition.leftEnd;
        break;

      case 'rightstart' :
        position = ElTooltipPosition.rightStart;
        break;

      case 'rightcenter' :
        position = ElTooltipPosition.rightCenter;
        break;

      case 'rightend' :
        position = ElTooltipPosition.rightEnd;
        break;

      case 'topstart' :
        position = ElTooltipPosition.topStart;
        break;

      case 'topcenter' :
        position = ElTooltipPosition.topCenter;
        break;

      case 'topend' :
        position = ElTooltipPosition.topEnd;
        break;
    }
    
    /// By calling [PositionManager.load()] we get returned the position
    /// of the tooltip, the arrow and the trigger.
    ToolTipElementsDisplay toolTipElementsDisplay = PositionManager(
      arrowBox: _arrowBox,
      overlayBox: _overlayBox,
      triggerBox: _triggerBox,
      screenSize: _screenSize,
      distance: widget.model.distance,
      radius: widget.model.radius,
    ).load(preferredPosition: position);

    late Widget child;

    // mouse attached
    switch (opener)
    {
      case openMethods.hover:
        child = MouseRegion(
        onEnter: (_)
        {
          if (timer != null) timer!.cancel();
        },
        onExit: (_)
        {
          if (timer != null) timer!.cancel();
          timer = Timer(Duration(milliseconds: widget.model.timeout > 0 ? widget.model.timeout : 1000), () => hideOverlay());
        },
        child: widget.child,
        );
        break;

      case openMethods.tap:
        child = GestureDetector(
        onTap: () {
        overlayEntry != null ? hideOverlay() : showOverlay(context);
        },
        child: widget.child,
        );
        break;

      case openMethods.longpress:
        child = GestureDetector(
          onLongPress: ()
          {
            overlayEntry != null ? hideOverlay() : showOverlay(context);
          },
          child: widget.child,
        );
        break;

      default:
        child = widget.child;
        break;
    }

    // build content
    List<Widget> children = [];
    if (widget.model.children != null)
      widget.model.children!.forEach((model)
      {
        if (model is IViewableWidget) {
          children.add((model as IViewableWidget).getView());
        }
      });
    var content = children.length == 1 ? children[0] : Column(children: children, mainAxisSize: MainAxisSize.min);
    
    overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Modal(
              color: Colors.black87,
              opacity: 0.7,
              visible: widget.model.modal,
              onTap: () {
                hideOverlay();
              },
            ),
            Positioned(
              top: toolTipElementsDisplay.bubble.y,
              left: toolTipElementsDisplay.bubble.x,
              child: Bubble(
                triggerBox: _triggerBox,
                padding: widget.model.padding,
                radius: toolTipElementsDisplay.radius,
                color: widget.model.color ?? Theme.of(context).colorScheme.surfaceVariant,
                child: content,
              ),
            ),
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
    if (widget.model.timeout > 0 && opener != openMethods.hover)
    {
      await Future.delayed(Duration(milliseconds: widget.model.timeout > 0 ? widget.model.timeout : 3000)).whenComplete(() => hideOverlay());
    }
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
      case openMethods.hover:
        child = MouseRegion(
          onEnter: (_)
          {
            if (timer != null) timer!.cancel();
            if (overlayEntry == null) showOverlay(context);
          },
          child: widget.child,
        );
        break;

      case openMethods.tap:
        child = GestureDetector(
        onTap: () {
          overlayEntry != null ? hideOverlay() : showOverlay(context);
        },
        child: widget.child,
        );
        break;

      case openMethods.longpress:
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
