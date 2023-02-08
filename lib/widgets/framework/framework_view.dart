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
import 'package:fml/widgets/footer/footer_model.dart';
import 'package:fml/widgets/framework/framework_model.dart';
import 'package:fml/widgets/tabview/tab_view.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart'    ;
import 'package:fml/widgets/header/header_view.dart';
import 'package:fml/widgets/header/header_model.dart';
import 'package:fml/widgets/footer/footer_view.dart';
import 'package:fml/widgets/drawer/drawer_view.dart';
import 'package:fml/widgets/box/box_model.dart';
import 'package:fml/widgets/box/box_view.dart';
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
  ScrollController _scrollController = ScrollController();

  // this is used to fire the models onstart
  bool started = false;

  Widget? minimized;
  Widget? maximized;

  BoxModel headerModel = BoxModel(null, null);
  BoxModel footerModel = BoxModel(null, null);
  BoxModel drawerModel = BoxModel(null, null);
  BoxModel bodyModel   = BoxModel(null, null);
  List<DeviceOrientation> orientation = [];

  DrawerView? drawerView;

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

    _scrollController.dispose();

    // framework is top level model?
    // cleanup the model
    if (widget.model.findAncestorOfExactType(FrameworkModel) == null) widget.model.dispose();

    // cleanup
    headerModel.dispose();
    footerModel.dispose();
    drawerModel.dispose();
    bodyModel.dispose();

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

  @override
  Widget build(BuildContext context)
  {
    super.build(context);
    return LayoutBuilder(builder: builder);
  }

  double viewportWidth  = 0;
  double viewportHeight = 0;
  double viewportSafeArea = 0;

  bool onScroll (ScrollNotification notification)
  {
    if ((notification.metrics.axisDirection == AxisDirection.left) || (notification.metrics.axisDirection == AxisDirection.right)) return false;

    double maxHeight = widget.model.header?.height ?? widget.model.header?.maxextent ?? 0;
    if (maxHeight < 0) maxHeight = 0;

    double minHeight = widget.model.header?.height ?? widget.model.header?.minextent ?? 0;
    if (minHeight < 0) minHeight = 0;

    // Non-Resizeable Header
    if (minHeight == maxHeight) return true;
    double height;
    double scrolled = notification.metrics.pixels;
    scrolled = scrolled > maxHeight ? maxHeight : scrolled;
    height = maxHeight - scrolled;
    if (height < minHeight) height = minHeight;
    headerModel.height  = height;
    bodyModel.height    = viewportHeight - height - (footerModel.height ?? 0) - viewportSafeArea.ceil();

    // Opacity Fade
    if (widget.model.header!.animation == Animations.fade)
    {
      headerModel.opacity = 0;
      if (maxHeight != 0) headerModel.opacity = height / maxHeight;
    }

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

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // model is initializing
    if (!widget.model.initialized) return Scaffold(body: Center(child: BusyView(BusyModel(null, visible: true))));

    // fire navigator change
    onNavigatorChange();

    // set orientation
    String ori = widget.model.orientation ?? 'all';
    switch (ori.toLowerCase())
    {
      case "landscape":
        orientation = [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft];
        break;
      case "portrait":
        orientation = [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown];
        break;
      case "all":
        orientation = [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown, DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft];
        break;
      default:
        orientation = [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown, DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft];
        break;
    }
    SystemChrome.setPreferredOrientations(orientation);

    // set constraints
    widget.model.minwidth  = constraints.minWidth;
    widget.model.maxwidth  = constraints.maxWidth;
    widget.model.minheight = constraints.minHeight;
    widget.model.maxheight = constraints.maxHeight;

    // build body
    List<Widget> children = [];
    widget.model.children?.forEach((model)
    {
      if (model is IViewableWidget) {
        children.add((model as IViewableWidget).getView());
      }
    });
    if (children.isEmpty) children.add(Container());

    // post onstart callback
    if (!started)
    {
      started = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.model.onStart(context));
    }

    viewportWidth  = constraints.maxWidth;
    viewportHeight = constraints.maxHeight;

    viewportSafeArea = MediaQuery.of(context).padding.top;

    // build header model
    Widget header = Container();
    if (widget.model.header != null && widget.model.header!.visible != false)
    {
      HeaderModel model  = widget.model.header!;
      headerModel.width  = viewportWidth;
      headerModel.height = model.height ?? model.maxextent;
      header = BoxView(headerModel, child: HeaderView(model));
    }

    // build footer model
    Widget footer = Container();
    if (widget.model.footer != null && widget.model.footer!.visible != false)
    {
      FooterModel model  = widget.model.footer!;
      footerModel.width  = viewportWidth;
      footerModel.height = model.height ?? 0;
      footer = BoxView(footerModel, child: FooterView(model));
    }

    bodyModel.height = viewportHeight - (headerModel.height ?? 0) - (footerModel.height ?? 0) - viewportSafeArea.ceil();
    bodyModel.width  = viewportWidth;
    Widget body = NotificationListener<ScrollNotification>(onNotification: onScroll, child: BoxView(bodyModel, child: Stack(fit: StackFit.loose, children: children)));

    List<Widget> stackChildren = [];
    stackChildren.add(header);
    stackChildren.add(body);
    stackChildren.add(footer);

    // We need to provide the stacks children to drawer because positioned
    // widgets must be direct children but the drawer uses a builder widget
    drawerView = (widget.model.drawer != null) ? DrawerView(widget.model.drawer!, Column(mainAxisSize: MainAxisSize.min, children: [...stackChildren])) : null;
    Widget? drawer = drawerView != null ? drawerView : Container();

    // primary view
    Widget? view = drawerView != null ? drawer : Container(child: SingleChildScrollView( controller: _scrollController, child: Column(mainAxisSize: MainAxisSize.min, children: [...stackChildren])));

    // scaffold with safe area
    view = SafeArea(child: Scaffold(resizeToAvoidBottomInset: true, body: view));

    final detector = (drawerView != null) ?
      GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () =>  WidgetModel.unfocus(),
      onVerticalDragStart: (dragStartDetails) => drawerView!.onDragOpen(dragStartDetails, 'vertical'),
      onHorizontalDragStart: (dragStartDetails) => drawerView!.onDragOpen(dragStartDetails, 'horizontal'),
      onVerticalDragUpdate: (dragUpdateDetails) => drawerView!.onDragSheet(dragUpdateDetails, 'vertical', true),
      onHorizontalDragUpdate: (dragUpdateDetails) => drawerView!.onDragSheet(dragUpdateDetails, 'horizontal', true),
      onVerticalDragEnd: (dragEndDetails) => drawerView!.onDragEnd(dragEndDetails, 'vertical', false),
      onHorizontalDragEnd: (dragEndDetails) => drawerView!.onDragEnd(dragEndDetails, 'horizontal', false),
      onLongPressStart: kDebugMode ? (_) => onLongPressStart() : null,
      onLongPressEnd:   kDebugMode ? (_) => onLongPressEnd()   : null,
      child: view)
     :
     GestureDetector(behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: onDragStart,
      onHorizontalDragEnd: onDragEnd,
      onHorizontalDragUpdate: onDragUpdate,
      onTap: () =>  WidgetModel.unfocus(),
      onLongPressStart: kDebugMode ? (_) => onLongPressStart() : null,
      onLongPressEnd:   kDebugMode ? (_) => onLongPressEnd()   : null,
      child: view);

    return detector;
  }

  bool swiping = false;
  double start = 0;
  double last  = 0;
  void onDragStart(DragStartDetails details)
  {
    // IOS back button functionality
    if ((System().useragent == "ios" || isDesktop) && (details.globalPosition.dx < 50))
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
}
