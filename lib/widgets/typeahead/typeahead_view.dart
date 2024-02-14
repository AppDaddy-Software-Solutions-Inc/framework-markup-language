// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fml/widgets/widget/widget_view_interface.dart';
import 'package:fml/widgets/typeahead/typeahead_model.dart';
import 'package:fml/widgets/option/option_model.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fml/helpers/helpers.dart';
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

  // selected option
  OptionModel? selected;

  // text editing controller
  final controller = TextEditingController();

  // suggestion controller
  final suggestionController = SuggestionsController<OptionModel>();

  // focus node
  final focus = FocusNode();

  @override
  void dispose()
  {
    controller.dispose();
    super.dispose();
  }

  Future<List<OptionModel>> buildSuggestions(String pattern) async
  {
    // trim
    pattern.trim();

    // case insensitive pattern
    if (!widget.model.caseSensitive) pattern = pattern.toLowerCase();

    // hack to force entire list to show
    // note the SuggestionsControllerOverride override
    // on the open method below
    if (controller.text == selected?.label) pattern = "";

    // empty pattern returns all
    if (isNullOrEmpty(pattern)) return widget.model.options.toList();

    // matching options at top of list
    return widget.model.options.where((option) => compare(option, pattern)).take(5).toList();
  }

  bool compare(OptionModel option, String pattern)
  {
    // not text matches all
    if (isNullOrEmpty(pattern)) return true;

    // get option search tags
    for (var tag in option.tags)
    {
      if (isNullOrEmpty(tag)) return false;
      tag = tag.trim();
      if (!widget.model.caseSensitive) tag = tag.toLowerCase();

      var type = widget.model.matchType.trim();
      if (!widget.model.caseSensitive) type = type.toLowerCase();

      switch (type)
      {
        case 'contains':
          if (tag.contains(pattern)) return true;
          break;
        case 'startswith':
          if (tag.startsWith(pattern)) return true;
          break;
        case 'endswith':
          if (tag.endsWith(pattern)) return true;
          break;
      }
    }
    return false;
  }

  void onSuggestionSelected(OptionModel option) async
  {
    // save the answer
    bool ok = await widget.model.answer(option.value);
    if (ok)
    {
      // set selected
      selected = option;

      // fire the onchange event
      await widget.model.onChange(context);

      // set the controller text
      controller.text = option.label ?? "";
    }

    // this forces the selection list to close
    focus.unfocus();
  }

  Widget itemBuilder(BuildContext context, OptionModel option)
  {
    Widget? view = option.getView();
    return DropdownMenuItem(child: view);
  }

  Widget fieldBuilder(BuildContext context, TextEditingController controller, FocusNode focusNode)
  {
    // set text style
    var hintTextStyle = TextStyle(fontSize: 14,
        color: widget.model.color != null
            ? (widget.model.color?.computeLuminance() ?? 1) < 0.4
            ? Colors.white.withOpacity(0.5)
            : Colors.black.withOpacity(0.5)
            : Theme.of(context).colorScheme.onSurfaceVariant);

    var style = TextStyle(
        color: widget.model.enabled != false ? widget.model.textcolor ?? Theme
            .of(context)
            .colorScheme
            .onBackground : Theme.of(context).colorScheme.surfaceVariant,
        fontSize: widget.model.size);

    var decoration = InputDecoration(
        contentPadding: EdgeInsets.only(bottom:2),
        isDense: true,
        hintText: widget.model.hint ?? '',
        hintStyle: hintTextStyle,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        suffixIcon: Icon(Icons.arrow_drop_down, size: 25));

    return TextField(
        enabled: widget.model.enabled,
        controller: controller,
        focusNode: focusNode,
        autofocus: false,
        obscureText: widget.model.obscure,
        style: style,
        decoration: decoration,
        textAlignVertical: TextAlignVertical.center);
  }

  Widget emptyBuilder(BuildContext context)
  {
    return Padding(
    padding: const EdgeInsets.all(8),
    child: Text(
      'Nothing found!',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleMedium,
    ));
  }

  Widget addBorders(Widget view)
  {
    if (widget.model.border == 'none')
    {
      view = Container(padding: const EdgeInsets.fromLTRB(12, 6, 0, 6),
        decoration: BoxDecoration(
          color: widget.model.getFieldColor(context),
          borderRadius: BorderRadius.circular(widget.model.radius.toDouble()),
        ),
        child: view,
      );
      return view;
    }

    if (widget.model.border == 'bottom' || widget.model.border == 'underline')
    {
      view = Container(padding: const EdgeInsets.fromLTRB(12, 5, 0, 6), decoration: BoxDecoration(color: widget.model.getFieldColor(context),
        border: Border(
          bottom: BorderSide(
              width: widget.model.borderWidth.toDouble(),
              color: widget.model.setErrorBorderColor(context, widget.model.borderColor)),
        ),),
        child: view,
      );
      return view;
    }

    view = Container(
        padding: const EdgeInsets.fromLTRB(12, 5, 0, 4),
        decoration: BoxDecoration(
          color: widget.model.getFieldColor(context),
          border: Border.all(
              width: widget.model.borderWidth.toDouble(),
              color: widget.model.setErrorBorderColor(context, widget.model.borderColor)),
          borderRadius: BorderRadius.circular(widget.model.radius.toDouble()),
        ),
        child: view,
      );

    return view;
  }

  Widget addAlarmText(Widget view)
  {
    if(!isNullOrEmpty(widget.model.alarmText))
    {
      Widget? errorText = Padding(padding: EdgeInsets.only(top: 6.0 , bottom: 2.0),
        child: Text("${widget.model.alarmText}", style: TextStyle(color: Theme.of(context).colorScheme.error),),);

      view = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [view, errorText],
      );
    }
    return view;
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

  void onFocusChange()
  {
    if (!focus.hasFocus)
    {
      controller.text = selected?.label ?? "";
    }
  }

  @override
  Widget build(BuildContext context)
  {
    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // set initial selection
    if (selected == null)
    {
      var o = getSelectedOption();
      if (o != null) controller.text = o.label ?? "";
    }

    // used to change types text back to its original value
    focus.removeListener(onFocusChange);
    focus.addListener(onFocusChange);

    // build the view
    Widget view = TypeAheadField<OptionModel>(
        key: ObjectKey(widget.model),
        suggestionsCallback: buildSuggestions,
        focusNode: focus,
        controller: controller,
        suggestionsController: suggestionController,
        showOnFocus: true,
        autoFlipDirection: true,
        onSelected: onSuggestionSelected,
        builder: fieldBuilder,
        itemBuilder: itemBuilder,
        emptyBuilder: emptyBuilder);

    // add borders
    view = addBorders(view);

    // add alarm text
    view = addAlarmText(view);

    // get the model constraints
    var modelConstraints = widget.model.constraints;

    // constrain the input to 200 pixels if not constrained by the model
    if (!modelConstraints.hasHorizontalExpansionConstraints) modelConstraints.width  = 200;

    // add margins
    view = addMargins(view);

    // apply constraints
    view = applyConstraints(view, modelConstraints);

    return view;
  }
}
