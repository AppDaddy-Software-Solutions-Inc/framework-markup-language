// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/box/box_data.dart';
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/pager/page/page_model.dart';
import 'package:fml/widgets/viewable/viewable_widget_model.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
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
    super.initState();

    _controller = PageController(initialPage: (widget.model.currentpage - 1));
    widget.model.controller = _controller;
  }


  Widget buildPage(BuildContext context, int index)
  {
    return _pages[index];
  }

  void page(dynamic page)
  {
    int currentPage = _controller!.page!.toInt() + 1;
    int? pageNum = S.toInt(page);
    int pages = widget.model.pages.length;

    if (pageNum == null && page is String) {
      switch (page.trim().toLowerCase()) {
        case 'previous':
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
    if (diff > 9) {
      _controller!.jumpToPage(pageNum - 1);
    } else {
      _controller!.animateToPage(pageNum - 1, duration: Duration(milliseconds: diff * 150), curve: Curves.easeInOutQuad);
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