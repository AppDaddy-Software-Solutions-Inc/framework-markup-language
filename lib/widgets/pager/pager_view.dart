// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/event/manager.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/event/event.dart' ;
import 'package:fml/widgets/busy/busy_view.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/widgets/pager/pager_model.dart';
import 'package:fml/widgets/pager/page/pager_page_view.dart';
import 'package:fml/widgets/pager/page/pager_page_model.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class PagerView extends StatefulWidget implements IWidgetView
{
  final PagerModel model;
  PagerView(this.model) : super(key: ObjectKey(model));

  @override
  _PagerViewState createState() => _PagerViewState();
}

class _PagerViewState extends WidgetState<PagerView>
{
  PageController? _controller;
  List<PagerPageView> _pages = [];
  BusyView? busy;

  @override
  void initState()
  {
    super.initState();

    _controller = PageController(initialPage: (widget.model.initialpage != null ? widget.model.initialpage! - 1 : 0));
    widget.model.currentpage = widget.model.initialpage ?? 1;
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


  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // save system constraints
    onLayout(constraints);

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    /// Busy / Loading Indicator
    if (busy == null) busy = BusyView(BusyModel(widget.model, visible: widget.model.busy, observable: widget.model.busyObservable));

    /////////////////
    /* Build Pages */
    /////////////////
    _pages = [];
    for (PagerPageModel model in widget.model.pages)
    {
      var page = PagerPageView(model);
      _pages.add(page);
    }

    dynamic pageView = PageView.builder(
        controller: _controller,
        itemBuilder: buildPage,
        itemCount: _pages.length,
        // Maintains our `currentpage` bindable when a page is changed, by dotsindicator/scroll/drag/event
        onPageChanged: (int page) => widget.model.currentpage = page + 1);

    dynamic pager = widget.model.pager ? Positioned(bottom: 8, child: Container(child: DotsIndicator(controller: _controller!, itemCount: _pages.length, color: widget.model.color ?? Theme.of(context).colorScheme.onBackground,
      onPageSelected: (int page) {
        _controller!.animateToPage(page, duration: Duration(milliseconds: 150), curve: Curves.ease,);
      },
    ))) : Container();

    var c = widget.model.constraints.calculate();
    if (!c.isNotEmpty && constraints.maxWidth == double.infinity)
      pageView = UnconstrainedBox(child: SizedBox(height: widget.model.height ?? widget.model.calculateMaxHeight(), width: widget.model.width ?? widget.model.calculateMaxWidth(), child: pageView));

    var view = Stack(alignment: Alignment.bottomCenter, children: [pageView, pager, Center(child: busy)]);

    return view;
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
      if (to.toLowerCase() == "previous")
        page = page - 1;
      else if (to.toLowerCase() == "next")
        page = page + 1;
      else if (to.toLowerCase() == "first")
        page = 1;
      else if (to.toLowerCase() == "last")
        page = pages;
      else if (S.isNumber(to)) page = S.toInt(to)!;

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
    return new Container(
      width: _kDotSpacing,
      child: new Center(
        child: new Material(
          color: color,
          type: MaterialType.circle,
          child: new Container(
            width: _kDotSize * zoom,
            height: _kDotSize * zoom,
            child: new InkWell(splashColor: color!.withOpacity(0.5),
              onTap: () => onPageSelected!(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List<Widget>.generate(itemCount!, _buildDot),
    );
  }
}