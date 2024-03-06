// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/button/button_model.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/widgets/widget/widget_state.dart';

/// Button View
///
/// Builds the Button View from [ButtonModel] properties
class ButtonView extends StatefulWidget implements IWidgetView
{
  @override
  final ButtonModel model;
  final Widget? child;

  ButtonView(this.model, {this.child});

  @override
  State<ButtonView> createState() => _ButtonViewState();
}

class _ButtonViewState extends WidgetState<ButtonView>
{
  ButtonStyle _getStyle()
  {
    var model = widget.model;

    BorderRadius? radius = BorderRadius.only(
        topRight: Radius.circular(widget.model.radiusTopRight),
        bottomRight: Radius.circular(widget.model.radiusBottomRight),
        bottomLeft: Radius.circular(widget.model.radiusBottomLeft),
        topLeft: Radius.circular(widget.model.radiusTopLeft));

    if (model.buttontype == 'elevated') {
      return ElevatedButton.styleFrom(
          minimumSize:  Size(model.constraints.minWidth ?? 64, (model.constraints.minHeight ?? 0) + 40), //add 40 to the constraint as the width is offset by 40
          backgroundColor: model.color ?? Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          disabledForegroundColor: Theme.of(context).colorScheme.onSurface,
          shadowColor: Theme.of(context).colorScheme.shadow,
          shape: RoundedRectangleBorder(borderRadius: radius),
          elevation: 3);
    }


    var borderSideStyle = model.buttontype == 'outlined' ? MaterialStateProperty.resolveWith((states)
    {
      if (states.contains(MaterialState.disabled)) {
        return BorderSide(style: BorderStyle.solid, color: Theme.of(context).colorScheme.surfaceVariant, width: 2);
      }
        return BorderSide(style: BorderStyle.solid, color: model.color ?? Theme.of(context).colorScheme.primary, width: 2);
    }) : null;

    var elevationStyle = model.buttontype == 'elevated' ? MaterialStateProperty.resolveWith((states)
    {
      if (states.contains(MaterialState.hovered)) return 8.0;
      if (states.contains(MaterialState.focused) || states.contains(MaterialState.pressed)) return 3.0;
      return 5.0;
    }) : null;
    
    // Button Type Styling
    var foregroundColorStyle = (!isNullOrEmpty(model.color) && model.buttontype != 'elevated') ?
    MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states)
    {
      if (states.contains(MaterialState.disabled)) return Theme.of(context).colorScheme.surfaceVariant;
      return model.color;// not sure if this is the correct color scheme for text.
    }) : null;

    var backgroundColorStyle = (!isNullOrEmpty(model.color) && model.buttontype == 'elevated') ?
    MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states)
    {
      if (states.contains(MaterialState.hovered)) return model.color!.withOpacity(0.85);
      if (states.contains(MaterialState.focused) || states.contains(MaterialState.pressed)) return model.color!.withOpacity(0.2);
      if (states.contains(MaterialState.disabled)) return Theme.of(context).colorScheme.shadow;
      return model.color;
    }) : null; // Defer to the widget

    var buttonShape = MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: radius));

    return ButtonStyle(
      minimumSize: MaterialStateProperty.all(
          Size(model.constraints.minWidth ?? 64, (model.constraints.minHeight?? 0) + 40)), //add 40 to the constraint as the width is offset by 40
      foregroundColor: foregroundColorStyle,
      backgroundColor: backgroundColorStyle,
      // overlayColor: overlayColorStyle,
      shape: buttonShape,
      side: borderSideStyle,
      elevation: elevationStyle,
    );
  }
  
  Widget _buildButton(Widget body)
  {
    var style = _getStyle();
    var onPressed = (widget.model.onclick != null && widget.model.enabled) ? () => widget.model.onPress(context) : null;

    Widget view;
    switch (widget.model.buttontype)
    {
      case 'outlined':
        view = OutlinedButton(style: style, onPressed: onPressed, child: body);
        break;
      case 'elevated':
        view = ElevatedButton(style: style, onPressed: onPressed, child: body);
        break;
      default:
        view = TextButton(style: style, onPressed: onPressed, child: body);
        break;
    }

    // If onclick is null or enabled is false we fade the button
    if (widget.model.onclick == null || !widget.model.enabled) view = Opacity(opacity: 0.9, child: view); // Disabled

    return view;
  }

  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // build the body
    Widget body = BoxView(widget.model.getContentModel());

    // disabled?
    if (!widget.model.enabled)
    {
      body = Opacity(opacity: .8, child: body);
    }

    // Build the Button Types
    var view = _buildButton(body);

    // apply constraints
    view = applyConstraints(view, widget.model.constraints);

    // add margins around the entire widget
    view = addMargins(view);

    return view;
  }
}
