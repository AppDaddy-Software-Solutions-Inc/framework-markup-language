// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:fml/event/handler.dart';
import 'package:fml/navigation/navigation_manager.dart';
import 'package:fml/observable/binding.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/system.dart';
import 'package:fml/navigation/navigation_observer.dart';
import 'package:fml/event/event.dart'             ;
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/widgets/busy/busy_view.dart';
import 'package:fml/widgets/framework/framework_model.dart';
import 'package:fml/widgets/scroller/scroller_model.dart';
import 'package:fml/widgets/tabview/tab_view.dart';
import 'package:fml/widgets/widget/widget_model.dart'    ;
import 'package:fml/widgets/drawer/drawer_view.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/phrase.dart';

typedef TitleChangeCallback = void Function (String title);

class FrameworkView extends StatefulWidget
{
  final FrameworkModel model;

  FrameworkView(this.model) : super(key: ObjectKey(model));

  @override
  FrameworkViewState createState() => FrameworkViewState();
}

class FrameworkViewState extends State<FrameworkView> with AutomaticKeepAliveClientMixin implements IModelListener, INavigatorObserver
{
  BusyView? busy;

  // this is used to fire the models onstart
  bool started = false;

  Widget? minimized;
  Widget? maximized;

  @override
  bool get wantKeepAlive => true;

  bool goto = false;

  @override
  void initState() 
  {
    // register model listener
    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();

    super.initState();
  }

  @override
  didChangeDependencies()
  {
    // register route listener
    NavigationObserver().registerListener(this);

    // register event listeners
    widget.model.registerEventListener(EventTypes.home, onHome);
    widget.model.registerEventListener(EventTypes.close, onClose);
    widget.model.registerEventListener(EventTypes.maximize, onMaximize);
    widget.model.registerEventListener(EventTypes.showtemplate, onShowTemplate);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(FrameworkView oldWidget)
  {
    super.didUpdateWidget(oldWidget);

    if ((oldWidget.model != widget.model))
    {
      // reset started to fire again
      started = false;

      // register new route listener
      NavigationObserver().registerListener(this);

      // remove old event listeners
      oldWidget.model.removeEventListener(EventTypes.home, onHome);
      oldWidget.model.removeEventListener(EventTypes.close, onClose);
      oldWidget.model.removeEventListener(EventTypes.maximize, onMaximize);
      oldWidget.model.removeEventListener(EventTypes.showtemplate, onShowTemplate);

      // register new event listeners
      widget.model.registerEventListener(EventTypes.home, onHome);
      widget.model.registerEventListener(EventTypes.close, onClose);
      widget.model.registerEventListener(EventTypes.maximize, onMaximize);
      widget.model.registerEventListener(EventTypes.showtemplate, onShowTemplate);

      // remove old model listener
      oldWidget.model.removeListener(this);

      // register new model listener
      widget.model.registerListener(this);
    }
  }

  @override
  void dispose()
  {
    // Log().debug('Dispose called on framework view => <FML name="${widget.model.templateName}" url="${widget.model.url}"/>');

    // Stop Listening to Route Changes 
    NavigationObserver().removeListener(this);

    if(widget.model.orientation != null)
    {
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
    if (widget.model.findAncestorOfExactType(FrameworkModel) == null) widget.model.dispose();

    // remove event listeners
    widget.model.removeEventListener(EventTypes.home, onHome);
    widget.model.removeEventListener(EventTypes.close, onClose);
    widget.model.removeEventListener(EventTypes.maximize, onMaximize);
    widget.model.removeEventListener(EventTypes.showtemplate, onShowTemplate);
    
    super.dispose();
  }

  BuildContext getNavigatorContext() => context;

  Map<String?,String>? onNavigatorPop()
  {
    return widget.model.onPop();
  }

  void onNavigatorPush({Map<String?, String>? parameters})
  {
    if (parameters != null) widget.model.onPush(parameters);
  }

  void onNavigatorChange()
  {
    widget.model.index = NavigationManager().positionInStack(context);
    if (widget.model.index == 0) widget.model.onTitleChange(context);
  }

  /// Callback function for when the model changes, used to force a rebuild with setState()
  onModelChange(WidgetModel model,{String? property, dynamic value})
  {
    try
    {
      var b = Binding.fromString(property);
      if (widget.model.initialized && this.mounted && b?.property != 'busy') setState(() {});
    }
    catch(e)
    {
      Log().exception(e, caller: 'Framework.View');
    }
  }

  bool onScroll (ScrollNotification notification)
  {
    if ((notification.metrics.axisDirection == AxisDirection.left) || (notification.metrics.axisDirection == AxisDirection.right)) return false;

    double maxHeight = widget.model.header?.height ?? widget.model.header?.constraints.model.maxHeight ?? 0;
    if (maxHeight < 0) maxHeight = 0;

    double minHeight = widget.model.header?.height ?? widget.model.header?.constraints.model.minHeight ?? 0;
    if (minHeight < 0) minHeight = 0;

    // Non-Resizeable Header
    if (minHeight == maxHeight) return true;
    double height;
    double scrolled = notification.metrics.pixels;
    scrolled = scrolled > maxHeight ? maxHeight : scrolled;

    height = maxHeight - scrolled;
    if (height < minHeight) height = minHeight;

    var safeArea = MediaQuery.of(context).padding.top.ceil();
    var viewportHeight = widget.model.constraints.system.maxHeight!;
    widget.model.header?.height = height;
    widget.model.height = viewportHeight - height - (widget.model.footer?.constraints.model.height ?? 0) - safeArea;

    /* Stop Notification Bubble */
    return false;
  }


  void onMinimize()
  {
    setState(()
    {
      maximized = null;
    });
  }

  void onMaximize(Event event) async
  {
    if (event.model != null)
    {
      event.handled = true;
      minimized = context.widget;
      maximized = event.model?.context?.widget;
      setState(() {});
    }
  }


  bool swiping = false;
  double start = 0;
  double last  = 0;
  void onDragStart(DragStartDetails details)
  {
    // IOS back button functionality
    if (details.globalPosition.dx < 50)
    {
      swiping = true;
      start = details.globalPosition.dx;
      last  = details.globalPosition.dx;
    }
  }

  void onDragUpdate(DragUpdateDetails details)
  {
    if (details.globalPosition.dx < last) swiping = false;
    if (swiping) last = details.globalPosition.dx;
  }

  void onDragEnd(DragEndDetails details)
  {
    double velocity = details.velocity.pixelsPerSecond.dx.abs();
    double distance = (last - start);
    if ((swiping) && (distance > 50) && (velocity > 100)) NavigationManager().back(1);
    swiping = false;
    start = 0;
    last = 0;
  }

  void onHome(Event event)
  {
    event.handled = true;
    NavigationManager().back(NavigationManager().pages.length - 1);
  }

  void onShowTemplate(Event event)
  {
    event.handled = true;
    widget.model.showTemplate();
  }

  void onClose(Event event) { // onBack(Event event)
    //OVERLAY.OverlayEntry? overlay = context.findAncestorWidgetOfExactType<OVERLAY.OverlayEntry>();
    TabView? tabview = context.findAncestorWidgetOfExactType<TabView>();
    if (tabview != null) return;
    event.handled = true;
    String? until = S.mapVal(event.parameters, 'until');
    NavigationManager().back(until ?? 1);
  }

  void onExport(Event event) {
    if (event.parameters!['format'] == 'print') {
      event.handled = true;
      final snackBar = SnackBar(content: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(phrase.exportingData)]), duration: Duration(milliseconds: 300), behavior: SnackBarBehavior.floating, elevation: 5);
      ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((_) => Platform.openPrinterDialog());
    }
    else {
      Log().warning('Unhandled Event onExport(format: ${event.parameters!['format'].toString()}, raw: ${event.parameters!['raw'].toString()})');
    }
  }

