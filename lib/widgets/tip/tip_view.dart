// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/tip/tip_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';

/// Modified Flutter Class to allow Widget Children within a tooltip
class TipView extends StatefulWidget
{
  final TipModel model;
  TipView(this.model) : super(key: ObjectKey(model));

  @override
  _WidgetTooltipState createState() => _WidgetTooltipState();

  static final List<_WidgetTooltipState> _openedTooltips = <_WidgetTooltipState>[];

  // Causes any current tooltips to be concealed. Only called for mouse hover enter
  // detections. Won't conceal the supplied tooltip.
  static void _concealOtherTooltips(_WidgetTooltipState current) {
    if (_openedTooltips.isNotEmpty) {
      // Avoid concurrent modification.
      final List<_WidgetTooltipState> openedTooltips = _openedTooltips.toList();
      for (final _WidgetTooltipState state in openedTooltips) {
        if (state == current) {
          continue;
        }
        state._concealTooltip();
      }
    }
  }

  // Causes the most recently concealed tooltip to be revealed. Only called for mouse
  // hover exit detections.
  static void _revealLastTooltip() {
    if (_openedTooltips.isNotEmpty) {
      _openedTooltips.last._revealTooltip();
    }
  }

  /// Dismiss all of the tooltips that are currently shown on the screen.
  ///
  /// This method returns true if it successfully dismisses the tooltips. It
  /// returns false if there is no tooltip shown on the screen.
  static bool dismissAllToolTips() {
    if (_openedTooltips.isNotEmpty) {
      // Avoid concurrent modification.
      final List<_WidgetTooltipState> openedTooltips = _openedTooltips.toList();
      for (final _WidgetTooltipState state in openedTooltips) {
        state._dismissTooltip(immediately: true);
      }
      return true;
    }
    return false;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('height', model.height, defaultValue: null));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', model.padit, defaultValue: null));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('margin', model.margin, defaultValue: null));
    properties.add(DoubleProperty('vertical offset', model.verticalOffset, defaultValue: null));
    properties.add(FlagProperty('position', value: model.preferBelow, ifTrue: 'below', ifFalse: 'above', showName: true));
    properties.add(FlagProperty('semantics', value: model.excludeFromSemantics, ifTrue: 'excluded', showName: true));
    properties.add(DiagnosticsProperty<Duration>('wait duration', model.waitDuration, defaultValue: null));
    properties.add(DiagnosticsProperty<Duration>('show duration', model.showDuration, defaultValue: null));
    properties.add(DiagnosticsProperty<TooltipTriggerMode>('triggerMode', model.triggerMode, defaultValue: null));
    properties.add(FlagProperty('enableFeedback', value: model.enableFeedback, ifTrue: 'true', showName: true));
  }
}

class _WidgetTooltipState extends State<TipView> with SingleTickerProviderStateMixin {
  static const double _defaultVerticalOffset = 24.0;
  static const bool _defaultPreferBelow = true;
  static const EdgeInsetsGeometry _defaultMargin = EdgeInsets.zero;
  static const Duration _fadeInDuration = Duration(milliseconds: 150);
  static const Duration _fadeOutDuration = Duration(milliseconds: 75);
  static const Duration _defaultShowDuration = Duration(milliseconds: 1500);
  static const Duration _defaultHoverShowDuration = Duration(milliseconds: 100);
  static const Duration _defaultWaitDuration = Duration.zero;
  static const bool _defaultExcludeFromSemantics = false;
  static const TooltipTriggerMode _defaultTriggerMode = TooltipTriggerMode.longPress;
  static const bool _defaultEnableFeedback = true;

  double? height;
  EdgeInsetsGeometry? padding;
  EdgeInsetsGeometry? margin;
  Decoration? decoration;
  TextStyle? textStyle;
  double? verticalOffset;
  bool? preferBelow;
  bool? excludeFromSemantics;
  late AnimationController _controller;
  OverlayEntry? _entry;
  Timer? _dismissTimer;
  Timer? _showTimer;
  late Duration showDuration;
  late Duration hoverShowDuration;
  late Duration waitDuration;
  bool? _mouseIsConnected;
  bool _pressActivated = false;
  TooltipTriggerMode? triggerMode;
  late bool enableFeedback;
  late bool _isConcealed;
  late bool _forceRemoval;
  late bool _visible;

