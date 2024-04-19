// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/widgets/viewable/viewable_widget_view.dart';
import 'package:fml/widgets/widget/model.dart';
import 'package:fml/widgets/datepicker/datepicker_model.dart';
import 'package:flutter/services.dart';
import 'package:fml/helpers/helpers.dart';
import 'package:fml/widgets/viewable/viewable_widget_state.dart';

class DatepickerView extends StatefulWidget implements ViewableWidgetView {
  @override
  final DatepickerModel model;
  DatepickerView(this.model) : super(key: ObjectKey(model));

  @override
  State<DatepickerView> createState() => DatepickerViewState();
}

class DatepickerViewState extends ViewableWidgetState<DatepickerView> {
  String? format;
  String? date;
  String? oldValue;
  TextEditingController? cont;
  FocusNode? focusNode;

  @override
  void initState() {
    super.initState();

    // register camera
    widget.model.datepicker = this;

    focusNode = FocusNode();

    // Create a TextEditingController
    cont = TextEditingController();

    // Add Controller Listener
    if (cont != null) {
      cont!.addListener(onTextEditingController);

      // Set initial value to the controller
      if (cont!.text != widget.model.value) {
        cont!.text = toStr(widget.model.value) ?? "";
      }
    }
  }

  @override
  void didUpdateWidget(DatepickerView oldWidget) {
    super.didUpdateWidget(oldWidget);

    /* Add Controller Listener */
    if (cont != null) cont!.addListener(onTextEditingController);
  }

  @override
  void dispose() {
    super.dispose();

    // Remove Controller Listener
    cont?.removeListener(onTextEditingController);
    cont?.dispose();
    focusNode?.dispose();
  }

  // Flex: We need to listen to the controller of the picker because it uses internal setstates
  // and our model does not know of that state so we modify the model directly from listener
  onTextEditingController() {
    oldValue = widget.model.value;
    widget.model.value = cont!.value.text;
  }

  /// Callback function for when the model changes, used to force a rebuild with setState()
  @override
  onModelChange(Model model, {String? property, dynamic value}) {
    if ((cont!.text != widget.model.value) &&
        (widget.model.isPicking != true)) {
      widget.model.onChange(context);
    }
    cont!.text = widget.model.value;
    super.onModelChange(model);
  }

  void onChange(String d) async {
    cont!.value = TextEditingValue(
        text: widget.model.value.toString(),
        selection: TextSelection(
            baseOffset: 0, extentOffset: widget.model.value.toString().length));

    if (oldValue != widget.model.value) {
      // set answer
      bool ok = await widget.model.answer(widget.model.value);

      // fire on change event
      if (ok == true && mounted) await widget.model.onChange(context);
    }

    return;
  }

  void onClear() {
    cont!.text = '';
    widget.model.value = '';
  }

