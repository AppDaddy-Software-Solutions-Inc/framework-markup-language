// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/select/select_model.dart';
import 'package:fml/widgets/option/option_model.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class SelectView extends StatefulWidget implements IWidgetView {
  @override
  final SelectModel model;

  SelectView(this.model) : super(key: ObjectKey(model));

  @override
  State<SelectView> createState() => _SelectViewState();
}

class _SelectViewState extends WidgetState<SelectView> {
  FocusNode focus = FocusNode();

  void onChangeOption(OptionModel? option) async {
    // no data?
    if (option != null && option == widget.model.noDataOption) return;

    // no match?
    if (option != null && option == widget.model.noMatchOption) return;

    // stop model change notifications
    widget.model.removeListener(this);

    // set the selected option
    await widget.model.setSelectedOption(option);

    // resume model change notifications
    widget.model.registerListener(this);

    // unfocus
    focus.unfocus();

    // force a rebuild
    setState(() {});
  }

  Widget addBorders(Widget view) {
    // border padding - this need to be changed to check border width
    var padding = const EdgeInsets.only(left: 10, top: 3, right: 0, bottom: 3);
    if (widget.model.border == "none") {
      padding = const EdgeInsets.only(left: 10, top: 4, right: 10, bottom: 4);
    }

    // border radius
    var radius = BorderRadius.circular(widget.model.radius.toDouble());

    // border color
    var color =
        widget.model.borderColor ?? Theme.of(context).colorScheme.outline;
    if (widget.model.alarming) {
      color = widget.model.getBorderColor(context, widget.model.borderColor);
    }
    if (!widget.model.enabled) color = Theme.of(context).disabledColor;

    // border width
    var width = widget.model.borderWidth.toDouble();

    BoxDecoration decoration = BoxDecoration(
        color: widget.model.getFieldColor(context),
        border: Border.all(width: width, color: color),
        borderRadius: radius);

    // no border
    if (widget.model.border == 'none') {
      decoration = BoxDecoration(
          color: widget.model.getFieldColor(context), borderRadius: radius);
    }

    if (widget.model.border == 'bottom' || widget.model.border == 'underline') {
      decoration = BoxDecoration(
          color: widget.model.getFieldColor(context),
          border: Border(bottom: BorderSide(width: width, color: color)));
    }

    return Container(padding: padding, decoration: decoration, child: view);
  }

  Widget addAlarmText(Widget view) {
    if (isNullOrEmpty(widget.model.alarmText)) return view;

    Widget? errorText = Padding(
        padding: const EdgeInsets.only(top: 6.0, bottom: 2.0),
        child: Text("${widget.model.alarmText}",
            style: TextStyle(color: Theme.of(context).colorScheme.error)));
    view = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [view, errorText],
    );

    return view;
  }

  Widget buildSelect() {
    var hintColor = Theme.of(context).colorScheme.onSurfaceVariant;
    if (widget.model.color != null) {
      var luminance = widget.model.color!.computeLuminance();
      hintColor = luminance < 0.4
          ? Colors.white.withOpacity(0.5)
          : Colors.black.withOpacity(0.5);
    }

    // set text style
    var hintTextStyle = TextStyle(
        fontSize: (widget.model.size ?? 14) - 2,
        fontWeight: FontWeight.w300,
        color: hintColor);

    var style = TextStyle(
        color: widget.model.enabled
            ? widget.model.textcolor ??
                Theme.of(context).colorScheme.onBackground
            : Theme.of(context).colorScheme.surfaceVariant,
        fontSize: widget.model.size);

    var decoration = InputDecoration(
        contentPadding: const EdgeInsets.only(bottom: 2),
        isDense: true,
        hintText: widget.model.hint ?? '',
        hintStyle: hintTextStyle,
        border: InputBorder.none,
        focusedBorder: InputBorder.none);

    // hints
    var hint = TextField(
        enabled: widget.model.enabled,
        autofocus: false,
        style: style,
        readOnly: true,
        decoration: decoration,
        textAlignVertical: TextAlignVertical.center);

    double defaultHeight = widget.model.height ?? 48;
    if (defaultHeight < 48) defaultHeight = 48;

    // border radius
    var borderRadius = BorderRadius.circular(
        widget.model.radius.toDouble() <= 24
            ? widget.model.radius.toDouble()
            : 24);

    // widget is enabled?
    var enabled = (widget.model.enabled && !widget.model.busy);
    if (!enabled) {
      return widget.model.selectedOption?.getView() ??
          Container(
              alignment: Alignment.centerLeft,
              height: defaultHeight,
              child: hint);
    }

    // build options
    List<DropdownMenuItem<OptionModel>> options = [];
    for (OptionModel option in widget.model.options) {
      if (option.visible) {
        Widget view = option.getView();
        options.add(DropdownMenuItem(value: option, child: view));
      }
    }

    // select
    Widget view = DropdownButton<OptionModel>(
        itemHeight: widget.model.height ?? defaultHeight,
        value: widget.model.selectedOption,
        hint: hint,
        focusNode: focus,
        items:
            options, // if this is set to null it disables the dropdown but also hides any value
        onChanged: onChangeOption,
        dropdownColor: Theme.of(context).colorScheme.onInverseSurface,
        isExpanded: true,
        borderRadius: borderRadius,
        underline: Container(),
        focusColor:
            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.15));

    // defeat focus colors
    view = Theme(data: ThemeData(hoverColor: Colors.transparent), child: view);

    // show hand cursor
    view = MouseRegion(cursor: SystemMouseCursors.click, child: view);

    return view;
  }

  Widget? buildBusy() {
    if (!widget.model.busy) return null;

    var view = BusyModel(widget.model,
            visible: true,
            size: 24,
            color:
                Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
            modal: false)
        .getView();

    return view;
  }

  @override
  Widget build(BuildContext context) {
    // check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // build select
    Widget view = buildSelect();

    // add borders
    view = addBorders(view);

    // display busy
    Widget? busy = buildBusy();
    if (busy != null) {
      view = Stack(children: [
        view,
        Positioned(top: 0, bottom: 0, left: 0, right: 0, child: busy)
      ]);
    }

    // add alarm text
    view = addAlarmText(view);

    // get the model constraints
    var modelConstraints = widget.model.constraints;

    // constrain the input to 200 pixels if not constrained by the model
    if (!modelConstraints.hasHorizontalExpansionConstraints) {
      modelConstraints.width = 200;
    }

    // add margins
    view = addMargins(view);

    // apply constraints
    view = applyConstraints(view, modelConstraints);

    // unfocus
    focus.unfocus();

    return view;
  }
}
