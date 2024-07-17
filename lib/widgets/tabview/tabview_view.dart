// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:collection/collection.dart';
import 'package:fml/event/event.dart';
import 'package:flutter/material.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'package:fml/widgets/modal/modal_model.dart';
import 'package:fml/widgets/tabview/tabview_model.dart';
import 'package:fml/helpers/helpers.dart';

class TabView extends StatefulWidget implements ViewableWidgetView {

  @override
  final TabViewModel model;

  TabView(this.model) : super(key: ObjectKey(model));

  @override
  State<TabView> createState() => _TabViewState();
}

class _TabViewState extends ViewableWidgetState<TabView> with TickerProviderStateMixin {
  TabController? _tabController;

  double barheight = 38.0;
  double barpadding = 6.0;
  double buttonWidth = 38.0;

  @override
  didChangeDependencies() {
    // register event listeners
    EventManager.of(widget.model)?.registerEventListener(EventTypes.refresh, onRefresh, priority: 0);
    EventManager.of(widget.model)?.registerEventListener(EventTypes.open, onOpen, priority: 0);
    EventManager.of(widget.model)?.registerEventListener(EventTypes.close, onClose, priority: 0);
    EventManager.of(widget.model)?.registerEventListener(EventTypes.back, onBack, priority: 0);
    EventManager.of(widget.model)?.registerEventListener(EventTypes.trigger, onTrigger, priority: 0);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(TabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.model != widget.model)) {
      // remove old event listeners
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.refresh, onRefresh);
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.open, onOpen);
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.close, onClose);
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.back, onBack);
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.trigger, onTrigger);

      // register new event listeners
      EventManager.of(widget.model)?.registerEventListener(EventTypes.refresh, onRefresh, priority: 0);
      EventManager.of(widget.model)?.registerEventListener(EventTypes.open, onOpen, priority: 0);
      EventManager.of(widget.model)?.registerEventListener(EventTypes.close, onClose, priority: 0);
      EventManager.of(widget.model)?.registerEventListener(EventTypes.back, onBack, priority: 0);
      EventManager.of(widget.model)?.registerEventListener(EventTypes.trigger, onTrigger, priority: 0);
    }
  }

  @override
  void dispose() {
    // remove old event listeners
    EventManager.of(widget.model)
        ?.removeEventListener(EventTypes.refresh, onRefresh);
    EventManager.of(widget.model)?.removeEventListener(EventTypes.open, onOpen);
    EventManager.of(widget.model)
        ?.removeEventListener(EventTypes.close, onClose);
    EventManager.of(widget.model)?.removeEventListener(EventTypes.back, onBack);
    EventManager.of(widget.model)?.removeEventListener(EventTypes.trigger, onTrigger);
    super.dispose();
  }

  void onRefresh(Event event) async {
    // mark event as handled
    event.handled = true;

    if (widget.model.index != -1) {

      // get the url
      var url = widget.model.currentTab?.url;

      // display the tab
      if (url != null) widget.model.showTab(url, refresh: true);
    }
  }

  void onOpen(Event event) async {

    // open by url?
    String? url;
    if (event.parameters?.containsKey('url') ?? false) {

      // get the url
      url = event.parameters?['url'];

      // allow framework to handle open if fully qualified
      var uri = url != null ? Uri.tryParse(url) : null;
      if (uri != null && uri.isAbsolute) return;
    }

    // allow framework to handle open if Modal
    bool modal = false;
    if (event.parameters?.containsKey('modal') ?? false) {
      modal = toBool(event.parameters!['modal']) ?? false;
      if (modal) return;
    }
    if (event.model?.findDescendantOfExactType(ModalModel, id: url) != null) return;

    // mark event as handled
    event.handled = true;

    return widget.model.showTab(url, dependency: event.model?.id);
  }

   // As it's not expected that there will be nested views, such as TabView, this function
   // currently only propagates the triggers to any TriggerModels of the view inside the page model.
   // If there are instances of nested views, another method may have to be found to
   // recursively propagate the triggers through each layer. For good measure,
   // the trigger event is broadcast() to the nested model, but this will need
   // to be tested.

  void onTrigger(Event event) async => widget.model.fireTriggers(event);

  onTap() => widget.model.index = _tabController!.index;

  onButtonTap(dynamic v) {

    if (v == -1 && widget.model.index != -1) {

      // remove specified tab
      widget.model.deleteAllTabsExcept(widget.model.index);

      // display first tab
      widget.model.showFirstTab();
    }
    else
    {
      widget.model.index = v;
    }
  }

  void onBack(Event event) {
    int until = int.parse(event.parameters?['until'] ?? '1');
    if (widget.model.tabs.isNotEmpty && widget.model.index != -1) {
      while (until > 0) {
        until--;
        var tab = widget.model.tabs[widget.model.index];
        widget.model.deleteTab(tab);

        int i = widget.model.index - 1;
        if (i.isNegative) i = widget.model.tabs.length - 1;
        widget.model.index = i;
      }
      event.handled = true;
    }
  }

  void onClose(Event event) {
    onBack(event);
  }

  List<Tab> _buildTabs(double? height) {

    List<Tab> tabs = [];

    // process each view
    for (var tab in widget.model.tabs) {

      // build close button
      Widget closeButton = Container();
      if (tab.closeable) {
        closeButton = Padding(
            padding: const EdgeInsets.only(right: 5),
            child: SizedBox(
                width: 26,
                height: 26,
                child: IconButton(
                    onPressed: () => widget.model.deleteTab(tab),
                    padding: const EdgeInsets.all(1.5),
                    icon: Icon(Icons.close,
                        size: 22,
                        color: Theme
                            .of(context)
                            .colorScheme
                            .onSurfaceVariant))));
      }

      // body
      Widget view = Row(children: [
        Expanded(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(child: Text(tab.title, overflow: TextOverflow.clip))
                ])),
        Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [closeButton])
      ]);

      // size the bar
      view = SizedBox(height: height, child: view);

      // add tooltip
      if (tab.url != null && tab.url != tab.title && tab.tooltip != null) {
        view = Tooltip(
            waitDuration: const Duration(milliseconds: 500),
            message: tab.tooltip,
            child: SizedBox(height: height, child: view));
      }

      // add tab
      tabs.add(Tab(child: view));
    }
    return tabs;
  }

  Widget _buildTabBar({double? height}) {
    // Build List of Tabs
    List<Tab> tabs = _buildTabs(height);

    // Initialize Controller
    _tabController = TabController(
        length: tabs.length,
        vsync: this,
        initialIndex: widget.model.index,
        animationDuration: const Duration(milliseconds: 100));

    // Add Listener
    _tabController!.addListener(onTap);

    // Tab Bar
    var bar = TabBar(
        controller: _tabController,
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        indicator: BoxDecoration(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14.0),
                topRight: Radius.circular(14.0)),
            color: Theme.of(context).colorScheme.surface),
        labelColor: Theme.of(context).colorScheme.onSurface,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        tabs: tabs);

    // Formatted bar
    var view = Container(
        height: height,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14.0),
                topRight: Radius.circular(14.0))),
        child: bar);

    return view;
  }

  Widget _buildTabsButton({double? height}) {

      // Build List of Tabs
    List<PopupMenuItem> popoverItems = [];

    bool hasCloseableTabs = widget.model.tabs.firstWhereOrNull((t) => t.closeable) != null;

    // Build close all but open tab
    if (hasCloseableTabs) {

      PopupMenuItem closeOtherTabs = PopupMenuItem(
        value: -1,
        child: Text('Close other tabs',
            style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant)));
      if (widget.model.tabs.isNotEmpty) popoverItems.add(closeOtherTabs);
    }

    int i = 0;
    for (var tab in widget.model.tabs) {

      // Style
      var style = widget.model.index == i
          ? TextStyle(color: Theme.of(context).colorScheme.primary)
          : TextStyle(color: Theme.of(context).colorScheme.secondary);

      // Button
      PopupMenuItem button =
          PopupMenuItem(value: i, child: Text(tab.title, style: style));

      popoverItems.add(button);
      i++;
    }

    var popover = PopupMenuButton(
      tooltip: 'Show tab list',
      color: Theme.of(context).colorScheme.surface,
      onSelected: (val) => onButtonTap(val),
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[...popoverItems],
      child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onInverseSurface,
              borderRadius: const BorderRadius.all(Radius.circular(100))),
          child: Padding(
              padding: const EdgeInsets.all(5),
              child: Icon(Icons.clear_all,
                  size: 22,
                  color: Theme.of(context).colorScheme.inverseSurface))),
    );

    return popover;
  }

  Widget _tabViewWithTabBarAndButton() {
    // max height
    double? height = widget.model.myMaxHeightOrDefault;

    // max width
    double? width = widget.model.myMaxWidthOrDefault;

    // Build Tab Bar
    var bar = _buildTabBar(height: barheight - barpadding);

    // Build Button Bar
    var button = _buildTabsButton(height: barheight);

    // get tab views
    List<Widget> tabs = [];
    for (var tab in widget.model.tabs) {
      tabs.add(tab.getView());
    }

    Widget view = Column(children: [
      Container(
          color: Theme.of(context).colorScheme.onInverseSurface,
          child: Padding(
              padding: EdgeInsets.only(top: barpadding),
              child: SizedBox(
                  width: width,
                  height: barheight,
                  child: Row(children: [
                    SizedBox(
                        width:
                            (width - buttonWidth < 0 ? 0 : width - buttonWidth),
                        height: barheight,
                        child: bar),
                    SizedBox(
                        width: buttonWidth, height: barheight, child: button),
                  ])))),
      SizedBox(
          height: height - barheight - barpadding,
          child: IndexedStack(
              index: widget.model.index,
              children: tabs))
    ]);

    return view;
  }

  Widget _tabViewWithTabBar() {
    // max height
    double? height = widget.model.myMaxHeightOrDefault;

    // max width
    double? width = widget.model.myMaxWidthOrDefault;

    // Build Tab Bar
    var bar = _buildTabBar(height: barheight - barpadding);

    var con = widget.model.constraints;

    // get tab views
    List<Widget> tabs = [];
    for (var tab in widget.model.tabs) {
      tabs.add(tab.getView());
    }

    Widget view = Column(children: [
      SizedBox(width: width, height: barheight, child: bar),
      SizedBox(
          height: height - barheight - barpadding,
          child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: con.minHeight!,
                  maxHeight: con.maxHeight!,
                  minWidth: con.minWidth!,
                  maxWidth: con.maxWidth!),
              child: IndexedStack(
                  index: widget.model.index,
                  children: tabs)))
    ]);

    return view;
  }

  Widget _tabView() {

    // get tab views
    List<Widget> tabs = [];
    for (var tab in widget.model.tabs) {
      tabs.add(tab.getView());
    }

    Widget view = IndexedStack(
        index: widget.model.index,
        children: tabs);

    return view;
  }

  Widget _tabViewWithTabButton() {

    // build button bar
    var button = _buildTabsButton(height: barheight);

    // get tab views
    List<Widget> tabs = [];
    for (var tab in widget.model.tabs) {
      tabs.add(tab.getView());
    }

    // build indexed stack
    Widget view = Stack(children: [
      IndexedStack(
          index: widget.model.index,
          children: tabs),
      Positioned(top: 0, right: 0, child: button),
    ]);

    return view;
  }

  Widget _buildTabView() {

    // no tabs defined
    if (widget.model.tabs.isEmpty) return Container();

    // tab bar
    if (widget.model.tabbar) {
      return widget.model.tabbutton
          ? _tabViewWithTabBarAndButton()
          : _tabViewWithTabBar();
    }

    // no tab bar
    else {
      return widget.model.tabbutton ? _tabViewWithTabButton() : _tabView();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // build the view
    Widget view = _buildTabView();

    // add margins
    view = addMargins(view);

    // apply visual transforms
    view = applyTransforms(view);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.constraints);

    return view;
  }
}
