// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/helpers/string.dart';
import 'package:fml/system.dart';
import 'package:fml/widgets/viewable/viewable_view.dart';
import 'package:fml/widgets/datepicker/datepicker_model.dart';
import 'package:flutter/services.dart';
import 'package:fml/helpers/helpers.dart';

class DatepickerView extends StatefulWidget implements ViewableWidgetView {
  @override
  final DatepickerModel model;
  DatepickerView(this.model) : super(key: ObjectKey(model));

  @override
  State<DatepickerView> createState() => DatepickerViewState();
}

class DatepickerViewState extends ViewableWidgetState<DatepickerView> {

  String? date;
  String? oldValue;
  TextEditingController controller = TextEditingController();

  // input padding
  double pad = 4;

  String get controllerText {
    var text = '';
    if (!isNullOrEmpty(widget.model.value)) {
      text = widget.model.value!;
      if (!isNullOrEmpty(widget.model.value2)) {
        text = "$text to ${widget.model.value2}";
      }
    }
    return text;
  }

  @override
  void initState() {

    super.initState();

    // register date picker with model
    widget.model.datepicker = this;

    // add controller Listener
    controller.addListener(onTextEditingController);

    // set initial controller text
    if (controller.text != controllerText) {
      controller.text = controllerText;
    }
  }

  @override
  void dispose() {
    super.dispose();

    // dispose of text controller and focus node
    controller.removeListener(onTextEditingController);
    controller.dispose();
  }

  // Flex: We need to listen to the controller of the picker because it uses internal setstates
  // and our model does not know of that state so we modify the model directly from listener
  onTextEditingController() {
    oldValue = controllerText;
  }

  void onClear() => widget.model.setAnswer();

  _getBorder(Color mainColor, Color? secondaryColor) {
    secondaryColor ??= mainColor;

    if (widget.model.border == "none") {
      return OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(widget.model.radius)),
        borderSide: const BorderSide(color: Colors.transparent, width: 1),
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

    if (mounted) {

      var dateOldest = toDate(widget.model.oldest, format: widget.model.format) ?? DateTime(DateTime.now().year - 100);
      var dateNewest = toDate(widget.model.newest, format: widget.model.format) ?? DateTime(DateTime.now().year + 10);

      var date1 = toDate(widget.model.value,  format: widget.model.format);
      var date2 = toDate(widget.model.value2, format: widget.model.format);
      var range = date1 is DateTime  && date2 is DateTime ? DateTimeRange(start: date1, end: date2) : null;

      var result = await showDateRangePicker(
          context: context,
          initialEntryMode: mode,
          currentDate: DateTime.now(),
          initialDateRange: range,
          firstDate: dateOldest,
          lastDate: dateNewest,
          builder: rangeBuilder);

      // set the value
      if (result != null) {
        widget.model.setAnswer(date: result.start, date2: result.end);
      }
    }
  }

