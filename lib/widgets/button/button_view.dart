// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/button/button_model.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'package:fml/helpers/helpers.dart';

/// Button View
///
/// Builds the Button View from [ButtonModel] properties
class ButtonView extends StatefulWidget implements ViewableWidgetView {
  @override
  final ButtonModel model;
  final Widget? child;

  const ButtonView(this.model, {super.key, this.child});

  @override
  State<ButtonView> createState() => _ButtonViewState();
}

class _ButtonViewState extends ViewableWidgetState<ButtonView> {

  ColorScheme? colorScheme;
  Brightness? brightness;

  ButtonStyle _getStyle() {

    var theme = Theme.of(context);

    // elevated button?
    WidgetStateProperty<Color?>? backgroundColor;
    if (widget.model.type == 'elevated') {

      var color    = theme.colorScheme.surfaceContainerLow;
      var disabled = theme.colorScheme.surfaceContainer.withOpacity(0.12);
      var hovered  = theme.colorScheme.surfaceContainerHigh;
      if (widget.model.color != null) {
        color = widget.model.color!;
        disabled = color.withOpacity(.12);
        hovered  = ColorHelper.darken(color);
      }

      backgroundColor = WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) return disabled;
        if (states.contains(WidgetState.hovered))  return hovered;
        return color;
      });
    }

    // outlined button
    WidgetStateProperty<BorderSide?>? border;
    if (widget.model.type == 'outlined') {
      var color = widget.model.borderColor ?? widget.model.color;
      // set border style
      border = WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(
              style: BorderStyle.solid,
              color: color?.withOpacity(0.12) ?? theme.colorScheme.outlineVariant,
              width: widget.model.borderWidth ?? 1);
        }
        return BorderSide(
            style: BorderStyle.solid,
            color: color ?? theme.colorScheme.outline,
            width: widget.model.borderWidth ?? 1);
      });
    }

    // button shape radius
    var radius = BorderRadius.only(
        topRight: Radius.circular(widget.model.radiusTopRight),
        bottomRight: Radius.circular(widget.model.radiusBottomRight),
        bottomLeft: Radius.circular(widget.model.radiusBottomLeft),
        topLeft: Radius.circular(widget.model.radiusTopLeft));

    // button shape
    var shape = WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: radius));

    // button minimum size - add 40 to the constraint as the width is offset by 40
    var size = Size(widget.model.constraints.minWidth ?? 64, (widget.model.constraints.minHeight ?? 0) + 40);

    // button style
    var style = ButtonStyle(
      minimumSize: WidgetStateProperty.all(size),
      // foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
      shape: shape,
      side: border,
    );

    return style;
  }

  var lastOnClick = 0;

  void onClickHandler() {
    // if 0 or less fire set last clicked to 0
    // this will force an onclick event
    if (widget.model.debounce <= 0) lastOnClick = 0;

    // get elapsed time in milliseconds
    var elapsed = DateTime.now().millisecondsSinceEpoch - lastOnClick;

    // elapsed time is greater than debounce time?
    // fire the onclick event
    if (elapsed > widget.model.debounce) {
      // record last clicked time
      lastOnClick = DateTime.now().millisecondsSinceEpoch;

      // fire onclick event
      widget.model.onClick();
    }
  }

  Widget _buildButton(Widget body) {

    // get style
    var style = _getStyle();

    // on click
    var onClick = (widget.model.onclick != null && widget.model.enabled) ?
        () => onClickHandler() : null;

    // If onclick is null or enabled is false we fade the button
    if (widget.model.onclick == null || !widget.model.enabled) {
      body = Opacity(opacity: 0.5, child: body); // Disabled
    }

    Widget view;
    switch (widget.model.type) {
      case 'outlined':
        view = OutlinedButton(style: style, onPressed: onClick, child: body);
        break;
      case 'elevated':
        view = ElevatedButton(style: style, onPressed: onClick, child: body);
        break;
      default:
        view = TextButton(style: style, onPressed: onClick, child: body);
        break;
    }

    return view;
  }

  @override
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // build the body
    var model = widget.model.getContentModel();
    Widget body = BoxView(model, (_,__) => model.inflate());

    // disabled?
    if (!widget.model.enabled) {
      body = Opacity(opacity: .8, child: body);
    }

    // Build the Button Types
    var view = _buildButton(body);

    // add margins
    view = addMargins(view);

    // apply visual transforms
    view = applyTransforms(view);

    // apply constraints
    view = applyConstraints(view, widget.model.constraints);

    return view;
  }
}
