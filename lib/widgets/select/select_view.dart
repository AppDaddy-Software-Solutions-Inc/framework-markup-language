// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/select/select_model.dart';
import 'package:fml/widgets/option/option_model.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class SelectView extends StatefulWidget implements IWidgetView
{
  @override
  final SelectModel model;

  SelectView(this.model) : super(key: ObjectKey(model));

  @override
  State<SelectView> createState() => _SelectViewState();
}

class _SelectViewState extends WidgetState<SelectView>
{
  FocusNode focus = FocusNode();

  void onChangeOption(OptionModel? option) async
  {
    // stop model change notifications
    widget.model.removeListener(this);

    // set the selected option
    await widget.model.setSelectedOption(option);

    // resume model change notifications
    widget.model.registerListener(this);
  }

  onFocusChange() async
  {
    var editable = (widget.model.editable != false);
    if (!editable) return;

    // commit changes on loss of focus
    if (!focus.hasFocus) await _commit();
  }

  Future<bool> _commit() async => true;

  Widget addBorders(Widget view)
  {
    // no borders
    if (widget.model.border == 'none')
    {
      view = Container(
        padding: const EdgeInsets.fromLTRB(12, 2, 8, 2),
        decoration: BoxDecoration(
          color: widget.model.getFieldColor(context),
          borderRadius: BorderRadius.circular(widget.model.radius.toDouble()),
        ),
        child: view,
      );
      return view;
    }

    // only bottom borders
    if (widget.model.border == 'bottom' || widget.model.border == 'underline')
    {
      view = Container(
        padding: const EdgeInsets.fromLTRB(12, 0, 8, 3),
        decoration: BoxDecoration(
          color: widget.model.getFieldColor(context),
          border: Border(
            bottom: BorderSide(
                width: widget.model.borderWidth.toDouble(),
                color: widget.model.setErrorBorderColor(context, widget.model.borderColor)),
          ),),
        child: view,
      );
      return view;
    }

    // default - all borders
    view = Container(
      padding: const EdgeInsets.fromLTRB(12, 1, 9, 0),
      decoration: BoxDecoration(
        color: widget.model.getFieldColor(context),
        border: Border.all(
            width: widget.model.borderWidth.toDouble(),
            color: widget.model.setErrorBorderColor(context, widget.model.borderColor)),
        borderRadius: BorderRadius.circular(widget.model.radius.toDouble()),
      ),
      child: view,
    );

    return view;
  }

  Widget addAlarmText(Widget view)
  {
    if (isNullOrEmpty(widget.model.alarmText)) return view;

    Widget? errorText = Padding(padding: EdgeInsets.only(top: 6.0 , bottom: 2.0), child: Text("${widget.model.alarmText}", style: TextStyle(color: Theme.of(context).colorScheme.error)));
    view = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [view, errorText],
    );

    return view;
  }

  List<Widget> selectedItemBuilder(BuildContext context)
  {
    // nothing selected
    if (widget.model.selectedOption == null) return [Text('')];

    // option view
    return [widget.model.selectedOption!.getView()];
  }

  Widget buildSelect()
  {
    // hints
    Widget? hint;
    Widget? hintDisabled;
    if (!isNullOrEmpty(widget.model.hint))
    {
      var ts = TextStyle(fontSize: widget.model.size,
          color: widget.model.color != null
              ? (widget.model.color?.computeLuminance() ?? 1) < 0.4
              ? Colors.white.withOpacity(0.5)
              : Colors.black.withOpacity(0.5)
              : Theme.of(context).colorScheme.onSurfaceVariant);

      var ts2 = TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.50));

      hint = Text(widget.model.hint!, style: ts);
      hintDisabled = Text(widget.model.hint!, style: ts2);
    }

    // border radius
    var borderRadius = BorderRadius.circular(widget.model.radius.toDouble() <= 24 ? widget.model.radius.toDouble() : 24);

    // widget is enabled?
    var enabled = (widget.model.enabled && !widget.model.busy);

    // build options
    List<DropdownMenuItem<OptionModel>> options = [];
    for (OptionModel option in widget.model.options)
    {
      Widget view = option.getView();
      options.add(DropdownMenuItem(value: option, child: view));
    }

    // select
    Widget view = DropdownButton<OptionModel>(
          selectedItemBuilder: selectedItemBuilder,
          itemHeight: 48,
          value: widget.model.selectedOption,
          hint: hint,
          items: options, // if this is set to null it disables the dropdown but also hides any value
          onChanged: enabled ? onChangeOption : null,
          dropdownColor: Theme.of(context).colorScheme.onInverseSurface,
          isExpanded: true,
          borderRadius: borderRadius,
          underline: Container(),
          disabledHint: hintDisabled,
          focusColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.15));

    // show hand cursor
    if (enabled) view = MouseRegion(cursor: SystemMouseCursors.click,child: view);

    return view;
  }

  Widget? buildBusy()
  {
    if (!widget.model.busy) return null;

    var view = BusyModel(widget.model,
          visible: true,
          size: 24,
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          modal: false).getView();

    return view;
  }

  @override
  Widget build(BuildContext context)
  {
    // check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // build select
    Widget view = buildSelect();

    // add borders
    view = addBorders(view);

    // display busy
    Widget? busy = buildBusy();
    if (busy != null) view = Stack(children: [view, Positioned(top: 0, bottom: 0, left: 0, right: 0, child: busy)]);

    // add alarm text
    view = addAlarmText(view);

    // get the model constraints
    var modelConstraints = widget.model.constraints;

    // constrain the input to 200 pixels if not constrained by the model
    if (!modelConstraints.hasHorizontalExpansionConstraints) modelConstraints.width = 200;

    // add margins
    view = addMargins(view);

    // apply constraints
    view = applyConstraints(view, modelConstraints);

    return view;
  }
}