  // on long press start actions
  Timer? onLongPressTimer;
  void onLongPressStart()
  {
    // show debug window
    if (onLongPressTimer != null) onLongPressTimer!.cancel();
    onLongPressTimer = Timer(Duration(seconds: 1), () => EventHandler(widget.model).executeEvent("DEBUG.open()"));
  }

  // on long press end actions
  void onLongPressEnd()
  {
    if (onLongPressTimer != null) onLongPressTimer!.cancel();
    onLongPressTimer = null;
  }

  Widget _buildHeader(BoxConstraints constraints)
  {
    Widget view = Container();

    if (widget.model.header != null && widget.model.header!.visible != false)
    {
      var model = widget.model.header!;

      var viewportWidth  = constraints.maxWidth;

      // set header constraints
      model.width = viewportWidth - (model.marginLeft ?? 0) - (model.marginRight ?? 0);

      // this is required to drive %sizing
      //model.constraints.system = constraints;

      // build framework header view
      view = model.getView();
    }
    else widget.model.header?.height = 0;

    return view;
  }

  Widget _buildFooter(BoxConstraints constraints)
  {
    Widget view = Container();

    if (widget.model.footer != null && widget.model.footer!.visible != false)
    {
      var model = widget.model.footer!;

      var viewportWidth  = constraints.maxWidth;

      // set footer constraints
      model.layout = "stack";
      model.width  = viewportWidth - (model.marginLeft ?? 0) - (model.marginRight ?? 0);

      // this is required to drive %sizing
      //model.constraints.system = constraints;

      // build framework footer view
      view = model.getView();
    }
    else widget.model.footer?.height = 0;

    return view;
  }

