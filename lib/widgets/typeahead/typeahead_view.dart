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

class TypeaheadView extends StatefulWidget implements IWidgetView
{
  @override
  final TypeaheadModel model;

  TypeaheadView(this.model) : super(key: ObjectKey(model));

  @override
  State<TypeaheadView> createState() => TypeaheadViewState();
}

class TypeaheadViewState extends WidgetState<TypeaheadView>
{
  // typeahead has been initialized
  bool initialized = false;

  // text editing controller
  final controller = TextEditingController();

  // suggestion controller
  final suggestionController = SuggestionsController<OptionModel>();

  // focus node
  final focus = FocusNode();

  @override
  void initState()
  {
    super.initState();

    // used to change controller text back to its original value
    focus.addListener(onFocusChange);
  }

  @override
  void dispose()
  {
    controller.dispose();
    focus.dispose();
    super.dispose();
  }

  Widget fieldBuilder(BuildContext context, TextEditingController controller, FocusNode focusNode)
  {
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
        decoration: _getDecoration(),
        textAlignVertical: TextAlignVertical.center);

    if (widget.model.clear)
    {
      var clear = SizedBox(width: 24, height: 24, child: IconButton(padding: EdgeInsets.zero, splashRadius: 5, icon: Icon(Icons.clear_rounded, size: 12, color: Colors.black), onPressed: () => onChangeOption(null)));
      view = Stack(children: [view, Positioned(top: 0, right: 0, child: clear)]);
    }
    return view;
  }

  Widget emptyBuilder(BuildContext context)
  {
    Widget? view;

    // no data
    if (widget.model.options.isEmpty)
    {
      view = widget.model.noData?.getView();
      view ??= Text(Phrases().noData, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium);
      view = Padding(padding: const EdgeInsets.all(8),child: view);
      view = GestureDetector(onTap: () => focus.unfocus(), child: MouseRegion(cursor: SystemMouseCursors.click, child: view));
      return view;
    }

    view = widget.model.noMatch?.getView();
    view ??= Text(Phrases().noMatchFound, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium);
    view = Padding(padding: const EdgeInsets.all(8),child: view);
    view = GestureDetector(onTap: () => focus.unfocus(), child: MouseRegion(cursor: SystemMouseCursors.click, child: view));
    return view;
  }

  Widget addBorders(Widget view)
  {
    // border padding - this need to be changed to check border width
    var padding = EdgeInsets.only(left: 10, top: 3, right: 0, bottom: 3);
    if (widget.model.border == "none") padding = EdgeInsets.only(left: 10, top: 4, right: 10, bottom: 4);

    // border radius
    var radius = BorderRadius.circular(widget.model.radius.toDouble());

    // border color
    var color = widget.model.borderColor ?? Theme.of(context).colorScheme.outline;
    if (widget.model.alarming) color = widget.model.getBorderColor(context, widget.model.borderColor);
    if (!widget.model.enabled) color = Theme.of(context).disabledColor;

    // border width
    var width = widget.model.borderWidth.toDouble();

    BoxDecoration decoration = BoxDecoration(
        color: widget.model.getFieldColor(context),
        border: Border.all(width: width, color: color),
        borderRadius: radius);

    // no border
    if (widget.model.border == 'none')
    {
      decoration = BoxDecoration(color: widget.model.getFieldColor(context), borderRadius: radius);
    }

    if (widget.model.border == 'bottom' || widget.model.border == 'underline')
    {
      decoration =  BoxDecoration(color: widget.model.getFieldColor(context),
          border: Border(bottom: BorderSide(width: width, color: color)));
    }

    return Container(padding: padding, decoration: decoration, child: view);
  }

  InputDecoration _getDecoration()
  {
    // set the border colors
    Color? enabledBorderColor = widget.model.borderColor ?? Theme.of(context).colorScheme.outline;
    Color? disabledBorderColor = Theme.of(context).disabledColor;
    Color? focusBorderColor = Theme.of(context).focusColor;
    Color? errorBorderColor = Theme.of(context).colorScheme.error;

    String? hint = widget.model.hint;
    Color? hintTextColor = widget.model.textcolor?.withOpacity(0.7) ?? Theme.of(context).colorScheme.onSurfaceVariant;
    Color? errorTextColor = Theme.of(context).colorScheme.error;

    double? fontsize = widget.model.size;

    // set padding
    double paddingTop = 15;
    double paddingBottom = 15;
    if (widget.model.border == "bottom" || widget.model.border == "underline")
    {
      paddingTop = 3;
      paddingBottom = 14;
    }
    var padding = EdgeInsets.only(left: 10, top: paddingTop, right: 10, bottom: paddingBottom);
    if (widget.model.dense == true) padding = EdgeInsets.only(left: 6, top: 0, right: 6, bottom: 0);

    var decoration = InputDecoration(
      isDense: false,
      errorMaxLines: 8,
      hintMaxLines: 8,
      fillColor: widget.model.getFieldColor(context),
      filled: true,
      contentPadding: padding,
      alignLabelWithHint: true,
      labelText: widget.model.dense ? null : hint,
      labelStyle: TextStyle(
        fontSize: fontsize != null ? fontsize - 2 : 14,
        color: widget.model.getErrorHintColor(context, color: hintTextColor),
        shadows: <Shadow>[
          Shadow(
              offset: Offset(0.0, 0.5),
              blurRadius: 2.0,
              color: widget.model.color ?? Colors.transparent
          ),
          Shadow(
              offset: Offset(0.0, 0.5),
              blurRadius: 2.0,
              color: widget.model.color ?? Colors.transparent
          ),
          Shadow(
              offset: Offset(0.0, 0.5),
              blurRadius: 2.0,
              color: widget.model.color ?? Colors.transparent
          ),
        ],
      ),
      errorStyle: TextStyle(
        fontSize: fontsize ?? 14,
        fontWeight: FontWeight.w300,
        color: errorTextColor,
      ),
      errorText: widget.model.alarmText,
      hintText: widget.model.dense ? hint : null,
      hintStyle: TextStyle(
        fontSize: fontsize ?? 14,
        fontWeight: FontWeight.w300,
        color: widget.model.getErrorHintColor(context, color: hintTextColor),
      ),


      counterText: "",
      // widget.model.error is getting set to null somewhere.

      //Icon Attributes
      prefixIcon: widget.model.icon != null ? Padding(
          padding: EdgeInsets.only(
              right: 10,
              left: 10,
              bottom: 0),
          child: Icon(widget.model.icon)) : null,
      prefixIconConstraints: BoxConstraints(maxHeight: 24),
      suffixIcon: Icon(Icons.arrow_drop_down, size: 25),

      //border attributes
      border: _getBorder(enabledBorderColor, null),
      errorBorder: _getBorder(errorBorderColor, null),
      focusedErrorBorder: _getBorder(errorBorderColor, null),
      focusedBorder: _getBorder(focusBorderColor, null),
      enabledBorder: _getBorder(enabledBorderColor, null),
      disabledBorder: _getBorder(disabledBorderColor, enabledBorderColor),
    );

    return decoration;
  }

  _getBorder(Color mainColor, Color? secondaryColor)
  {
    secondaryColor ??= mainColor;

    if(widget.model.border == "none")
    {
      return OutlineInputBorder(
        borderRadius:
        BorderRadius.all(Radius.circular(widget.model.radius)),
        borderSide: BorderSide(
            color: Colors.transparent,
            width: 2),
      );
    }
    else if (widget.model.border == "bottom" ||
        widget.model.border == "underline"){
      return UnderlineInputBorder(
        borderRadius: BorderRadius.all(
            Radius.circular(0)),
        borderSide: BorderSide(
            color: widget.model.editable ? mainColor : secondaryColor,
            width: widget.model.borderWidth),
      );}

    else {
      return OutlineInputBorder(
        borderRadius:
        BorderRadius.all(Radius.circular(widget.model.radius)),
        borderSide: BorderSide(
            color: mainColor,
            width: widget.model.borderWidth),
      );
    }

  }

  Future<List<OptionModel>> buildSuggestions(String pattern) async
  {
    // if not enable then show no list
    if (!widget.model.enabled) return [];

    // hack to force entire list to show
    // note the SuggestionsControllerOverride override
    // on the open method below
    if (controller.text == widget.model.selectedOption?.label) pattern = "";

    // get matching options
    return widget.model.getMatchingOptions(pattern);
  }

  void onChangeOption(OptionModel? option) async
  {
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

  Widget itemBuilder(BuildContext context, OptionModel option)
  {
    Widget? view = option.getView();
    if (option == widget.model.selectedOption)
    {
      view = Container(color: Theme.of(context).focusColor, child: view);
    }
    view = Padding(padding: const EdgeInsets.all(8),child: view);
    return DropdownMenuItem(child: view);
  }

  OptionModel? getSelectedOption()
  {
    // add options
    for (OptionModel option in widget.model.options)
    {
      if (widget.model.value == option.value) return option;
    }
    return null;
  }

  // set controller text
  setControllerText(String? text) 
  {
    if (controller.text != text) controller.text = text ?? "";
  }

  // focus change sets the text to the most recent selection
  void onFocusChange()
  {
    // set the label
    setControllerText(widget.model.selectedOption?.label);

    // select all
    if (focus.hasFocus && widget.model.editable) controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
  }

  Widget? buildBusy()
  {
    if (!widget.model.busy) return null;

    var view = BusyModel(widget.model,
        visible: true,
        size: 24,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
        modal: false).getView();

    return view;
  }

  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

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
    if (busy != null) view = Stack(children: [view, Positioned(top: 0, bottom: 0, left: 0, right: 0, child: busy)]);

    // dense
    if (widget.model.dense) view = Padding(padding: EdgeInsets.all(4), child: view);

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
}
