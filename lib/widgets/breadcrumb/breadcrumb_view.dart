// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/navigation/navigation_manager.dart';
import 'package:flutter/material.dart';
import 'package:fml/navigation/page.dart';
import 'package:fml/widgets/breadcrumb/breadcrumb_model.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_state.dart';

/// Breadcrumb View
///
/// Builds the View from the [BREADCRUMB.BreadcrumbModel] properties
class BreadcrumbView extends StatefulWidget implements IWidgetView
{
  @override
  final BreadcrumbModel model;

  /// Height of the breadcrumb bar
  final double height = 25;

  final ScrollController sc = ScrollController();
  ScrollController getScrollController() {
    return sc;
  }

  BreadcrumbView(this.model) : super(key: ObjectKey(model));

  @override
  State<BreadcrumbView> createState() => _BreadcrumbViewState();
}

class _BreadcrumbViewState extends WidgetState<BreadcrumbView>
{
  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    double height = widget.model.height ?? widget.height;

    List<Widget> children = [];
    List<Page> pages = NavigationManager().pages;

    int index = 0;
    for (var page in pages) {
      if (page.arguments is PageConfiguration) {
        PageConfiguration conf = (page.arguments as PageConfiguration);
        Widget view = _TextCrumb(
            conf.breadcrumb,
            widget.model.color ?? Theme.of(context).colorScheme.onBackground,
            height,
            '/',
            index == 0);

        int i = pages.length - (index + 1);
        if (i > 0) {
          view = GestureDetector(
              onTap: () => NavigationManager().back(i), child: view);
        } else {
          view = GestureDetector(
              onTap: () => NavigationManager().refresh(), child: view);
        }
        children.add(view);

        index++;
      }
    }

    // Shortens the length of breadcrumbs from the length of the full screen when given a width < 0 or sets the width if given > 0
    // ^ this is an older feature and could likely be removed.
    double? shorten;
    if (widget.model.width != null) {
      shorten = ((widget.model.width!.isNegative) &&
              (MediaQuery.of(context).size.width + widget.model.width! > 0))
          ? widget.model.width
          : ((widget.model.width! >= 0) &&
                  (MediaQuery.of(context).size.width - widget.model.width! >=
                      0))
              ? (widget.model.width! - MediaQuery.of(context).size.width)
              : 0;
    } else {
      shorten = 0;
    }
    return Container(
        color: widget.model.backgroundcolor
                ?.withOpacity(widget.model.opacity ?? 1.0) ??
            Colors.transparent,
        height: height,
        width: MediaQuery.of(context).size.width + shorten!,
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: widget.sc,
            child: Row(
              children: [/*goBack ?? Container(), */ ...children],
              mainAxisSize: MainAxisSize.max,
            )));
  }
}

/// TextCrumb Widget
///
/// The individual crumbs that are contained in the [BREADCRUMB.getView]
/// These are clickable piece of text that navigate to previous routes on the stack
class _TextCrumb extends StatefulWidget {
  final String text;
  final Color color;
  final double height;
  final String separator;
  final bool isFirstButton;

  _TextCrumb(
      this.text, this.color, this.height, this.separator, this.isFirstButton);

  @override
  _TextCrumbState createState() => _TextCrumbState();
}

class _TextCrumbState extends State<_TextCrumb> {
  bool hovered = false;

  void setHovered(bool hovered) {
    setState(() => this.hovered = hovered);
  }

  @override
  Widget build(BuildContext context) {
    Widget crumb = Container(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        child: Padding(
          padding: EdgeInsetsDirectional.only(
              start: widget.isFirstButton ? 16 : 8, end: 8),
          child: Text(
            widget.isFirstButton ? '' : widget.separator,
            style: TextStyle(color: widget.color, fontSize: 14),
          ),
        ),
      ),
      MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (event) {
            setHovered(true);
          },
          onExit: (event) {
            setHovered(false);
          },
          child: Container(
            child: Text(
              widget.text,
              style: TextStyle(
                  color: widget.color,
                  fontSize: 13,
                  decoration:
                      hovered ? TextDecoration.underline : TextDecoration.none),
            ),
          ))
    ]));
    return crumb;
  }
}
