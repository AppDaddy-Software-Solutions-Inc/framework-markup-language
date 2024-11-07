import 'dart:async';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/navigation/navigation_observer.dart';
import 'package:fml/widgets/gesture/gesture_model.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/tooltip/v2/tooltip_model.dart';
import 'src/arrow.dart';
import 'src/bubble.dart';
import 'src/element_box.dart';
import 'src/modal.dart';
import 'src/position_manager.dart';
import 'src/tooltip_elements_display.dart';

enum Gestures { tap, longpress, hover, manual }

class TooltipView extends StatefulWidget implements ViewableWidgetView {

  @override
  final TooltipModel model;

  late final Widget child;
  late final Widget content;
  late final TooltipPosition position;

  TooltipView(this.model, this.child) : super(key: ObjectKey(model)) {
    // set tooltip position
    var position = TooltipPosition.rightCenter;
    switch (model.position?.toLowerCase().trim()) {

      case 'leftstart':
        position = TooltipPosition.leftStart;
        break;

      case 'leftcenter':
        position = TooltipPosition.leftCenter;
        break;

      case 'leftend':
        position = TooltipPosition.leftEnd;
        break;

      case 'topstart':
        position = TooltipPosition.topStart;
        break;

      case 'topcenter':
        position = TooltipPosition.topCenter;
        break;

      case 'topend':
        position = TooltipPosition.topEnd;
        break;

      case 'bottomstart':
        position = TooltipPosition.bottomStart;
        break;

      case 'bottomcenter':
        position = TooltipPosition.bottomCenter;
        break;

      case 'bottomend':
        position = TooltipPosition.bottomEnd;
        break;

      case 'rightstart':
        position = TooltipPosition.rightStart;
        break;

      case 'rightcenter':
        position = TooltipPosition.rightCenter;
        break;

      case 'rightend':
        position = TooltipPosition.rightEnd;
        break;
    }
    this.position = position;

    // set tooltip content
    List<Widget> children = model.inflate();
    content = children.length == 1
        ? children[0]
        : Column(mainAxisSize: MainAxisSize.min, children: children);
  }

  @override
  TooltipViewState createState() => TooltipViewState();
}

