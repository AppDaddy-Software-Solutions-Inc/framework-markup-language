// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fml/helper/color.dart';
import 'package:fml/observable/scope.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/menu/item/menu_item_model.dart';
import 'package:fml/widgets/widget/iViewableWidget.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/widgets/image/image_view.dart';
import 'package:fml/helper/helper_barrel.dart';

class MenuItemView extends StatefulWidget
{
  final MenuItemModel model;

  MenuItemView(this.model) : super(key: ObjectKey(model));

  String? getTitle() {
    return this.model.title;
  }

  @override
  _MenuItemViewState createState() => _MenuItemViewState();
}

class _MenuItemViewState extends State<MenuItemView>
    implements IModelListener {
  @override
  void initState() {
    super.initState();

    
    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(MenuItemView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if ((oldWidget.model != widget.model)) {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }

  }

  @override
  void dispose() {
    widget.model.removeListener(this);

    super.dispose();
  }

  /// Callback function for when the model changes, used to force a rebuild with setState()
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    if (this.mounted) setState(() {});
  }

  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    ColorScheme t = Theme.of(context).colorScheme;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    Widget menuItem = SizedBox.shrink();
    double borderRadius = widget.model.radius ?? 8.0;
    var shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius));

    if (widget.model.children != null) {
      // Custom Item

      ////////////////////
      /* Build Children */
      ////////////////////
      List<Widget> children = [];
      if (widget.model.children != null)
        widget.model.children!.forEach((model) {
          if (model is IViewableWidget) {
            children.add((model as IViewableWidget).getView());
          }
        });
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
    } else {
      //  Static Item
      String? backgroundImage = widget.model.backgroundimage;
      Widget? iconImage;
      if (!S.isNullOrEmpty(widget.model.iconBase64))
        iconImage = Image.memory(base64Decode(widget.model.iconBase64!),
            width: 48, height: 48, fit: null);
      else if (widget.model.iconImage != null)
        iconImage = ImageView.getImage(widget.model.iconImage,
            scope: Scope.of(widget.model), width: 48, height: 48, fit: null);
      Widget? icon;
      if (widget.model.icon != null) {
        double size =
            (widget.model.iconsize ?? 48.0) - (isMobile ? 4 : 0);
        Color color =
            widget.model.iconcolor ?? t.primary; //System.colorDefault;
        icon = Icon(widget.model.icon ?? Icons.touch_app,
            size: size, color: color);

        double? opacity = widget.model.iconopacity;
        if (opacity != null) icon = Opacity(opacity: opacity, child: icon);

        icon = Center(child: icon);
      }

      var title;
      if (widget.model.title != null) {
        title = Text(widget.model.title ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize:
                    (widget.model.fontsize ?? 16.0) - (isMobile ? 2 : 0),
                color: backgroundImage != null
                    ? (widget.model.fontcolor ?? Colors.black)
                    : widget.model.fontcolor ?? t.primary,
                fontWeight:
                    Theme.of(context).primaryTextTheme.headline6!.fontWeight));
      }

      var subtitle;
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

      if (iconImage != null)
        btn.add(iconImage);
      else if (icon != null) btn.add(icon);
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
              ? (widget.model.onLongPress ?? null)
              : null,
          shape: shape);

      if (widget.model.enabled != false)
        button = MouseRegion(cursor: SystemMouseCursors.click, child: button);

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
              onHover: (event) => setState(() => isHovered = true),
              onExit: (event) => setState(() => isHovered = false),
              child: staticButton);
    }
    return menuItem;
  }

  void onTap() async
  {
    WidgetModel.unfocus();
    widget.model.onClick();
  }
}
