// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/slider/slider_model.dart';
import 'package:fml/widgets/widget/widget_model.dart' ;
import 'package:fml/helper/helper_barrel.dart';

class SliderView extends StatefulWidget {
  final SliderModel model;
  final dynamic onChangeCallback;
  SliderView(this.model, {this.onChangeCallback});

  @override
  _SliderViewState createState() => _SliderViewState();
}

class _SliderViewState extends State<SliderView>
    with WidgetsBindingObserver
    implements IModelListener {
  RenderBox? box;
  Offset? position;

  @override
  void initState() {
    super.initState();

    
    widget.model.registerListener(this);

    // If the model contains any databrokers we fire them before building so we can bind to the data
    widget.model.initialize();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(SliderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if ((oldWidget.model != widget.model)) {
      oldWidget.model.removeListener(this);
      widget.model.registerListener(this);
    }

  }

  @override
  void dispose() {
    widget.model.removeListener(this);
    super.dispose();
  }

  /// Callback to fire the [_SliderViewState.build] when the [SliderModel] changes
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    if (this.mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: builder);
  }

  Widget builder(BuildContext context, BoxConstraints constraints) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _afterBuild(context);
    });

    // Set Build Constraints in the [WidgetModel]
    widget.model.minwidth = constraints.minWidth;
    widget.model.maxwidth = constraints.maxWidth;
    widget.model.minheight = constraints.minHeight;
    widget.model.maxheight = constraints.maxHeight;

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
        activeColor:
            widget.model.color ?? Theme.of(context).colorScheme.primary,
        inactiveColor: Theme.of(context).colorScheme.secondaryContainer,
        thumbColor: Theme.of(context).colorScheme.primary,
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
        activeColor:
            widget.model.color ?? Theme.of(context).colorScheme.primary,
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

  onRangeChange(RangeValues values) async {
    List modelValues = widget.model.value?.split(',') ?? [widget.model.minimum, widget.model.maximum];
    double value1 = S.toDouble(modelValues[0]) ??  widget.model.minimum ?? 0;
    double value2 = (modelValues.length > 1 ?  S.toDouble(modelValues[1]) : value1) ??  widget.model.maximum ?? 0;
    if (widget.model.editable == false)
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