  @override
  void initState() {
    super.initState();
    _isConcealed = false;
    _forceRemoval = false;
    _mouseIsConnected = RendererBinding.instance.mouseTracker.mouseIsConnected;
    _controller = AnimationController(
      duration: _fadeInDuration,
      reverseDuration: _fadeOutDuration,
      vsync: this,
    )
      ..addStatusListener(_handleStatusChanged);
    // Listen to see when a mouse is added.
    RendererBinding.instance.mouseTracker.addListener(_handleMouseTrackerChange);
    // Listen to global pointer events so that we can hide a tooltip immediately
    // if some other control is clicked on.
    GestureBinding.instance.pointerRouter.addGlobalRoute(_handlePointerEvent);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _visible = TooltipVisibility.of(context);
  }

  // https://material.io/components/tooltips#specs
  double _getDefaultTooltipHeight() {
    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return 24.0;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
        return 32.0;
    }
  }

  EdgeInsets? _getDefaultPadding() {
    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const EdgeInsets.symmetric(horizontal: 8.0);
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
        return const EdgeInsets.symmetric(horizontal: 16.0);
    }
  }

  double _getDefaultFontSize() {
    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return 10.0;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
        return 14.0;
    }
  }

  // Forces a rebuild if a mouse has been added or removed.
  void _handleMouseTrackerChange() {
    if (!mounted) {
      return;
    }
    bool? mouseIsConnected = RendererBinding.instance.mouseTracker.mouseIsConnected;
    if ((mouseIsConnected = _mouseIsConnected)!) {
      setState(() {
        _mouseIsConnected = mouseIsConnected;
      });
    }
  }

  void _handleStatusChanged(AnimationStatus status) {
    // If this tip is concealed, don't remove it, even if it is dismissed, so that we can
    // reveal it later, unless it has explicitly been hidden with _dismissTooltip.
    if (status == AnimationStatus.dismissed && (_forceRemoval || _isConcealed)) {
      _removeEntry();
    }
  }

  void _dismissTooltip({ bool immediately = false }) {
    _showTimer?.cancel();
    _showTimer = null;
    if (immediately) {
      _removeEntry();
      return;
    }
    // So it will be removed when it's done reversing, regardless of whether it is
    // still concealed or not.
    _forceRemoval = true;
    if (_pressActivated) {
      _dismissTimer = Timer(showDuration, _controller.reverse);
    } else {
      _dismissTimer = Timer(hoverShowDuration, _controller.reverse);
    }
    _pressActivated = false;
  }

  void _showTooltip({ bool immediately = false }) {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    if (immediately) {
      ensureTooltipVisible();
      return;
    }
    _showTimer = Timer(waitDuration, ensureTooltipVisible);
  }

  void _concealTooltip() {
    if (_isConcealed || _forceRemoval) {
      // Already concealed, or it's being removed.
      return;
    }
    _isConcealed = true;
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _showTimer?.cancel();
    _showTimer = null;
    if (_entry!= null) {
      _entry!.remove();
    }
    _controller.reverse();
  }

  void _revealTooltip() {
    if (!_isConcealed) {
      // Already uncovered.
      return;
    }
    _isConcealed = false;
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _showTimer?.cancel();
    _showTimer = null;
    if (!_entry!.mounted) {
      final OverlayState overlayState = Overlay.of(
        context,
        debugRequiredFor: widget,
      );
      overlayState.insert(_entry!);
    }
    _controller.forward();
  }

  /// Shows the tooltip if it is not already visible.
  ///
  /// Returns `false` when the tooltip shouldn't be shown or when the tooltip
  /// was already visible.
  bool ensureTooltipVisible() {
    if (!_visible)
      return false;
    _showTimer?.cancel();
    _showTimer = null;
    _forceRemoval = false;
    if (_isConcealed) {
      if (_mouseIsConnected!) {
        TipView._concealOtherTooltips(this);
      }
      _revealTooltip();
      return true;
    }
    if (_entry != null) {
      // Stop trying to hide, if we were.
      _dismissTimer?.cancel();
      _dismissTimer = null;
      _controller.forward();
      return false; // Already visible.
    }
    _createNewEntry();
    _controller.forward();
    return true;
  }

  static final Set<_WidgetTooltipState> _mouseIn = <_WidgetTooltipState>{};

  void _handleMouseEnter() {
    _showTooltip();
  }

  void _handleMouseExit({bool immediately = false}) {
    // If the tip is currently covered, we can just remove it without waiting.
    _dismissTooltip(immediately: _isConcealed || immediately);
  }

  void _createNewEntry() {
    final OverlayState overlayState = Overlay.of(
      context,
      debugRequiredFor: widget,
    );

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset target = box.localToGlobal(
      box.size.center(Offset.zero),
      ancestor: overlayState.context.findRenderObject(),
    );

    // We create this widget outside of the overlay entry's builder to prevent
    // updated values from happening to leak into the overlay when the overlay
    // rebuilds.
    final Widget overlay = Directionality(
      textDirection: Directionality.of(context),
      child: _TooltipOverlay(
        height: height,
        padding: padding,
        margin: margin,
        onEnter: _mouseIsConnected! ? (_) => _handleMouseEnter() : null,
        onExit: _mouseIsConnected! ? (_) => _handleMouseExit() : null,
        decoration: decoration,
        textStyle: textStyle,
        animation: CurvedAnimation(
          parent: _controller,
          curve: Curves.fastOutSlowIn,
        ),
        target: target,
        verticalOffset: verticalOffset,
        preferBelow: preferBelow,
        widgetOverlay: null,
      ),
    );
    _entry = OverlayEntry(builder: (BuildContext context) => overlay);
    _isConcealed = false;
    overlayState.insert(_entry!);
    if (_mouseIsConnected!) {
      // Hovered tooltips shouldn't show more than one at once. For example, a chip with
      // a delete icon shouldn't show both the delete icon tooltip and the chip tooltip
      // at the same time.
      TipView._concealOtherTooltips(this);
    }
    assert(!TipView._openedTooltips.contains(this));
    TipView._openedTooltips.add(this);
  }

  void _removeEntry() {
    TipView._openedTooltips.remove(this);
    _mouseIn.remove(this);
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _showTimer?.cancel();
    _showTimer = null;
    if (!_isConcealed) {
      _entry?.remove();
    }
    _isConcealed = false;
    _entry = null;
    if (_mouseIsConnected!) {
      TipView._revealLastTooltip();
    }
  }

  void _handlePointerEvent(PointerEvent event) {
    if (_entry == null) {
      return;
    }
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _handleMouseExit();
    } else if (event is PointerDownEvent) {
      _handleMouseExit(immediately: true);
    }
  }

  @override
  void deactivate() {
    if (_entry != null) {
      _dismissTooltip(immediately: true);
    }
    _showTimer?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_handlePointerEvent);
    RendererBinding.instance.mouseTracker.removeListener(_handleMouseTrackerChange);
    _removeEntry();
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    _pressActivated = true;
    final bool tooltipCreated = ensureTooltipVisible();
    if (tooltipCreated && enableFeedback) {
      if (triggerMode == TooltipTriggerMode.longPress)
        Feedback.forLongPress(context);
      else
        Feedback.forTap(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TooltipThemeData tooltipTheme = TooltipTheme.of(context);
    TextStyle defaultTextStyle;
    BoxDecoration defaultDecoration;
    if (theme.brightness == Brightness.dark) {
      defaultTextStyle = theme.textTheme.bodyMedium!.copyWith(
        color: Colors.black,
        fontSize: _getDefaultFontSize(),
      );
      defaultDecoration = BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      );
    } else {
      defaultTextStyle = theme.textTheme.bodyMedium!.copyWith(
        color: Colors.white,
        fontSize: _getDefaultFontSize(),
      );
      defaultDecoration = BoxDecoration(
        color: Colors.grey[700]!.withOpacity(0.9),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      );
    }

    height = widget.model.height ?? tooltipTheme.height ?? _getDefaultTooltipHeight();
    padding = widget.model.padit ?? tooltipTheme.padding ?? _getDefaultPadding();
    margin = widget.model.margin ?? tooltipTheme.margin ?? _defaultMargin;
    verticalOffset = widget.model.verticalOffset ?? tooltipTheme.verticalOffset ?? _defaultVerticalOffset;
    preferBelow = widget.model.preferBelow ?? tooltipTheme.preferBelow ?? _defaultPreferBelow;
    excludeFromSemantics = widget.model.excludeFromSemantics ?? tooltipTheme.excludeFromSemantics ?? _defaultExcludeFromSemantics;
    decoration = widget.model.decoration ?? tooltipTheme.decoration ?? defaultDecoration;
    textStyle = widget.model.textStyle ?? tooltipTheme.textStyle ?? defaultTextStyle;
    waitDuration = widget.model.waitDuration ?? tooltipTheme.waitDuration ?? _defaultWaitDuration;
    showDuration = widget.model.showDuration ?? tooltipTheme.showDuration ?? _defaultShowDuration;
    hoverShowDuration = widget.model.showDuration ?? tooltipTheme.showDuration ?? _defaultHoverShowDuration;
    triggerMode = widget.model.triggerMode ?? tooltipTheme.triggerMode ?? _defaultTriggerMode;
    enableFeedback = widget.model.enableFeedback ?? tooltipTheme.enableFeedback ?? _defaultEnableFeedback;

    // build the children
    List<Widget> children = [];
    if (widget.model.children != null)
    widget.model.children!.forEach((model)
    {
        if (model is IViewableWidget)
        {
          children.add((model as IViewableWidget).getView());
        }
    });
    Widget child = children.length == 1 ? children[0] : Column(children: children, mainAxisSize: MainAxisSize.min);

    // Only check for gestures if tooltip should be visible.
    if (_visible) {
      child = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: (triggerMode == TooltipTriggerMode.longPress) ?
        _handlePress : null,
        onTap: (triggerMode == TooltipTriggerMode.tap) ? _handlePress : null,
        excludeFromSemantics: true,
        child: child,
      );
      // Only check for hovering if there is a mouse connected.
      if (_mouseIsConnected!) {
        child = MouseRegion(
          onEnter: (_) => _handleMouseEnter(),
          onExit: (_) => _handleMouseExit(),
          child: child,
        );
      }
    }

    return child;
  }
}

