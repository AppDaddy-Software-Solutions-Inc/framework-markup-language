// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/event/event.dart';
import 'package:flutter/material.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/phrase.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/framework/framework_model.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:fml/widgets/modal/modal_model.dart';
import 'package:fml/widgets/busy/busy_view.dart';
import 'package:fml/widgets/tabview/tab_model.dart';
import 'package:fml/widgets/framework/framework_view.dart';
import 'package:fml/helper/common_helpers.dart';

class TabView extends StatefulWidget implements IWidgetView
{
  final TabModel model;

  TabView(this.model) : super(key: ObjectKey(model));

  @override
  _TabViewState createState() => _TabViewState();
}

class _TabViewState extends WidgetState<TabView> with TickerProviderStateMixin
{
  BusyView? busy;
  TabController? _tabController;

  @override
  didChangeDependencies()
  {
    // register event listeners
    EventManager.of(widget.model)?.registerEventListener(EventTypes.refresh, onRefresh, priority: 0);
    EventManager.of(widget.model)?.registerEventListener(EventTypes.open, onOpen, priority: 0);
    EventManager.of(widget.model)?.registerEventListener(EventTypes.close, onClose, priority: 0);
    EventManager.of(widget.model)?.registerEventListener(EventTypes.back, onBack, priority: 0);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(TabView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.model != widget.model))
    {
      // remove old event listeners
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.refresh, onRefresh);
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.open, onOpen);
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.close, onClose);
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.back, onBack);

      // register new event listeners
      EventManager.of(widget.model)?.registerEventListener(EventTypes.refresh, onRefresh, priority: 0);
      EventManager.of(widget.model)?.registerEventListener(EventTypes.open, onOpen, priority: 0);
      EventManager.of(widget.model)?.registerEventListener(EventTypes.close, onClose, priority: 0);
      EventManager.of(widget.model)?.registerEventListener(EventTypes.back, onBack, priority: 0);
    }
  }

  @override
  void dispose()
  {
    // remove old event listeners
    EventManager.of(widget.model)?.removeEventListener(EventTypes.refresh, onRefresh);
    EventManager.of(widget.model)?.removeEventListener(EventTypes.open, onOpen);
    EventManager.of(widget.model)?.removeEventListener(EventTypes.close, onClose);
    EventManager.of(widget.model)?.removeEventListener(EventTypes.back, onBack);

    super.dispose();
  }

  void onRefresh(Event event) async
  {
    // mark event as handled
    event.handled = true;
    if (widget.model.index != null)
    {
      // get the url
      String url = widget.model.views.keys.toList()[widget.model.index!];

      // display the page
      _showPage(url, refresh: true);
    }
  }

  void onOpen(Event event) async
  {
    // url
    String? url;
    if (event.parameters != null && event.parameters!.containsKey('url')) url = event.parameters!['url'];

    // modal
    bool? modal = false;
    if ((event.parameters != null) && (event.parameters!.containsKey('modal'))) modal = S.toBool(event.parameters!['modal']);
    if ((modal != true) && (event.model != null)) modal = (event.model!.findDescendantOfExactType(ModalModel, id: url) != null);

    // allow framework to handle open if fully qualified
    if (url != null)
    {
      var uri = Uri.tryParse(url);
      if (uri != null && uri.isAbsolute) return;
    }

    // allow framework to handle open if Modal
    if (modal == true) return;

    // mark event as handled
    event.handled = true;

    // String template = uri.host;
    var uri = URI.parse(url);
    if (uri == null)
    {
      Log().error('Missing template $url');
      System.toast('${phrase.missingTemplate} $url');
      return;
    }

    String? template = uri.url.toLowerCase();
    if (template == 'previous') return _showPrevious();
    if (template == 'next')     return _showNext();
    if (template == 'first')    return _showFirst();
    if (template == 'last')     return _showLast();

    return _showPage(uri.url, event: event);
  }

  void _showPrevious()
  {
    if (widget.model.index == null) return;

    int i = widget.model.index! - 1;
    if (i < 0) i = widget.model.views.length - 1;
    widget.model.index = i;
  }

  void _showNext()
  {
    if (widget.model.index == null) return;
    int i = widget.model.index! + 1;
    if (i >= widget.model.views.length) i = 0;
    widget.model.index = i;
  }

  void _showFirst() => widget.model.index = 0;

  void _showLast()
  {
    int i = widget.model.views.length - 1;
    if (i < 0) i = 0;
    widget.model.index = i;
  }

  void _showPage(String url, {bool refresh = false, Event? event}) async
  {
    FrameworkView  view;
    FrameworkModel model;

    // New Tab
    if ((!widget.model.views.containsKey(url)) || (refresh == true))
    {
      // build the model
      model = FrameworkModel.fromUrl(widget.model, url, dependency: event?.model?.id);

      // build the view
      view = FrameworkView(model);

      // save the view
      widget.model.views[url] = view;
    }

    // Open Tab
    else view = widget.model.views[url] as FrameworkView;

    int i = widget.model.views.values.toList().indexOf(view);
    widget.model.index = i;
  }

  onTap() => widget.model.index = _tabController!.index;

  onButtonTap(dynamic v)
  {
    if (v == -1 && widget.model.index != null) {
      widget.model.deleteAllIndexesExcept(widget.model.index!);
      _showFirst();
    }
    else {
      widget.model.index = v;
      if (widget.model.views.containsValue(v)) {
        int i = widget.model.views.values.toList().indexOf(v);
        widget.model.index = i;
      }
    }
  }

  void onBack(Event event)
  {
    int until = int.parse(event.parameters?['until'] ?? '1');
    if (widget.model.views.length > 0 && widget.model.index != null)
    {
      while(until > 0) {
        until--;
        var view = widget.model.views.values.toList()[widget.model.index!];
        widget.model.deleteView(view);

        int i = widget.model.index! - 1;
        if (i < 0) i = widget.model.views.length - 1;
        widget.model.index = i;
      }
      event.handled = true;
    }
  }

  void onClose(Event event) {
    onBack(event);
  }

  _onDelete(Widget view)
  {
    widget.model.deleteView(view);
    _showPrevious();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  List<Tab> _buildTabs(double? height)
  {
    List<Tab> tabs = [];

    // process each view
    widget.model.views.forEach((url, view)
    {
      Uri uri = URI.parse(url)!;

      // Has delete button?
      bool closeable = S.toBool(uri.queryParameters['closeable']) ?? true;
      Widget delete = (closeable == false) ? Container()
      : Padding(padding: EdgeInsets.only(right: 5), child: Container(width: 26, height: 26,
          child: IconButton(onPressed: () => _onDelete(view), padding: EdgeInsets.all(1.5), icon: Icon(Icons.close, size: 22, color: Theme.of(context).colorScheme.onSurfaceVariant))));

      // tab bar
      String title   = uri.queryParameters['title'] ?? url;
      Widget child = Row(children: [
        Expanded(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
              Flexible(child: Text(title, overflow: TextOverflow.clip))
            ])),
        Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [delete])
      ]);
      Tab tab = Tab(
          child: Tooltip(
              waitDuration: Duration(milliseconds: 500),
              message: url,
              child: Container(height: height, child: child)));
      tabs.add(tab);
    });
    return tabs;
  }

  Widget _buildTabBar({double? height})
  {
    // Build List of Tabs
    List<Tab> tabs = _buildTabs(height);

    // Initialize Controller
    _tabController = TabController(length: tabs.length, vsync: this, initialIndex: widget.model.index ?? 0, animationDuration: Duration(milliseconds: 100));

    // Add Listener
    _tabController!.addListener(onTap);

    // Tab Bar
    var bar = TabBar(controller: _tabController,
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        indicator: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(14.0), topRight: Radius.circular(14.0)), color: Theme.of(context).colorScheme.surface),
        labelColor: Theme.of(context).colorScheme.onBackground,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        tabs: tabs);

    // Formatted bar
    var view = Container(child: bar, height: height, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.only(topLeft: Radius.circular(14.0), topRight: Radius.circular(14.0))));

    return view;
  }

  Widget _buildTabsButton({double? height})
  {
    // Build List of Tabs
    List<PopupMenuItem> popoverItems = [];

    // Build close all but open tab
    PopupMenuItem closeOtherTabs = PopupMenuItem(child: Text('Close other tabs', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)), value: -1);
    popoverItems.add(closeOtherTabs);

    int i = 0;
    widget.model.views.forEach((url, view)
    {
      Uri? uri = URI.parse(url);
      String title = uri?.queryParameters['title'] ?? url;

      // Style
      var style = widget.model.index == i ? TextStyle(color: Theme.of(context).colorScheme.primary) : TextStyle(color: Theme.of(context).colorScheme.secondary);

      // Button
      PopupMenuItem button = PopupMenuItem(child: Text(title, style: style), value: i);

      popoverItems.add(button);
      i++;
    });

    var popover = PopupMenuButton(
      tooltip: 'Show tab list',
      color: Theme.of(context).colorScheme.surface,
      onSelected: (val) => onButtonTap(val),
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[...popoverItems],
      child: Container(decoration: BoxDecoration(color: Theme.of(context).colorScheme.onInverseSurface, borderRadius: BorderRadius.all(Radius.circular(100))), child: Padding(padding: EdgeInsets.all(5), child: Icon(Icons.clear_all, size: 22, color: Theme.of(context).colorScheme.inverseSurface))),
    );

    return popover;
  }

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // save system constraints
    widget.model.setSystemConstraints(constraints);

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    if (widget.model.views.isNotEmpty)
    {
      double barheight = 38.0;
      double barpadding = 6.0;
      double buttonWidth = 38.0;

      ///////////////////
      /* Build Tab Bar */
      ///////////////////
      var bar = _buildTabBar(height: barheight - barpadding);

      //////////////////////
      /* Build Button Bar */
      //////////////////////
      var button = _buildTabsButton(height: barheight);

      ////////////////
      /* Max Height */
      ////////////////
      double? height = widget.model.getGlobalMaxHeight();

      ////////////////
      /* Split View */
      ////////////////
      dynamic view;

      if (widget.model.tabbar == true && widget.model.tabbutton == true) {
        view = Column(children: [
          Container(color: Theme.of(context).colorScheme.onInverseSurface, child:
            Padding(padding: EdgeInsets.only(top: barpadding), child: SizedBox(width: widget.model.getGlobalMaxWidth(), height: barheight,
                child: Row(children: [
                  SizedBox(width: (widget.model.getGlobalMaxWidth()! - buttonWidth < 0 ? 0 : widget.model.getGlobalMaxWidth()! - buttonWidth),
                      height: barheight,
                      child: bar),
                  SizedBox(width: buttonWidth, height: barheight, child: button),
                ]),
              )
            )
          ),
          SizedBox(
              height: height! - barheight - barpadding,
              child: IndexedStack(
                  children: widget.model.views.values.toList(),
                  index: widget.model.index))
        ]);
      }
      else if (widget.model.tabbar == true && widget.model.tabbutton == false)
      {
        var con = widget.model.getGlobalConstraints();

        view = Column(children: [
          SizedBox(width: widget.model.getGlobalMaxWidth(), height: barheight,
            child: bar
          ),
          SizedBox(
              height: height! - barheight - barpadding,
              child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: con.minHeight!,
                maxHeight: con.maxHeight!,
                minWidth: con.minWidth!,
                maxWidth: con.maxWidth!),
                  child: IndexedStack(
                    children: widget.model.views.values.toList(),
                    index: widget.model.index)))
        ]);
      }
      else if (widget.model.tabbar == false && widget.model.tabbutton == true) {
        view = Stack(children: [
          IndexedStack(
            children: widget.model.views.values.toList(),
            index: widget.model.index),
          Positioned(top: 0, right: 0, child: button),
        ]);
      }
      else if (widget.model.tabbar == false && widget.model.tabbutton == false) {
        view = IndexedStack(
            children: widget.model.views.values.toList(),
            index: widget.model.index);
      }

      // apply user defined constraints
      return applyConstraints(view, widget.model.getLocalConstraints());
    }
    else return Container();
  }
}