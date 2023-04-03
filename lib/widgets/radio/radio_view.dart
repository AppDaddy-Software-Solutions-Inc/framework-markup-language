// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/radio/radio_model.dart';
import 'package:fml/widgets/option/option_model.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/widgets/widget/viewable_widget_model.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class RadioView extends StatefulWidget implements IWidgetView
{
  final RadioModel model;
  RadioView(this.model) : super(key: ObjectKey(model));

  @override
  _RadioViewState createState() => _RadioViewState();
}

class _RadioViewState extends WidgetState<RadioView>
{
  List<Widget>? options;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // save system constraints
    onLayout(constraints);

    /////////////
    /* Options */
    /////////////
    if (widget.model.options.isNotEmpty) {
      if (options == null) options = [];
      options!.clear();
      for (OptionModel option in widget.model.options) {
        var checked = Icon(Icons.radio_button_checked,
            size: widget.model.size,
            color: widget.model.enabled != false
                ? widget.model.color ?? Theme.of(context).colorScheme.primary
                : (widget.model.color ?? Theme.of(context).colorScheme.primary)
                    .withOpacity(0.5));
        var unchecked = Icon(Icons.radio_button_unchecked,
            size: widget.model.size,
            color: widget.model.enabled != false
                ? widget.model.color ??
                    Theme.of(context).colorScheme.surfaceVariant
                : (widget.model.color ?? Theme.of(context).colorScheme.primary)
                    .withOpacity(0.5));
        var radio = MouseRegion(
            cursor:
                widget.model.enabled != false && widget.model.editable != false
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.basic,
            child: GestureDetector(
                onTap: () => {
                      widget.model.enabled != false &&
                              widget.model.editable != false
                          ? _onCheck(option)
                          : () => {}
                    },
                child: (widget.model.value == option.value)
                    ? checked
                    : unchecked));

        ///////////
        /* Label */
        ///////////
        Widget label = Text('');
        if (option.label is ViewableWidgetModel) label = option.label!.getView();

        ////////////
        /* Option */
        ////////////
        var opt = Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding:
                  EdgeInsets.only(top: 8, bottom: 8, right: 8, left: 4),
                  child: radio),
              label
            ]);

        options!.add(widget.model.editable != false && widget.model.enabled != false ? opt : Opacity(opacity: 0.7, child: opt));
      }
    }

    //this must go after the children are determined
    var alignment = AlignmentHelper.alignWidgetAxis(AlignmentHelper.getLayoutType(widget.model.layout), widget.model.center, AlignmentHelper.getHorizontalAlignmentType(widget.model.halign), AlignmentHelper.getVerticalAlignmentType(widget.model.valign));

    /* View */
    Widget view;
    if (widget.model.layout == 'row') {
      if (widget.model.wrap == true)
        view = Wrap(
            children: options!,
            direction: Axis.horizontal,
            alignment: alignment.mainWrapAlignment,
            runAlignment: alignment.mainWrapAlignment,
            crossAxisAlignment: alignment.crossWrapAlignment);
      else
        view = Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: alignment.crossAlignment,
            mainAxisAlignment: alignment.mainAlignment,
            children: options!);
    } else {
      if (widget.model.wrap == true)
        view = Wrap(
            children: options!,
            direction: Axis.vertical,
            alignment: alignment.mainWrapAlignment,
            runAlignment: alignment.mainWrapAlignment,
            crossAxisAlignment: alignment.crossWrapAlignment);
      else
        view = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: alignment.crossAlignment,
            mainAxisAlignment: alignment.mainAlignment,
            children: options!);
    }

    return view;
  }

  void _onCheck(OptionModel option) async {
    await widget.model.onCheck(option);
    setState(() {});
  }
}