  Widget _buildBody(BoxConstraints constraints)
  {
    var model  = widget.model;
    var header = widget.model.header;
    var footer = widget.model.header;

    // build body
    var safeArea = MediaQuery.of(context).padding.top.ceil();

    var viewportWidth  = constraints.maxWidth;
    var viewportHeight = constraints.maxHeight;

    // set body constraints
    var usedHeight = (header?.height ?? 0) + (footer?.height ?? 0) + safeArea;
    model.height   = viewportHeight- usedHeight - (model.marginTop ?? 0) - (model.marginBottom ?? 0);
    model.width    = viewportWidth - (model.marginLeft ?? 0) - (model.marginRight ?? 0);

    // build framework body
    Widget view =  widget.model.getBoxView();

    // listen to scroll events if the body
    // is wrapped in a Scroller
    if (model.findChildOfExactType(ScrollerModel) != null) view = NotificationListener<ScrollNotification>(onNotification: onScroll, child: view);

    return view;//UnconstrainedBox(child: SizedBox(child: view, width: model.width, height: model.height));
  }

  _setDeviceOrientation(String? orientation)
  {
    List<DeviceOrientation> _orientation = [];

    orientation = orientation?.toLowerCase().trim();
    switch (orientation)
    {
      case "landscape":
        _orientation = [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft];
        break;
      case "portrait":
        _orientation = [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown];
        break;
      case "all":
      default:
        _orientation = [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown, DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft];
        break;
    }
    SystemChrome.setPreferredOrientations(_orientation);
  }

  GestureDetector _getGestureDetector(Widget view, DrawerView? drawer)
  {
    late final GestureDetector detector;

    if (drawer != null)
    {
      detector = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () =>  WidgetModel.unfocus(),
          onVerticalDragStart: (dragStartDetails) => drawer.onDragOpen(dragStartDetails, 'vertical'),
          onHorizontalDragStart: (dragStartDetails) => drawer.onDragOpen(dragStartDetails, 'horizontal'),
          onVerticalDragUpdate: (dragUpdateDetails) => drawer.onDragSheet(dragUpdateDetails, 'vertical', true),
          onHorizontalDragUpdate: (dragUpdateDetails) => drawer.onDragSheet(dragUpdateDetails, 'horizontal', true),
          onVerticalDragEnd: (dragEndDetails) => drawer.onDragEnd(dragEndDetails, 'vertical', false),
          onHorizontalDragEnd: (dragEndDetails) => drawer.onDragEnd(dragEndDetails, 'horizontal', false),
          onLongPressStart: kDebugMode ? (_) => onLongPressStart() : null,
          onLongPressEnd:   kDebugMode ? (_) => onLongPressEnd()   : null,
          child: view);

      return detector;
    }

    // simulate a swipe to move back on all desktop applications
    // and mobile IOS applications
    bool enableSwipeBack = isDesktop || (isMobile && System().useragent == "ios");

    if (enableSwipeBack)
    {
      detector = GestureDetector(behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: onDragStart,
          onHorizontalDragEnd: onDragEnd,
          onHorizontalDragUpdate: onDragUpdate,
          onTap: () =>  WidgetModel.unfocus(),
          onLongPressStart: kDebugMode ? (_) => onLongPressStart() : null,
          onLongPressEnd:   kDebugMode ? (_) => onLongPressEnd()   : null,
          child: view);

      return detector;
    }

    detector = GestureDetector(behavior: HitTestBehavior.translucent,
        onTap: () =>  WidgetModel.unfocus(),
        onLongPressStart: kDebugMode ? (_) => onLongPressStart() : null,
        onLongPressEnd:   kDebugMode ? (_) => onLongPressEnd()   : null,
        child: view);

    return detector;
  }
  @override
  Widget build(BuildContext context)
  {
    super.build(context);
    return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // model is initializing
    if (!widget.model.initialized) return Scaffold(body: Center(child: BusyView(BusyModel(null, visible: true))));

    // set the system constraints
    widget.model.setLayoutConstraints(constraints);

    Log().debug('Build called on framework view => <FML name=${widget.model.templateName} url="${widget.model.url}"/>');

    // stop listening during build
    widget.model.removeListener(this);

    // fire navigator change
    onNavigatorChange();

    // set device orientation
    _setDeviceOrientation(widget.model.orientation);

    // post onstart callback
    if (!started)
    {
      started = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.model.onStart(context));
    }

    // build framework header
    Widget header = _buildHeader(constraints);

    // build framework footer
    Widget footer = _buildFooter(constraints);

    // build framework body
    Widget body = _buildBody(constraints);

    // framework is header, body, footer stacked in a single column inside a fixed frame
    Widget view = Column(children: [header, body, footer]);

    // We need to provide the stacks children to drawer because positioned
    // widgets must be direct children but the drawer uses a builder widget
    DrawerView? drawer;
    if (widget.model.drawer != null) drawer = DrawerView(widget.model.drawer!, view);

    // wrap view in gesture detector
    view = _getGestureDetector(view,drawer);

    // scaffold with safe area
    view = SafeArea(child: Scaffold(resizeToAvoidBottomInset: true, body: view));

    // start listening to model changes
    widget.model.registerListener(this);

    return view;
  }
}
