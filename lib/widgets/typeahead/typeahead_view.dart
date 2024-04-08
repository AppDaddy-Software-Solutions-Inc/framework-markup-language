// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fml/phrase.dart';
import 'package:fml/widgets/busy/busy_model.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/typeahead/typeahead_model.dart';
import 'package:fml/widgets/option/option_model.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fml/widgets/widget/widget_state.dart';

class TypeaheadView extends StatefulWidget implements IWidgetView {
  @override
  final TypeaheadModel model;

  TypeaheadView(this.model) : super(key: ObjectKey(model));

  @override
  State<TypeaheadView> createState() => TypeaheadViewState();
}

class TypeaheadViewState extends WidgetState<TypeaheadView> {
  // typeahead has been initialized
  bool initialized = false;

  // text editing controller
  var controller = TextEditingController();

  // suggestion controller
  final suggestionController = SuggestionsController<OptionModel>();

  // focus node
  final focus = FocusNode();

  @override
  void initState() {
    super.initState();

    // used to change controller text back to its original value
    focus.addListener(onFocusChange);
  }

  @override
  void dispose() {
    controller.dispose();
    focus.dispose();
    super.dispose();
  }

  Widget fieldBuilder(BuildContext context, TextEditingController controller,
      FocusNode focusNode) {
    // set the text color arrays
    Color? enabledTextColor = widget.model.textcolor;
    Color? disabledTextColor = Theme.of(context).disabledColor;
    double? fontsize = widget.model.size;

    var style = TextStyle(
        color: widget.model.enabled
            ? enabledTextColor ?? Theme.of(context).colorScheme.onBackground
            : disabledTextColor,
        fontSize: fontsize);

    Widget view = TextField(
        enabled: widget.model.enabled,
        controller: controller,
        focusNode: focusNode,
        autofocus: false,
        obscureText: widget.model.obscure,
        style: style,
        readOnly: widget.model.readonly,
        decoration: _getTextDecoration(),
        textAlignVertical: TextAlignVertical.center);

    if (widget.model.clear) {
      var clear = SizedBox(
          width: 24,
          height: 24,
          child: IconButton(
              padding: EdgeInsets.zero,
              splashRadius: 5,
              icon: const Icon(Icons.clear_rounded,
                  size: 12, color: Colors.black),
              onPressed: () => onChangeOption(null)));
      view =
          Stack(children: [view, Positioned(top: 0, right: 0, child: clear)]);
    }
    return view;
  }

