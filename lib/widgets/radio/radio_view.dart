// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/radio/radio_model.dart';
import 'package:fml/widgets/option/option_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:fml/widgets/alignment/alignment.dart';

class RadioView extends StatefulWidget implements IWidgetView
{
  @override
  final RadioModel model;
  RadioView(this.model) : super(key: ObjectKey(model));

  @override
  State<RadioView> createState() => _RadioViewState();
}

class _RadioViewState extends WidgetState<RadioView>
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

  Widget buildRadioButton(OptionModel option)
  {
    var selectedColor = widget.model.getBorderColor(context, widget.model.color ?? Theme.of(context).colorScheme.primary);
    var unselectedColor = widget.model.getBorderColor(context, Theme.of(context).colorScheme.outline);

    var selected = (widget.model.selectedOption == option);
    var enabled = (widget.model.editable && widget.model.enabled);

    Widget button = selected ?
      Icon(Icons.radio_button_checked, size: widget.model.size, color: selectedColor) :
      Icon(Icons.radio_button_unchecked, size: widget.model.size, color: unselectedColor);

    // add gestures to the button
    button = addGestures(button, option);

    // set opacity
    if (!enabled) button = Opacity(opacity: 0.7, child: button);

    // pad icon
    button = Padding(
        padding:
        const EdgeInsets.only(top: 8, bottom: 8, right: 8, left: 3),
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
      Widget view = buildRadioButton(option);
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
            direction: Axis.horizontal,
            alignment: alignment.mainWrapAlignment,
            runAlignment: alignment.mainWrapAlignment,
            crossAxisAlignment: alignment.crossWrapAlignment,
            children: options);
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
          direction: Axis.vertical,
          alignment: alignment.mainWrapAlignment,
          runAlignment: alignment.mainWrapAlignment,
          crossAxisAlignment: alignment.crossWrapAlignment,
          children: options);
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
    if (!widget.model.visible) return const Offstage();

   // View 
    Widget view = buildView();

    view = addAlarmText(view);

    return view;
  }
}
