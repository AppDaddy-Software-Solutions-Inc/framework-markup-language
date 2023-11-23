// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/icon/icon_model.dart';
import 'dart:math' as math;

import 'package:fml/widgets/widget/widget_state.dart';

class IconView extends StatefulWidget implements IWidgetView {
  @override
  final IconModel model;

  IconView(this.model) : super(key: ObjectKey(model));

  @override
  State<IconView> createState() => _IconViewState();
}

class _IconViewState extends WidgetState<IconView> {

  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    IconData? value = widget.model.icon;

    double? size = 32;
    if (widget.model.size != null) size = widget.model.size;

    ///////////
    /* Color */
    ///////////
    Color? color = Theme.of(context).colorScheme.inverseSurface;
    if (widget.model.color != null) color = widget.model.color;
    if (widget.model.opacity != null) {
      color = color!.withOpacity(widget.model.opacity!);
    }

    // view
    Widget view = Icon(value, size: size, color: color);

    // rotation
    if (widget.model.rotation != 0) {
      view = Transform.rotate(
          angle: widget.model.rotation * math.pi / 180, child: view);
    }

    return view;
  }
}
