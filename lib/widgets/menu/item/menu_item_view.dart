// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fml/widgets/menu/item/menu_item_model.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'package:fml/widgets/widget/model.dart';

// platform
import 'package:fml/platform/platform.vm.dart'
if (dart.library.io) 'package:fml/platform/platform.vm.dart'
if (dart.library.html) 'package:fml/platform/platform.web.dart';

class MenuItemView extends StatefulWidget implements ViewableWidgetView {
  @override
  final MenuItemModel model;

  MenuItemView(this.model) : super(key: ObjectKey(model));

  String? getTitle() {
    return model.title;
  }

  @override
  State<MenuItemView> createState() => _MenuItemViewState();
}

class _MenuItemViewState extends ViewableWidgetState<MenuItemView> {

  bool isHovered = false;

  Widget animate(Widget view) {

    var theme = Theme.of(context).colorScheme;

    var s1 =  isHovered ? BoxShadow(
      color: Theme.of(context).brightness == Brightness.dark
          ? theme.shadow.withOpacity(0.75)
          : theme.shadow.withOpacity(0.25),
      offset: const Offset(4, 4),
      blurRadius: 10,
      spreadRadius: 1,
    ) : null;

    var s2 = isHovered ? BoxShadow(
      color: theme.onSecondary.withOpacity(0.75),
      offset: const Offset(-2, -2),
      blurRadius: 10,
      spreadRadius: 1,
    ) : null;

    var decoration = BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(8.0)), boxShadow: isHovered ? [s1!, s2!] : null);

    view = Padding(
        padding: EdgeInsets.all(isMobile ? 0 : 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width:  widget.model.width, // These constraints are more strict than a Material Button's
          height: widget.model.height, // button
          decoration: decoration,
          child: view));

    view = isMobile
        ? view
        : MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: (event) {
          if (!isHovered) setState(() => isHovered = true);
        },
        onExit: (event) {
          if (isHovered) setState(() => isHovered = false);
        },
        child: view);

    return view;
  }

  Widget buildDynamicView() {

    var theme = Theme.of(context).colorScheme;
    var borderRadius = 8.0;
    var shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius));

    // build the child views
    List<Widget> children = widget.model.inflate();
    if (children.isEmpty) children.add(Container());

    Widget child = children.length == 1
        ? children[0]
        : Column(
        mainAxisAlignment: MainAxisAlignment.center, children: children);

    var c1 = widget.model.color  ?? theme.surface;
    var c2 = widget.model.color2 ?? theme.onSecondary;

    Widget button = MaterialButton(
        onPressed: onTap,
        shape: shape,
        elevation: 0,
        hoverElevation: 0,
        minWidth: widget.model.width,
        height: widget.model.height,
        color: c1,
        hoverColor: c2,
        child: Padding(
            padding: EdgeInsets.all(isMobile ? 0 : 10),
            child: child));

    if (widget.model.enabled) {
      button = MouseRegion(cursor: SystemMouseCursors.click, child: button);
    }

    // return animated item
    return animate(button);
  }

  Widget buildDefaultView() {

    var theme = Theme.of(context).colorScheme;
    var shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0));

    List<Widget> btn = [];

    //  image
    Widget? image;
    if (widget.model.image != null) {

      // svg image?
      if (widget.model.image!.mimeType == "image/svg+xml") {

        image = SvgPicture.memory(widget.model.image!.contentAsBytes(),
            width: 48, height: 48);

      } else {

        image = Image.memory(widget.model.image!.contentAsBytes(),
            width: 48, height: 48, fit: null);
      }
      btn.add(image);
    }

    // icon
    Widget? icon;
    if (image == null && widget.model.icon != null) {
      var size = (widget.model.iconsize ?? 48.0) - (isMobile ? 4 : 0);
      var color = widget.model.iconcolor ?? theme.primary;
      icon = Icon(widget.model.icon ?? Icons.touch_app, size: size, color: color);
      icon = Center(child: icon);
      btn.add(icon);
    }

    // title
    Text? title;
    btn.add(Container(height: 10));
    if (widget.model.title != null) {
      title = Text(widget.model.title ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: (widget.model.fontsize ?? 16.0) -
                  (isMobile ? 2 : 0),
              color: widget.model.fontcolor ?? theme.primary,
              fontWeight:
              Theme.of(context).primaryTextTheme.titleLarge!.fontWeight));
      btn.add(title);
    }

    // subtitle
    Text? subtitle;
    btn.add(Container(height: 10));
    if (widget.model.subtitle != null) {
      subtitle = Text(widget.model.subtitle ?? '',
          textAlign: TextAlign.center,
          softWrap: true,
          style: TextStyle(
              fontSize: widget.model.fontsize != null
                  ? widget.model.fontsize! - 4
                  : 12,
              color: widget.model.fontcolor ?? theme.onSurface));
      btn.add(subtitle);
    }

    // colors
    var c1 = widget.model.color  ?? theme.surface;
    var c2 = widget.model.color2 ?? theme.onSecondary;

    Widget button = MaterialButton(
        elevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        minWidth: widget.model.width,
        height:   widget.model.height,
        color: c1,
        hoverColor: c2,
        animationDuration: const Duration(milliseconds: 200),
        onPressed:
        widget.model.enabled ? (widget.model.onTap ?? onTap) : null,
        onLongPress: widget.model.enabled ? (widget.model.onLongPress) : null,
        shape: shape,
        child: Padding(
            padding: EdgeInsets.all(isMobile ? 0 : 10),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: btn)));

    if (widget.model.enabled) {
      button = MouseRegion(cursor: SystemMouseCursors.click, child: button);
    }

    // return animated item
    return animate(button);
  }

  @override
  Widget build(BuildContext context) {

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // build view
    Widget view = widget.model.children?.isEmpty ?? true
        ? buildDefaultView()
        : buildDynamicView();

    return view;
  }

  void onTap() async {
    Model.unfocus();
    widget.model.onClick();
  }
}