/// _ElTooltipState extends ElTooltip class
class TooltipViewState extends ViewableWidgetState<TooltipView>
    with WidgetsBindingObserver
    implements INavigatorObserver {

  // holds the wrapped view
  Widget view = Container();

  ElementBox? box;
  OverlayEntry? hidden;
  OverlayEntry? tooltip;

  final key = GlobalKey();
  var registered = false;
  var measured = false;

  Timer? timer;

  @override
  didChangeDependencies() {

    // force measurement on next display
    measured = false;

    // listen to route changes in order to close overlay
    NavigationObserver().registerListener(this);

    super.didChangeDependencies();
  }

  /// Automatically hide the overlay when the screen dimension changes
  /// or when the user scrolls. This is done to avoid displacement.
  @override
  void didChangeMetrics() {

    // hide the overlay
    hide();
  }

  /// dispose of the tooltip
  @override
  void dispose() {

    // stop listening to route changes
    NavigationObserver().removeListener(this);

    // hide overlay
    hide();

    // remove binding observer
    if (registered) {
      WidgetsBinding.instance.removeObserver(this);
      registered = false;
    }

    super.dispose();
  }

  // Nav Changes used to hide overlay
  @override
  BuildContext getNavigatorContext() => context;

  @override
  Map<String, String>? onNavigatorPop() => null;

  @override
  void onNavigatorPush({Map<String?, String>? parameters}) {}

  @override
  onNavigatorChange() => hide();

  @override
  Future<bool> canPop() async => true;

  ElementBox get _screenSize => _getScreenSize();

  ElementBox get _triggerBox => _getTriggerSize();

  /// Measures the hidden tooltip after it's loaded with _loadHiddenOverlay(_)
  void _measure3() {

    measured = true;

    // find the render box
    var rb = key.currentContext?.findRenderObject() as RenderBox;

    // save render box size
    box = ElementBox(w: rb.size.width, h: rb.size.height);

    // remove the hidden overlay entry
    hidden?.remove();
    hidden = null;

    // show the tooltip
    show();
  }

  Widget _measure2(_) {

    // build the callout
    var callout = Bubble(
      key: key,
      padding: widget.model.padding,
      child: widget.content,
    );

    // set the callout to invisible
    var view = Opacity(opacity: 0, child: Center(child: callout));

    // set measured on next frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure3());

    return view;
  }

  /// Loads the tooltip without opacity to measure the rendered size
  void _measure1() {
    hidden = OverlayEntry(builder: _measure2);
    Overlay.of(context).insert(hidden!);
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
    hide();
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
  void show() {

    // tooltip is already visible
    if (tooltip != null) return;

    // force measurement
    if (!measured) {
        _measure1();
        return;
    }

    // cancel timer
    timer?.cancel();
    timer = null;

    // listen for changes in screen size
    if (!registered) {
      WidgetsBinding.instance.addObserver(this);
      registered = true;
    }

    OverlayState? overlayState = Overlay.of(context);

    /// By calling [PositionManager.load()] we get returned the position
    /// of the tooltip, the arrow and the trigger.
    ToolTipElementsDisplay toolTipElementsDisplay = PositionManager(
      showArrow: widget.model.arrow,
      arrowBox: ElementBox(h: 9.0, w: 14.0),
      overlayBox: box ?? ElementBox(w: 10, h: 10),
      triggerBox: _triggerBox,
      screenSize: _screenSize,
      distance: widget.model.distance,
      radius: widget.model.radius,
    ).load(preferredPosition: widget.position);

    // build the overlay
    List<Widget> children = [];

    // modal curtain
    if (widget.model.modal) {
      children
          .add(Modal(visible: widget.model.modal, onTap: () => hide()));
    }

    // bubble
    var bubble = Positioned(
        top: toolTipElementsDisplay.bubble.y,
        left: toolTipElementsDisplay.bubble.x,
        child: Bubble(
          padding: widget.model.padding,
          radius: toolTipElementsDisplay.radius,
          color: widget.model.color ??
              Theme.of(context).colorScheme.surfaceContainerHighest,
          child: widget.content,
        ));
    children.add(bubble);

    // arrow
    var arrow = widget.model.arrow
        ? Positioned(
            top: toolTipElementsDisplay.arrow.y,
            left: toolTipElementsDisplay.arrow.x,
            child: Arrow(
                color: widget.model.color ??
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                position: toolTipElementsDisplay.position,
                width: 9,
                height: 14))
        : Container();
    children.add(arrow);

    // child
    if (widget.model.modal) {
      children.add(
          Positioned(top: _triggerBox.y, left: _triggerBox.x, child: view));
    }

    // build overlay entry
    tooltip = OverlayEntry(builder: (context) => Stack(children: children));
    overlayState.insert(tooltip!);

    // Add timeout for the tooltip to disappear after specified timeout
    if (widget.model.timeout > 0) {
      timer = Timer(Duration(milliseconds: widget.model.timeout), hide);
    }
  }

  /// Method to hide the tooltip
  void hide() {

    // cancel timer
    timer?.cancel();
    timer = null;

    // remove the overlay and set it to null
    tooltip?.remove();
    tooltip = null;

    // stop listening for changes in screen size
    if (registered) {
      WidgetsBinding.instance.removeObserver(this);
      registered = true;
    }
  }

  @override
  Widget build(BuildContext context) {

    // set opener
    var gesture = toEnum(widget.model.gesture, Gestures.values) ?? Gestures.hover;

    // wrap child in detector
    switch (gesture) {

      // hover
      case Gestures.hover:

        view = MouseRegion(
            cursor: GestureModel.toCursor(widget.model.cursor),
            onEnter: (_) => show(),
            onExit: (_) => hide(),
            hitTestBehavior: HitTestBehavior.translucent,
            child: widget.child);
        break;

      // tap
      case Gestures.tap:
        view = GestureDetector(
            onTap: () =>
                tooltip == null ? show() : hide(),
            behavior: HitTestBehavior.translucent,
            child: widget.child);
        break;

      // long tap
      case Gestures.longpress:
        view = GestureDetector(
            onLongPress: () =>
                tooltip == null ? show() : hide(),
            behavior: HitTestBehavior.translucent,
            child: widget.child);
        break;

      // manual
      case Gestures.manual:
      default:
        view = widget.child;
        break;
    }
    return view;
  }
}
