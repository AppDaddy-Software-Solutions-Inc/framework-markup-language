// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:fml/widgets/colorpicker/colorpicker_model.dart';
import 'package:fml/helpers/string.dart';

class ColorPickerView
{
  static launchPicker(ColorpickerModel model, BuildContext? context) async
  {
    if (context == null) return;

    var buttons = ColorPickerActionButtons(dialogActionButtons: false);

    var view = ColorPicker(
        color: toColor(model.value) ?? Colors.transparent,
        onColorChanged: (Color color) => onColorChange(model, color),
        width: model.width ?? 44,
        height: model.height ?? 44,
        hasBorder: model.border != 'none',
        borderRadius: model.radius,
        borderColor: model.borderColor,
        actionButtons: buttons,
        heading: Text('Select color', style: Theme.of(context).textTheme.headlineSmall),
        subheading: Text('Select color shade', style: Theme.of(context).textTheme.titleSmall));

    view.showPickerDialog(context);
  }

  static Future onColorChange(ColorpickerModel model, Color? color) async
  {
    await model.setSelectedColor(color);
  }
}