// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/switch/switch_model.dart';
import 'package:fml/widgets/viewable/viewable_widget_view.dart';
import 'package:fml/widgets/viewable/viewable_widget_state.dart';
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

    bool value = widget.model.value;
    String? label = widget.model.label;
    bool canSwitch = widget.model.enabled && widget.model.editable;

    // view
    ColorScheme th = Theme.of(context).colorScheme;
    Widget view = Switch.adaptive(
      value: value, onChanged: canSwitch ? onChange : null,
      // activeColor: th.inversePrimary, activeTrackColor: th.primaryContainer, inactiveThumbColor: th.onInverseSurface, inactiveTrackColor: th.surfaceVariant,);
      activeColor: widget.model.color ?? th.primary,
      activeTrackColor:
          widget.model.color?.withOpacity(0.65) ?? th.inversePrimary,
      inactiveThumbColor: th.onInverseSurface,
      inactiveTrackColor: th.surfaceVariant,
    );

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
              color: th.onSurfaceVariant.withOpacity(0.75))),
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
