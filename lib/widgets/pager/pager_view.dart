// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/pager/page/page_model.dart';
import 'package:fml/widgets/positioned/positioned_model.dart';
import 'package:fml/widgets/viewable/viewable_widget_view.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/widgets/pager/pager_model.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/widgets/viewable/viewable_widget_state.dart';

class PagerView extends StatefulWidget implements ViewableWidgetView {
  @override
  final PagerModel model;
  PagerView(this.model) : super(key: ObjectKey(model));

  @override
  State<PagerView> createState() => PagerViewState();
}

class PagerViewState extends ViewableWidgetState<PagerView> {
  PageController? _controller;
  List<Widget> _pages = [];
  Widget? busy;
  Widget? pageView;
  Widget? pager;

  @override
  void initState() {
    super.initState();

    _controller = PageController(initialPage: (widget.model.currentpage - 1));
    widget.model.controller = _controller;
  }

  Widget buildPage(BuildContext context, int index) {
    return _pages[index];
  }

  void pageTo(dynamic page, String transition) {
    int currentPage = _controller!.page!.toInt() + 1;
    int? pageNum = toInt(page);
    int pages = widget.model.pages.length;

    if (pageNum == null && page is String) {
      switch (page.trim().toLowerCase()) {
        case 'previous':
        case 'prev':
          pageNum = currentPage - 1;
          if (pageNum < 1) pageNum = pages;
          break;
        case 'next':
          pageNum = currentPage + 1;
          if (pageNum > pages) pageNum = 1;
          break;
        case 'first':
          pageNum = 1;
          break;
        case 'last':
          pageNum = pages;
          break;
        default:
          break;
      }
    }

    pageNum ??= 1;

    if (pageNum > pages) pageNum = 1;
    if (pageNum < 1) pageNum = pages;
    int diff = (currentPage - pageNum).abs();

    // jump to page
    if (transition == "jump") {
      _controller!.jumpToPage(pageNum - 1);
    }

    // animate to page
    else {
      _controller!.animateToPage(pageNum - 1,
          duration: Duration(milliseconds: diff * 150),
          curve: Curves.easeInOutQuad);
    }
  }

  // called by models inflate
  List<Widget> inflate() {
    List<Widget> list = [];

    // create page view
    if (pageView == null) {

      // Build Pages
      _pages = [];
      for (PageModel model in widget.model.pages) {
        var view = model.getView();
        _pages.add(view);
      }

      pageView = PageView.builder(
          controller: _controller,
          itemBuilder: buildPage,
          itemCount: _pages.length,
          onPageChanged: (int page) => widget.model.currentpage = page + 1);

      pageView = BoxView(widget.model, children: [pageView!]);
    }

    list.add(pageView!);

    // create pager
    if (pager == null && widget.model.pager) {

      pager = DotsIndicator(
          controller: _controller!,
          itemCount: _pages.length,
          color:
              widget.model.color ?? Theme.of(context).colorScheme.onBackground,
          onPageSelected: (int page) =>
              pageTo(page + 1, widget.model.transition));

      var model = PositionedModel(widget.model, null, bottom: 8, child: pager);

      pager = BoxView(model, children: [Positioned(bottom: 8, child: pager!)]);
    }
    if (pager != null) {
      list.add(pager!);
    }

    // create busy indicator
    if (busy == null) {
      var model = BusyModel(widget.model,
          visible: widget.model.busy, observable: widget.model.busyObservable);
      busy = model.getView();
    }
    list.add(busy!);

    return list;
  }

  @override
  Widget build(BuildContext context) => BoxView(widget.model);
}

class DotsIndicator extends AnimatedWidget {
  const DotsIndicator({
    super.key,
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
    double zoom = 1.0 +
        (_kMaxZoom - 1.0) *
            (index == (controller.page ?? controller.initialPage) ? 1 : 0);
    return SizedBox(
      width: _kDotSpacing,
      height: (_kDotSize * zoom),
      child: Center(
        child: Material(
          color: color,
          type: MaterialType.circle,
          child: SizedBox(
            width: _kDotSize * zoom,
            height: _kDotSize * zoom,
            child: InkWell(
              splashColor: color!.withOpacity(0.5),
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