  Widget rangeBuilder (context, child) {

    var width  = 400.0;
    var height = System().screenheight - (System().screenheight * .05);

    Widget view = Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: width,
              maxHeight: height,
            ),
            child: child,
          )
        ]);

    return view;
  }

  Future _showTimePicker(TimePickerEntryMode mode) async {

    if (mounted) {

      // get time value
      TimeOfDay? time = toTime(widget.model.value, format: widget.model.format) ?? TimeOfDay.now();

      var result = await showTimePicker(
          context: context,
          initialTime: time,
          initialEntryMode: mode);

      // set the value
      if (result != null) {
        widget.model.setAnswer(time: result);
      }
    }
  }

  Future<void> _showDateTimePicker(
      DatePickerEntryMode dmode,
      TimePickerEntryMode tmode) async {

    DateTime?  date = toDate(widget.model.value, format: widget.model.format) ?? DateTime.now();
    TimeOfDay? time = toTime(widget.model.value, format: widget.model.format) ?? TimeOfDay.now();

    // show date picker
    if (mounted) {

      // display date picker
      var result = await showDatePicker(
          context: context,
          initialDatePickerMode: widget.model.mode == "year"
              ? DatePickerMode.year
              : DatePickerMode.day,
          initialEntryMode: dmode,
          initialDate: date,
          firstDate: toDate(widget.model.oldest, format: widget.model.format) ?? DateTime(DateTime.now().year - 100),
          lastDate:  toDate(widget.model.newest, format: widget.model.format) ?? DateTime(DateTime.now().year + 10));

      // set date
      if (result != null) {
        date = result;
      }
    }

    // show time picker
    if (mounted && widget.model.type == "datetime") {

        // display time picker
        var result = await showTimePicker(
            context: context,
            initialTime: time,
            initialEntryMode: tmode);

        // set date
        if (result != null) {
          time = result;
        }
    }

    // set the value
    widget.model.setAnswer(date: date, time: time);
  }

  DatePickerEntryMode _getDatePickerMode() {

    // return date picker mode
    switch (widget.model.mode) {
      case "calendar":
        return DatePickerEntryMode.calendar;
      case "calendaronly":
        return DatePickerEntryMode.calendarOnly;
      case "input":
        return DatePickerEntryMode.input;
      case "inputonly":
        return DatePickerEntryMode.inputOnly;
      case "year":
      default:
        return DatePickerEntryMode.calendar;
    }
  }

  TimePickerEntryMode _getTimePickerMode() {

    // return date picker mode
    switch (widget.model.tmode) {
      case "dial":
        return TimePickerEntryMode.dial;
      case "dialonly":
        return TimePickerEntryMode.dialOnly;
      case "input":
        return TimePickerEntryMode.input;
      case "inputonly":
        return TimePickerEntryMode.inputOnly;
      default:
        return TimePickerEntryMode.input;
    }
  }

  Future<bool> show() async {

    switch (widget.model.type) {

      case "range":
        await _showDateRangePicker(_getDatePickerMode());
        break;

      case "time":
        await _showTimePicker(_getTimePickerMode());
        break;

      default:
        await _showDateTimePicker(_getDatePickerMode(), _getTimePickerMode());
    }
    return true;
  }

  _getSuffixIcon(Color hintTextColor) {
    if (widget.model.enabled &&
        widget.model.editable &&
        widget.model.clear) {
      Widget button = IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(Icons.clear_rounded, size: 17, color: hintTextColor),
        onPressed: () {
          onClear();
        },
      );

      button = MouseRegion(cursor: SystemMouseCursors.grab, child: button);

      return button;
    }
    else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // set the border color arrays
    // set the border colors
    var enabledBorderColor =
        widget.model.borderColor ?? Theme.of(context).colorScheme.outline;
    var disabledBorderColor = Theme.of(context).disabledColor;
    var focusBorderColor = Theme.of(context).focusColor;
    var errorBorderColor = Theme.of(context).colorScheme.error;

    // set the text color arrays
    var enabledTextColor = widget.model.textColor;
    var disabledTextColor = Theme.of(context).disabledColor;
    var errorTextColor = Theme.of(context).colorScheme.error;

    var fontsize = widget.model.textSize;

    var hint = widget.model.hint;
    var hintTextColor = widget.model.textColor?.withOpacity(0.7) ??
        Theme.of(context).colorScheme.onSurfaceVariant;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    // set the value
    controller = TextEditingController(text: controllerText);

    // view
    Widget view;

    // input field
    view = Container(
      color: Colors.transparent,
      child: IgnorePointer(
        child: TextField(
          keyboardType: TextInputType.none,
          showCursor: false,
          controller: controller,
          autofocus: false,
          enabled: widget.model.enabled,
          style: TextStyle(
              color: widget.model.enabled
                  ? enabledTextColor ??
                  Theme.of(context).colorScheme.onSurface
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
              fontSize: fontsize - 2,
              color: widget.model.getErrorHintColor(context),
            ),
            counterText: "",
            errorText: widget.model.alarm,
            errorStyle: TextStyle(
              fontSize: fontsize,
              fontWeight: FontWeight.w300,
              color: errorTextColor,
            ),
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: fontsize,
              fontWeight: FontWeight.w300,
              color: widget.model.getErrorHintColor(context),
            ),
            prefixIcon: widget.model.showicon
                ? Padding(
                padding:
                const EdgeInsets.only(right: 10, left: 10, bottom: 0),
                child: Icon(widget.model.icon ??
                    (widget.model.type == "time"
                        ? Icons.access_time
                        : Icons.calendar_today)))
                : null,
            prefixIconConstraints: const BoxConstraints(maxHeight: 24),
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
    );

    // show hand cursor
    if (widget.model.editable && widget.model.enabled) {
      view = MouseRegion(cursor: SystemMouseCursors.click, child: view);
    }

    // add a clear button?
    if (widget.model.clear && widget.model.editable && widget.model.enabled) {
      view = Stack(children: [view,Positioned(right: 0, top:0, bottom: 0, child: _getSuffixIcon(hintTextColor))]);
    }

    view = GestureDetector(

      //a wee bit janky way of copying and highlighting entire selection without datepicker opening.
      onLongPress: () {
        controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.value.text.length);
        Clipboard.setData(ClipboardData(text: controller.text));
      },

      onTap: () async {
        if (widget.model.editable) {
          widget.model.isPicking = true;
          await show();
          widget.model.isPicking = false;
        }
      },

      child: view,
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
