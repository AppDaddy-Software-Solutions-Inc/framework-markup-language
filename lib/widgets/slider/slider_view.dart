// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/slider/slider_model.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/widget/widget_state.dart' ;
import 'package:fml/helper/common_helpers.dart';

class SliderView extends StatefulWidget implements IWidgetView
{
  final SliderModel model;
  final dynamic onChangeCallback;
  SliderView(this.model, {this.onChangeCallback});

  @override
  _SliderViewState createState() => _SliderViewState();
}

class _SliderViewState extends WidgetState<SliderView> with WidgetsBindingObserver
{
  RenderBox? box;
  Offset? position;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _afterBuild(context);
    });

    // save system constraints
    widget.model.setSystemConstraints(constraints);

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    var min   = S.toDouble(widget.model.minimum) ?? 0;
    var max   = S.toDouble(widget.model.maximum) ?? 0;
    List values = widget.model.value?.split(',') ?? [min];
    double value1 = S.toDouble(values[0]) ?? min;
    double value2 = (values.length > 1 ?  S.toDouble(values[1]) : value1) ?? max;

    String? label;

      if (value1 % 1 == 0)
         label = value1.toString().split('.')[0];
    else label = value1.toString();

    // if any of the above are null, all are 0 to prevent errors;
    if (max < min) {
      max = min;
      value1 = min;
      label = 'Slider Loading';
    } else {
      if (min > max) {
        min = 0;
        max = 0;
        Log().debug('Slider min > max' + widget.model.id.toString(), caller: (widget.model.elementName) + '.' + this.runtimeType.toString());
      }
      if (value1 < min || value1 > max)
      {
        value1 = min;
        Log().debug('Slider value out of range' + widget.model.id.toString(), caller: (widget.model.elementName) + '.' + this.runtimeType.toString());
      }
    }

    //////////
    /* View */
    //////////

    Widget? view;
    if (widget.model.range == false)
      view = Slider(
        value: value1,
        min: min,
        max: max,
        divisions: !S.isNullOrEmpty(widget.model.divisions) &&
                S.toInt(widget.model.divisions)! > 0
            ? S.toInt(widget.model.divisions)
            : null,
        label: label,
        onChanged: onChange,
        activeColor: ColorHelper.lighten(widget.model.color ?? Theme.of(context).colorScheme.primary, 0.05),
        inactiveColor: Theme.of(context).colorScheme.secondaryContainer,
        thumbColor: widget.model.color ?? Theme.of(context).colorScheme.primary,
      );
    else if (widget.model.range == true) {
      view = RangeSlider(
        values: RangeValues(S.toDouble(value1)!,
            S.toDouble(value2)!),
        min: min,
        max: max,
        divisions: !S.isNullOrEmpty(widget.model.divisions) &&
            S.toInt(widget.model.divisions)! > 0
            ? S.toInt(widget.model.divisions)
            : null,
        labels: RangeLabels(value1.toString(),
            value2.toString()),
        onChanged: (RangeValues values) => onRangeChange(values),
        activeColor: ColorHelper.lighten(widget.model.color ?? Theme.of(context).colorScheme.primary, 0.05),
        inactiveColor: Theme.of(context).colorScheme.secondaryContainer,
      );
    }

    ///////////
    /* Width */
    ///////////
    double width = widget.model.width;

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

  String validate(String text) {
    return 'field must be supplied';
  }

  onChange(double value) async {
    if (widget.model.editable == false || widget.model.enabled == false)
      return;

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

  onRangeChange(RangeValues values) async {
    List modelValues = widget.model.value?.split(',') ?? [widget.model.minimum, widget.model.maximum];
    double value1 = S.toDouble(modelValues[0]) ??  widget.model.minimum ?? 0;
    double value2 = (modelValues.length > 1 ?  S.toDouble(modelValues[1]) : value1) ??  widget.model.maximum ?? 0;
    if (widget.model.editable == false || widget.model.enabled == false)
      return;

    //////////////////////////
    /* Start Value Changed? */
    //////////////////////////
    else if (S.toDouble(value1) != values.start) {
      ///////////////////////////
      /* Retain Rollback Value */
      ///////////////////////////
      dynamic old = '$value1,$value2';

      //////////////////////////
      /* Fire on Change Event */
      //////////////////////////
      await widget.model.answer('${values.start},${values.end}', range: true);
      if ('${values.start},${values.end}' != old) await widget.model.onChange(context);
    }

    ////////////////////////
    /* End Value Changed? */
    ////////////////////////
    else if (S.toDouble(value2) != values.end) {
      ///////////////////////////
      /* Retain Rollback Value */
      ///////////////////////////
      dynamic old = '$value1,$value2';

      ////////////////
      /* Set Answer */
      ////////////////
      await widget.model.answer('${values.start},${values.end}', range: true);

      //////////////////////////
      /* Fire on Change Event */
      //////////////////////////
      if ('${values.start},${values.end}' != old) await widget.model.onChange(context);
    }
  }
}