/// A delegate for computing the layout of a tooltip to be displayed above or
/// bellow a target specified in the global coordinate system.
class _TooltipPositionDelegate extends SingleChildLayoutDelegate {
  /// Creates a delegate for computing the layout of a tooltip.
  ///
  /// The arguments must not be null.
  _TooltipPositionDelegate({
    required this.target,
    required this.verticalOffset,
    required this.preferBelow,
  });

  /// The offset of the target the tooltip is positioned near in the global
  /// coordinate system.
  final Offset target;

  /// The amount of vertical distance between the target and the displayed
  /// tooltip.
  final double verticalOffset;

  /// Whether the tooltip is displayed below its widget by default.
  ///
  /// If there is insufficient space to display the tooltip in the preferred
  /// direction, the tooltip will be displayed in the opposite direction.
  final bool preferBelow;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return positionDependentBox(
      size: size,
      childSize: childSize,
      target: target,
      verticalOffset: verticalOffset,
      preferBelow: preferBelow,
    );
  }

  @override
  bool shouldRelayout(_TooltipPositionDelegate oldDelegate) {
    return target != oldDelegate.target
        || verticalOffset != oldDelegate.verticalOffset
        || preferBelow != oldDelegate.preferBelow;
  }
}

class _TooltipOverlay extends StatelessWidget {
  const _TooltipOverlay({
    Key? key,
    required this.height,
    this.padding,
    this.margin,
    this.decoration,
    this.textStyle,
    required this.animation,
    required this.target,
    required this.verticalOffset,
    required this.preferBelow,
    this.onEnter,
    this.onExit,
    this.widgetOverlay
  }) : super(key: key);

  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final TextStyle? textStyle;
  final Animation<double> animation;
  final Offset target;
  final double? verticalOffset;
  final bool? preferBelow;
  final PointerEnterEventListener? onEnter;
  final PointerExitEventListener? onExit;
  final Widget? widgetOverlay;

  @override
  Widget build(BuildContext context) {
    Widget result = IgnorePointer(
        child: FadeTransition(
          opacity: animation,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height!),
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.bodyMedium!,
              child: Container(
                decoration: decoration,
                padding: padding,
                margin: margin,
                child: Center(
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: widgetOverlay
                ),
              ),
            ),
          ),
        )
    );
    if (onEnter != null || onExit != null) {
      result = MouseRegion(
        onEnter: onEnter,
        onExit: onExit,
        child: result,
      );
    }
    return Positioned.fill(
      child: CustomSingleChildLayout(
        delegate: _TooltipPositionDelegate(
          target: target,
          verticalOffset: verticalOffset!,
          preferBelow: preferBelow!,
        ),
        child: result,
      ),
    );
  }
}