  Widget emptyBuilder(BuildContext context) {
    Widget? view;

    // no data
    if (widget.model.options.isEmpty) {
      view = widget.model.noDataOption?.getView();
      view ??= Text(Phrases().noData,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium);
      view = Padding(padding: const EdgeInsets.all(8), child: view);
      view = GestureDetector(
          onTap: () => focus.unfocus(),
          child: MouseRegion(cursor: SystemMouseCursors.click, child: view));
      return view;
    }

    view = widget.model.noMatchOption?.getView();
    view ??= Text(Phrases().noMatchFound,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium);
    view = Padding(padding: const EdgeInsets.all(8), child: view);
    view = GestureDetector(
        onTap: () => focus.unfocus(),
        child: MouseRegion(cursor: SystemMouseCursors.click, child: view));
    return view;
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

  TextStyle _getLabelStyle({required Color color}) {
    var style = TextStyle(
      fontSize: widget.model.size != null ? widget.model.size! - 2 : 14,
      color: widget.model.getErrorHintColor(context, color: color),
      shadows: <Shadow>[
        Shadow(
            offset: const Offset(0.0, 0.5),
            blurRadius: 2.0,
            color: widget.model.color ?? Colors.transparent),
        Shadow(
            offset: const Offset(0.0, 0.5),
            blurRadius: 2.0,
            color: widget.model.color ?? Colors.transparent),
        Shadow(
            offset: const Offset(0.0, 0.5),
            blurRadius: 2.0,
            color: widget.model.color ?? Colors.transparent),
      ],
    );
    return style;
  }

  Widget? _getPrefixIcon() {
    if (widget.model.icon == null) return null;
    return Padding(
        padding: const EdgeInsets.only(right: 10, left: 10, bottom: 0),
        child: Icon(widget.model.icon));
  }

  EdgeInsets _getTextPadding() {
    // set padding
    double paddingTop = 0; //widget.model.paddingTop ?? 15;
    double paddingBottom = widget.model.paddingBottom ?? 15;
    double paddingLeft = widget.model.paddingLeft ?? 10;
    double paddingRight = widget.model.paddingRight ?? 10;
    if (widget.model.border == "bottom" || widget.model.border == "underline") {
      paddingTop = widget.model.paddingTop ?? 3;
      paddingBottom = widget.model.paddingBottom ?? 14;
    }
    var padding = EdgeInsets.only(
        left: paddingLeft,
        top: paddingTop,
        right: paddingRight,
        bottom: paddingBottom);
    if (widget.model.dense) {
      padding = const EdgeInsets.only(left: 6, top: 0, right: 6, bottom: 0);
    }

    return padding;
  }

  InputDecoration _getTextDecoration() {
    // set colors
    Color? color = widget.model.textcolor?.withOpacity(0.7) ??
        Theme.of(context).colorScheme.onSurfaceVariant;
    Color? borderColor =
        widget.model.borderColor ?? Theme.of(context).colorScheme.outline;

    var decoration = InputDecoration(
      isDense: false,
      errorMaxLines: 8,
      hintMaxLines: 8,
      fillColor: widget.model.getFieldColor(context),
      filled: true,
      contentPadding: _getTextPadding(),
      alignLabelWithHint: true,

      labelText: widget.model.dense ? null : widget.model.hint,
      labelStyle: _getLabelStyle(color: color),

      errorText: widget.model.alarm,
      errorStyle: TextStyle(
        fontSize: widget.model.size ?? 14,
        fontWeight: FontWeight.w300,
        color: Theme.of(context).colorScheme.error,
      ),

      hintText: widget.model.dense ? widget.model.hint : null,
      hintStyle: TextStyle(
        fontSize: widget.model.size ?? 14,
        fontWeight: FontWeight.w300,
        color: widget.model.getErrorHintColor(context, color: color),
      ),

      counterText: "",

      //Icon Attributes
      prefixIcon: _getPrefixIcon(),
      prefixIconConstraints: const BoxConstraints(maxHeight: 24),
      suffixIcon: const Icon(Icons.arrow_drop_down, size: 25),

      //border attributes
      border: _getBorder(borderColor, null),
      errorBorder: _getBorder(Theme.of(context).colorScheme.error, null),
      focusedErrorBorder: _getBorder(Theme.of(context).colorScheme.error, null),
      focusedBorder: _getBorder(Theme.of(context).focusColor, null),
      enabledBorder: _getBorder(borderColor, null),
      disabledBorder: _getBorder(Theme.of(context).disabledColor, borderColor),
    );

    return decoration;
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

  Future<List<OptionModel>> buildSuggestions(String pattern) async {
    // if not enable then show no list
    if (!widget.model.enabled) return [];

    // hack to force entire list to show
    // note the SuggestionsControllerOverride override
    // on the open method below
    if (controller.text == widget.model.selectedOption?.label) pattern = "";

    // get matching options
    return widget.model.getMatchingOptions(pattern);
  }

  void onChangeOption(OptionModel? option) async {
    // no data?
    if (option != null && option == widget.model.noDataOption) return;

    // no match?
    if (option != null && option == widget.model.noMatchOption) return;

    // stop model change notifications
    widget.model.removeListener(this);

    // set the selected option
    await widget.model.setSelectedOption(option);

    // set the controller text
    setControllerText(widget.model.selectedOption?.label);

    // resume model change notifications
    widget.model.registerListener(this);

    // hack to close window
    focus.unfocus();
  }

  Widget itemBuilder(BuildContext context, OptionModel option) {
    Widget? view = option.getView();
    if (option == widget.model.selectedOption) {
      view = Container(color: Theme.of(context).focusColor, child: view);
    }
    view = Padding(padding: const EdgeInsets.all(8), child: view);
    return DropdownMenuItem(child: view);
  }

  OptionModel? getSelectedOption() {
    // add options
    for (OptionModel option in widget.model.options) {
      if (widget.model.value == option.value) return option;
    }
    return null;
  }

  // set controller text
  setControllerText(String? text) {
    if (controller.text != text) controller.text = text ?? "";
  }

  // focus change sets the text to the most recent selection
  void onFocusChange() {
    // set the label
    setControllerText(widget.model.selectedOption?.label);

    // select all
    if (focus.hasFocus && widget.model.editable) {
      controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
    }
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
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return const Offstage();

    controller.dispose();

    controller = TextEditingController();

    // set the controller text
    setControllerText(widget.model.selectedOption?.label);

    // build the view
    Widget view = TypeAheadField<OptionModel>(
        key: ObjectKey(widget.model),
        suggestionsCallback: buildSuggestions,
        focusNode: focus,
        controller: controller,
        showOnFocus: true,
        hideOnSelect: true,
        autoFlipDirection: true,
        onSelected: onChangeOption,
        builder: fieldBuilder,
        itemBuilder: itemBuilder,
        emptyBuilder: emptyBuilder);

    // display busy
    Widget? busy = buildBusy();
    if (busy != null) {
      view = Stack(children: [
        view,
        Positioned(top: 0, bottom: 0, left: 0, right: 0, child: busy)
      ]);
    }

    // dense
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

    // apply constraints
    view = applyConstraints(view, modelConstraints);

    // apply visual transforms
    view = applyTransforms(view);

    return view;
  }
}
