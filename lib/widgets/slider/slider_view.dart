// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/slider/slider_model.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/widget/widget_state.dart' ;
import 'package:fml/helpers/helpers.dart';

class SliderView extends StatefulWidget implements IWidgetView
{
  @override
  final SliderModel model;
  final dynamic onChangeCallback;
  const SliderView(this.model, {super.key, this.onChangeCallback});

  @override
  State<SliderView> createState() => _SliderViewState();
}

class _SliderViewState extends WidgetState<SliderView> with WidgetsBindingObserver
{
  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    var min   = toDouble(widget.model.minimum) ?? 0;
    var max   = toDouble(widget.model.maximum) ?? 0;
    List values = widget.model.value?.split(',') ?? [min];
    double value1 = toDouble(values[0]) ?? min;
    double value2 = (values.length > 1 ?  toDouble(values[1]) : value1) ?? max;

    String? label;

      if (value1 % 1 == 0) {
        label = value1.toString().split('.')[0];
      } else {
        label = value1.toString();
      }

    // if any of the above are null, all are 0 to prevent errors;
    if (max < min) {
      max = min;
      value1 = min;
      label = 'Slider Loading';
    } else {
      if (min > max) {
        min = 0;
        max = 0;
        Log().debug('Slider min > max${widget.model.id}', caller: '${widget.model.elementName}.$runtimeType');
      }
      if (value1 < min || value1 > max)
      {
        value1 = min;
        Log().debug('Slider value out of range${widget.model.id}', caller: '${widget.model.elementName}.$runtimeType');
      }
    }

    // create the view
    Widget view;
    if (widget.model.range) {
      view = RangeSlider(
          values: RangeValues(toDouble(value1)!,
              toDouble(value2)!),
          min: min,
          max: max,
          divisions: !isNullOrEmpty(widget.model.divisions) &&
              toInt(widget.model.divisions)! > 0
              ? toInt(widget.model.divisions)
              : null,
          labels: RangeLabels(value1.toString(),
              value2.toString()),
          onChanged: (RangeValues values) => onRangeChange(values),
          activeColor: ColorHelper.lighten(widget.model.color ?? Theme.of(context).colorScheme.primary, 0.05),
          inactiveColor: Theme.of(context).colorScheme.secondaryContainer);
    } else {
      view = Slider(
        value: value1,
        min: min,
        max: max,
        divisions: !isNullOrEmpty(widget.model.divisions) &&
            toInt(widget.model.divisions)! > 0
            ? toInt(widget.model.divisions)
            : null,
        label: label,
        onChanged: onChange,
        activeColor: ColorHelper.lighten(widget.model.color ?? Theme.of(context).colorScheme.primary, 0.05),
        inactiveColor: Theme.of(context).colorScheme.secondaryContainer,
        thumbColor: widget.model.color ?? Theme.of(context).colorScheme.primary,
      );
    }

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

  String validate(String text) {
    return 'field must be supplied';
  }

  onChange(double value) async
  {
    if (!widget.model.editable || !widget.model.enabled) return;

    // value changed?
    if (widget.model.value != value)
    {
      // set answer
      await widget.model.answer(value);

      // fire the onChange event
      await widget.model.onChange(mounted ? context : null);
    }
  }

  onRangeChange(RangeValues values) async {
    List modelValues = widget.model.value?.split(',') ?? [widget.model.minimum, widget.model.maximum];
    double value1 = toDouble(modelValues[0]) ??  widget.model.minimum ?? 0;
    double value2 = (modelValues.length > 1 ?  toDouble(modelValues[1]) : value1) ??  widget.model.maximum ?? 0;

    if (!widget.model.editable || !widget.model.enabled) return;

    if (toDouble(value1) != values.start)
    {
      /* Retain Rollback Value */
      dynamic old = '$value1,$value2';

      /* Fire on Change Event */
      await widget.model.answer('${values.start},${values.end}', range: true);
      if ('${values.start},${values.end}' != old)
      {
        await widget.model.onChange(mounted ? context : null);
      }
    }

    // End Value Changed?
    else if (toDouble(value2) != values.end) {
      /* Retain Rollback Value */
      dynamic old = '$value1,$value2';

      // Set Answer
      await widget.model.answer('${values.start},${values.end}', range: true);

      // Fire on Change Event
      if ('${values.start},${values.end}' != old)
      {
        await widget.model.onChange(mounted ? context : null);
      }
    }
  }
}
