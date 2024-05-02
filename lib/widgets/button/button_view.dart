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
  ButtonStyle _getStyle() {
    var model = widget.model;

    BorderRadius? radius = BorderRadius.only(
        topRight: Radius.circular(widget.model.radiusTopRight),
        bottomRight: Radius.circular(widget.model.radiusBottomRight),
        bottomLeft: Radius.circular(widget.model.radiusBottomLeft),
        topLeft: Radius.circular(widget.model.radiusTopLeft));

    if (model.type == 'elevated') {
      return ElevatedButton.styleFrom(
          minimumSize: Size(
              model.constraints.minWidth ?? 64,
              (model.constraints.minHeight ?? 0) +
                  40), //add 40 to the constraint as the width is offset by 40
          backgroundColor: model.color ?? Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          disabledForegroundColor: Theme.of(context).colorScheme.onSurface,
          shadowColor: Theme.of(context).colorScheme.shadow,
          shape: RoundedRectangleBorder(borderRadius: radius),
          elevation: 3);
    }

    var borderWidth = widget.model.borderWidth ?? 1;

    var borderSideStyle = model.type == 'outlined'
        ? MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return BorderSide(
                  style: BorderStyle.solid,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  width: borderWidth);
            }
            return BorderSide(
                style: BorderStyle.solid,
                color: model.color ?? Theme.of(context).colorScheme.primary,
                width: borderWidth);
          })
        : null;

    var elevationStyle = model.type == 'elevated'
        ? MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.hovered)) return 8.0;
            if (states.contains(MaterialState.focused) ||
                states.contains(MaterialState.pressed)) return 3.0;
            return 5.0;
          })
        : null;

    // Button Type Styling
    var foregroundColorStyle =
        (!isNullOrEmpty(model.color) && model.type != 'elevated')
            ? MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) {
                  return Theme.of(context).colorScheme.surfaceVariant;
                }
                return model
                    .color; // not sure if this is the correct color scheme for text.
              })
            : null;

    var backgroundColorStyle =
        (!isNullOrEmpty(model.color) && model.type == 'elevated')
            ? MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                if (states.contains(MaterialState.hovered)) {
                  return model.color!.withOpacity(0.85);
                }
                if (states.contains(MaterialState.focused) ||
                    states.contains(MaterialState.pressed)) {
                  return model.color!.withOpacity(0.2);
                }
                if (states.contains(MaterialState.disabled)) {
                  return Theme.of(context).colorScheme.shadow;
                }
                return model.color;
              })
            : null; // Defer to the widget

    var buttonShape =
        MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: radius));

    return ButtonStyle(
      minimumSize: MaterialStateProperty.all(Size(
          model.constraints.minWidth ?? 64,
          (model.constraints.minHeight ?? 0) +
              40)), //add 40 to the constraint as the width is offset by 40
      foregroundColor: foregroundColorStyle,
      backgroundColor: backgroundColorStyle,
      // overlayColor: overlayColorStyle,
      shape: buttonShape,
      side: borderSideStyle,
      elevation: elevationStyle,
    );
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

    // If onclick is null or enabled is false we fade the button
    if (widget.model.onclick == null || !widget.model.enabled) {
      view = Opacity(opacity: 0.9, child: view); // Disabled
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