  _getBorder(Color mainColor, Color? secondaryColor) {
    secondaryColor ??= mainColor;

    if (widget.model.border == "none") {
      return OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(widget.model.radius)),
        borderSide: const BorderSide(color: Colors.transparent, width: 2),
      );
    } else if (widget.model.border == "bottom" ||
        widget.model.border == "underline") {
      return UnderlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(0)),
        borderSide: BorderSide(
            color: widget.model.editable ? mainColor : secondaryColor,
            width: widget.model.borderWidth),
      );
    } else {
      return OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(widget.model.radius)),
        borderSide:
            BorderSide(color: mainColor, width: widget.model.borderWidth),
      );
    }
  }

  Future _showDateRangePicker(DatePickerEntryMode mode) async {
    if (!mounted) return;

    var format = widget.model.format;
    var newest = widget.model.newest;
    var oldest = widget.model.oldest;

    DateTimeRange? result;

    if (mounted) {
      result = await showDateRangePicker(
        context: context,
        initialEntryMode: mode,
        firstDate: toDate(oldest, format: format) ??
            DateTime(DateTime.now().year - 100),
        currentDate: DateTime.now(),
        lastDate: toDate(newest, format: format) ??
            DateTime(DateTime.now().year + 10),
      );
    }
    if (result == null) return;

    // set value
    widget.model.setValue(result.start, TimeOfDay.now(), format,
        secondResult: result.end);
  }

  Future _showTimePicker(TimePickerEntryMode mode) async {
    if (!mounted) return;

    TimeOfDay time = TimeOfDay.now();
    var format = widget.model.format;
    try {
      time =
          TimeOfDay.fromDateTime(toDate(widget.model.value, format: format)!);
    } catch (e) {
      Log().exception(e, caller: 'Datepicker');
    }

    TimeOfDay? result;
    if (mounted) {
      result = await showTimePicker(
          context: context, initialTime: time, initialEntryMode: mode);
    }
    if (result == null) return;

    // set value
    widget.model.setValue(DateTime.now(), result, format);
  }

  Future _showDateTimePicker(
      DatePickerEntryMode dmode, TimePickerEntryMode tmode) async {
    if (!mounted) return;

    var type = widget.model.type;
    var newest = widget.model.newest;
    var oldest = widget.model.oldest;
    var value = widget.model.value;
    var format = widget.model.format;

    DateTime? date;
    TimeOfDay? time;

    // show date picker
    if (mounted) {
      date = await showDatePicker(
          context: context,
          initialDatePickerMode: type == "year" || type == "yeartime"
              ? DatePickerMode.year
              : DatePickerMode.day,
          initialEntryMode: dmode,
          firstDate: toDate(oldest, format: format) ??
              DateTime(DateTime.now().year - 100),
          initialDate: toDate(value, format: format) ?? DateTime.now(),
          lastDate: toDate(newest, format: format) ??
              DateTime(DateTime.now().year + 10));

      // show time picker
      var show =
          (type == 'datetime' || type == 'yeartime' || type == 'rangetime');
      if (show && mounted) {
        time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
            initialEntryMode: tmode);
      }
    }
    if (date == null) return;

    // set the value
    widget.model.setValue(date, time, format);
  }

  Future<bool> show() async {
    TimePickerEntryMode tmode = TimePickerEntryMode.dial;
    DatePickerEntryMode dmode = DatePickerEntryMode.calendar;
    switch (widget.model.mode) {
      case "gui":
        {
          tmode = TimePickerEntryMode.dial;
          dmode = DatePickerEntryMode.calendarOnly;
        }
        break;
      case "input":
        {
          tmode = TimePickerEntryMode.input;
          dmode = DatePickerEntryMode.inputOnly;
        }
        break;
      case "bothinput":
        {
          tmode = TimePickerEntryMode.input;
          dmode = DatePickerEntryMode.input;
        }
        break;
      case "bothgui":
        {
          tmode = TimePickerEntryMode.dial;
          dmode = DatePickerEntryMode.calendar;
        }
        break;
      default:
        {
          tmode = TimePickerEntryMode.dial;
          dmode = DatePickerEntryMode.calendar;
        }
        break;
    }

    widget.model.setFormat();

    switch (widget.model.type) {
      case "range":
        await _showDateRangePicker(dmode);
        break;

      case "time":
        await _showTimePicker(tmode);
        break;

      default:
        await _showDateTimePicker(dmode, tmode);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // set the border color arrays
    // set the border colors
    Color? enabledBorderColor =
        widget.model.borderColor ?? Theme.of(context).colorScheme.outline;
    Color? disabledBorderColor = Theme.of(context).disabledColor;
    Color? focusBorderColor = Theme.of(context).focusColor;
    Color? errorBorderColor = Theme.of(context).colorScheme.error;

    // set the text color arrays
    Color? enabledTextColor = widget.model.textcolor;
    Color? disabledTextColor = Theme.of(context).disabledColor;
    Color? errorTextColor = Theme.of(context).colorScheme.error;

    double? fontsize = widget.model.size;
    String? hint = widget.model.hint;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    String? value = widget.model.value;
    cont = TextEditingController(text: value);
    double pad = 4;
    // View
    Widget view;
    view = GestureDetector(
      //a wee bit janky way of copying and highlighting entire selection without datepicker opening.
      onLongPress: () {
        focusNode!.requestFocus();
        cont!.selection =
            TextSelection(baseOffset: 0, extentOffset: cont!.value.text.length);
        Clipboard.setData(ClipboardData(text: cont!.text));
      },
      onTap: () async {
        focusNode!.requestFocus();
        if (widget.model.editable) {
          widget.model.isPicking = true;
          await show();
          widget.model.isPicking = false;
        }
      },
      child: view = Container(
        color: Colors.transparent,
        child: IgnorePointer(
          child: TextField(
            keyboardType: TextInputType.none,
            showCursor: false,
            focusNode: focusNode,
            onChanged: (val) => onChange(val),
            controller: cont,
            autofocus: false,
            enabled: widget.model.enabled,
            style: TextStyle(
                color: widget.model.enabled
                    ? enabledTextColor ??
                        Theme.of(context).colorScheme.onBackground
                    : disabledTextColor,
                fontSize: fontsize),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              isDense: false,
              errorMaxLines: 8,
              hintMaxLines: 8,
              fillColor: widget.model.getFieldColor(context),
              filled: true,
              contentPadding: EdgeInsets.only(
                  left: pad + 10,
                  top: pad + 15,
                  right: pad + 10,
                  bottom: pad + 15),
              alignLabelWithHint: true,
              labelStyle: TextStyle(
                fontSize: fontsize != null ? fontsize - 2 : 14,
                color: widget.model.getErrorHintColor(context),
              ),
              counterText: "",
              errorText: widget.model.alarm,
              errorStyle: TextStyle(
                fontSize: fontsize ?? 12,
                fontWeight: FontWeight.w300,
                color: errorTextColor,
              ),
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: fontsize ?? 14,
                fontWeight: FontWeight.w300,
                color: widget.model.getErrorHintColor(context),
              ),
              prefixIcon: Padding(
                  padding:
                      const EdgeInsets.only(right: 10, left: 10, bottom: 0),
                  child: Icon(widget.model.icon ??
                      (widget.model.type.toLowerCase() == "time"
                          ? Icons.access_time
                          : Icons.calendar_today))),
              prefixIconConstraints: const BoxConstraints(maxHeight: 24),
              suffixIcon: null,
              suffixIconConstraints: null,
              border: _getBorder(enabledBorderColor, null),
              errorBorder: _getBorder(errorBorderColor, null),
              focusedErrorBorder: _getBorder(focusBorderColor, null),
              focusedBorder: _getBorder(focusBorderColor, null),
              enabledBorder: _getBorder(enabledBorderColor, null),
              disabledBorder:
                  _getBorder(disabledBorderColor, enabledBorderColor),
            ),
          ),
        ),
      ),
    );

    if (widget.model.dense) {
      view = Padding(padding: const EdgeInsets.all(4), child: view);
    }

    // get the model constraints
    var modelConstraints = widget.model.constraints;

    // constrain the input to 200 pixels if not constrained by the model
    if (!modelConstraints.hasHorizontalExpansionConstraints) {
      modelConstraints.width = 200;
    }

    // add margins
    view = addMargins(view);

    // apply visual transforms
    view = applyTransforms(view);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.constraints);

    return view;
  }
}
