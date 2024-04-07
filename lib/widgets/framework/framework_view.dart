// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fml/event/handler.dart';
import 'package:fml/fml.dart';
import 'package:fml/navigation/navigation_manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'package:fml/navigation/navigation_observer.dart';
import 'package:fml/event/event.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/framework/framework_model.dart';
import 'package:fml/widgets/scroller/scroller_model.dart';
import 'package:fml/widgets/tabview/tab_view.dart';
import 'package:fml/widgets/widget/widget_model_interface.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/phrase.dart';

// platform
import 'package:fml/platform/platform.web.dart'
    if (dart.library.io) 'package:fml/platform/platform.vm.dart'
    if (dart.library.html) 'package:fml/platform/platform.web.dart';

typedef TitleChangeCallback = void Function(String title);

class FrameworkView extends StatefulWidget {
  final FrameworkModel model;

  FrameworkView(this.model) : super(key: ObjectKey(model));

  @override
  FrameworkViewState createState() => FrameworkViewState();
}

class FrameworkViewState extends State<FrameworkView>
    with AutomaticKeepAliveClientMixin
    implements IModelListener, INavigatorObserver {
  //Widget? busy;

  double get safeAreaHeight {
    // if we are not a root framework then
    // safe area can be ignored
    if (widget.model.framework != null) return 0;
    return MediaQuery.viewPaddingOf(context).top +
        MediaQuery.of(context).viewPadding.bottom +
        MediaQuery.of(context).viewInsets.top +
        MediaQuery.of(context).viewInsets.bottom;
  }

  double get safeAreaWidth {
    // if we are not a root framework then
    // safe area can be ignored
    if (widget.model.framework != null) return 0;
    return MediaQuery.of(context).viewPadding.left +
        MediaQuery.of(context).viewPadding.right +
        MediaQuery.of(context).viewInsets.left +
        MediaQuery.of(context).viewInsets.right;
  }

  // this is used to fire the models onstart
  bool started = false;

  Widget? minimized;
  Widget? maximized;

  @override
  bool get wantKeepAlive => true;

  bool goto = false;

  @override
  void initState() {
    // register model listener
    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();

    super.initState();
  }

  @override
  didChangeDependencies() {
    // register model listener
    widget.model.registerListener(this);

    // register event listeners
    widget.model.registerEventListener(EventTypes.home, onHome);
    widget.model.registerEventListener(EventTypes.close, onClose);
    widget.model.registerEventListener(EventTypes.maximize, onMaximize);
    widget.model.registerEventListener(EventTypes.showtemplate, onShowTemplate);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(FrameworkView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if ((oldWidget.model != widget.model)) {
      // reset started to fire again
      started = false;

      // register new route listener
      NavigationObserver().registerListener(this);

      // remove old event listeners
      oldWidget.model.removeEventListener(EventTypes.home, onHome);
      oldWidget.model.removeEventListener(EventTypes.close, onClose);
      oldWidget.model.removeEventListener(EventTypes.maximize, onMaximize);
      oldWidget.model
          .removeEventListener(EventTypes.showtemplate, onShowTemplate);

      // register new event listeners
      widget.model.registerEventListener(EventTypes.home, onHome);
      widget.model.registerEventListener(EventTypes.close, onClose);
      widget.model.registerEventListener(EventTypes.maximize, onMaximize);
      widget.model
          .registerEventListener(EventTypes.showtemplate, onShowTemplate);

      // remove old model listener
      oldWidget.model.removeListener(this);

      // register new model listener
      widget.model.registerListener(this);
    }
  }

  @override
  void dispose() {
    // Stop Listening to Route Changes
    NavigationObserver().removeListener(this);

    if (widget.model.orientation != null) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight
      ]);
    }

    // Remove the Listener
    widget.model.removeListener(this);

    // framework is top level model?
    // cleanup the model
    if (widget.model.findAncestorOfExactType(FrameworkModel) == null) {
      widget.model.dispose();
    }

    // remove event listeners
    widget.model.removeEventListener(EventTypes.home, onHome);
    widget.model.removeEventListener(EventTypes.close, onClose);
    widget.model.removeEventListener(EventTypes.maximize, onMaximize);
    widget.model.removeEventListener(EventTypes.showtemplate, onShowTemplate);

    super.dispose();
  }

  @override
  BuildContext getNavigatorContext() => context;

  @override
  Map<String?, String>? onNavigatorPop() {
    // Stop Listening to Route Changes
    NavigationObserver().removeListener(this);

    // pop the page
    return widget.model.onPop();
  }

  @override
  void onNavigatorPush({Map<String?, String>? parameters}) {
    return widget.model.onPush(parameters);
  }

  @override
  void onNavigatorChange() {
    widget.model.index = NavigationManager().positionInStack(context);

    // top of stack?
    if (widget.model.index == 0) {
      // set page title
      widget.model.onTitleChange(context);
    }
  }

  /// Callback function for when the model changes, used to force a rebuild with setState()
  @override
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    var b = Binding.fromString(property);
    if (mounted && widget.model.initialized && b?.property != 'busy') {
      setState(() {});
    }
  }

  bool onScroll(ScrollNotification notification) {
    if ((notification.metrics.axisDirection == AxisDirection.left) ||
        (notification.metrics.axisDirection == AxisDirection.right)) {
      return false;
    }

    double maxHeight = widget.model.header?.height ??
        widget.model.header?.constraints.maxHeight ??
        0;
    if (maxHeight.isNegative) maxHeight = 0;

    double minHeight = widget.model.header?.height ??
        widget.model.header?.constraints.minHeight ??
        0;
    if (minHeight.isNegative) minHeight = 0;

    // Non-Resizeable Header
    if (minHeight == maxHeight) return true;
    double height;
    double scrolled = notification.metrics.pixels;
    scrolled = scrolled > maxHeight ? maxHeight : scrolled;

    height = maxHeight - scrolled;
    if (height < minHeight) height = minHeight;

    var viewportHeight = widget.model.system.maxHeight!;
    widget.model.header?.height = height;
    widget.model.height = viewportHeight -
        height -
        (widget.model.footer?.constraints.height ?? 0) -
        safeAreaHeight.ceil();

    /* Stop Notification Bubble */
    return false;
  }

  void onMinimize() {
    setState(() {
      maximized = null;
    });
  }

  void onMaximize(Event event) async {
    if (event.model != null) {
      event.handled = true;
      minimized = context.widget;
      maximized = event.model?.context?.widget;
      setState(() {});
    }
  }

  bool swiping = false;
  double start = 0;
  double last = 0;
  void onDragStart(DragStartDetails details) {
    // IOS back button functionality
    if (details.globalPosition.dx < 50) {
      swiping = true;
      start = details.globalPosition.dx;
      last = details.globalPosition.dx;
    }
  }

  void onDragUpdate(DragUpdateDetails details) {
    if (details.globalPosition.dx < last) swiping = false;
    if (swiping) last = details.globalPosition.dx;
  }

  void onDragEnd(DragEndDetails details) {
    double velocity = details.velocity.pixelsPerSecond.dx.abs();
    double distance = (last - start);
    if ((swiping) && (distance > 50) && (velocity > 100)) {
      NavigationManager().back(1);
    }
    swiping = false;
    start = 0;
    last = 0;
  }

  void onHome(Event event) {
    event.handled = true;
    NavigationManager().back(NavigationManager().pages.length - 1);
  }

  void onShowTemplate(Event event) {
    event.handled = true;
    widget.model.showTemplate();
  }

  void onClose(Event event) {
    // onBack(Event event)
    //OVERLAY.OverlayEntry? overlay = context.findAncestorWidgetOfExactType<OVERLAY.OverlayEntry>();
    TabView? tabview = context.findAncestorWidgetOfExactType<TabView>();
    if (tabview != null) return;
    event.handled = true;
    String? until = fromMap(event.parameters, 'until');
    NavigationManager().back(until ?? 1);
  }

  void onExport(Event event) {
    if (event.parameters!['format'] == 'print') {
      event.handled = true;
      final snackBar = SnackBar(
          content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text(phrase.exportingData)]),
          duration: const Duration(milliseconds: 300),
          behavior: SnackBarBehavior.floating,
          elevation: 5);
      ScaffoldMessenger.of(context)
          .showSnackBar(snackBar)
          .closed
          .then((_) => Platform.openPrinterDialog());
    } else {
      Log().warning(
          'Unhandled Event onExport(format: ${event.parameters!['format'].toString()}, raw: ${event.parameters!['raw'].toString()})');
    }
  }

  // on long press start actions
  Timer? onLongPressTimer;
  void onLongPressStart() {
    // show debug window
    if (onLongPressTimer != null) onLongPressTimer!.cancel();
    onLongPressTimer = Timer(const Duration(seconds: 1),
        () => EventHandler(widget.model).executeEvent("DEBUG.open()"));
  }

  // on long press end actions
  void onLongPressEnd() {
    if (onLongPressTimer != null) onLongPressTimer!.cancel();
    onLongPressTimer = null;
  }

  Widget? _wait;
  Widget _buildWait() {
    if (_wait == null) {
      var c1 = System.theme.background ?? Colors.white60;
      var c2 = System.theme.inversePrimary ?? Colors.black45;

      var spinner = AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(seconds: 2),
          curve: Curves.easeInExpo,
          child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(c2)));

      _wait = SizedBox(width: 32, height: 32, child: spinner);
      _wait = Container(color: c1, child: Center(child: _wait));
    }
    return _wait!;
  }

  Widget _buildHeader(BoxConstraints constraints) {
    var header = widget.model.header;
    if (header == null) return Container();

    header.removeAllListeners();
    header.width = header.visible ? constraints.maxWidth : 0;

    return SizedBox(
        width: header.width, height: header.height, child: header.getView());
  }

  Widget _buildFooter(BoxConstraints constraints) {
    var footer = widget.model.footer;
    if (footer == null) return Container();

    footer.removeAllListeners();
    footer.width = footer.visible ? constraints.maxWidth : 0;

    return SizedBox(
        width: footer.width, height: footer.height, child: footer.getView());
  }

  Widget _buildBody(BoxConstraints constraints) {
    var header = widget.model.header;
    var footer = widget.model.footer;
    var body = widget.model;

    // default model layout to stack if not supplied
    if (widget.model.layout == null) body.layout = "stack";

    // set body constraints
    var viewportWidth = constraints.maxWidth;
    var viewportHeight = constraints.maxHeight;
    var usedHeight =
        (header?.height ?? 0) + (footer?.height ?? 0) + safeAreaHeight.ceil();

    // build framework body
    Widget view = BoxView(body);

    // listen to scroll events if the body
    // is wrapped in a Scroller
    if (body.findChildOfExactType(ScrollerModel) != null) {
      view = NotificationListener<ScrollNotification>(
          onNotification: onScroll, child: view);
    }

    var height = viewportHeight - usedHeight;
    var width = viewportWidth;

    return SizedBox(width: width, height: height, child: view);
  }

  _setDeviceOrientation(String? orientation) {
    List<DeviceOrientation> myOrientation = [];

    orientation = orientation?.toLowerCase().trim();
    switch (orientation) {
      case "landscape":
        myOrientation = [
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft
        ];
        break;
      case "portrait":
        myOrientation = [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown
        ];
        break;
      case "all":
      default:
        myOrientation = [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft
        ];
        break;
    }
    SystemChrome.setPreferredOrientations(myOrientation);
  }

  GestureDetector _setGestures(Widget view) {

    // simulate a swipe to move back on all desktop applications
    // and mobile IOS applications
    bool enableSwipeBack = FmlEngine.isDesktop ||
        (FmlEngine.isMobile && System().useragent == "ios");

    // gesture detector is swipe back on IOS
    if (enableSwipeBack) {
      return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: onDragStart,
          onHorizontalDragEnd: onDragEnd,
          onHorizontalDragUpdate: onDragUpdate,
          onTap: onTapHandler,
          onLongPressStart: kDebugMode ? (_) => onLongPressStart() : null,
          onLongPressEnd: kDebugMode ? (_) => onLongPressEnd() : null,
          child: view);
    }

    // standard gesture detector for commit
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTapHandler,
        onLongPressStart: kDebugMode ? (_) => onLongPressStart() : null,
        onLongPressEnd: kDebugMode ? (_) => onLongPressEnd() : null,
        child: view);
  }

  void onTapHandler() {
    System().setActiveFramework(widget.model);
    WidgetModel.unfocus();
  }

  // holds the current view
  Widget? view;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // model is initializing
    if (!widget.model.initialized) return view ?? _buildWait();

    /// Pages on Navigator stack rebuild when a new page is pushed
    /// https://github.com/flutter/flutter/issues/11655
    /// This hack prevents rebuiling the page that is being navigated away from.
    if (NavigationManager().positionInStack(context) != 0) {
      return view ?? _buildWait();
    }

    // model has initialized. show framework
    return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints) {
    // set focused framework
    System().setActiveFramework(widget.model);

    // set the system constraints
    widget.model.setLayoutConstraints(constraints);

    // stop listening during build
    widget.model.removeListener(this);

    // fire navigator change
    onNavigatorChange();

    // set device orientation
    _setDeviceOrientation(widget.model.orientation);

    // post onstart callback
    if (widget.model.initialized && !started) {
      started = true;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => widget.model.onStart(context));
    }

    // build framework header
    Widget header = _buildHeader(constraints);

    // build framework footer
    Widget footer = _buildFooter(constraints);

    // build framework body
    Widget body = _buildBody(constraints);

    // framework is header, body, footer stacked in a single column inside a fixed frame
    Widget view = Column(children: [header, body, footer]);

    // wrapped drawer view?
    if (widget.model.drawer == null) {
      view = _setGestures(view);
    }

    // check to ensure framework is null before applying SA
    if (widget.model.framework == null) view = SafeArea(child: view);

    // scaffold with safe area
    view = Scaffold(resizeToAvoidBottomInset: true, body: view);

    // start listening to model changes
    widget.model.registerListener(this);

    // assign the current view
    this.view = view;

    return view;
  }
}
