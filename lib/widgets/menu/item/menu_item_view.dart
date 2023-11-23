// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fml/helpers/color.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/menu/item/menu_item_model.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/widget/widget_state.dart';

class MenuItemView extends StatefulWidget implements IWidgetView
{
  @override
  final MenuItemModel model;

  MenuItemView(this.model) : super(key: ObjectKey(model));

  String? getTitle() {
    return model.title;
  }

  @override
  State<MenuItemView> createState() => _MenuItemViewState();
}

class _MenuItemViewState extends WidgetState<MenuItemView>
{
  bool isHovered = false;

  @override
  Widget build(BuildContext context)
  {
    ColorScheme t = Theme.of(context).colorScheme;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    Widget menuItem = SizedBox.shrink();
    double borderRadius = widget.model.radius ?? 8.0;
    var shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius));

    if (widget.model.children != null)
    {
      // build the child views
      List<Widget> children = widget.model.inflate();
      if (children.isEmpty) children.add(Container());
      Widget child = children.length == 1
          ? children[0]
          : Column(
              children: children, mainAxisAlignment: MainAxisAlignment.center);

      Widget button = MaterialButton(
          onPressed: onTap,
          shape: shape,
          elevation: 0,
          hoverElevation: 0,
          minWidth: isMobile ? 160 : 250,
          height: isMobile ? 160 : 250,
          color: widget.model.backgroundimage == null
              ? Colors.transparent
              : t.background,
          hoverColor: widget.model.backgroundimage == null
              ? ColorHelper.lighten(widget.model.backgroundcolor ?? Colors.white, 0.1).withOpacity(0.1)
              : t.onSecondary,
          child: Padding(
              padding: EdgeInsets.all(isMobile ? 0 : 10), child: child));
      button = MouseRegion(cursor: SystemMouseCursors.click, child: button);
      Widget customButton = Padding(
          padding: EdgeInsets.all(isMobile ? 0 : 10),
          child: Container(
            width: isMobile
                ? 160
                : 250, // These constraints are more strict than a Material Button's
            height: isMobile ? 160 : 250,
            child: button, // button
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            ),
          ));
      menuItem = customButton;
    }
    else
    {
      //  Static Item
      String? backgroundImage = widget.model.backgroundimage;
      Widget? image;
      if (widget.model.image != null)
      {
        // svg image?
        if (widget.model.image!.mimeType == "image/svg+xml") {
          image = SvgPicture.memory(widget.model.image!.contentAsBytes(), width: 48, height: 48);
        } else {
          image = Image.memory(widget.model.image!.contentAsBytes(), width: 48, height: 48, fit: null);
        }
      }

      Widget? icon;
      if (widget.model.icon != null)
      {
        double size = (widget.model.iconsize ?? 48.0) - (isMobile ? 4 : 0);
        Color color = widget.model.iconcolor ?? t.primary; //System.colorDefault;
        icon = Icon(widget.model.icon ?? Icons.touch_app, size: size, color: color);
        double? opacity = widget.model.iconopacity;
        if (opacity != null) icon = Opacity(opacity: opacity, child: icon);
        icon = Center(child: icon);
      }

      Text? title;
      if (widget.model.title != null)
      {
        title = Text(widget.model.title ?? '', textAlign: TextAlign.center, style: TextStyle(fontSize: (widget.model.fontsize ?? 16.0) - (isMobile ? 2 : 0), color: backgroundImage != null
                    ? (widget.model.fontcolor ?? Colors.black)
                    : widget.model.fontcolor ?? t.primary,
                fontWeight:
                    Theme.of(context).primaryTextTheme.titleLarge!.fontWeight));
      }

      Text? subtitle;
      if (widget.model.subtitle != null) {
        subtitle = Text(widget.model.subtitle ?? '',
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(
                fontSize: widget.model.fontsize != null
                    ? widget.model.fontsize! - 4
                    : 12,
                color: backgroundImage != null
                    ? (widget.model.fontcolor ?? Colors.black)
                    : widget.model.fontcolor ?? t.onBackground));
      }

      List<Widget> btn = [];

      if (image != null) {
        btn.add(image);
      } else if (icon != null) {
        btn.add(icon);
      }
      btn.add(Container(height: 10));
      if (title != null) btn.add(title);
      btn.add(Container(height: 10));
      if (subtitle != null) btn.add(subtitle);
      Widget button = MaterialButton(
          elevation: backgroundImage != null ? 2.0 : 0,
          hoverElevation: backgroundImage != null ? 3.0 : 0,
          highlightElevation: 0,
          minWidth: isMobile ? 160 : 250,
          height: isMobile ? 160 : 250,
          child: Padding(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: btn,
                  mainAxisSize: MainAxisSize.max),
              padding: EdgeInsets.all(isMobile ? 0 : 10)),
          color: backgroundImage != null
              ? Colors.white.withOpacity(0.4)
              : t.surface,
          hoverColor: backgroundImage != null
              ? Colors.white.withOpacity(0.2)
              : t.onSecondary,
          animationDuration: Duration(milliseconds: 200),
          onPressed: widget.model.enabled != false
              ? (widget.model.onTap ?? onTap)
              : null,
          onLongPress: widget.model.enabled != false
              ? (widget.model.onLongPress)
              : null,
          shape: shape);

      if (widget.model.enabled != false) {
        button = MouseRegion(cursor: SystemMouseCursors.click, child: button);
      }

      Widget staticButton = Padding(
          padding: EdgeInsets.all(isMobile ? 0 : 10),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: isMobile
                ? 160
                : 250, // These constraints are more strict than a Material Button's
            height: isMobile ? 160 : 250,
            child: button, // button
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                // color: Colors.grey[300],
                boxShadow: !isHovered
                    ? null
                    : [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? t.shadow.withOpacity(0.75)
                              : t.shadow.withOpacity(0.25),
                          offset: Offset(4, 4),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: t.onSecondary.withOpacity(0.75),
                          offset: Offset(-2, -2),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]),
          ));

      menuItem = isMobile
          ? staticButton
          : MouseRegion(
              cursor: SystemMouseCursors.click,
              onHover: (event)
              {
                if (!isHovered) setState(() => isHovered = true);
              },
              onExit: (event)
              {
                if (isHovered) setState(() => isHovered = false);
              },
              child: staticButton);
    }
    return menuItem;
  }

  void onTap() async
  {
    WidgetModel.unfocus();
    widget.model.onClick();
  }

  Widget? getView() => throw("getView() Not Implemented");
}
