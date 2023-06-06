// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/widgets/box/box_view.dart';
import 'package:fml/widgets/button/button_model.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/helper/common_helpers.dart';
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
    var foregroundColorStyle = (!S.isNullOrEmpty(model.color) && model.buttontype != 'elevated') ?
    MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states)
    {
      if (states.contains(MaterialState.disabled)) return Theme.of(context).colorScheme.surfaceVariant;
      return model.color;// not sure if this is the correct color scheme for text.
    }) : null;

    var backgroundColorStyle = (!S.isNullOrEmpty(model.color) && model.buttontype == 'elevated') ?
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
    var model = widget.model;
    var style = _getStyle();
    var onPressed = (model.onclick != null && model.enabled != false) ? () => model.onPress(context) : null;

    switch (model.buttontype)
    {
      case 'outlined': return OutlinedButton(style: style, onPressed: onPressed, child: body);
      case 'elevated': return ElevatedButton(style: style, onPressed: onPressed, child: body);
      default: return TextButton(style: style, onPressed: onPressed, child: body);
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    var body = BoxView(widget.model);

    // Build the Button Types
    var view = _buildButton(body);

    // If onclick is null or enabled is false we fade the button
    if (widget.model.onclick == null || widget.model.enabled == false) view = Opacity(opacity: 0.9, child: view); // Disabled

    // add margins
    view = addMargins(view);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.constraints);

    // allow button to shrink to size of its contents
    view = UnconstrainedBox(child: view);

    return view;
  }
}
