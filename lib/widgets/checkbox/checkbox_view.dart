// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/checkbox/checkbox_model.dart';
import 'package:fml/widgets/option/option_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:fml/widgets/alignment/alignment.dart';

/// Checkbox View
///
/// Builds the Checkbox View from [Model] properties
class CheckboxView extends StatefulWidget implements IWidgetView
{
  @override
  final CheckboxModel model;
  CheckboxView(this.model) : super(key: ObjectKey(model));

  @override
  State<CheckboxView> createState() => _CheckboxViewState();
}

class _CheckboxViewState extends WidgetState<CheckboxView>
{
  void onChangeOption(OptionModel? option) async
  {
    // stop model change notifications
    widget.model.removeListener(this);

    // set the selected option
    await widget.model.setSelectedOption(option);

    // resume model change notifications
    widget.model.registerListener(this);

    // force a rebuild
    setState(() {});
  }

  Widget addGestures(Widget view, OptionModel option)
  {
    if (!widget.model.enabled || !widget.model.editable) return view;

    view = GestureDetector(onTap: () => onChangeOption(option), child: view);
    view = MouseRegion(cursor: SystemMouseCursors.click, child: view);
    return view;
  }

  Widget addAlarmText(Widget view)
  {
    if (isNullOrEmpty(widget.model.alarmText)) return view;

    Widget? text = Text("${widget.model.alarmText}", style: TextStyle(color: Theme.of(context).colorScheme.error));

    view = Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [view, text]);

    return view;
  }

  Widget buildCheckboxButton(OptionModel option)
  {
    var selectedColor = widget.model.getBorderColor(context, widget.model.color ?? Theme.of(context).colorScheme.primary);
    var unselectedColor = widget.model.getBorderColor(context, Theme.of(context).colorScheme.outline);

    var selected = (widget.model.selectedOptions.contains(option));
    var enabled = (widget.model.editable && widget.model.enabled);

    Widget button = selected ?
    Icon(Icons.check_box, size: widget.model.size, color: selectedColor) :
    Icon(Icons.check_box_outline_blank_sharp, size: widget.model.size, color: unselectedColor);

    // add gestures to the button
    button = addGestures(button, option);

    // set opacity
    if (!enabled) button = Opacity(opacity: 0.7, child: button);

    // pad icon
    button = Padding(
        padding:
        EdgeInsets.only(top: 8, bottom: 8, right: 8, left: 3),
        child: button);

    // add label
    var label = option.getView();

    // add gestures to the button
    label = addGestures(label, option);

    // Option
    Widget view = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [button,label]);

    return view;
  }

  List<Widget> buildOptions()
  {
    // no options specified?
    if (widget.model.options.isEmpty) return [];

    List<Widget> options = [];
    for (OptionModel option in widget.model.options)
    {
      // build radio button
      Widget view = buildCheckboxButton(option);
      options.add(view);
    }

    return options;
  }

  Widget buildView()
  {
    // build radio buttons
    List<Widget> options = buildOptions();

    //this must go after the children are determined
    var alignment = WidgetAlignment(widget.model.layoutType, widget.model.center, widget.model.halign, widget.model.valign);

    // wrapped row
    if (widget.model.layout == 'row' && widget.model.wrap)
    {
      return Wrap(
          children: options,
          direction: Axis.horizontal,
          alignment: alignment.mainWrapAlignment,
          runAlignment: alignment.mainWrapAlignment,
          crossAxisAlignment: alignment.crossWrapAlignment);
    }

    // row
    if (widget.model.layout == 'row' && !widget.model.wrap)
    {
      return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: alignment.crossAlignment,
          mainAxisAlignment: alignment.mainAlignment,
          children: options);
    }

    // wrapped column
    if (widget.model.wrap)
    {
      return Wrap(
          children: options,
          direction: Axis.vertical,
          alignment: alignment.mainWrapAlignment,
          runAlignment: alignment.mainWrapAlignment,
          crossAxisAlignment: alignment.crossWrapAlignment);
    }

    // default - column
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: alignment.crossAlignment,
        mainAxisAlignment: alignment.mainAlignment,
        children: options);
  }

  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // View
    Widget view = buildView();

    // add alarm text
    view = addAlarmText(view);

    // add margins
    view = addMargins(view);

    // apply constraints
    view = applyConstraints(view, widget.model.constraints);

    // return view
    return view;
  }
}