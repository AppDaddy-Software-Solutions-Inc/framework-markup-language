// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/switch/switch_model.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_state.dart' ;
import 'package:fml/widgets/text/text_model.dart';
import 'package:fml/widgets/text/text_view.dart';

class SwitchView extends StatefulWidget implements IWidgetView
{
  final SwitchModel model;
  final dynamic onChangeCallback;
  SwitchView(this.model, {this.onChangeCallback});

  @override
  _SwitchViewState createState() => _SwitchViewState();
}

class _SwitchViewState extends WidgetState<SwitchView> with WidgetsBindingObserver {
  RenderBox? box;
  Offset? position;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _afterBuild(context);
    });

    // save system constraints
    widget.model.systemConstraints = constraints;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    bool value = widget.model.value;
    String? label = widget.model.label;
    bool canSwitch =
        (widget.model.enabled != false && widget.model.editable != false);
    double width = widget.model.width;

    //////////
    /* View */
    //////////
    Widget view;
    ColorScheme th = Theme.of(context).colorScheme;
    view = Switch.adaptive(
      value: value, onChanged: canSwitch ? onChange : null,
      // activeColor: th.inversePrimary, activeTrackColor: th.primaryContainer, inactiveThumbColor: th.onInverseSurface, inactiveTrackColor: th.surfaceVariant,);
      activeColor: widget.model.color ?? th.primary,
      activeTrackColor:
          widget.model.color?.withOpacity(0.65) ?? th.inversePrimary,
      inactiveThumbColor: th.onInverseSurface,
      inactiveTrackColor: th.surfaceVariant,
    );

    ///////////////
    /* Disabled? */
    ///////////////
    if (!canSwitch)
      view = MouseRegion(
          cursor: SystemMouseCursors.forbidden,
          child: Tooltip(
              message: 'Locked',
              preferBelow: false,
              verticalOffset: 12,
              child: view));

    ///////////////
    /* Labelled? */
    ///////////////
    if (widget.model.label != null)
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

    ////////////////////
    /* Constrain Size */
    ////////////////////
    view = SizedBox(child: view, width: width);

    return view;
  }

  /// After [iFormFields] are drawn we get the global offset for scrollTo functionality
  _afterBuild(BuildContext context) {
    // Set the global offset position of each input
    box = context.findRenderObject() as RenderBox?;
    if (box != null) position = box!.localToGlobal(Offset.zero);
    if (position != null) widget.model.offset = position;
  }

  onChange(bool value) async {
    var editable = (widget.model.editable != false);
    if (!editable) return;

      ////////////////////
      /* Value Changed? */
      ////////////////////
    if (widget.model.value != value) {
      ///////////////////////////
      /* Retain Rollback Value */
      ///////////////////////////
      dynamic old = widget.model.value;

      ////////////////
      /* Set Answer */
      ////////////////
      await widget.model.answer(value);

      //////////////////////////
      /* Fire on Change Event */
      //////////////////////////
      if (value != old) await widget.model.onChange(context);
    }
  }
}
