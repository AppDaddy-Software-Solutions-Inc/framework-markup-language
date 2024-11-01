// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/switch/switch_model.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/text/text_view.dart';

class SwitchView extends StatefulWidget implements ViewableWidgetView {
  @override
  final SwitchModel model;
  final dynamic onChangeCallback;
  const SwitchView(this.model, {super.key, this.onChangeCallback});

  @override
  State<SwitchView> createState() => _SwitchViewState();
}

class _SwitchViewState extends ViewableWidgetState<SwitchView>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    ColorScheme theme = Theme.of(context).colorScheme;

    bool value = widget.model.value;
    String? label = widget.model.label;
    bool canSwitch = widget.model.enabled && widget.model.editable;

    // inactive thumb color (left)
    var c1 = widget.model.color ?? theme.primary;

    // active thumb color (right)
    var c2 = widget.model.color2 ?? c1;

    // track color
    var c3 = widget.model.color3 ?? c1.withOpacity(0.5);

    // border color
    var c4 = widget.model.borderColor ?? c3;

    // view
    Widget view = Switch.adaptive(
      value: value, onChanged: canSwitch ? onChange : null,
        inactiveThumbColor: c1,
        inactiveTrackColor: c3,
        activeColor: c2,
        activeTrackColor: c3,
        trackOutlineColor: WidgetStateProperty.all(c4));

    // disabled?
    if (!canSwitch) {
      view = MouseRegion(
          cursor: SystemMouseCursors.forbidden,
          child: Tooltip(
              message: 'Locked',
              preferBelow: false,
              verticalOffset: 12,
              child: view));
    }

    // labelled?
    if (widget.model.label != null) {
      view = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text(label, style: TextStyle(fontStyle: )),
          TextView(TextModel(null, null,
              value: label,
              style: 'caption',
              color: theme.onSurfaceVariant.withOpacity(0.75))),
          view
        ],
      );
    }

    // add margins
    view = addMargins(view);

    // apply visual transforms
    view = applyTransforms(view);

    // apply constraints
    view = applyConstraints(view, widget.model.constraints);

    return view;
  }

  onChange(bool value) async {
    if (!widget.model.editable) return;

    // value changed?
    if (widget.model.value != value) {
      // set answer
      await widget.model.answer(value);

      // fire the onChange event
      await widget.model.onChange(mounted ? context : null);
    }
  }
}
