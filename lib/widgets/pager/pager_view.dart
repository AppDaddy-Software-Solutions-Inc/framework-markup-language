// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/widgets/box/box_data.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/pager/page/page_model.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/event/event.dart' ;
import 'package:fml/widgets/busy/busy_view.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/widgets/pager/pager_model.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class PagerView extends StatefulWidget implements IWidgetView
{
  @override
  final PagerModel model;
  PagerView(this.model) : super(key: ObjectKey(model));

  @override
  State<PagerView> createState() => PagerViewState();
}

class PagerViewState extends WidgetState<PagerView>
{
  PageController? _controller;
  List<Widget> _pages = [];
  Widget? busy;
  Widget? pageView;
  Widget? pager;

  @override
  void initState()
  {
    // call before super so that we don't trigger a loop on the listener created in super.initState();

    // stop listening to prevent rebuilt
    widget.model.removeListener(this);
    widget.model.currentpage = widget.model.initialpage ?? 1;
    // resume listening to model changes
    widget.model.registerListener(this);

    super.initState();

    _controller = PageController(initialPage: (widget.model.initialpage != null ? widget.model.initialpage! - 1 : 0));
    widget.model.controller = _controller;
  }

  @override
  void didChangeDependencies()
  {
    // register event listeners
    EventManager.of(widget.model)?.registerEventListener(EventTypes.page, onPage);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(PagerView oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.model != widget.model))
    {
      // remove old event listeners
      EventManager.of(oldWidget.model)?.removeEventListener(EventTypes.page, onPage);

      // register new event listeners
      EventManager.of(widget.model)?.registerEventListener(EventTypes.page, onPage);
    }
  }

  @override
  void dispose()
  {
    // remove old event listeners
    EventManager.of(widget.model)?.removeEventListener(EventTypes.page, onPage);

    super.dispose();
  }

  @override
  onModelChange(WidgetModel model, {String? property, value})
  {
    // TODO missing setState?
  }

  Widget buildPage(BuildContext context, int index)
  {
    return _pages[index];
  }

  void onPage(Event event)
  {
    if ((event.parameters != null) &&
        (event.parameters!.containsKey('page'))) {
      int page = _controller!.page!.toInt() + 1; // add 1 because page 1 is index 0
      int initialPage = page;
      int pages = widget.model.pages.length;

      String to = event.parameters!['page']!;
      if (to.toLowerCase() == "previous") {
        page = page - 1;
      } else if (to.toLowerCase() == "next") {
        page = page + 1;
      } else if (to.toLowerCase() == "first") {
        page = 1;
      } else if (to.toLowerCase() == "last") {
        page = pages;
      } else if (S.isNumber(to)) {
        page = S.toInt(to)!;
      }

      if (pages == 0) {
        event.handled = true;
        return;
      }

      if (page > pages) page = 1;
      if (page < 1) page = pages;
      int diff = (initialPage - page).abs();
      if (diff > 9) _controller!.jumpToPage(page - 1);
      _controller!.animateToPage(page - 1, duration: Duration(milliseconds: diff * 150), curve: Curves.easeInOutQuad);

      event.handled = true;
    }
  }

  // called by models inflate
  List<Widget> inflate(BoxConstraints constraints)
  {
    List<Widget> list = [];

    // create page view
    if (pageView == null)
    {
      // Build Pages
      _pages = [];
      for (PageModel model in widget.model.pages)
      {
        var view = LayoutBoxChildData(model: model, child: model.getView());
        _pages.add(view);
      }
      pageView = PageView.builder(controller: _controller, itemBuilder: buildPage, itemCount: _pages.length, onPageChanged: (int page) => widget.model.currentpage = page + 1);
      pageView = LayoutBoxChildData(model: widget.model, child: pageView!);
    }
    list.add(pageView!);

    // create pager
    if (pager == null && widget.model.pager)
    {
      var model = ViewableWidgetModel(widget.model, null);
      pager = Container(child: DotsIndicator(controller: _controller!, itemCount: _pages.length, color: widget.model.color ?? Theme.of(context).colorScheme.onBackground,
          onPageSelected: (int page)
          {
            _controller!.animateToPage(page, duration: Duration(milliseconds: 150), curve: Curves.ease,);
          }));
      pager = LayoutBoxChildData(model: model, child: pager!, bottom: 8);
    }
    if (pager != null)
    {
      list.add(pager!);
    }

    // create busy indicator
    if (busy == null)
    {
      var model = BusyModel(widget.model, visible: widget.model.busy, observable: widget.model.busyObservable);
      busy = BusyView(model);
      busy = LayoutBoxChildData(model: model, child: busy!);
    }
    list.add(busy!);

    return list;
  }

  @override
  Widget build(BuildContext context) => BoxView(widget.model);
}

class DotsIndicator extends AnimatedWidget {
  DotsIndicator({
    required this.controller,
    this.itemCount,
    this.onPageSelected,
    this.color,
  }) : super(listenable: controller);

  /// The PageController that this DotsIndicator is representing.
  final PageController controller;

  /// The number of items managed by the PageController
  final int? itemCount;

  /// Called when a dot is tapped
  final ValueChanged<int>? onPageSelected;

  /// The color of the dots.
  ///
  /// Defaults to `Colors.white`.
  final Color? color;

  // The base size of the dots
  static const double _kDotSize = 8.0;

  // The increase in the size of the selected dot
  static const double _kMaxZoom = 1.55;

  // The distance between the center of each dot
  static const double _kDotSpacing = 14.0;

  Widget _buildDot(int index) {
    double zoom = 1.0 + (_kMaxZoom - 1.0) * (index == (controller.page ?? controller.initialPage) ? 1 : 0);
    return Container(
      width: _kDotSpacing,
      child: Center(
        child: Material(
          color: color,
          type: MaterialType.circle,
          child: Container(
            width: _kDotSize * zoom,
            height: _kDotSize * zoom,
            child: InkWell(splashColor: color!.withOpacity(0.5),
              onTap: () => onPageSelected!(index),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(itemCount!, _buildDot),
    );
  }
}