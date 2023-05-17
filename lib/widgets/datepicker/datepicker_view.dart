// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/iwidget_view.dart';
import 'package:fml/widgets/widget/widget_model.dart';
import 'package:fml/widgets/datepicker/datepicker_model.dart';
import 'package:flutter/services.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class DatepickerView extends StatefulWidget implements IWidgetView {
  @override
  final DatepickerModel model;
  DatepickerView(this.model) : super(key: ObjectKey(model));

  @override
  State<DatepickerView> createState() => _DatepickerViewState();
}

class _DatepickerViewState extends WidgetState<DatepickerView> {
  String? format;
  String? date;
  String? oldValue;
  TextEditingController? cont;
  FocusNode? focusNode;

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode();

    // Create a TextEditingController
    cont = TextEditingController();

    // Add Controller Listener
    if (cont != null) {
      cont!.addListener(onTextEditingController);

      // Set initial value to the controller
      if (cont!.text != widget.model.value)
        cont!.text = S.toStr(widget.model.value) ?? "";
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
  onModelChange(WidgetModel model, {String? property, dynamic value}) {
    if ((cont!.text != widget.model.value) &&
        (widget.model.isPicking != true)) {
      widget.model.onChange(context);
    }
    cont!.text = widget.model.value;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints) {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // save system constraints
    onLayout(constraints);

    // set the border color arrays
    Color? enabledBorderColor;
    Color? disabledBorderColor;
    Color? focusBorderColor;
    Color? errorBorderColor;
    List? bordercolors = [];
    if (widget.model.bordercolor != null) {
      bordercolors = widget.model.bordercolor?.split(',');
      enabledBorderColor = ColorObservable.toColor(bordercolors![0]?.trim());
      if (bordercolors.length > 1) {
        disabledBorderColor = ColorObservable.toColor(bordercolors[1]?.trim());
      }
      if (bordercolors.length > 2) {
        focusBorderColor = ColorObservable.toColor(bordercolors[2]?.trim());
      }
      if (bordercolors.length > 3) {
        errorBorderColor = ColorObservable.toColor(bordercolors[3]?.trim());
      }
    }

    // set the text color arrays
    Color? enabledTextColor;
    Color? disabledTextColor;
    Color? hintTextColor;
    Color? errorTextColor;
    List? textColors = [];
    if (widget.model.textcolor != null) {
      textColors = widget.model.textcolor?.split(',');
      enabledTextColor = ColorObservable.toColor(textColors![0]?.trim());
      if (textColors.length > 1) {
        disabledTextColor = ColorObservable.toColor(textColors[1]?.trim());
      }
      if (textColors.length > 2) {
        hintTextColor = ColorObservable.toColor(textColors[2]?.trim());
      }
      if (textColors.length > 3) {
        errorTextColor = ColorObservable.toColor(textColors[3]?.trim());
      }
    }

    Color? enabledColor = widget.model.color;
    Color? disabledColor = widget.model.color2;
    Color? errorColor = widget.model.color3;

    double? fontsize = widget.model.size;
    String? hint = widget.model.hint;

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    String? value = widget.model.value;
    // bool editable = (widget.model.editable != false);
    // bool enabled = (widget.model.enabled != false) && (editable);
    double? rad = S.toDouble(widget.model.radius);
    cont = TextEditingController(text: value);

    var padding = widget.model.padding;

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
        if (widget.model.editable != false) {
          widget.model.isPicking = true;

          await widget.model.show(context, widget.model.mode, widget.model.type,
              widget.model.oldest, widget.model.newest, widget.model.format);
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
            enabled: (widget.model.enabled == false) ? false : true,
            style: TextStyle(
                color: widget.model.enabled != false
                    ? enabledTextColor ??
                        Theme.of(context).colorScheme.onBackground
                    : disabledTextColor ??
                        Theme.of(context).colorScheme.surfaceVariant,
                fontSize: fontsize),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              isDense: (widget.model.dense == true),
              errorMaxLines: 8,
              hintMaxLines: 8,
              fillColor: widget.model.enabled == false
                  ? disabledColor ??
                      Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.2)
                  : widget.model.error == true
                      ? errorColor ?? Colors.transparent
                      : enabledColor ?? Colors.transparent,
              filled: true,
              contentPadding: ((widget.model.dense == true)
                  ? EdgeInsets.only(
                      left: padding,
                      top: padding + 10,
                      right: padding,
                      bottom: padding,
                    )
                  : EdgeInsets.only(
                      left: padding + 10,
                      top: padding + 4,
                      right: padding,
                      bottom: padding + 4,
                    )),
              alignLabelWithHint: true,
              labelText: widget.model.dense ? null : hint,
              labelStyle: TextStyle(
                fontSize: fontsize != null ? fontsize - 2 : 14,
                color: widget.model.enabled != false
                    ? hintTextColor ?? Theme.of(context).colorScheme.outline
                    : disabledTextColor ??
                        Theme.of(context).colorScheme.surfaceVariant,
              ),
              counterText: "",
              errorText: widget.model.error == true &&
                      widget.model.errortext != 'null' &&
                      widget.model.errortext != 'none'
                  ? widget.model.errortext ?? ""
                  : null,
              errorStyle: TextStyle(
                fontSize: fontsize ?? 12,
                fontWeight: FontWeight.w300,
                color: errorTextColor ?? Theme.of(context).colorScheme.error,
              ),
              errorBorder: (widget.model.border == "outline" ||
                      widget.model.border == "all")
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(rad ?? 4)),
                      borderSide: BorderSide(
                          color: errorBorderColor ??
                              (Theme.of(context).brightness == Brightness.light
                                  ? Theme.of(context)
                                      .colorScheme
                                      .error
                                      .withOpacity(0.70)
                                  : Theme.of(context).colorScheme.onError),
                          width: widget.model.borderwidth),
                    )
                  : widget.model.border == "none"
                      ? InputBorder.none
                      : (widget.model.border == "bottom" ||
                              widget.model.border == "underline")
                          ? UnderlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(rad ?? 0)),
                              borderSide: BorderSide(
                                  color: errorBorderColor ??
                                      Theme.of(context).colorScheme.error,
                                  width: widget.model.borderwidth),
                            )
                          : InputBorder.none,
              focusedErrorBorder: (widget.model.border == "outline" ||
                      widget.model.border == "all")
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(rad ?? 4)),
                      borderSide: BorderSide(
                          color: errorBorderColor ??
                              (Theme.of(context).brightness == Brightness.light
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context)
                                      .colorScheme
                                      .errorContainer),
                          width: widget.model.borderwidth),
                    )
                  : widget.model.border == "none"
                      ? InputBorder.none
                      : (widget.model.border == "bottom" ||
                              widget.model.border == "underline")
                          ? UnderlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(rad ?? 0)),
                              borderSide: BorderSide(
                                  color: errorBorderColor ??
                                      Theme.of(context).colorScheme.error,
                                  width: widget.model.borderwidth),
                            )
                          : InputBorder.none,
              hintText: widget.model.dense ? hint : null,
              hintStyle: TextStyle(
                fontSize: fontsize ?? 14,
                fontWeight: FontWeight.w300,
                color: widget.model.enabled != false
                    ? hintTextColor ?? Theme.of(context).colorScheme.outline
                    : disabledTextColor ??
                        Theme.of(context).colorScheme.surfaceVariant,
              ),
              prefixIcon: Padding(
                  padding: EdgeInsets.only(
                      right: 10,
                      left: widget.model.border == "all" ? 10 : 0,
                      bottom: widget.model.border == "all" ? 9 : 0),
                  child: Icon(widget.model.icon ??
                      (widget.model.type.toLowerCase() == "time"
                          ? Icons.access_time
                          : Icons.calendar_today))),
              prefixIconConstraints: BoxConstraints(maxHeight: 24),
              suffixIcon: null,
              suffixIconConstraints: null,
              border: (widget.model.border == "outline" ||
                      widget.model.border == "all")
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(rad ?? 4)),
                      borderSide: BorderSide(
                          color: enabledBorderColor ??
                              Theme.of(context).colorScheme.outline,
                          width: widget.model.borderwidth),
                    )
                  : widget.model.border == "none"
                      ? InputBorder.none
                      : (widget.model.border == "bottom" ||
                              widget.model.border == "underline")
                          ? UnderlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(rad ?? 0)),
                              borderSide: BorderSide(
                                  color: enabledBorderColor ??
                                      Theme.of(context).colorScheme.outline,
                                  width: widget.model.borderwidth),
                            )
                          : InputBorder.none,
              focusedBorder: (widget.model.border == "outline" ||
                      widget.model.border == "all")
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(rad ?? 4)),
                      borderSide: BorderSide(
                          color: focusBorderColor ??
                              Theme.of(context).colorScheme.primary,
                          width: widget.model.borderwidth),
                    )
                  : (widget.model.border == "bottom" ||
                          widget.model.border == "underline")
                      ? UnderlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(rad ?? 0)),
                          borderSide: BorderSide(
                              color: focusBorderColor ??
                                  Theme.of(context).colorScheme.primary,
                              width: widget.model.borderwidth),
                        )
                      : widget.model.border == "none"
                          ? InputBorder.none
                          : InputBorder.none,
              enabledBorder: (widget.model.border == "outline" ||
                      widget.model.border == "all")
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(rad ?? 4)),
                      borderSide: BorderSide(
                          color: enabledBorderColor ??
                              Theme.of(context).colorScheme.outline,
                          width: widget.model.borderwidth),
                    )
                  : widget.model.border == "none"
                      ? InputBorder.none
                      : (widget.model.border == "bottom" ||
                              widget.model.border == "underline")
                          ? UnderlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(rad ?? 0)),
                              borderSide: BorderSide(
                                  color: enabledBorderColor ??
                                      Theme.of(context).colorScheme.outline,
                                  width: widget.model.borderwidth),
                            )
                          : InputBorder.none,
              disabledBorder: (widget.model.border == "outline" ||
                      widget.model.border == "all")
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(rad ?? 4)),
                      borderSide: BorderSide(
                          color: disabledBorderColor ??
                              Theme.of(context).colorScheme.surfaceVariant,
                          width: widget.model.borderwidth),
                    )
                  : widget.model.border == "none"
                      ? InputBorder.none
                      : (widget.model.border == "bottom" ||
                              widget.model.border == "underline")
                          ? UnderlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(rad ?? 0)),
                              borderSide: BorderSide(
                                  color: widget.model.editable == false
                                      ? enabledBorderColor ??
                                          Theme.of(context)
                                              .colorScheme
                                              .surfaceVariant
                                      : disabledBorderColor ??
                                          Theme.of(context)
                                              .colorScheme
                                              .surfaceVariant,
                                  width: widget.model.borderwidth),
                            )
                          : InputBorder.none,
            ),
          ),
        ),
      ),
    );

    // get the model constraints
    var modelConstraints = widget.model.constraints;

    // constrain the input to 200 pixels if not constrained by the model
    if (!modelConstraints.hasHorizontalExpansionConstraints)
      modelConstraints.width = 200;

    // add margins
    view = addMargins(view);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.constraints);

    return view;
  }

  void onChange(String d) async {
    if (true) {
      cont!.value = TextEditingValue(
          text: widget.model.value.toString(),
          selection: TextSelection(
              baseOffset: 0,
              extentOffset: widget.model.value.toString().length));

      if (oldValue != widget.model.value) {
        // set answer
        bool ok = await widget.model.answer(widget.model.value);

        // fire on change event
        if (ok == true) await widget.model.onChange(context);
      }
    }

    return;
  }

  void onClear() {
    cont!.text = '';
    widget.model.value = '';
  }
}
