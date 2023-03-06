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
  _TooltipViewState createState() => _TooltipViewState();
}

/// _ElTooltipState extends ElTooltip class
class _TooltipViewState extends WidgetState<TooltipView> with WidgetsBindingObserver
{
  final ElementBox _arrowBox = ElementBox(h: 10.0, w: 16.0);
  ElementBox _overlayBox = ElementBox(h: 0.0, w: 0.0);
  OverlayEntry? _overlayEntry;
  OverlayEntry? _overlayEntryHidden;
  final GlobalKey _widgetKey = GlobalKey();

  /// Automatically hide the overlay when the screen dimension changes
  /// or when the user scrolls. This is done to avoid displacement.
  @override
  void didChangeMetrics()
  {
    _hideOverlay();
  }

  /// Dispose the observer
  @override
  void dispose()
  {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Init state and trigger the hidden overlay to measure its size
  @override
  void initState()
  {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHiddenOverlay(context));
    WidgetsBinding.instance.addObserver(this);
  }

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
    _hideOverlay();
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
  void _showOverlay(BuildContext context) async {
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
    if (hasMouse)
    {
      child = MouseRegion(
        onEnter: (_)
        {
          print('on enter 2');
          if (timer != null) timer!.cancel();
        },
        onExit: (_)
        {
          print('on exit 2');
          if (timer != null) timer!.cancel();
          timer = Timer(Duration(seconds: 3), () => _hideOverlay());
        },
        child: widget.child,
      );
    }
    else child = GestureDetector(
      onTap: () {
        _overlayEntry != null ? _hideOverlay() : _showOverlay(context);
      },
      child: widget.child,
    );

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
    
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Modal(
              color: Colors.black87,
              opacity: 0.7,
              visible: widget.model.modal,
              onTap: () {
                _hideOverlay();
              },
            ),
            Positioned(
              top: toolTipElementsDisplay.bubble.y,
              left: toolTipElementsDisplay.bubble.x,
              child: Bubble(
                triggerBox: _triggerBox,
                padding: widget.model.padding,
                radius: toolTipElementsDisplay.radius,
                color: widget.model.color ?? Colors.white,
                child: content,
              ),
            ),
            Positioned(
              top: toolTipElementsDisplay.arrow.y,
              left: toolTipElementsDisplay.arrow.x,
              child: Arrow(
                color: widget.model.color ?? Colors.white,
                position: toolTipElementsDisplay.position,
                width: _arrowBox.w,
                height: _arrowBox.h,
              ),
            ),
            Positioned(
              top: _triggerBox.y,
              left: _triggerBox.x,
              child: GestureDetector(
                onTap: () {
                  _overlayEntry != null
                      ? _hideOverlay()
                      : _showOverlay(context);
                },
                child: child,
              ),
            ),
          ],
        );
      },
    );

    if (_overlayEntry != null) {
      overlayState.insert(_overlayEntry!);
    }

    // Add timeout for the tooltip to disapear after a few seconds
    if (widget.model.timeout > 0) {
      await Future.delayed(Duration(seconds: 1))
          .whenComplete(() => _hideOverlay());
    }
  }

  /// Method to hide the tooltip
  void _hideOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  Timer? timer;

  @override
  Widget build(BuildContext context)
  {
    late Widget child;

    // mouse attached
    if (hasMouse)
    {
      child = MouseRegion(
        onEnter: (_)
        {
          print('on enter');
          if (timer != null) timer!.cancel();
          if (_overlayEntry == null) _showOverlay(context);
        },
        child: widget.child,
      );
    }

    else child = GestureDetector(
      onTap: () {
        _overlayEntry != null ? _hideOverlay() : _showOverlay(context);
      },
      child: widget.child,
    );

    return child;
  }
}
